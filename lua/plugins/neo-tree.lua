-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\<leader>', ':Neotree toggle reveal position=float<CR>', desc = 'NeoTree reveal', silent = true },
    { '\\e', ':Neotree toggle buffers position=right<CR>', desc = 'Toggle NeoTree buffers', silent = true },
  },
  config = function()
    require('neo-tree').setup {
      close_if_last_window = true, -- Close Neo-tree if it's the last window left
    }

    -- vim.api.nvim_create_autocmd('VimEnter', {
    --   callback = function()
    --     if vim.fn.argc() == 0 then
    --       vim.cmd 'Neotree show buffers position=right'
    --     end
    --   end,
    -- })
  end,
}
