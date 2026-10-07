#!/usr/bin/env bash
# setup-device-fixes.sh: sanitation + sanity checks for AYN Thor on Armada OS.
#   [1/3] masks the failing weekly rpm-ostree-countme timer (the only change this script makes)
#   [2/3] CHECKS (never edits) the saved Desktop-Mode display layout for the two DSI outputs
#   [3/3] CHECKS zram swap / swappiness
# It reports warnings honestly and exits 0; read the output rather than trusting the last line.
set -uo pipefail
warn=0

echo "==> [1/3] Masking rpm-ostree-countme (failing weekly reporting job)..."
if sudo systemctl mask --now rpm-ostree-countme.timer rpm-ostree-countme.service >/dev/null 2>&1; then
    echo "    masked."
else
    echo "    WARN: could not mask rpm-ostree-countme (already masked, or sudo not available)."
    warn=$((warn + 1))
fi

echo "==> [2/3] Checking the saved KWin layout for DSI-1 (bottom) / DSI-2 (top)..."
KWIN_CONFIG="${HOME}/.config/kwinoutputconfig.json"
if [ ! -f "$KWIN_CONFIG" ]; then
    echo "    no saved layout yet (Desktop Mode not used on this install) — nothing to check."
elif ! command -v python3 >/dev/null 2>&1; then
    echo "    WARN: python3 missing, layout not checked."
    warn=$((warn + 1))
else
    result=$(python3 - "$KWIN_CONFIG" <<'PY'
import json, sys
try:
    cfg = json.load(open(sys.argv[1]))
except Exception as e:
    print("ERR unreadable: %s" % e); sys.exit(0)
outs = next((s["data"] for s in cfg if s.get("name") == "outputs"), [])
idx = {o.get("connectorName"): i for i, o in enumerate(outs)}
if "DSI-1" not in idx or "DSI-2" not in idx:
    print("OK no saved two-DSI layout"); sys.exit(0)
top, bot = idx["DSI-2"], idx["DSI-1"]
problems = []
for s in next((s["data"] for s in cfg if s.get("name") == "setups"), []):
    by = {o.get("outputIndex"): o for o in s.get("outputs", [])}
    if top in by and bot in by:
        if not by[top].get("enabled", True):
            problems.append("top screen (DSI-2) is DISABLED in a saved layout")
        elif by[bot].get("priority", 1) < by[top].get("priority", 1):
            problems.append("bottom screen (DSI-1) has priority over the top screen")
print("WARN " + "; ".join(problems) if problems else "OK top screen enabled and primary")
PY
)
    case "$result" in
        OK*)  echo "    ${result#OK }" ;;
        WARN*) echo "    ${result}"
               echo "    Fix (while NOT in Desktop Mode): edit $KWIN_CONFIG so the two-output setup has DSI-2 enabled with priority 1 and DSI-1 priority 2, or run Armada's setup-dual-screen from a Desktop session."
               warn=$((warn + 1)) ;;
        *)    echo "    WARN: could not check layout (${result})."; warn=$((warn + 1)) ;;
    esac
fi

echo "==> [3/3] Checking VM & zram settings..."
if swapon --show 2>/dev/null | grep -q zram; then
    echo "    zram swap: present"
else
    echo "    WARN: no zram swap active."
    warn=$((warn + 1))
fi
echo "    swappiness: $(cat /proc/sys/vm/swappiness)"

if [ "$warn" -eq 0 ]; then
    echo "==> Device fixes: OK (no warnings)."
else
    echo "==> Device fixes: finished with ${warn} warning(s) — see above."
fi
exit 0
