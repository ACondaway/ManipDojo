#!/bin/bash

gpu_id=${1:-0}
ckpt_setting="policy_last"

# Per-task expert_data_num
export blocks_ranking_rgb_expert_data_num=50
export blocks_ranking_size_expert_data_num=50
export handover_mic_expert_data_num=50
export move_can_pot_expert_data_num=50
export move_stapler_pad_expert_data_num=50
export open_microwave_expert_data_num=50
export place_can_basket_expert_data_num=50
export place_dual_shoes_expert_data_num=50
export place_fan_expert_data_num=50
export stack_blocks_three_expert_data_num=50

# Per-task clean seeds
export blocks_ranking_rgb_clean_seeds="0 1 2 3 4"
export blocks_ranking_size_clean_seeds="0 1 2 3 4"
export handover_mic_clean_seeds="0 1 2 3 4"
export move_can_pot_clean_seeds="0 1 2 3 4"
export move_stapler_pad_clean_seeds="0 1 2 3 4"
export open_microwave_clean_seeds="0 1 2 3 4"
export place_can_basket_clean_seeds="0 1 2 3 4"
export place_dual_shoes_clean_seeds="0 1 2 3 4"
export place_fan_clean_seeds="0 1 2 3 4"
export stack_blocks_three_clean_seeds="0 1 2 3 4"

# Per-task randomized seeds
export blocks_ranking_rgb_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export blocks_ranking_size_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export handover_mic_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export move_can_pot_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export move_stapler_pad_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export open_microwave_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export place_can_basket_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export place_dual_shoes_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export place_fan_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"
export stack_blocks_three_rand_seeds="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14"

tasks=(
    blocks_ranking_rgb
    blocks_ranking_size
    handover_mic
    move_can_pot
    move_stapler_pad
    open_microwave
    place_can_basket
    place_dual_shoes
    place_fan
    stack_blocks_three
)

for task in "${tasks[@]}"; do
    clean_var="${task}_clean_seeds"
    rand_var="${task}_rand_seeds"

    clean_seeds_csv=$(echo ${!clean_var} | tr ' ' ',')
    rand_seeds_csv=$(echo ${!rand_var} | tr ' ' ',')

    echo "Evaluating $task | clean | seeds: ${!clean_var}"
    bash eval_ACT.sh "$task" demo_clean "$ckpt_setting" "$clean_seeds_csv" "$gpu_id"

    echo "Evaluating $task | randomized | seeds: ${!rand_var}"
    bash eval_ACT.sh "$task" demo_randomized "$ckpt_setting" "$rand_seeds_csv" "$gpu_id"
done

echo ""
echo "=========================================="
echo "Computing final benchmark score..."
echo "=========================================="
python3 compute_score.py | tee eval_result.txt
