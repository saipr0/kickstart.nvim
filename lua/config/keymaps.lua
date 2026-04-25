-- Basic
vim.keymap.set('n', ';', ':')
vim.keymap.set('t', '<C-\\>', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Goto Prev Diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Goto Next Diagnostic' })
vim.keymap.set('n', 'Q', '"_', { noremap = true, silent = true })
vim.keymap.set('x', 'p', function()
  return 'pgv"' .. vim.v.register .. 'y'
end, { remap = false, expr = true })
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- Tabs
vim.keymap.set('n', '<Tab>', function()
  if vim.fn.tabpagenr '$' > 1 then
    vim.api.nvim_command 'tabnext'
  end
end, { desc = 'Next tab' })

vim.keymap.set('n', '<S-Tab>', function()
  if vim.fn.tabpagenr '$' > 1 then
    vim.api.nvim_command 'tabprevious'
  end
end, { desc = 'Previous tab' })

-- Buffers
vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', { desc = '[B]uffer [N]ew' })
vim.keymap.set('n', '<leader>bd', function()
  require('mini.bufremove').delete()
end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bD', function()
  require('mini.bufremove').delete(0, true)
end, { desc = '[B]uffer [D]elete!' })
vim.keymap.set('n', '<leader>bw', function()
  require('mini.bufremove').wipeout()
end, { desc = '[B]uffer [W]ipeout' })
vim.keymap.set('n', '<leader>bW', function()
  require('mini.bufremove').wipeout(0, true)
end, { desc = '[B]uffer [W]ipeout!' })

-- Search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to upper window' })
