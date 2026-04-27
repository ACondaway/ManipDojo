<h1 align="center">
  <a href="https://robotwin-benchmark.github.io">RoboTwin Platform for ManipDojo-2026<br></a>
</h1>
<h2 align="center">Lastest Version: RoboTwin 2.0<br>🤲 <a href="https://robotwin-platform.github.io/">Webpage</a> | <a href="https://robotwin-platform.github.io/doc/">Document</a> | <a href="https://arxiv.org/abs/2506.18088">Paper</a> | <a href="https://robotwin-platform.github.io/doc/community/index.html">Community</a> | <a href="https://robotwin-platform.github.io/leaderboard">Leaderboard</a></h2>

# About the challenge

ManipDojo Challenge focuses on cutting-edge research and practical validation of dual-arm cooperative manipulation for robotic embodied intelligence. Through simulation-based tasks, it advances the generalization and real-world deployment of related algorithms. Powered by D-Robotics' Robogo, the one-Stop cloud-based robot development and collaboration Platform, the challenge delivers an efficient online competition experience. You can know about the code detail to [Easy Start Tutorial](https://github.com/ACondaway/ManipDojo/blob/main/EASYSTART.md).

# Timeline

- April 7: Registration Opens
- April 13: Preliminary Task Release 
- April 21: Participating Team Training
- May 11: Preliminary Round Ends
- May 15: Final Round Starts
- May 28: Final Round Results Released
- May 30: Award Winners Announced
- June 5: Achievement Showcase at ICRA Workshop

# Scoring Criteria

Using the same checkpoint, tests will be conducted on 10 tasks via the RoboTwin simulation platform. Each task is worth 10 points, with 0.5 points per evaluation. For long-horizon tasks, intermediate process scores will be provided.
Specific criteria are as follows:
| Task Name              | Score Details                                                                 |
|-----------------------|-------------------------------------------------------------------------------|
| move_stapler_pad      | 100% (task completed)                                                        |
| place_fan             | 100% (successful placement)                                                  |
| handover_mic          | 100% (handover action completed)                                             |
| open_microwave        | 100% (task completed)                                                        |
| place_can_basket      | 100% (task completed)                                                        |
| place_dual_shoes      | 100% (task completed)                                                        |
| stack_blocks_three    | First stack: 40%, Overall: 100%                                              |
| move_can_pot          | 100% (task completed)                                                        |
| blocks_ranking_rgb    | First block: 20%, Second block: 60%, Third block: 100%                       |
| blocks_ranking_size   | First block: 20%, Second block: 60%, Third block: 100%                       |

# Contact and Community

1. Registration Page: https://promo.d-robotics.cc/manipdojo2026
2. GitHub Repo: [Please provide the GitHub link]
3. Technical Support Contacts:
- Xu Congsheng: acondaway@sjtu.edu.cn
- Liu Yitian: violetevar@sjtu.edu.cn
- Wu Yuhao: charleshen1412@gmail.com
- Shen Weijie: shenweijie@sjtu.edu.cn
4. Competition Q&A:
- Chinese Forum of D-Robotics Developer Community: https://forum.d-robotics.cc/c/38-category/48-category/48
- English Forum of D-Robotics Developer Community: https://forum-en.d-robotics.cc/c/community-dynamics/2026-manipdojo/50
5. Join D-Robotics Discord: https://discord.gg/6ukuyJ66By




# 以 PI0 为模板的 RoboTwin 整体 Pipeline 运行教程

本文档记录如何基于 **PI0 / OpenPI** 模板，在 **RoboTwin / ManipDojo** 环境中完成从环境安装、数据生成、数据转换、模型训练到最终评测的完整流程。

---

## 1. 安装 RoboTwin 环境

首先创建并激活 RoboTwin 所需的 Conda 环境。

```bash
conda create -n RoboTwin python=3.10 -y
conda activate RoboTwin
```

---

## 2. 克隆仓库

克隆 ManipDojo 仓库。

```bash
git clone https://github.com/ACondaway/ManipDojo.git
cd ManipDojo
```

---

## 3. 安装依赖并下载资产

运行环境安装脚本和资产下载脚本。

```bash
bash script/_install.sh
bash script/_download_assets.sh
```

如果安装过程中遇到问题，可以参考 RoboTwin 官方安装文档：

```text
https://robotwin-platform.github.io/doc/usage/robotwin-install.html#1-dependencies
```

---

## 4. 生成 RoboTwin 任务数据

运行以下脚本生成 RoboTwin 任务数据。

```bash
bash collect_data_all.sh
```

该脚本通常用于批量生成多个 RoboTwin 任务的数据，例如 10 个任务的数据。

---

## 5. 配置 PI0 环境

进入 PI0 策略目录，并使用 `uv` 安装依赖。

