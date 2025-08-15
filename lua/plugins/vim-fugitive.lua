return {
  -- Git plugin
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set('n', '<leader>gd', function()
      vim.cmd 'Gvdiffsplit develop:%'
      vim.cmd 'wincmd w'
      vim.cmd 'normal! zR'
    end, { desc = 'Diff with develop, focus current file with open folds' })
  end,
}
