return {
  {
    'loctvl842/monokai-pro.nvim',
    priority = 1000,
    config = function()
      require('monokai-pro').setup {
        transparent_background = true,
        terminal_colors = true,
        filter = 'octagon',
        background_clear = {
          'toggleterm',
          'telescope',
          'renamer',
          'notify',
        },
      }
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
  },
  {
    'marko-cerovac/material.nvim',
    dependencies = 'rktjmp/lush.nvim',
    priority = 1000,
    config = function()
      require('material').setup {
        disable = {
          background = true,
        },
      }

      vim.g.material_style = 'palenight'
    end,
  },
  {
    'EdenEast/nightfox.nvim',
  },
  {
    'bluz71/vim-moonfly-colors',
    name = 'moonfly',
    lazy = false,
    priority = 1000,
  },
  {
    -- Colorscheme persistence (not a real plugin)
    dir = vim.fn.stdpath 'config',
    name = 'colorscheme-persistence',
    lazy = false,
    priority = 500,
    config = function()
      -- Load saved colorscheme or default to moonfly
      local colorscheme_file = vim.fn.stdpath 'data' .. '/colorscheme.txt'
      local colorscheme = 'moonfly'
      if vim.fn.filereadable(colorscheme_file) == 1 then
        colorscheme = vim.fn.readfile(colorscheme_file)[1]
      end
      vim.cmd.colorscheme(colorscheme)

      -- Save colorscheme when changed
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function(args)
          vim.fn.writefile({ args.match }, colorscheme_file)
        end,
      })
      vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })
    end,
  },
}