```bash
conda activate RoboTwin

pip install uv

cd policy/pi0

GIT_LFS_SKIP_SMUDGE=1 uv sync
```

说明：

- `uv sync` 用于安装 PI0 / OpenPI 所需依赖；
- `GIT_LFS_SKIP_SMUDGE=1` 表示跳过 Git LFS 大文件的自动下载，避免下载过慢或失败。

---

## 6. 将 RoboTwin 数据转换为 PI0 格式

首先创建数据目录。

```bash
mkdir processed_data
mkdir training_data
```

然后运行数据处理脚本。

```bash
bash process_data_pi0.sh ${task_name} ${task_config} ${expert_data_num}
```

参数说明：

| 参数 | 含义 | 示例 |
|---|---|---|
| `${task_name}` | RoboTwin 任务名称 | `beat_block_hammer` |
| `${task_config}` | 数据配置类型 | `demo_clean` |
| `${expert_data_num}` | 专家演示数据数量 | `50` |

示例命令：

```bash
bash process_data_pi0.sh beat_block_hammer demo_clean 50
```

如果需要处理随机化数据，可以使用：

```bash
bash process_data_pi0.sh beat_block_hammer demo_randomized 50
```

---

## 7. processed_data 目录结构

数据处理完成后，`processed_data/` 目录结构如下：

```text
processed_data/
├── ${task_name}-${task_config}-${expert_data_num}
│   ├── episode_0
│   │   ├── instructions.json
│   │   └── episode_0.hdf5
│   ├── episode_1
│   │   ├── instructions.json
│   │   └── episode_1.hdf5
│   ├── ...
```

其中：

- `instructions.json`：该 episode 对应的语言指令；
- `episode_x.hdf5`：该 episode 对应的轨迹数据。

---

## 8. 整理训练数据目录

将需要用于训练的数据从 `processed_data/` 复制到 `training_data/${model_name}/` 下。

---

### 8.1 多任务训练数据示例

如果需要进行多任务训练，可以将多个任务的数据放入同一个 `${model_name}` 目录中。

```text
training_data/
├── ${model_name}
│   ├── ${task_0}
│   │   ├── episode_0
│   │   │   ├── instructions.json
│   │   │   └── episode_0.hdf5
│   │   ├── episode_1
│   │   │   ├── instructions.json
│   │   │   └── episode_1.hdf5
│   │   ├── ...
│   ├── ${task_1}
│   │   ├── episode_0
│   │   │   ├── instructions.json
│   │   │   └── episode_0.hdf5
│   │   ├── episode_1
│   │   │   ├── instructions.json
│   │   │   └── episode_1.hdf5
│   │   ├── ...
```

---

### 8.2 单任务训练数据示例

如果只训练单个任务，例如 `beat_block_hammer-demo_clean-50`，目录结构如下：

```text
training_data/
├── demo_clean
│   ├── beat_block_hammer-demo_clean-50
│   │   ├── episode_0
│   │   │   ├── instructions.json
│   │   │   └── episode_0.hdf5
│   │   ├── episode_1
│   │   │   ├── instructions.json
│   │   │   └── episode_1.hdf5
│   │   ├── ...
```

此时 `demo_clean` 可以作为后续训练时的数据目录名或模型名。

---

## 9. 设置缓存路径

为了避免 Hugging Face 或其他依赖缓存写入默认目录，可以手动指定缓存路径。

```bash
export XDG_CACHE_HOME=/path/to/your/cache
```

示例：

```bash
export XDG_CACHE_HOME=/mnt/pfs/your_name/.cache
```

---

## 10. 生成 PI0 训练数据集

将整理好的 HDF5 数据进一步转换为 PI0 训练所需的数据集格式。

```bash
bash generate.sh ${hdf5_path} ${repo_id}
```

参数说明：

| 参数 | 含义 | 示例 |
|---|---|---|
| `${hdf5_path}` | 已整理好的 HDF5 数据目录 | `./training_data/demo_clean/` |
| `${repo_id}` | 生成后的数据集名称 | `demo_clean_repo` |

示例命令：

```bash
bash generate.sh ./training_data/demo_clean/ demo_clean_repo
```

说明：

- `${hdf5_path}` 通常指向 `training_data/${model_name}/`；
- `${repo_id}` 后续需要写入 PI0 的训练配置中。

---

## 11. 编写 PI0 训练配置

PI0 的训练配置文件位于：

```text
src/openpi/training/config.py
```

该文件中有一个 `_CONFIGS` 字典，用于管理不同训练配置。

官方实验中使用的配置为：

```text
pi0_base_aloha_robotwin_lora
```

目前可以修改以下 4 个预配置：

```text
pi0_base_aloha_robotwin_lora
pi0_fast_aloha_robotwin_lora
pi0_base_aloha_robotwin_full
pi0_fast_aloha_robotwin_full
```

