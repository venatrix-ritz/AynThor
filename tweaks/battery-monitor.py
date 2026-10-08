#!/usr/bin/env python3
"""battery-monitor.py: record as much battery and power state as the Thor exposes.

Read-only. Appends JSON lines to one log file, two kinds:
  "k":"full"  every --interval seconds (default 5): every readable attribute of every
              /sys/class/power_supply/* device, hwmon power/current/voltage/fan readings,
              all thermal zones, per-core CPU frequency and utilisation, GPU and UFS devfreq,
              backlights, LEDs, USB-C role/power state, Wi-Fi link and traffic counters,
              memory, suspend counters, the top CPU processes, and Gleipnir's unit state
              and last journal line.
  "k":"fast"  every --fast seconds (default 1): only the fields that move quickly while
              charging is clamped or released (status, current, voltage, limit, capacity).
Usage: battery-monitor.py [--interval SEC] [--fast SEC] [--out FILE]
Default out: ~/battery-logs/battery-<start time>.jsonl
Stop with Ctrl-C or SIGTERM. Nothing here writes to sysfs.
"""
import argparse
import glob
import json
import os
import signal
import subprocess
import sys
import time

PS = "/sys/class/power_supply"
B = PS + "/battery"
SKIP = {"uevent", "wakeup6"}  # uevent duplicates the attributes below
FAST_ATTRS = ("capacity", "status", "charge_type", "current_now", "voltage_now", "power_now",
              "temp", "constant_charge_current", "charge_now", "time_to_full_avg", "time_to_empty_avg")


def rd(path):
    try:
        with open(path) as f:
            return f.read().strip()
    except Exception:
        return None


def sh(*a, timeout=5):
    try:
        return subprocess.run(a, capture_output=True, text=True, timeout=timeout).stdout.strip()
    except Exception:
        return None


def attrs_of(dev, maxlen=200):
    out = {}
    for f in sorted(glob.glob(dev + "/*")):
        name = os.path.basename(f)
        if name in SKIP or not os.path.isfile(f):
            continue
        v = rd(f)
        if v is not None and len(v) < maxlen:
            out[name] = v
    return out


def power_supplies():
    return {os.path.basename(d): attrs_of(d) for d in sorted(glob.glob(PS + "/*"))}


def hwmon():
    out = {}
    for h in sorted(glob.glob("/sys/class/hwmon/hwmon*")):
        name = rd(h + "/name") or os.path.basename(h)
        if name.endswith("_thermal"):
            continue  # covered by thermal()
        vals = {}
        for f in sorted(glob.glob(h + "/*_input")) + sorted(glob.glob(h + "/power[0-9]*")):
            if os.path.isfile(f):
                v = rd(f)
                if v is not None and len(v) < 40:
                    vals[os.path.basename(f)] = v
        out[name] = vals
    return out


def thermal():
    out = {}
    for z in sorted(glob.glob("/sys/class/thermal/thermal_zone*")):
        t = rd(z + "/temp")
        if t is not None:
            out[rd(z + "/type") or os.path.basename(z)] = t
    return out


_prev_stat = {}


def cpu():
    freqs = {}
    for c in sorted(glob.glob("/sys/devices/system/cpu/cpu[0-9]*")):
        v = rd(c + "/cpufreq/scaling_cur_freq")
        if v is not None:
            freqs[os.path.basename(c)] = v
    util = {}
    stat = rd("/proc/stat") or ""
    for line in stat.splitlines():
        p = line.split()
        if p and p[0].startswith("cpu"):
            nums = list(map(int, p[1:9]))
            idle, total = nums[3] + nums[4], sum(nums)
            if p[0] in _prev_stat:
                di, dt = idle - _prev_stat[p[0]][0], total - _prev_stat[p[0]][1]
                util[p[0]] = round(100.0 * (1 - di / dt), 1) if dt > 0 else None
            _prev_stat[p[0]] = (idle, total)
    return {"freq_khz": freqs, "util_pct": util, "loadavg": rd("/proc/loadavg")}


def devfreq():
    return {os.path.basename(d): {k: rd(d + "/" + k) for k in ("cur_freq", "min_freq", "max_freq", "governor")}
            for d in sorted(glob.glob("/sys/class/devfreq/*"))}


