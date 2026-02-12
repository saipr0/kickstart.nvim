return { -- Multiple cursors
  'mg979/vim-visual-multi',
  branch = 'master',
  config = function()
    -- Ensure Ctrl+N is available for multi-cursor selection
    vim.g.VM_maps = {
      ['Find Under'] = '<C-n>',         -- Select next occurrence
      ['Find Subword Under'] = '<C-n>', -- Select next occurrence
    }
  end,
}
