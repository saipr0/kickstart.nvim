local state = {
  floating = {
    buf = -1,
    win = -1,
  },
  lazygit = {
    buf = -1,
    win = -1,
  },
}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end
  -- Define window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal', -- No borders or extra UI elements
    border = 'rounded',
  }
  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)
  -- Fix background color to match your colorscheme exactly
  -- This forces the floating window to use the same background as your main editor
  vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,NormalFloat:Normal,FloatBorder:Normal', { win = win })
  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

local toggle_lazygit = function()
  if not vim.api.nvim_win_is_valid(state.lazygit.win) then
    state.lazygit = create_floating_window { buf = state.lazygit.buf }
    if vim.bo[state.lazygit.buf].buftype ~= 'terminal' then
      vim.fn.termopen 'lazygit'
    end
  else
    vim.api.nvim_win_hide(state.lazygit.win)
  end
end

-- Example usage:
-- Create a floating window with default dimensions
vim.api.nvim_create_user_command('Floaterm', toggle_terminal, {})
-- Create a floating window with lazygit
vim.api.nvim_create_user_command('Floatgit', toggle_lazygit, {})

-- Force floating windows to match editor background exactly
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'NormalFloat', {
      bg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg or 'NONE',
    })
  end,
})

-- Set it immediately for current colorscheme
vim.api.nvim_set_hl(0, 'NormalFloat', {
  bg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg or 'NONE',
})
