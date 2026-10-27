# DeepInfer 源码编译指南

> 第三方部署指南 · 非 DeepInfer 官方仓库。官方项目：[deepseek-ai/DeepInfer](https://github.com/deepseek-ai/DeepInfer)
> 内容来自官方文档（2026-10-27）。项目迭代快，请以[官方文档](https://github.com/deepseek-ai/DeepInfer#getting-started)为准。

[![⚡ 源码编译](https://img.shields.io/badge/%E2%9A%A1_%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#源码编译推荐用百度搭子)

## 源码编译（推荐：用百度搭子）

> [!TIP]
> 想在自己机器上跑 DeepSeek 的推理栈，让百度搭子把 DeepInfer 编译好，直接做 V4.1-Flash 离线推理。

⚠️ 仅支持 Linux。需要 GCC 13+、Python 3.12、CUDA 13（NVIDIA SM100）或 CANN 9.2（昇腾 950）。Windows 请用 WSL2，且必须有对应 GPU，普通消费级显卡跑不了。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/deepinfer-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子克隆仓库、检查 GCC/Python/CUDA 环境，然后执行 build.sh 编译，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Git；构建依赖以官方文档为准。）



## DeepInfer 是什么？

DeepInfer 是开源的23.3k stars，Apache-2.0，DeepSeek 生产环境推理框架的开源版，支持 SM100 与昇腾 950（协议：Apache-2.0，<img src="https://img.shields.io/github/stars/deepseek-ai/DeepInfer?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

DeepSeek 生产推理框架的开源版本：包含优化 kernel、MoE 并行、异步调度、结构化输出与确定性采样，支持 DeepSeek-V4.1-Flash 的离线推理。

- 23.3k stars：2026-10-16 建仓，10 天破 2 万
- 生产级：DeepSeek 线上服务同款框架
- MoE 并行：Attention DP / 平衡 CP / EP + EPLB
- 优化 kernel：FlashMLA、DeepGEMM、DeepEP 等
- 确定性推理：批不变 + 固定种子
- 结构化输出：正则、JSON Schema、EBNF

（来源：[官方仓库](https://github.com/deepseek-ai/DeepInfer)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 23.3k stars | 10 天破 2 万，增速极猛 |
| 生产同款 | DeepSeek 线上服务框架开源版 |
| kernel 齐全 | FlashMLA / DeepGEMM / DeepEP 都在 |
| 确定性推理 | 适合评测与回归 |
| 结构化输出 | 正则、Schema、文法都支持 |
| Apache-2.0 | 可商用可改 |

| 需要注意 | 说明 |
|---|---|
| 硬件门槛极高 | 要 SM100 或昇腾 950 |
| 只支持 Linux | Windows 得走 WSL2 |
| 要源码编译 | GCC 13 + CUDA 13 |
| 不含完整服务 | KV cache 与 PD 分离要自己补 |
| 模型体积大 | V4.1-Flash 下载与显存都不小 |

> 以上基于官方文档与社区反馈整理（2026-10-27），以官方最新文档为准。

## 快速部署（官方方式）

```bash
git clone https://github.com/deepseek-ai/DeepInfer.git deepinfer-src
cd deepinfer-src ; python3 -c "import sys; assert sys.version_info[:2]==(3,12), '需要 Python 3.12'"
export DEEPINFER_ACCELERATOR=nvidia ; ./build.sh
echo '编译完成：模型默认从 Hugging Face 下载，可用 DEEPINFER_HF_MODEL_DIR 指向本地目录'
```

部署步骤来源：[https://github.com/deepseek-ai/DeepInfer#getting-started](https://github.com/deepseek-ai/DeepInfer#getting-started)

## 验证状态

| 场景 | 状态 |
|---|---|
| 仓库元数据已核对：23.3k stars、Apache-2.0、2026-10-16 建仓 | 已核对 2026-10-27 |
| README 确认仅 Linux，需要 GCC 13 / Python 3.12 / CUDA 13 或 CANN 9.2 | 已核对 2026-10-27 |
| 未实测编译（本机无 SM100 / 昇腾 950 硬件） | 说明 2026-10-27 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

DeepInfer 是推理框架，不是 MCP server；本仓库不注册 MCP。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-27）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\deepinfer-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 编译前置条件

| 项 | 要求 |
|---|---|
| 系统 | Linux |
| GCC | >= 13.0 |
| Python | 3.12 |
| NVIDIA | CUDA 13，SM100 |
| 昇腾 | CANN 9.2，Ascend 950 |

### 编译

```bash
export DEEPINFER_ACCELERATOR=nvidia   # 昇腾用 ascend
./build.sh
```

### 离线推理

```bash
export DEEPINFER_HF_MODEL_DIR=/path/to/DeepSeek-V4.1-Flash-1017
```

不设就首次运行时自动下载到 Hugging Face 缓存。

### 常用开关

| 变量 | 作用 |
|---|---|
| `DEEPINFER_ENABLE_MTP_VARLEN=1` | 开启 DSpark 草稿验证 |
| `DEEPINFER_BATCH_INVARIANT=1` | 批不变推理（仅 NVIDIA） |
| `DEEPINFER_YOCO_PREFILL_TRUNCATION_MODE=compact` | 缩短 decoder prefill |

> ⚠️ 开源版不含 KV cache 系统与 PD 分离，完整生产服务要自己补；普通 4090 等消费卡不在支持列表内。

## 常见坑

- Python 版本不对：必须 3.12
- GCC 太旧：升到 13 以上
- 忘记导出 `DEEPINFER_ACCELERATOR`：编译脚本会报错
- 消费级显卡跑不了：先确认是否 SM100
- 模型下载慢：先手动拉 Hugging Face 仓库再设本地路径
- 显存不足：确认并行配置与模型规模匹配

## 免责声明

本仓库为第三方指南，与 DeepInfer 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-27），项目迭代快，请以[官方文档](https://github.com/deepseek-ai/DeepInfer#getting-started)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
