#!/bin/sh

WORKSPACE_DIR=../../workspace

python main.py --experiment_dir \
  "$WORKSPACE_DIR/experiment" \
  --experiment_name brotato_experiment \
  --restore brotato_experiment_1 \
  --save_checkpoint_frequency 100 \
  --onnx_export_path="$WORKSPACE_DIR/model/model.zip" \
  --speedup 3 \
  --viz