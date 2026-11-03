local M = {}
local namespace = vim.api.nvim_create_namespace("dictation")
local session

local function stop(current)
  if not current.stopping then
    current.stopping = true
    local ok, err = vim.uv.kill(vim.fn.jobpid(current.job), "sigint")
    if not ok then
      vim.notify("Could not stop dictation: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

function M.toggle()
  if session then
    stop(session)
    return
  end

  if vim.fn.executable("transcribe-macos.py") == 0 then
    vim.notify("transcribe-macos.py is not in PATH", vim.log.levels.ERROR)
    return
  end

  local buffer = vim.api.nvim_get_current_buf()
  if not vim.bo[buffer].modifiable then
    vim.notify("The current buffer is not modifiable", vim.log.levels.ERROR)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local mark = vim.api.nvim_buf_set_extmark(buffer, namespace, cursor[1] - 1, cursor[2], { right_gravity = true })
  local current = { buffer = buffer, mark = mark, pending_newline = false }
  session = current

  current.job = vim.fn.jobstart({ "transcribe-macos.py" }, {
    on_stdout = function(_, data)
      local text = table.concat(data, "\n")
      if text == "" then
        return
      end
      if current.pending_newline then
        text = "\n" .. text
      end
      current.pending_newline = text:sub(-1) == "\n"
      if current.pending_newline then
        text = text:sub(1, -2)
      end
      if text == "" or not vim.api.nvim_buf_is_loaded(buffer) then
        return
      end
      local position = vim.api.nvim_buf_get_extmark_by_id(buffer, namespace, mark, {})
      if #position == 0 then
        return
      end
      vim.api.nvim_buf_set_text(buffer, position[1], position[2], position[1], position[2], vim.split(text, "\n", { plain = true }))
    end,
    on_stderr = function(_, data)
      local message = table.concat(data, "\n"):gsub("%s+$", "")
      if message ~= "" then
        vim.notify(message, vim.log.levels.INFO, { title = "Dictation" })
      end
    end,
    on_exit = function(_, code)
      if vim.api.nvim_buf_is_valid(buffer) then
        pcall(vim.api.nvim_buf_del_extmark, buffer, namespace, mark)
      end
      if session == current then
        session = nil
      end
      if current.stopping then
        vim.notify("Dictation stopped")
      elseif code ~= 0 then
        vim.notify("Dictation exited with code " .. code, vim.log.levels.ERROR)
      end
    end,
  })

  if current.job <= 0 then
    vim.api.nvim_buf_del_extmark(buffer, namespace, mark)
    session = nil
    vim.notify("Could not start dictation", vim.log.levels.ERROR)
    return
  end
  vim.notify("Starting dictation...")
end

return M
