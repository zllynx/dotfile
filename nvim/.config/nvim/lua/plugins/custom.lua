return {
  {
    "Shatur/neovim-ayu",
    config = function()
      require("ayu").setup({})
    end,
  },
  {
    "LazyVim/LazyVim",
    dependencies = {
    },
    opts = {
      colorscheme = "ayu"
    },
  },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "Plugin Updates",
        },
        opts = { skip = true },
      })
      opts.presets.lsp_doc_border = true
    end,
  },
  -- UI animations
  -- {
  --   "echasnovski/mini.animate",
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     opts.scroll = {
  --       enable = false,
  --     }
  --   end,
  -- },
  -- customize snacks dashboard header
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
██████╗ ██╗     ██╗     ██╗   ██╗███╗   ██╗██╗  ██╗
╚══███╗██║     ██║     ╚██╗ ██╔╝████╗  ██║╚██╗██╔╝
  ███╔╝██║     ██║      ╚████╔╝ ██╔██╗ ██║ ╚███╔╝
 ███╔╝ ██║     ██║       ╚██╔╝  ██║╚██╗██║ ██╔██╗
███████╗███████╗███████╗   ██║   ██║ ╚████║██╔╝ ██╗
╚══════╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═══╝╚═╝  ╚═╝
          ]],
        },
      },
    },
  },
  -- filename
  {
    "b0o/incline.nvim",
    dependencies = { "craftzdog/solarized-osaka.nvim" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local colors = require("solarized-osaka.colors").setup()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
            InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },
  -- buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = function(_, opts)
      opts.options = {
        mode = "tabs",
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics_indicator = false,
        numbers = "ordinal",
        tab_size = 12,
        indicator = {
          style = 'none'
        },
        show_duplicate_prefix = false,
        separator_style = "thin",
      }
      local bg_color = "#18524D"
      opts.highlights = {
        buffer_selected = {
          bg = bg_color,
          bold = true,
          italic = true,
        },
        numbers_selected = {
          bg = bg_color,
        },
      }
    end,
  },
  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        -- globalstatus = false,
        -- theme = "solarized_dark",
        -- theme = "nightfox",
      },
    },
  },
}
