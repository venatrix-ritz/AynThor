#!/usr/bin/env python3
"""system-bench.py: memory, storage (per I/O scheduler) and Wi-Fi latency (power save on/off) on the Thor.

Run as root on the Thor with no game running. It changes two things temporarily and puts both back:
the I/O scheduler of the UFS disk (/sys/block/sda/queue/scheduler) and the Wi-Fi power-save flag (iw).
Storage is READ-ONLY: it reads the raw disk with O_DIRECT, so no file is written and no data can change.

Usage: sudo python3 system-bench.py [--seconds 8] [--disk sda] [--wifi wlp1s0] [--skip-wifi]
"""
import argparse
import mmap
import multiprocessing as mp
import os
import random
import re
import statistics
import subprocess
import threading
import time


def sh(*a, **k):
    return subprocess.run(a, capture_output=True, text=True, **k)


MEM_N = 256 * 1024 * 1024


def mem_worker(q):  # module level: the forkserver start method cannot pickle a local function
    s, d = bytearray(os.urandom(1 << 20)) * (MEM_N >> 21), bytearray(MEM_N >> 1)
    t0 = time.perf_counter()
    for _ in range(4):
        d[:] = s
    q.put(4 * (MEM_N >> 1) / (time.perf_counter() - t0) / 1e9)


def memory():
    n = MEM_N
    src, dst = bytearray(os.urandom(1 << 20)) * (n >> 20), bytearray(n)
    t = time.perf_counter()
    for _ in range(4):
        dst[:] = src
    one = 4 * n / (time.perf_counter() - t) / 1e9
    q = mp.Queue()
    ps = [mp.Process(target=mem_worker, args=(q,)) for _ in range(4)]
    for p in ps:
        p.start()
    tot = sum(q.get() for _ in ps)
    for p in ps:
        p.join()
    return {"copy_1_thread_GBps": round(one, 1), "copy_4_procs_GBps": round(tot, 1)}


def aligned(size):
    return mmap.mmap(-1, size)


def disk_size(path):
    fd = os.open(path, os.O_RDONLY)
    try:
        return os.lseek(fd, 0, os.SEEK_END)
    finally:
        os.close(fd)


def seq_read(path, seconds):
    fd = os.open(path, os.O_RDONLY | os.O_DIRECT)
    buf, off, total, t0 = aligned(1 << 20), random.randrange(0, 200) << 30, 0, time.perf_counter()
    try:
        while time.perf_counter() - t0 < seconds:
            total += os.preadv(fd, [buf], off + total)
    finally:
        os.close(fd)
    return total / (time.perf_counter() - t0) / 1e6


def rand_read(path, seconds, threads, size):
    stop, counts, lat = time.perf_counter() + seconds, [0] * threads, []

    def w(i):
        fd = os.open(path, os.O_RDONLY | os.O_DIRECT)
        buf, lats = aligned(4096), []
        try:
            while time.perf_counter() < stop:
                off = random.randrange(0, size // 4096 - 1) * 4096
                t = time.perf_counter()
                os.preadv(fd, [buf], off)
                lats.append(time.perf_counter() - t)
        finally:
            os.close(fd)
        counts[i] = len(lats)
        if i == 0:
            lat.extend(lats)

    ts = [threading.Thread(target=w, args=(i,)) for i in range(threads)]
    for t in ts:
        t.start()
    for t in ts:
        t.join()
    lat.sort()
    return sum(counts) / seconds, (lat[len(lat) // 2] * 1e6 if lat else 0), (lat[int(len(lat) * 0.99)] * 1e6 if lat else 0)


def storage(disk, seconds):
    path, sched = f"/dev/{disk}", f"/sys/block/{disk}/queue/scheduler"
    original = re.search(r"\[(\w[\w-]*)\]", open(sched).read()).group(1)
    size, out = disk_size(path), {}
    try:
        for name in ("none", "mq-deadline", "bfq"):
            if name not in open(sched).read():
                continue
            open(sched, "w").write(name)
            time.sleep(1)
            iops1, p50, p99 = rand_read(path, seconds, 1, size)
            iops8, _, _ = rand_read(path, seconds, 8, size)
            out[name] = {"seq_read_MBps": round(seq_read(path, seconds)), "rand4k_qd1_iops": round(iops1),
                         "rand4k_qd1_p50_us": round(p50), "rand4k_qd1_p99_us": round(p99), "rand4k_qd8_iops": round(iops8)}
    finally:
        open(sched, "w").write(original)
    out["restored"] = original
    return out


def gateway():
    m = re.search(r"default via (\S+)", sh("ip", "route", "show", "default").stdout)
    return m.group(1) if m else None


def wifi(dev, count=100):
    gw, out = gateway(), {}
    if not gw:
        return {"error": "no default gateway"}
    original = re.search(r"Power save: (\w+)", sh("iw", "dev", dev, "get", "power_save").stdout).group(1)
    try:
        for mode in ("on", "off"):
            sh("iw", "dev", dev, "set", "power_save", mode)
            time.sleep(3)
            r = sh("ping", "-i", "0.2", "-c", str(count), "-q", gw).stdout
            m = re.search(r"min/avg/max/mdev = ([\d.]+)/([\d.]+)/([\d.]+)/([\d.]+)", r)
            loss = re.search(r"([\d.]+)% packet loss", r)
            out[f"power_save_{mode}"] = {"min_ms": float(m.group(1)), "avg_ms": float(m.group(2)), "max_ms": float(m.group(3)),
                                         "jitter_ms": float(m.group(4)), "loss_pct": float(loss.group(1))} if m else {"error": r[-200:]}
    finally:
        sh("iw", "dev", dev, "set", "power_save", original)
    out["restored"] = original
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seconds", type=int, default=8)
    ap.add_argument("--disk", default="sda")
    ap.add_argument("--wifi", default="wlp1s0")
    ap.add_argument("--skip-wifi", action="store_true")
    a = ap.parse_args()
    print("memory:", memory(), flush=True)
    for name, r in storage(a.disk, a.seconds).items():
        print("storage", name, r, flush=True)
    if not a.skip_wifi:
        print("wifi:", wifi(a.wifi), flush=True)


if __name__ == "__main__":
    main()
