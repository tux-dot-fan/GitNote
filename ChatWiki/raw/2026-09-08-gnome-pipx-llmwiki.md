---
title: Raw 快照 2026-09-08 GNOME显示器/pipx/LLM wiki
date: 2026-09-08
tags: [chat-wiki, raw]
---

# 会话原始要点（append-only，勿改）

来源：与 AI 助手的对话，2026-09-08。以下为要点实录，供 ingest 使用。

## 主题A：GNOME 显示器一键重排

- 需求：gnome 下有没有脚本可以一键重新组织显示器布局
- 事实核查结论：
  - GNOME 默认 Wayland，xrandr 在 Wayland 下不可用
  - 本机 GNOME Shell 50.1 / Mutter 50.1，**系统自带 `gdctl`**（GNOME 48+ 内置的显示器 CLI，官方文档建议用它替代第三方工具）
  - `gdctl` 子命令：show / set / prefs
  - `gdctl set` 语法：多个 `--logical-monitor` 组，组内 `--monitor <连接器>` + `--primary/--scale/--transform/--x/--y/--right-of` 等；monitor 级 `--mode`
  - `gdctl set --verify` 只验证不应用
  - 其他方案：autorandr（仅 X11）；gnome-randr（Python 原版年久失修；Rust 版作者已停维护并建议 GNOME48+ 用 gdctl）；wlr-randr/kanshi 属于 wlroots，不适用 GNOME
  - GNOME 会把布局存在 `~/.config/monitors.xml`，插拔自动恢复；拷贝该文件不会即时生效（需注销重登），不推荐当一键方案
- 本机硬件现状：3 块屏 —— DP-2（小米27" 2560x1440@60，支持120Hz）、HDMI-1（小米27" 同款）、eDP-1（笔记本内置 2880x1800@120）
- 已做动作：
  - pipx 装到 ~/.local/bin，ensurepath 已加 ~/.bashrc
  - gnome-randr 在 PyPI 上不存在（uv 报 not found），放弃
  - 写脚本 `~/.local/bin/monitor-layout-desk.sh`：HDMI-1 主屏(0,0) + DP-2 竖屏(旋转90°)在 (2560,0)，内置屏关闭；支持 `--dry-run`（调 gdctl set --verify）
  - gsettings 注册自定义快捷键 custom5：`<Super><Alt>d` → 该脚本（已存在 custom0-4：flameshot×2、albert、Tux Launcher、Tux Voice Input）

## 主题B：pipx

- pipx = Python 应用安装/运行工具：每个应用独立 venv + 软链到 ~/.local/bin
- pip 装库、pipx 装命令行工具、apt 装系统包
- 常用：pipx install / run / list / upgrade / uninstall / ensurepath / completions
- 安装：apt install pipx 或 python3 -m pip install --user pipx
- Ubuntu24.04+ 的 pip 有 PEP668 externally-managed 限制，--user 安装要加 --break-system-packages

## 主题C：LLM wiki 方法论

- 两含义：
  1. 方法论：Karpathy 的 llm-wiki.md（gist），LLM 增量构建并维护个人 wiki，而非每次现查的 RAG
  2. 实现：nashsu/llm_wiki —— 跨平台桌面应用，17.5k★，最新 v0.6.11（有 linux amd64 .deb/AppImage）
- Karpathy 模式要点：三层 Raw Sources(只读)→Wiki(LLM生成)→Schema(规则)；操作 ingest/query/lint；index.md 目录、log.md 日志、[[wikilink]]、YAML frontmatter、Obsidian 兼容、人策展 LLM 维护
- nashsu 实现亮点：两步链式摄入、PDF 图文、多种格式、模型按项目配置、Rust 后端聊天 Agent、知识图谱+Louvain 社区发现、LanceDB 向量搜索、Deep Research、Chrome 剪藏、HTTP API+MCP server+agent skill、源文件夹自动监视
- 易混淆：llms.txt/llmstxt.org（网站给 LLM 的清单规范）、llmwiki.com（LLM 工具目录站）
- 用户意图：把"从对话中学到的东西"用此方法论组织进 GitNote vault → 建立 ChatWiki

## 环境备注

- Ubuntu 26.04 LTS，user dean，Wayland 会话
- 沙箱环境 home 目录只读，需完整权限才能写 ~/.local（仅记录，非知识）
