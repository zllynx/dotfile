-- Wezterm Configuration

local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 主题
-- config.color_scheme = 'Kanagawa Dragon (Gogh)'
config.color_scheme = 'Gruvbox Material (Gogh)'
  
-- 字体 (Maple Mono NF CN)
config.font = wezterm.font 'Maple Mono NF CN'
config.font_size = 16

-- 窗口
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }


return config
