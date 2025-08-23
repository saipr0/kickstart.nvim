return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    -- helper function to use fzf-lua on harpoon list
    local function toggle_fzf(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end
      
      require('fzf-lua').fzf_exec(file_paths, {
        prompt = 'Harpoon❯ ',
        winopts = {
          height = 0.4,
          width = 0.6,
        },
        actions = {
          ['default'] = function(selected)
            vim.cmd('edit ' .. selected[1])
          end,
        },
      })
    end

    local harpoon = require 'harpoon'
    -- Set highlight groups for floating windows
    vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Normal' })
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end)
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)
    vim.keymap.set('n', '<leader>fl', function()
      toggle_fzf(harpoon:list())
    end, { desc = 'Open harpoon window' })
    vim.keymap.set('n', '<C-p>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<C-n>', function()
      harpoon:list():next()
    end)
  end,
}
