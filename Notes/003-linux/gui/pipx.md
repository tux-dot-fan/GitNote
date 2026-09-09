---
title: pipx — Python 命令行工具安装器
date: 2026-09-08
tags: [chat, linux, python, tooling]
source: 2026-09-08 会话
---

# pipx

> `pipx` 是 **Python 命令行应用的安装/运行工具**：给每个应用建独立虚拟环境，再把命令软链到 `~/.local/bin`，装完即全局可用、互不污染。

## 为什么需要它

`pip` 装应用的两个麻烦：装全局污染系统 Python；装 venv 里又只能在那个环境用。pipx 每个应用一个独立 venv，命令符号链接到 `~/.local/bin`。

## 与 apt / pip 的分工

| 命令 | 用途 | 装到哪 |
|---|---|---|
| `apt install` | 系统包 | 系统目录（需 sudo） |
| `pip install` | Python **库** | 当前 Python 环境 |
| `pipx install` | Python 写的**命令行工具** | 独立 venv + `~/.local/bin` |

记法：**装库用 pip，装工具用 pipx**。

## 常用命令

```bash
pipx install <app>     # 安装（命令立即可用）
pipx run <app>         # 临时运行，不安装
pipx list              # 列出已装应用
pipx upgrade <app>
pipx uninstall <app>
pipx ensurepath        # 把 ~/.local/bin 加进 PATH（写 ~/.bashrc）
pipx completions       # 启用 shell 补全
```

## 安装与坑

```bash
sudo apt install pipx
# 或：python3 -m pip install --user pipx
```

- Ubuntu 的 pip 有 **PEP668（externally-managed）** 限制，`--user` 安装需加 `--break-system-packages`
- 装完 `pipx ensurepath` 后要重开终端才生效
- 应用包名不是想当然：`pipx install gnome-randr` 会报 "not found in the package registry"（PyPI 无此包名），装前先 `pipx install` 或查 GitHub/PyPI

## 相关

- [[appimage]] / [[debian_package]]：同一话题的其它"应用分发"形态
- [[gnome-display-cli]]：本机用 pipx 装了 pipx 本身，但最终显示工具用的是系统自带的 gdctl
