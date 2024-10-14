STEAM_ACCOUNT_NAME=$1
WORKSPACE_DIR=$(readlink -f ../workspace)

if [ ! $STEAM_ACCOUNT_NAME ]; then
  echo "Please provide your Steam account name owning Brotato game as an argument."
  exit 1
fi

echo "Installing the workspace..."

# SteamCMD
mkdir -p "$WORKSPACE_DIR/SteamCMD"
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz" | tar zxvf - -C "$WORKSPACE_DIR/SteamCMD"

# Brotato app
mkdir -p "$WORKSPACE_DIR/brotato"
"$WORKSPACE_DIR/SteamCMD/steamcmd.sh" +@sSteamCmdForcePlatformType windows +force_install_dir ../brotato/ +login $STEAM_ACCOUNT_NAME +app_update 1942280 validate +quit

# GDRE
curl -sqL -o "$WORKSPACE_DIR/GDRE_tools-v0.6.2-macos.zip" "https://github.com/bruvzg/gdsdecomp/releases/download/v0.6.2/GDRE_tools-v0.6.2-macos.zip"
unzip "$WORKSPACE_DIR/GDRE_tools-v0.6.2-macos.zip" -d "$WORKSPACE_DIR"
rm "$WORKSPACE_DIR/GDRE_tools-v0.6.2-macos.zip"

# Seems command line is not working anymore, don't know why
echo "Please run Godot RE tools manually and extract the Brotato.pck file to $WORKSPACE_DIR/brotato_sources"
mkdir -p "$WORKSPACE_DIR/brotato_sources"
# chmod +x "$WORKSPACE_DIR/Godot RE Tools.app/Contents/MacOS/Godot RE Tools"
# "$WORKSPACE_DIR/Godot RE Tools.app/Contents/MacOS/Godot RE Tools" --headless --recover="$WORKSPACE_DIR/brotato/Brotato.pck" --output="$WORKSPACE_DIR/brotato_sources"

# Copy steam_data.json to source folder
cp "$WORKSPACE_DIR/brotato/steam_data.json" "$WORKSPACE_DIR/brotato_sources/steam_data.json"

# Godot editor (Steam version)
curl -sqL -o ./workspace/GodotSteam_universal.zip "https://github.com/GodotSteam/GodotSteam/releases/download/g35-s155-gs3174/macos-g35-s155-gs3174-universal.zip"
unzip ./workspace/GodotSteam_universal.zip -d ./workspace
rm ./workspace/GodotSteam_universal.zip

# Godot editor (Standard version)
# curl -sqL -o ./workspace/Godot_v3.5-stable_osx.universal.zip "https://github.com/godotengine/godot-builds/releases/download/3.5-stable/Godot_v3.5-stable_osx.universal.zip"
# unzip -q -d ./workspace ./Godot_v3.5-stable_osx.universal.zip
# rm ./workspace/Godot_v3.5-stable_osx.universal.zip

# Mods folder
mkdir -p "$WORKSPACE_DIR/brotato_sources/mods-unpacked"

# ModOption
curl -sqL -o ./workspace/ModOption.zip "https://github.com/BrotatoMods/Brotato-Mod-Options/archive/refs/heads/main.zip"
unzip ./workspace/ModOption.zip ./workspace/ModOption
cp -r ./workspace/Brotato-Mod-Options-main/dami-ModOptions ./workspace/brotato_sources/mods-unpacked

echo "Installation of the workspace completed."
echo "Please run Godot editor manually and open the project at $WORKSPACE_DIR/brotato_sources"