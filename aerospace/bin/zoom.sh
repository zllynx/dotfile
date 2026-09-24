#!/bin/bash
# M+f 智能「放大 ⇄ 还原」
#
# 背景：'layout accordion tiles' 对浮动窗口是 no-op（报 The window is non-tiling）。
#       云空间在线预览等子窗口会被 AeroSpace 自动判为浮动；焦点不在预期窗口时
#       按 M+shift+space 也会把窗口悄悄翻成浮动。
# 行为：
#   - 焦点窗口是浮动 → 先收编为平铺，再 accordion 放大（还原后会保持平铺，
#     想回到浮动再按 M+shift+space）
#   - 焦点窗口已平铺 → 原 accordion ⇄ tiles 放大/还原切换
AERO=/opt/homebrew/bin/aerospace
layout=$("$AERO" list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null)
if [ "$layout" = "floating" ]; then
    "$AERO" layout floating tiling   # 浮动 → 平铺
    "$AERO" layout accordion         # 放大
else
    "$AERO" layout accordion tiles   # 放大 ⇄ 还原
fi
