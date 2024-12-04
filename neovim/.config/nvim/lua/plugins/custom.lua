-- setup new plugins
return {
  {
    "almo7aya/openingh.nvim",
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- config = function()
    --   local oil = require("oil")
    --   oil.setup()
    -- end,
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>c-",
        function ()
          require('oil').toggle_float()
        end,
        desc = "Edit files",
      },
    },
  },
}
