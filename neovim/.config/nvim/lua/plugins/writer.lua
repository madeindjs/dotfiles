-- WIP script to run command on startup
local M = {}

local function create_terminal(cmd)
  local current_id = vim.fn.bufnr()

  vim.cmd(":terminal " .. cmd)

  local buf_id = vim.fn.bufnr()
  local term_id = vim.b.terminal_job_id

  vim.api.nvim_set_current_buf(current_id)

  if term_id == nil then
    -- TODO error happens
    return nil
  end
end

local function command()
  create_terminal("echo ok")
end

vim.api.nvim_create_user_command("WriterStart", command, {})

return M