---

### 11.1 修改 repo_id

在对应的 `TrainConfig` 中，将 `repo_id` 修改为前面生成的数据集名称。

例如，如果前面生成的数据集为：

```text
demo_clean_repo
```

则需要在配置中设置：

```python
repo_id="demo_clean_repo"
```

---

### 11.2 选择 PI0 或 PI0-Fast

如果使用普通 PI0，可以选择：

```text
pi0_base_aloha_robotwin_full
```

如果使用 PI0-Fast，可以选择：

```text
pi0_fast_aloha_robotwin_full
```

如果修改配置名称，并且使用的是 `pi0_fast` 模型，建议在配置名称中包含 `fast`，方便后续区分。

---

### 11.3 显存不足时的设置

如果 GPU 显存不足，可以调整 `fsdp_devices`。

相关配置可以参考：

```text
src/openpi/training/config.py
```

例如查看大约第 352 行附近的 FSDP 设置。

---

## 12. 计算数据集归一化统计量

训练前需要先计算数据集的 normalization statistics。

```bash
uv run scripts/compute_norm_stats.py --config-name ${train_config_name}
```

参数说明：

| 参数 | 含义 | 示例 |
|---|---|---|
| `${train_config_name}` | `config.py` 中 `_CONFIGS` 对应的配置名称 | `pi0_base_aloha_robotwin_full` |

示例命令：

```bash
uv run scripts/compute_norm_stats.py --config-name pi0_base_aloha_robotwin_full
```

---

## 13. 训练 PI0 模型

运行微调脚本。

```bash
bash finetune.sh ${train_config_name} ${model_name} ${gpu_use}
```

参数说明：

| 参数 | 含义 | 示例 |
|---|---|---|
| `${train_config_name}` | 训练配置名称 | `pi0_base_aloha_robotwin_full` |
| `${model_name}` | 保存的模型名称 | `demo_clean` |
| `${gpu_use}` | 使用的 GPU 编号 | `0` 或 `0,1,2,3` |

单卡训练示例：

```bash
bash finetune.sh pi0_base_aloha_robotwin_full demo_clean 0
```

多卡训练示例：

```bash
bash finetune.sh pi0_base_aloha_robotwin_full demo_clean 0,1,2,3
```

说明：

- 如果只使用单张 GPU，`${gpu_use}` 写成单个 GPU ID，例如 `0`；
- 如果使用多张 GPU，写成逗号分隔形式，例如 `0,1,2,3`。

---

## 14. 评测 PI0 模型

训练完成后，运行 RoboTwin 下的 PI0 评测脚本。

```bash
bash eval_all_pi0.sh
```

评测完成后，最终结果会保存在：

```text
eval_result.txt
```

可以使用以下命令查看结果：

```bash
cat eval_result.txt
```

---

## 15. 完整流程总结

整体运行流程如下：

```text
创建 RoboTwin 环境
        ↓
克隆 ManipDojo 仓库
        ↓
安装依赖并下载资产
        ↓
生成 RoboTwin 专家数据
        ↓
进入 policy/pi0 配置 PI0 环境
        ↓
将 RoboTwin 数据转换为 PI0 HDF5 格式
        ↓
整理 training_data 目录
        ↓
运行 generate.sh 生成训练数据集
        ↓
修改 src/openpi/training/config.py 中的 repo_id
        ↓
计算 normalization statistics
        ↓
运行 finetune.sh 训练 PI0
        ↓
运行 eval_all_pi0.sh 评测
        ↓
查看 eval_result.txt
```

---

## 16. 常用命令速查

```bash
# 创建并激活环境
conda create -n RoboTwin python=3.10 -y
conda activate RoboTwin

# 克隆仓库
git clone https://github.com/ACondaway/ManipDojo.git
cd ManipDojo

# 安装依赖与下载资产
bash script/_install.sh
bash script/_download_assets.sh

# 生成 RoboTwin 数据
bash collect_data_all.sh

# 配置 PI0 环境
cd policy/pi0
pip install uv
GIT_LFS_SKIP_SMUDGE=1 uv sync

# 创建数据目录
mkdir processed_data
mkdir training_data

# 数据转换
bash process_data_pi0.sh beat_block_hammer demo_clean 50

# 设置缓存路径
export XDG_CACHE_HOME=/path/to/your/cache

# 生成 PI0 数据集
bash generate.sh ./training_data/demo_clean/ demo_clean_repo

# 计算归一化统计量
uv run scripts/compute_norm_stats.py --config-name pi0_base_aloha_robotwin_full

# 训练模型
bash finetune.sh pi0_base_aloha_robotwin_full demo_clean 0,1,2,3

# 评测模型
bash eval_all_pi0.sh

# 查看结果
cat eval_result.txt
```