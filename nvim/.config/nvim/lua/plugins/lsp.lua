return {
  --mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- mason 工具从 GitHub releases 下载; 直连 GitHub 不通的环境(云电脑 WSL)跳过,
      -- 否则每次打开文件都重试安装并弹 "Installation failed" (2026-10-29 cloudbook)
      if vim.uv.os_uname().sysname ~= "Darwin" then
        opts.ensure_installed = {}
        return
      end
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "clangd",
        "pyright",
        "gopls",
      })
    end,
  },
}
