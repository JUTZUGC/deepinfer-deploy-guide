#!/usr/bin/env bash
set -euo pipefail
# DeepInfer 源码编译脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/deepseek-ai/DeepInfer#getting-started
# 更新日期：2026-10-27
# 类型：script
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v git >/dev/null 2>&1 || { echo "需要先安装 Git"; exit 1; }
command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || { echo "需要先安装 Python 3"; exit 1; }

mkdir -p .download
cd .download

git clone https://github.com/deepseek-ai/DeepInfer.git deepinfer-src
cd deepinfer-src ; python3 -c "import sys; assert sys.version_info[:2]==(3,12), '需要 Python 3.12'"
export DEEPINFER_ACCELERATOR=nvidia ; ./build.sh
echo '编译完成：模型默认从 Hugging Face 下载，可用 DEEPINFER_HF_MODEL_DIR 指向本地目录'

echo ""

echo "编译完成：按 README 跑 examples 里的离线推理脚本；模型会在首次运行时下载到 Hugging Face 缓存"
echo "若结果异常或需要改配置，请参考官方文档：https://github.com/deepseek-ai/DeepInfer#getting-started"
