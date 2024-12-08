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
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<C-k>", "<cmd>Neotree reveal<cr>", desc = "Show file in Tree" },
    },
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = function()
      return {
        window = {
          position = "right", -- setup Tree to the right
        },
        filesystem = {
          window = {
            mappings = {
              -- add telescope shortcuts
              ["t"] = "noop",
              ["tf"] = "telescope_find",
              ["tg"] = "telescope_grep",
              -- add shortcuts to copy the path
              ["y"] = "noop",
              ["ya"] = "copy_absolute_path",
              ["yr"] = "copy_relative_path",
            },
          },
        },
        commands = {
          copy_absolute_path = function(state)
            local node = state.tree:get_node()
            local result = node:get_id()
            vim.fn.setreg("+", result)
            vim.notify("Copied: " .. result)
          end,
          copy_relative_path = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            local result = vim.fn.fnamemodify(path, ":.")
            vim.fn.setreg("+", result)
            vim.notify("Copied: " .. result)
          end,
          telescope_find = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("telescope.builtin").find_files({
              cwd = path,
              search_dirs = { path },
            })
          end,
          telescope_grep = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("telescope.builtin").live_grep({
              cwd = path,
              search_dirs = { path },
            })
          end,
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      -- remove some elements to have more space for the path
      sections = {
        lualine_a = {},
        lualine_c = {
          LazyVim.lualine.root_dir(),
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path() },
        },
        lualine_b = {},
        lualine_y = {
          -- { "progress" },
        },
        lualine_z = {
          { "location" },
        },
      },
    },
  },
  {
    "catppuccin/nvim",
    enabled = false,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },
  {
    "iamcco/markdown-preview.nvim",
    enabled = false,
  },
  {
    "markdown-preview.nvim",
    enabled = false,
  },
}
