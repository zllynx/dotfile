return {
  "folke/sidekick.nvim",
  -- NES (Next Edit Suggestions) 需要 Copilot LSP + 订阅, 见 :help / README
  opts = {
    cli = {
      -- 启用会话持久化: backend 自动检测 (tmux 下用 tmux, zellij 下用 zellij)
      mux = { enabled = true },
      tools = {
        -- Oh My Pi (命令 omp). 仅保留安全的 --continue; omp 的 --resume 需带值故省略
        omp = {
          cmd = { "omp" },
          is_proc = "\\<omp\\>",
          continue = { "--continue" },
        },
      },
    },
  },
  keys = {
    -- 焦点切换: 在编辑区和 AI CLI 终端间来回跳
    {
      "<c-.>",
      function() require("sidekick.cli").focus() end,
      desc = "Sidekick Focus",
      mode = { "n", "t", "i", "x" },
    },
    -- 打开/关闭 AI CLI 终端 (选已安装的工具)
    { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "Sidekick Toggle CLI" },
    -- 选择要启动/附加的 CLI 工具 (claude/codex/...)
    {
      "<leader>as",
      function() require("sidekick.cli").select({ filter = { installed = true } }) end,
      desc = "Sidekick Select CLI",
    },
    -- 关闭/分离当前 CLI 会话
    { "<leader>ad", function() require("sidekick.cli").close() end, desc = "Sidekick Close CLI" },
    -- 发送当前光标位置上下文给 AI
    {
      "<leader>at",
      function() require("sidekick.cli").send({ msg = "{this}" }) end,
      mode = { "x", "n" },
      desc = "Sidekick Send This",
    },
    -- 发送整个文件
    { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Sidekick Send File" },
    -- 发送可视选区
    {
      "<leader>av",
      function() require("sidekick.cli").send({ msg = "{selection}" }) end,
      mode = { "x" },
      desc = "Sidekick Send Selection",
    },
    -- 选择一个内置 prompt (explain/fix/tests/review...)
    {
      "<leader>ap",
      function() require("sidekick.cli").prompt() end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    -- 直接打开 Claude (你已安装 claude CLI)
    {
      "<leader>ac",
      function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
      desc = "Sidekick Toggle Claude",
    },
    -- 直接打开 Oh My Pi (omp)
    {
      "<leader>ao",
      function() require("sidekick.cli").toggle({ name = "omp", focus = true }) end,
      desc = "Sidekick Toggle Oh My Pi",
    },
  },
}
