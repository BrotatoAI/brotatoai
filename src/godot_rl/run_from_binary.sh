#!/bin/sh

WORKSPACE_DIR=$(readlink -f ../../workspace)
EXPERIMENT_ID=4

mkdir -p "$WORKSPACE_DIR/model"

python main_sb3.py \
  --n_parallel 10 \
  --env_path "$WORKSPACE_DIR/BrotatoAITraining.app" \
  --experiment_dir "$WORKSPACE_DIR/experiment_$EXPERIMENT_ID" \
  --experiment_name brotato_experiment \
  --restore brotato_experiment \
  --onnx_export_path "$WORKSPACE_DIR/model/model_$EXPERIMENT_ID.onnx" \
  --timesteps 500_000 \
  --linear_lr_schedule \
  --speedup 1000 \
  --save_model_path "$WORKSPACE_DIR/model/model_$EXPERIMENT_ID.zip" \
  --resume_model_path "$WORKSPACE_DIR/model/model_$EXPERIMENT_ID.zip"
