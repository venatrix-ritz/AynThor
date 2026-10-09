#!/usr/bin/env python3
"""Build /etc/armada/game-tweaks.json for Ven's Thor (per-game Armada profiles).

Tiers are a judgement from engine, install size and genre read off the Thor's Steam appmanifests on 2026-10-09.
Nothing here was measured; see README.md. Usage: build_game_tweaks.py [OUT.json]  (default: game-tweaks.json beside this file)
"""
import json
import pathlib
import sys

# appid -> name
HEAVY = {
    979690: "The Ascent", 427410: "Abiotic Factor", 1971650: "OCTOPATH TRAVELER II",
    921570: "OCTOPATH TRAVELER", 4078430: "STAR WARS: Galactic Racer",
    3985950: "R.I.P. - Reincarnation Insurance Program", 3596700: "TerraTech Legion",
    1983260: "Dungeons of Hinterberg", 264710: "Subnautica", 753640: "Outer Wilds",
    3164500: "Schedule I", 2499520: "Be My Horde", 3167020: "Escape from Duckov",
}
MEDIUM = {
    1313140: "Cult of the Lamb", 1043810: "Tactical Breach Wizards", 2321470: "Deep Rock Galactic: Survivor",
    2163330: "Yet Another Zombie Survivors", 2820820: "Jotunnslayer: Hordes of Hel", 2350790: "Moonlighter 2",
    2015270: "Rotwood", 2059170: "Quasimorph", 1176710: "Space Crew", 1536620: "Galactic Glitch",
    2510960: "Temtem: Swarm", 4197610: "Librarian", 2218750: "Halls of Torment", 2868840: "Slay the Spire 2",
    686060: "Mewgenics", 3405340: "Megabonk", 381020: "Sky Rogue",
}
LIGHT = {
    1022980: "Ostranauts", 1292690: "Corruption of Champions II", 1782120: "ZERO Sievert",
    2026820: "Die in the Dungeon", 2062430: "BALL x PIT", 208580: "KOTOR II", 212680: "FTL",
    2436940: "Sephiria", 250900: "Binding of Isaac: Rebirth", 2832310: "ITER-8", 2845630: "Ocean Keeper",
    2934220: "Monsters are Coming!", 3039910: "Demon Hunt", 3091140: "Lootbound", 3199360: "Skull Horde",
    3232380: "FROGGY HATES SNOW", 32370: "KOTOR", 3314790: "CloverPit", 333640: "Caves of Qud",
    3467710: "Wall World 2", 3494210: "Choo Choo Survivor 2", 3526710: "Everything is Crab",
    3542380: "Rune Dice", 3839300: "Dogpile", 3934270: "How Many Dudes?", 3946950: "Click the Button",
    4075620: "Combolands", 4421010: "Bills Must Be Paid", 4601120: "Endless Rails", 599140: "Graveyard Keeper",
    606150: "Moonlighter", 646570: "Slay the Spire", 753420: "Dungreed", 846030: "Delta-V: Rings of Saturn",
}


def cap(fps):
    return {"DXVK_FRAME_RATE": str(fps), "VKD3D_FRAME_RATE": str(fps)}


def build():
    games = {}
    for appid in HEAVY:
        games[str(appid)] = {"fexProfile": "default", "cores": "big", "env": cap(40)}
    for appid in MEDIUM:
        games[str(appid)] = {"fexProfile": "default", "cores": "big", "env": cap(60)}
    for appid in LIGHT:
        games[str(appid)] = {"fexProfile": "default"}
    assert len(games) == len(HEAVY) + len(MEDIUM) + len(LIGHT), "an appid is in two tiers"
    return {"games": dict(sorted(games.items(), key=lambda kv: int(kv[0])))}


if __name__ == "__main__":
    out = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).with_name("game-tweaks.json")
    with out.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(build(), f, indent=2)
        f.write("\n")
    print(f"{out}: {len(build()['games'])} games")
