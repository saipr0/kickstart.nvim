return {
  'ibhagwan/fzf-lua',
  event = 'VimEnter',
  dependencies = {
    -- Optional: for file icons (same as your telescope setup)
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Setup fzf-lua
    require('fzf-lua').setup {
      'ivy',
      winopts = {
        preview = {
          hidden = 'hidden', -- Hide preview by default
        },
      },
      actions = {
        files = {
          true,
          ['ctrl-q'] = {
            fn = require('fzf-lua').actions.file_sel_to_qf,
            prefix = 'select-all+',
          },
        },
      },
      defaults = {
        file_icons = false, -- Sets default for all pickers
        git_icons = false,
        silent = true, -- Suppress messages
      },
      files = {
        formatter = 'path.filename_first',
        cwd_prompt = false,
      },
      lsp = {
        async = true,
        file_icons = false,
        formatter = 'path.filename_first',
      },
      hls = { path_colnr = 'Comment' },
    }

    -- Key mappings - matching your telescope setup
    local fzf = require 'fzf-lua'

    -- Helper function to get the monorepo root if we're in one
    local function get_search_root()
      local cwd = vim.fn.getcwd()
      -- If we're in tagntrac-infra/fulcrum, search from tagntrac-infra instead
      if cwd:match('/tagntrac%-infra/fulcrum') then
        return cwd:match('(.*/tagntrac%-infra)')
      end
      return cwd
    end

    -- Direct equivalents to your telescope mappings
    vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sc', fzf.colorschemes, { desc = '[S]earch [C]olorscheme' })
    vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', function()
      fzf.files({ cwd = get_search_root() })
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect fzf-lua' })
    vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function()
      fzf.live_grep({ cwd = get_search_root() })
    end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

    -- Current buffer fuzzy find equivalent
    vim.keymap.set('n', '<leader>/', fzf.blines, { desc = '[/] Fuzzily search in current buffer' })

    -- Live grep in open files equivalent
    vim.keymap.set('n', '<leader>s/', function()
      fzf.grep {
        search = '',
        no_esc = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case -g '*.{" .. table.concat(
          vim.tbl_map(function(buf)
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':e')
          end, vim.api.nvim_list_bufs()),
          ','
        ) .. "}' -e",
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Neovim config files search equivalent
    vim.keymap.set('n', '<leader>sn', function()
      fzf.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Additional useful fzf-lua mappings you might want
    vim.keymap.set('n', '<leader>st', fzf.tags, { desc = '[S]earch [T]ags' })
    vim.keymap.set('n', '<leader>sm', fzf.marks, { desc = '[S]earch [M]arks' })
    vim.keymap.set('n', '<leader>sj', fzf.jumps, { desc = '[S]earch [J]umps' })
    vim.keymap.set('n', '<leader>sq', fzf.quickfix, { desc = '[S]earch [Q]uickfix' })

    -- LSP mappings with custom cwd to show paths relative to monorepo root
    vim.keymap.set('n', '<leader>lr', function()
      fzf.lsp_references({ cwd = get_search_root() })
    end, { desc = '[L]SP [R]eferences' })
    vim.keymap.set('n', '<leader>ld', function()
      fzf.lsp_definitions({ cwd = get_search_root() })
    end, { desc = '[L]SP [D]efinitions' })
    vim.keymap.set('n', '<leader>li', function()
      fzf.lsp_implementations({ cwd = get_search_root() })
    end, { desc = '[L]SP [I]mplementations' })
    vim.keymap.set('n', '<leader>ls', fzf.lsp_document_symbols, { desc = '[L]SP Document [S]ymbols' })
    vim.keymap.set('n', '<leader>lw', fzf.lsp_workspace_symbols, { desc = '[L]SP [W]orkspace Symbols' })
  end,
}
