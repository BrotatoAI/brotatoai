#!/bin/bash

# Export the game for macOS
# More info about export options: https://docs.godotengine.org/en/3.5/tutorials/export/exporting_projects.html

GODOT_ROOT=$(readlink -f ..)
GODOT_PROJECT_SOURCES="$GODOT_ROOT/src/brotato_sources"
GODOT_BINARY="$GODOT_ROOT/workspace/GodotEditor.app/Contents/MacOS/godot"
GODOT_WORKSPACE="$GODOT_ROOT/workspace"

# Export the game for macOS
$GODOT_BINARY --headless --path "$GODOT_PROJECT_SOURCES" --export BrotatoAITraining $GODOT_WORKSPACE/BrotatoAITraining.app
