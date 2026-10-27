# DeepInfer 源码编译脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/deepseek-ai/DeepInfer#getting-started
# 更新日期：2026-10-27
# 类型：script
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '需要先安装 Git' }
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw '需要先安装 Python 3' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

throw 'DeepInfer 仅支持 Linux（GCC 13+ / Python 3.12 / CUDA 13 或 CANN 9.2）。Windows 请在 WSL2 中按 README 编译，且需要 SM100 或昇腾 950 硬件。'

Write-Host ''

Write-Host '编译完成：按 README 跑 examples 里的离线推理脚本；模型会在首次运行时下载到 Hugging Face 缓存'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://github.com/deepseek-ai/DeepInfer#getting-started'
