#!/bin/bash

godot_root=".."
godot_binary="$godot_root/workspace/GodotEditor.app/Contents/MacOS/godot"
godot_workspace="$godot_root/workspace"

$godot_binary --headless --export-release "MacOS" "$godot_workspace/Brotato.app"
