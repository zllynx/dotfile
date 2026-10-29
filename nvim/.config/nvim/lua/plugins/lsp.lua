return {
  --mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- mason 工具从 GitHub releases 下载; GitHub 直连不通的环境(云电脑 WSL)不自动装,
      -- 需要时先 setproxy 再 :MasonInstall <pkg> 手动装 (2026-10-29 cloudbook)
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
