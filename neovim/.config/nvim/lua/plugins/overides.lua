-- overides the defaults plugin from LazyVim
local HOME = vim.fn.stdpath("config")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
  {
    "garymjr/nvim-snippets",
    opts = {
      friendly_snippets = false,
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- remove some lint rules for Markdown
        markdownlint = {
          args = { "--disable", "MD013", "MD041", "--" },
        },
        ["markdownlint-cli2"] = {
          args = { "--config", HOME .. "linter/.markdownlint-cli2.yaml", "--" },
        },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        preview = {
          -- avoid preview for big files https://github.com/nvim-telescope/telescope.nvim/issues/623
          filesize_limit = 0.9999,
          timeout = 250,
        },
      },
    },
  },
  {
    "nvim-treesitter",
    keys = {
      { "v", desc = "Increment Selection" },
      { "V", desc = "Decrement Selection", mode = "x" },
    },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "v",
          scope_incremental = false,
          node_decremental = "V",
        },
      },
    },
  },
}
