local HOME = vim.fn.stdpath("config")

return {
  {
    "almo7aya/openingh.nvim",
  },
  {
    "garymjr/nvim-snippets",
    opts = {
      friendly_snippets = false,
    },
  },
  -- remove some lint rules for Markdown
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        markdownlint = {
          args = { "--disable", "MD013", "MD041", "--" },
        },
        ["markdownlint-cli2"] = {
          args = { "--config", HOME .. "linter/.markdownlint-cli2.yaml", "--" },
        },
      },
    },
  },
}
