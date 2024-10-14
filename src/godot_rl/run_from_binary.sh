#!/bin/sh

WORKSPACE_DIR=$(readlink -f ../../workspace)

mkdir -p "$WORKSPACE_DIR/model"

python main_sb3.py \
  --n_parallel 4 \
  --env_path "$WORKSPACE_DIR/BrotatoAITraining.app" \
  --experiment_dir "$WORKSPACE_DIR/experiment_2" \
  --experiment_name brotato_experiment \
  --restore brotato_experiment \
  --onnx_export_path "$WORKSPACE_DIR/model/model_2.onnx" \
  --timesteps 5000 \
  --speedup 5 \
  --viz \
  --save_model_path "$WORKSPACE_DIR/model/model_2.zip" \
  # --resume_model_path "$WORKSPACE_DIR/model/model_2.zip"