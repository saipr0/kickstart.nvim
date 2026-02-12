return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { 'mellow-theme/mellow.nvim', priority = 1000 },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  {
    'zenbones-theme/zenbones.nvim',
    dependencies = 'rktjmp/lush.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'vague2k/vague.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
  },
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
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none', fg = '#6b7280' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'none' })
      
      -- Fix split line - remove yellow background
      vim.api.nvim_set_hl(0, 'VertSplit', { bg = 'none', fg = '#666666' })
      vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'none', fg = '#666666' })
      
      -- Clear mini.pick backgrounds for transparency
      local pick_groups = {
        'MiniPickNormal', 'MiniPickBorder', 'MiniPickPrompt',
        'MiniPickMatchCur', 'MiniPickMatchRanges',
      }
      for _, group in ipairs(pick_groups) do
        vim.api.nvim_set_hl(0, group, { bg = 'none' })
      end

      -- Clear fidget.nvim backgrounds
      local fidget_groups = {
        'FidgetTask', 'FidgetTitle', 'FidgetNormal',
        'Fidget', 'FidgetProgress', 'FidgetProgressDone', 'FidgetProgressIcon',
      }
      for _, group in ipairs(fidget_groups) do
        vim.api.nvim_set_hl(0, group, { bg = 'none' })
      end
      
      -- Custom color for constants
      -- Change the color to whatever you prefer (examples below)
      vim.api.nvim_set_hl(0, 'Constant', { fg = '#ff79c6' })  -- Pink
      vim.api.nvim_set_hl(0, '@constant', { fg = '#ff79c6' }) -- Pink (Treesitter)
      -- Other color options:
      -- '#bd93f9' - Purple
      -- '#8be9fd' - Cyan
      -- '#50fa7b' - Green
      -- '#f1fa8c' - Yellow
      -- '#ff5555' - Red
      -- '#ffb86c' - Orange
    end,
  },
}
