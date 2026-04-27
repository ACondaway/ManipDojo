#!/bin/bash

# Match GPU memory use with policy/pi0/eval.sh (JAX on consumer GPUs)
export XLA_PYTHON_CLIENT_MEM_FRACTION=0.4

policy_name=pi0
task_name=${1}
task_config=${2}
# Same slot as eval_ACT.sh ckpt_setting; for pi0 this is the checkpoint step (e.g. 30000)
ckpt_setting=${3}
seeds=${4}
gpu_id=${5}

# Defaults match policy/pi0/checkpoints/.../dojo-10-tasks-clean-and-random/<step>/
: "${PI0_TRAIN_CONFIG_NAME:=pi0_base_aloha_robotwin_full}"
: "${PI0_MODEL_NAME:=dojo-10-tasks-clean-and-random}"
: "${PI0_STEP:=50}"

export CUDA_VISIBLE_DEVICES=${gpu_id}
echo -e "\033[33mgpu id (to use): ${gpu_id}\033[0m"

PYTHONWARNINGS=ignore::UserWarning \
python script/eval_policy.py --config policy/${policy_name}/deploy_policy.yml \
    --overrides \
    --task_name ${task_name} \
    --task_config ${task_config} \
    --ckpt_setting ${ckpt_setting} \
    --train_config_name ${PI0_TRAIN_CONFIG_NAME} \
    --model_name ${PI0_MODEL_NAME} \
    --checkpoint_id ${ckpt_setting} \
    --pi0_step ${PI0_STEP} \
    --seeds ${seeds} \
    --policy_name ${policy_name}
