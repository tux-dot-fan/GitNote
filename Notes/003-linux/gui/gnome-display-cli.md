---
title: GNOME 显示器布局一键切换（gdctl）
date: 2026-09-08
tags: [chat, linux, gnome, display, wayland]
source: 2026-09-08 会话 + 官方文档
---

# GNOME 显示器布局一键切换

> 需求：GNOME 上能否"一键重新组织"显示器布局？结论：能，用系统自带的 `gdctl`（GNOME 48+），见 [[DISPLAY]] 了解 X11 背景。

## 关键前提

- GNOME 默认 **Wayland**，`xrandr` 在 Wayland 下**不可用**
- GNOME 48+ 的 Mutter **自带 `gdctl`**（Display Control），官方文档明确建议用它，而不是第三方 gnome-randr
- `wlr-randr` / `kanshi` 属于 wlroots 系合成器（Sway 等），**不适用 GNOME**

## gdctl 用法

```bash
gdctl show              # 查看当前配置
gdctl show --modes      # 列出每块屏支持的模式（含刷新率）
gdctl set --verify …    # 只验证不应用（调试必备）
```

`set` 的模型：多个 `--logical-monitor` 组 = 多个逻辑屏；组内 `--monitor` 选物理连接器（HDMI-1 / DP-2 / eDP-1…）。

典型命令（HDMI-1 主屏在左 + DP-2 竖屏旋转 90° 在右，笔记本内置屏自动关闭）：

```bash
gdctl set \
  --logical-monitor --primary --monitor HDMI-1 --mode 2560x1440@59.951 --x 0 --y 0 \
  --logical-monitor --monitor DP-2 --mode 2560x1440@59.951 --transform 90 --x 2560 --y 0
```

逻辑屏选项：`--primary`、`--scale`、`--transform {normal,90,180,270,…}`、`--x/--y`、`--right-of/--left-of/--above/--below <连接器>`；monitor 选项：`--mode`、`--color-mode`、`--rgb-range`。相对摆放（`--right-of`）可避免硬编码坐标。

## GNOME 自带的记忆机制

- 布局自动存于 `~/.config/monitors.xml`，**插拔显示器自动恢复**上次布局（每种组合分别记忆）
- 注意：手动拷贝该文件**不会即时生效**（要注销/重启才读），别用它当一键切换方案

## 一键脚本（本机已落地）

- 脚本 `~/.local/bin/monitor-layout-desk.sh`：桌面双屏布局，支持 `--dry-run`
- 快捷键：`Super + Alt + D`（gsettings custom-keybindings custom5；改键：设置 → 键盘 → 查看及自定义快捷键）
- 加新布局：复制脚本改坐标/`--monitor` 即可；"仅内置屏"例：

```bash
gdctl set --logical-monitor --primary --monitor eDP-1 --mode 2880x1800@120
```

## 历史/其他方案

- **autorandr**：仅 X11，老牌，支持热插拔钩子
- **gnome-randr**：Python 原版年久失修；Rust 版（maxwellainatchi）作者已停维护，明确建议 GNOME48+ 用 gdctl；且 PyPI 上无此包名
- 相关：[[pipx]]（装 CLI 工具的正确姿势）、[[systemd]]/[[dbus]]（gdctl 底层走 org.gnome.Mutter.DisplayConfig）
