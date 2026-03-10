-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- Use telescope as the picker instead of auto-detecting
vim.g.lazyvim_picker = "telescope"
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim
vim.g.autoformat = false
vim.o.termguicolors = true
vim.opt.relativenumber = false
vim.opt.number = true
-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Tab
vim.opt.tabstop = 4 -- number of  visual spaces per TAB
vim.opt.softtabstop = 4 -- numer of spacesin tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces
