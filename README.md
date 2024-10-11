# BrotatoAI
BrotatoAI is a mod for the game Brotato that rely on AI model to play the game.

It's strongly inspired from the work of https://github.com/boardengineer/botato and rely on https://github.com/BrotatoMods/Brotato-Mod-Options for customizations.

This uses an LLM model accessed through python script to play the game.

# Install

## Quick Start
```bash
./make.sh
```

## Complete Install

### SteamCMD
Download from https://developer.valvesoftware.com/wiki/SteamCMD

### Brotato
Download brotato from steam using steamcmd.

```bash
./steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir ./brotato/ +login <your_brotato_steam_account> +app_update 1942280 validate +quit
```
### Godot RE
Download brotato Reverse Engineering tool from https://github.com/bruvzg/gdsdecomp/releases

Reverse godot pckg file using godot re.

Copy steam_data.json to extracted folder.

### GodotSteam Editor
Download godot editor from https://github.com/GodotSteam/GodotSteam/releases/tag/v3.25

### Follow guide if necessary

https://steamcommunity.com/sharedfiles/filedetails/?id=2931079751

### Brotato ModLoader

https://github.com/GodotModding/godot-mod-loader


## Python

```bash
python3 -m venv brotato_env

pip install -r requirements.txt

python3 src/godot_rl/main.py
```