#!/bin/sh

WORKSPACE_DIR=../../workspace

python main_sb3.py \
  --env gdrl \
  --experiment_dir "$WORKSPACE_DIR/experiment" \
  --experiment_name brotato_experiment \
  --restore brotato_experiment \
  --onnx_export_path model.onnx \
  --save_model_path model.zip \
  --timesteps 500 \
  --speedup 3 \
  --viz