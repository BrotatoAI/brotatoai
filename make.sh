STEAM_ACCOUNT_NAME=barrakuda666@hotmail.com

# SteamCMD
mkdir -p ./workspace/SteamCMD
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz" | tar zxvf - -C ./workspace/SteamCMD

# Brotato app
mkdir -p ./workspace/brotato
./workspace/SteamCMD/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir ../brotato/ +login $STEAM_ACCOUNT_NAME +app_update 1942280 validate +quit

# GDRE
curl -sqL -o ./workspace/GDRE_tools-v0.6.2-macos.zip "https://github.com/bruvzg/gdsdecomp/releases/download/v0.6.2/GDRE_tools-v0.6.2-macos.zip"
unzip ./workspace/GDRE_tools-v0.6.2-macos.zip -d ./workspace
rm ./workspace/GDRE_tools-v0.6.2-macos.zip

chmod +x ."/workspace/Godot RE Tools.app/Contents/MacOS/Godot RE Tools"
."/workspace/Godot RE Tools.app/Contents/MacOS/Godot RE Tools" --headless --recover=workspace/brotato/Brotato.pck --output=workspace/brotato_sources_2

# Godot python

# brew install scons yasm
# git clone https://github.com/touilleMan/godot-python.git ./workspace/godot-python
# asdf install python 3.10.8
# asdf local python 3.10.8
# python -m venv venv
# pip install typed-ast==1.5.0
# pip install -r requirements.txt
# scons platform=osx-64 arch=arm64 CC=clang release

# Godot editor
cp ./workspace/brotato/steam_data.json ./workspace/brotato_sources/steam_data.json

curl -sqL -o ./workspace/GodotSteam_universal.zip "https://github.com/GodotSteam/GodotSteam/releases/download/g35-s155-gs3174/macos-g35-s155-gs3174-universal.zip"
unzip ./workspace/GodotSteam_universal.zip -d ./workspace
rm ./workspace/GodotSteam_universal.zip

# curl -sqL -o ./workspace/Godot_v3.5-stable_osx.universal.zip "https://github.com/godotengine/godot-builds/releases/download/3.5-stable/Godot_v3.5-stable_osx.universal.zip"
# unzip -q -d ./workspace ./Godot_v3.5-stable_osx.universal.zip
# rm ./workspace/Godot_v3.5-stable_osx.universal.zip

# Mods folder
mkdir -p ./workspace/brotato_sources/mods-unpacked

# ModOption

curl -sqL -o ./workspace/ModOption.zip "https://github.com/BrotatoMods/Brotato-Mod-Options/archive/refs/heads/main.zip"
unzip ./workspace/ModOption.zip ./workspace/ModOption
cp -r ./workspace/Brotato-Mod-Options-main/dami-ModOptions ./workspace/brotato_sources/mods-unpacked