-- Wezterm Configuration
-- 对齐 Windows Terminal (wt-preview.settings.json):
-- Gruvbox Dark / Maple Mono NF CN / filledBox 光标 / 81% Acrylic

local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 默认启动 Arch WSL (WT defaultProfile)
if wezterm.target_triple:find 'windows' then
  config.default_prog = { 'wsl.exe', '-d', 'Arch', '--user', 'zllynx', '--cd', '~' }
end

-- 主题 (WT: Gruvbox Dark, 同源色板)
config.color_scheme = 'Gruvbox Dark (Gogh)'
config.colors = {
  -- WT: cursorColor / selectionBackground 均为 #FFFFFF
  -- selection_fg/cursor_fg 取 gruvbox bg0 保证白底可读 (WT 为自动反色)
  cursor_bg = '#FFFFFF',
  cursor_fg = '#282828',
  cursor_border = '#FFFFFF',
  selection_bg = '#FFFFFF',
  selection_fg = '#282828',
  tab_bar = {
    background = '#1D2021',
    active_tab = { bg_color = '#282828', fg_color = '#EBDBB2' },
    inactive_tab = { bg_color = '#1D2021', fg_color = '#928374' },
    inactive_tab_hover = { bg_color = '#3C3836', fg_color = '#EBDBB2' },
    new_tab = { bg_color = '#1D2021', fg_color = '#928374' },
    new_tab_hover = { bg_color = '#3C3836', fg_color = '#EBDBB2' },
  },
}

-- 光标 (WT: filledBox = 方块不闪烁)
config.default_cursor_style = 'SteadyBlock'

-- 窗口 (WT: opacity 81 + useAcrylic + Arch profile padding 0)
config.window_background_opacity = 0.81
config.win32_system_backdrop = 'Acrylic'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_close_confirmation = 'NeverPrompt'

-- 字体 (与 WT 相同: Maple Mono NF CN)
config.font = wezterm.font 'Maple Mono NF CN'
config.font_size = 14

-- 快捷键 (Ctrl+V 直贴; 选中即复制到剪贴板为 wezterm 默认行为)
config.keys = {
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
}

-- 滚动 (WT Arch profile: historySize 20000)
config.scrollback_lines = 20000

return config