def backlight():
    return {os.path.basename(b): {"brightness": rd(b + "/brightness"), "max": rd(b + "/max_brightness")}
            for b in sorted(glob.glob("/sys/class/backlight/*"))}


def leds():
    out = {}
    for l in sorted(glob.glob("/sys/class/leds/*")):
        v = rd(l + "/brightness")
        if v is not None and v != "0":
            out[os.path.basename(l)] = v
    return out  # only lit LEDs, to keep the line short


def typec():
    out = {}
    for p in sorted(glob.glob("/sys/class/typec/port*")):
        out[os.path.basename(p)] = {k: rd(p + "/" + k) for k in
                                    ("power_role", "data_role", "power_operation_mode", "usb_power_delivery_revision")}
    return out


def net():
    out = {}
    for line in (rd("/proc/net/dev") or "").splitlines()[2:]:
        name, _, rest = line.partition(":")
        name, f = name.strip(), rest.split()
        if name != "lo" and len(f) >= 9:
            out[name] = {"rx_bytes": f[0], "tx_bytes": f[8]}
    for ifc in [n for n in out if n.startswith("wl")]:
        link = sh("iw", "dev", ifc, "link")
        if link:
            out[ifc]["link"] = " | ".join(l.strip() for l in link.splitlines()
                                          if any(k in l for k in ("signal", "tx bitrate", "rx bitrate", "freq", "SSID")))
    return out


def mem():
    m = {}
    for line in (rd("/proc/meminfo") or "").splitlines():
        k, _, v = line.partition(":")
        if k in ("MemTotal", "MemAvailable", "SwapFree", "Dirty"):
            m[k] = v.strip()
    return m


def top_procs():
    out = sh("ps", "-eo", "pid,pcpu,rss,comm", "--sort=-pcpu", "--no-headers", timeout=5) or ""
    return [p for p in (l.split(None, 3) for l in out.splitlines()) if p[3] != "ps"][:6]


def suspend():
    return {k: rd("/sys/power/suspend_stats/" + k) for k in ("success", "fail", "last_hw_sleep")}


def gleipnir():
    return {"unit": sh("systemctl", "is-active", "gleipnir"),
            "last": (sh("journalctl", "-u", "gleipnir", "-n1", "--no-pager", "-o", "cat") or "")[:300]}


def full():
    return {
        "k": "full", "t": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "up": rd("/proc/uptime"),
        "ps": power_supplies(), "hwmon": hwmon(), "thermal": thermal(), "cpu": cpu(),
        "devfreq": devfreq(), "backlight": backlight(), "leds_lit": leds(), "typec": typec(),
        "net": net(), "mem": mem(), "suspend": suspend(), "top": top_procs(), "gleipnir": gleipnir(),
    }


def fast():
    d = {k: rd(B + "/" + k) for k in FAST_ATTRS}
    d["usb_online"] = rd(PS + "/qcom-battmgr-usb/online")
    d["usb_curr"] = rd(PS + "/qcom-battmgr-usb/current_now")
    d["k"] = "fast"
    d["t"] = time.strftime("%H:%M:%S")
    return d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--interval", type=float, default=5, help="full snapshot period")
    ap.add_argument("--fast", type=float, default=1, help="fast battery-only period (0 to disable)")
    ap.add_argument("--out")
    a = ap.parse_args()
    out = a.out or os.path.expanduser("~/battery-logs/battery-%s.jsonl" % time.strftime("%Y%m%d-%H%M%S"))
    os.makedirs(os.path.dirname(out), exist_ok=True)
    stop = []
    for s in (signal.SIGINT, signal.SIGTERM):
        signal.signal(s, lambda *_: stop.append(1))
    print("logging full every %ss, fast every %ss, to %s" % (a.interval, a.fast, out), file=sys.stderr)
    nxt_full = nxt_fast = 0.0
    with open(out, "a", buffering=1) as f:
        while not stop:
            now = time.time()
            if now >= nxt_full:
                f.write(json.dumps(full(), separators=(",", ":")) + "\n")
                nxt_full = now + a.interval
            elif a.fast > 0 and now >= nxt_fast:
                f.write(json.dumps(fast(), separators=(",", ":")) + "\n")
            if a.fast > 0 and now >= nxt_fast:
                nxt_fast = now + a.fast
            time.sleep(0.1)


if __name__ == "__main__":
    main()
