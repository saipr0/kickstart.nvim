vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

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

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Visual
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
vim.opt.cmdheight = 0
vim.opt.shortmess:append 'F'

-- Windows
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
  if vim.fn.executable 'pwsh' == 1 then
    vim.o.shell = 'pwsh.exe'
  else
    vim.o.shell = 'cmd.exe'
  end
end

vim.g.copilot_enabled = 0
