vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ Setting options ]]

-- Basic
vim.o.number = true
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.confirm = true
-- Next tab
vim.keymap.set('n', '<Tab>', function()
  if vim.fn.tabpagenr('$') > 1 then
    vim.api.nvim_command 'tabnext'
  end
end, { desc = 'Next tab' })

-- Previous tab
vim.keymap.set('n', '<S-Tab>', function()
  if vim.fn.tabpagenr('$') > 1 then
    vim.api.nvim_command 'tabprevious'
  end
end, { desc = 'Previous tab' })

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Visual
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
vim.opt.fillchars = { eob = ' ' }
vim.o.breakindent = true
vim.opt.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.opt.cmdheight = 0  -- Hide command line by default
vim.opt.shortmess:append('F')  -- Don't show file info messages

-- Tabline is now handled by mini.tabline

-- Windows
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
  if vim.fn.executable 'pwsh' == 1 then
    vim.o.shell = 'pwsh.exe'
  else
    vim.o.shell = 'cmd.exe'
  end
end

-- copilot
vim.g.copilot_enabled = 0

-- [[ Basic Keymaps ]]

-- Basic
vim.keymap.set('n', ';', ':')
vim.keymap.set('t', '<C-\\>', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Add diagnostic navigation keymaps to prevent conflicts
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Goto Prev Diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Goto Next Diagnostic' })
vim.keymap.set('n', 'Q', '"_', { noremap = true, silent = true })
vim.keymap.set('x', 'p', function()
  return 'pgv"' .. vim.v.register .. 'y'
end, { remap = false, expr = true })
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- Buffer management (like MiniMax)
vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', { desc = '[B]uffer [N]ew' })
vim.keymap.set('n', '<leader>bd', function() require('mini.bufremove').delete() end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { desc = '[B]uffer [D]elete!' })
vim.keymap.set('n', '<leader>bw', function() require('mini.bufremove').wipeout() end, { desc = '[B]uffer [W]ipeout' })
vim.keymap.set('n', '<leader>bW', function() require('mini.bufremove').wipeout(0, true) end, { desc = '[B]uffer [W]ipeout!' })

-- Search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- lazy plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
