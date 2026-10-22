# 03 - Data flow

## Deploy and status (workstation to device)

```mermaid
flowchart LR
    subgraph WS[Workstation]
        REPO["repo tweaks and scripts"]
        ENV[local/thor.env]
        ORCH[apply-all-tweaks.sh]
        BLD[build_game_tweaks.py]
        JSON[game-tweaks.json]
    end
    subgraph DEV["Thor device"]
        TMP["/tmp staging"]
        VLB["/var/local/bin"]
        SYSD["/etc/systemd/system"]
        NM["/etc/NetworkManager/conf.d"]
        PW["user pipewire conf.d"]
        ETC["/etc/armada/game-tweaks.json"]
    end
    ENV --> ORCH
    REPO --> ORCH
    ORCH -- "scp" --> TMP
    ORCH -- "ssh and sudo mv" --> VLB
    ORCH -- "ssh and sudo mv" --> SYSD
    ORCH -- "ssh and sudo mv" --> NM
    ORCH -- "scp" --> PW
    REPO --> BLD --> JSON
    JSON -. "manual copy" .-> ETC
```

## LED daemon (device)

```mermaid
flowchart TD
    CLI["stick-led-color set commands"] -->|"save_state: tmp file then rename"| CONF["/etc/armada/stick-led.conf"]
    CONF -->|"load_state every tick"| LOOP["run_daemon loop"]
    SUS["/run/armada/fake-suspend.active"] -->|"exists: all LEDs off"| LOOP
    EVDEV["gamepad evdev node"] -->|"reactive mode only"| LOOP
    DRMFB["DRM card via ffmpeg kmsgrab"] -->|"ambilight mode only, 2 fps"| LOOP
    BL["/sys/class/backlight entries"] -->|"screen_link scale"| LOOP
    BAT["/sys/class/power_supply/battery"] -->|"battery modes"| LOOP
    LOOP -->|"write_zone, 0 to 255"| LEDS["/sys/class/leds l and r channels"]
```

## Display sleep sync (device)

```mermaid
sequenceDiagram
    participant D as DRM debugfs state
    participant S as thor-display-sync
    participant G as gamescopectl as armada
    participant B as bl_power of ae94000 dsi 0
    loop every 0.5 s
        S->>D: read, parse crtc-0 and crtc-1 active=
        alt crtc-0 went to 0
            S->>G: drm_sleep_internal_screen 1 (gamescope-1)
            S->>B: write 4
        else crtc-0 went to 1
            S->>B: write 0
            S->>G: drm_sleep_internal_screen 0 (gamescope-1)
        else crtc-0 is 0 and crtc-1 is 1
            S->>G: drm_sleep_internal_screen 1
            S->>B: write 4
        end
    end
```

## WoWLAN enable (device)

```mermaid
sequenceDiagram
    participant U as systemd (thor-wowlan.service)
    participant W as thor-wowlan
    participant I as iw
    U->>W: ExecStart (oneshot)
    loop up to THOR_WAIT_S (60) s
        W->>I: iw dev, find phy number and Interface
    end
    W->>I: iw phy phyN info (must mention wowlan, else exit 78)
    W->>I: iw phy phyN wowlan enable magic-packet
    W->>I: iw phy phyN wowlan show (must say magic packet)
    W-->>U: exit 0 (or 1 transient, 78 unsupported)
```

## Wake from the workstation

```mermaid
sequenceDiagram
    participant O as Operator
    participant P as wake-thor.py / wake-thor.ps1
    participant N as LAN broadcast (UDP 9)
    participant T as Thor Wi-Fi (ath12k)
    O->>P: run (MAC and broadcast from env or local/thor.env)
    P->>N: 102-byte magic packet (sent twice)
    N->>T: broadcast frame
    T-->>T: wake if WoWLAN magic-packet is enabled
```

## Telemetry and benchmarks (device)

```mermaid
flowchart LR
    SYS["sys and proc state"] --> BM["battery-monitor.py"]
    BM -->|"full every 5 s, fast every 1 s"| LOG1["battery-logs jsonl"]
    PW["armada-power profile NAME"] <--> PB["profile-bench.py"]
    SYS2["thermal, battery, fan"] --> PB
    PB -->|"10 s samples"| LOG2["profile-bench jsonl"]
    SB["system-bench.py"] -->|"O_DIRECT reads, iw"| OUT["stdout"]
```
