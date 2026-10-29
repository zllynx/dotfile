return {
  --mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- 常用语言工具: shell / python / c-c++ / go / lua (rust 的 rust-analyzer 走 rustup, 不归 mason)
      -- 下载走 GitHub releases, 需代理的环境先 setproxy 再打开 nvim (2026-10-29 cloudbook)
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "bash-language-server",
        "shellcheck",
        "shfmt",
        "pyright",
        "ruff",
        "clangd",
        "gopls",
      })
    end,
  },
}
