#!/usr/bin/env bash
# Space Haven (Steam appid 979110) JVM flags on the Thor.
# Observed 2026-10-24: the x86 Zulu 8 JVM under FEX crashed in the New Game and crew menus
# (NPE in ShaderProgram.fetchAttributeLocation, JVM ShouldNotReachHere); with -Xint it survived.
# Cause beyond "the JIT is involved" is unverified.
# Usage (on the Thor): spacehaven-jvm.sh [c1|xint|default]   (default mode: c1)
#   c1      -XX:TieredStopAtLevel=1 (JIT limited to C1)
#   xint    -Xint (interpreter only, slow)
#   default remove both flags
# Backs up config.json first; safe to re-run (Steam updates may rewrite the file).
set -euo pipefail
mode="${1:-c1}"
cfg="$HOME/.local/share/Steam/steamapps/common/Space Haven/config.json"
[ -f "$cfg" ] || { echo "missing $cfg" >&2; exit 1; }
cp -p "$cfg" "$cfg.bak-$(date +%Y%m%d-%H%M%S)"
CFG="$cfg" MODE="$mode" python3 - <<'PY'
import json, os
p, mode = os.environ["CFG"], os.environ["MODE"]
c = json.load(open(p))
drop = ("-Xint", "-XX:TieredStopAtLevel=1")
args = [a for a in c.get("vmArgs", []) if a not in drop]
args += {"c1": ["-XX:TieredStopAtLevel=1"], "xint": ["-Xint"], "default": []}[mode]
c["vmArgs"] = args
json.dump(c, open(p, "w"), indent=2)
print(mode, c["vmArgs"])
PY
