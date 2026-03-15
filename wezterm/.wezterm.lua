local wezterm = require 'wezterm'

return {
  -- 你的 WezTerm 配置
  default_prog = {
    "wsl.exe",
    "-d",
    "Arch",
    "--cd",
    "~"
  },

  -- 字体配置
  font = wezterm.font('JetBrains Mono'),
  font_size = 11.0,

  -- 配色方案
  color_scheme = 'Tokyo Night',

  -- 窗口透明度
  window_background_opacity = 0.9,
}
