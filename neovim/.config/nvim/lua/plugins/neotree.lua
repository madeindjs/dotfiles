return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function()
    return {
      window = {
        position = "right", -- setup Tree to the right
      },
      filesystem = {
        window = {
          position = "right", -- setup Tree to the right
          mappings = {
            ["t"] = "noop",
            ["tf"] = "telescope_find",
            ["tg"] = "telescope_grep",
          },
        },
      },
      commands = {
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
}
