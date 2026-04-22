#!/usr/bin/env python3
"""
Compute final benchmark score from eval_result directory.

Score per task = sum of rewards across all 20 seeds (clean x5 + randomized x15),
normalized to 10 points (max reward per seed = 1.0, so max total = 20 -> 10).
Final score = sum of all 10 tasks = 100 points max.
"""

import os
import sys
from pathlib import Path
from collections import defaultdict

TASKS = [
    "blocks_ranking_rgb",
    "blocks_ranking_size",
    "handover_mic",
    "move_can_pot",
    "move_stapler_pad",
    "open_microwave",
    "place_can_basket",
    "place_dual_shoes",
    "place_fan",
    "stack_blocks_three",
]

CLEAN_SEEDS = list(range(5))
RAND_SEEDS = list(range(15))


def parse_result(result_dir: Path):
    """Parse _result.txt. Returns (total_reward, seed_count) or (None, 0).
    Supports both multi-seed format ("Total reward: X" + "Seeds: [...]")
    and legacy single-seed format (bare float line).
    """
    result_file = result_dir / "_result.txt"
    if not result_file.exists():
        return None, 0
    lines = result_file.read_text().strip().splitlines()

    total_reward = None
    seed_count = 0

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("Total reward:"):
            try:
                total_reward = float(stripped.split(":", 1)[1].strip())
            except ValueError:
                pass
        elif stripped.startswith("Seeds:"):
            seeds_str = stripped.split(":", 1)[1].strip()
            if seeds_str == "[]":
                seed_count = 0
            else:
                seed_count = seeds_str.count(",") + 1

    if total_reward is not None:
        return total_reward, seed_count

    # Backward compatibility: bare float line = single-seed result
    for line in lines:
        try:
            total_reward = float(line.strip())
            return total_reward, 1
        except ValueError:
            continue
    return None, 0


def main():
    eval_root = Path("eval_result")
    if not eval_root.exists():
        print(f"eval_result directory not found at {eval_root.resolve()}")
        sys.exit(1)

    # Discover policy and ckpt_setting from directory structure
    # eval_result/{task}/{policy}/{task_config}/{ckpt_setting}/{timestamp}/
    # We'll aggregate all results found per (task, task_config, seed)

    # Structure: eval_result/{task}/{policy}/{task_config}/{ckpt_setting}/{timestamp}/_result.txt
    # Collect rewards per task across all seeds

    task_rewards = defaultdict(float)
    task_seed_counts = defaultdict(int)
    missing = []

    for task in TASKS:
        task_dir = eval_root / task
        if not task_dir.exists():
            missing.append(f"{task}: directory missing")
            continue

        for policy_dir in task_dir.iterdir():
            if not policy_dir.is_dir():
                continue
            for config_dir in policy_dir.iterdir():
                if not config_dir.is_dir():
                    continue
                for ckpt_dir in config_dir.iterdir():
                    if not ckpt_dir.is_dir():
                        continue
                    # Use only the latest timestamp dir per config to avoid double-counting
                    for ts_dir in sorted(ckpt_dir.iterdir(), reverse=True):
                        if not ts_dir.is_dir():
                            continue
                        reward, seed_count = parse_result(ts_dir)
                        if reward is not None:
                            task_rewards[task] += reward
                            task_seed_counts[task] += seed_count
                            break

    print(f"\n{'Task':<30} {'Total Reward':>14} {'Seeds':>7} {'Score/10':>10}")
    print("-" * 65)

    total_score = 0.0
    for task in TASKS:
        reward = task_rewards.get(task, 0.0)
        count = task_seed_counts.get(task, 0)
        # max reward = 20 (1.0 per seed x 20 seeds) -> normalize to 10
        score = (reward / 20.0) * 10.0
        total_score += score
        status = "" if count == 20 else f"  [WARNING: {count}/20 seeds]"
        print(f"{task:<30} {reward:>14.4f} {count:>7} {score:>10.4f}{status}")

    print("-" * 65)
    print(f"{'TOTAL SCORE':<30} {'':>14} {'':>7} {total_score:>10.4f} / 100")

    if missing:
        print("\nMissing:")
        for m in missing:
            print(f"  {m}")


if __name__ == "__main__":
    main()
