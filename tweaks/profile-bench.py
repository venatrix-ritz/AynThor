#!/usr/bin/env python3
"""profile-bench.py: compare Armada's power profiles with the same fixed CPU load.

Run on the Thor (any session). For each profile it switches with `armada-power profile NAME`, waits for the chip to cool to
a common start temperature, runs 8 workers hashing 64 KB blocks for DURATION seconds, and logs one JSON line per
SAMPLE seconds: iterations per second, the three CPU clusters' clocks, the hottest CPU / GPU / overall thermal zone,
fan RPM, GPU clock, battery temperature, voltage, current and the battery power in watts. It restores the profile it
found, and stops early if a CPU zone reaches ABORT_CPU_C or the battery reaches ABORT_BATT_C.

Only the CPU is loaded. The GPU clock is logged but not stressed (no GPU benchmark is installed on the Thor).

Usage: profile-bench.py [--profiles eco,balanced,performance] [--duration 240] [--out FILE]
"""
import argparse
import glob
import hashlib
import json
import multiprocessing as mp
import os
import subprocess
import sys
import time

SAMPLE = 10
ABORT_CPU_C = 95.0
ABORT_BATT_C = 45.0
COOL_TARGET_C = 52.0
COOL_MAX_S = 300
B = "/sys/class/power_supply/battery"


def rd(path, default=None):
    try:
        with open(path) as f:
            return f.read().strip()
    except Exception:
        return default


def zones():
    out = {}
    for z in glob.glob("/sys/class/thermal/thermal_zone*"):
        t, v = rd(z + "/type"), rd(z + "/temp")
        if t and v and v.lstrip("-").isdigit():
            out[t] = int(v) / 1000.0
    return out


def hottest(z, prefix):
    vals = [v for k, v in z.items() if k.startswith(prefix)]
    return max(vals) if vals else None


def worker(counter, idx):
    buf = os.urandom(65536)
    n = 0
    while True:
        hashlib.sha256(buf).digest()
        n += 1
        if n % 20 == 0:
            counter[idx] = n


def fan_rpm():
    for h in glob.glob("/sys/class/hwmon/hwmon*"):
        if rd(h + "/name") == "pwmfan":
            return rd(h + "/fan1_input")
    return None


def snapshot(prev_total, prev_t, counter):
    total = sum(counter)
    now = time.monotonic()
    z = zones()
    v, i = int(rd(B + "/voltage_now", 0)), int(rd(B + "/current_now", 0))
    return {
        "ips": round((total - prev_total) / (now - prev_t), 1) if prev_t else None,
        "clk_mhz": {p: round(int(rd(f"/sys/devices/system/cpu/cpufreq/policy{p}/scaling_cur_freq", 0)) / 1000) for p in (0, 3, 7)},
        "cpu_c": hottest(z, "cpu"), "gpu_c": hottest(z, "gpuss"), "max_c": max(z.values()) if z else None,
        "fan_rpm": fan_rpm(), "gpu_mhz": round(int(rd("/sys/class/devfreq/3d00000.gpu/cur_freq", 0)) / 1e6),
        "batt_c": int(rd(B + "/temp", 0)) / 10.0, "batt_w": round(v * i / 1e12, 2), "status": rd(B + "/status"),
    }, total, now


def profile_now():
    out = subprocess.run(["armada-power", "status"], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if line.startswith("profile="):
            return line.split("=", 1)[1].strip().lower()
    return None


def set_profile(name):
    subprocess.run(["armada-power", "profile", name], capture_output=True, text=True)
    time.sleep(3)


def cool_down():
    t0 = time.time()
    while time.time() - t0 < COOL_MAX_S:
        c = hottest(zones(), "cpu")
        if c is not None and c <= COOL_TARGET_C:
            return round(time.time() - t0)
        time.sleep(5)
    return COOL_MAX_S


def run_profile(name, duration, out):
    set_profile(name)
    waited = cool_down()
    counter = mp.Array("L", 8, lock=False)
    procs = [mp.Process(target=worker, args=(counter, i), daemon=True) for i in range(8)]
    start_snap = snapshot(0, None, counter)[0]
    out.write(json.dumps({"event": "start", "profile": name, "cooled_s": waited, "t": time.strftime("%T"), **start_snap}) + "\n")
    out.flush()
    for p in procs:
        p.start()
    t_start, prev_total, prev_t, aborted = time.monotonic(), 0, time.monotonic(), None
    try:
        while time.monotonic() - t_start < duration:
            time.sleep(SAMPLE)
            snap, prev_total, prev_t = snapshot(prev_total, prev_t, counter)
            snap.update({"event": "sample", "profile": name, "t": time.strftime("%T"), "elapsed": round(time.monotonic() - t_start)})
            out.write(json.dumps(snap) + "\n")
            out.flush()
            if (snap["cpu_c"] or 0) >= ABORT_CPU_C or snap["batt_c"] >= ABORT_BATT_C:
                aborted = f"cpu {snap['cpu_c']} C / battery {snap['batt_c']} C"
                break
    finally:
        for p in procs:
            p.terminate()
    out.write(json.dumps({"event": "end", "profile": name, "aborted": aborted, "t": time.strftime("%T")}) + "\n")
    out.flush()
    return aborted


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profiles", default="eco,balanced,performance")
    ap.add_argument("--duration", type=int, default=240)
    ap.add_argument("--out", default=os.path.expanduser("~/profile-bench-%s.jsonl" % time.strftime("%Y%m%d-%H%M%S")))
    a = ap.parse_args()
    original = profile_now()
    print("original profile:", original, "| out:", a.out, file=sys.stderr, flush=True)
    try:
        with open(a.out, "a") as out:
            out.write(json.dumps({"event": "begin", "original": original, "duration": a.duration, "t": time.strftime("%T")}) + "\n")
            for name in a.profiles.split(","):
                aborted = run_profile(name.strip(), a.duration, out)
                if aborted:
                    print("aborted:", aborted, file=sys.stderr, flush=True)
                    break
    finally:
        if original:
            set_profile(original)
        print("restored profile:", profile_now(), file=sys.stderr, flush=True)


if __name__ == "__main__":
    main()
