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
      defaults = {
        file_icons = false, -- Sets default for all pickers
        git_icons = false,
      },
      files = {
        -- Shows "filename.txt path/to/directory" instead of "path/to/directory/filename.txt"
        formatter = 'path.filename_first',
        cwd_prompt = false,
      },
    }

    -- Key mappings - matching your telescope setup
    local fzf = require 'fzf-lua'

    -- Direct equivalents to your telescope mappings
    vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sc', fzf.colorschemes, { desc = '[S]earch [C]olorscheme' })
    vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect fzf-lua' })
    vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
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

    -- LSP mappings (you might want these if you use LSP)
    vim.keymap.set('n', '<leader>lr', fzf.lsp_references, { desc = '[L]SP [R]eferences' })
    vim.keymap.set('n', '<leader>ld', fzf.lsp_definitions, { desc = '[L]SP [D]efinitions' })
    vim.keymap.set('n', '<leader>li', fzf.lsp_implementations, { desc = '[L]SP [I]mplementations' })
    vim.keymap.set('n', '<leader>ls', fzf.lsp_document_symbols, { desc = '[L]SP Document [S]ymbols' })
    vim.keymap.set('n', '<leader>lw', fzf.lsp_workspace_symbols, { desc = '[L]SP [W]orkspace Symbols' })
  end,
}

