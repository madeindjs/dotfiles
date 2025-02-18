return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider_options = {
          codestral = {
            optional = {
              max_tokens = 256,
              stop = { "\n\n" },
            },
          },
        },
        -- Your configuration options here
      })
    end,
  },
  {
    "nvim-cmp",
    optional = true,
    opts = function(_, opts)
      -- if you wish to use autocomplete
      table.insert(opts.sources, 1, {
        name = "minuet",
        group_index = 1,
        priority = 100,
      })
      opts.performance = {
        -- It is recommended to increase the timeout duration due to
        -- the typically slower response speed of LLMs compared to
        -- other completion sources. This is not needed when you only
        -- need manual completion.
        fetching_timeout = 2000,
      }
      opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
        -- if you wish to use manual complete
        ["<A-y>"] = require("minuet").make_cmp_map(),
      })
    end,
  },
}

-- return {
--   "yetone/avante.nvim",
--   event = "VeryLazy",
--   lazy = false,
--   version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
--   opts = {
--     -- add any opts here
--     -- for example
--     provider = "mistral",
--     vendors = {
--       ["mistral"] = {
--         __inherited_from = "openai",
--         -- endpoint = "https://api.mistral.ai/v1",
--         endpoint = "https://codestral.mistral.ai/v1",
--         api_key_name = "MISTRAL_API_KEY",
--         model = "codestral-latest", -- your desired model (or use gpt-4o, etc.)
--       },
--     },
--   },
--   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
--   build = "make",
--   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
--   dependencies = {
--     "stevearc/dressing.nvim",
--     "nvim-lua/plenary.nvim",
--     "MunifTanjim/nui.nvim",
--     --- The below dependencies are optional,
--     "echasnovski/mini.pick", -- for file_selector provider mini.pick
--     "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
--     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
--     "ibhagwan/fzf-lua", -- for file_selector provider fzf
--     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
--     "zbirenbaum/copilot.lua", -- for providers='copilot'
--     {
--       -- support for image pasting
--       "HakonHarnes/img-clip.nvim",
--       event = "VeryLazy",
--       opts = {
--         -- recommended settings
--         default = {
--           embed_image_as_base64 = false,
--           prompt_for_file_name = false,
--           drag_and_drop = {
--             insert_mode = true,
--           },
--           -- required for Windows users
--           use_absolute_path = true,
--         },
--       },
--     },
--     {
--       -- Make sure to set this up properly if you have lazy=true
--       "MeanderingProgrammer/render-markdown.nvim",
--       opts = {
--         file_types = { "markdown", "Avante" },
--       },
--       ft = { "markdown", "Avante" },
--     },
--   },
-- }
