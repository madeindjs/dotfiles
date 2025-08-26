local function get_notes_path()
  local dir1 = os.getenv("HOME") .. "/Documents/perso/@plaintext/vault"

  if vim.fn.isdirectory(dir1) ~= false then
    return os.getenv("HOME") .. "/Documents/@plaintext/vault"
  end

  return dir1
end

return {
  {
    "folke/which-key.nvim",
    -- opts = {
    --   defaults = {
    --     ["<leader>p"] = { name = "+notes", icon = "󰍔" },
    --   },
    -- },
    setup = function()
      local wk = require("which-key")
      wk.add({ { "<leader>p", group = "notes", desc = "notes", icon = "󰍔" } })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>pf",
        function()
          require("telescope.builtin").find_files({ cwd = get_notes_path() })
          -- "<cmd>e <cr>"
        end,
        desc = "Find notes",
      },
      {
        "<leader>pg",
        function()
          require("telescope.builtin").live_grep({ cwd = get_notes_path() })
        end,
        desc = "Grep notes",
      },
      {
        "<leader>pw",
        function()
          vim.api.nvim_create_autocmd("BufWinEnter", {
            pattern = "*log.md",
            once = true,
            callback = function()
              vim.cmd("setlocal foldlevel=0")
              vim.cmd("normal! gg") -- Move cursor to the first line
              vim.cmd("normal! zO") -- Open the fold under the cursor
            end,
          })
          vim.cmd("e " .. get_notes_path() .. "/@writer/log.md")
        end,
        desc = "Open log (Writer)",
      },
      {
        "<leader>pt",
        function()
          vim.cmd("e " .. get_notes_path() .. "/../todo.txt")
        end,
        desc = "Open todos",
      },
    },
  },
}
