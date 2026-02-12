return { -- Collection of various small independent plugins/modulesmini
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
    -- Disable mini.diff entirely to avoid keymap conflicts
    -- require('mini.diff').setup()

    require('mini.pairs').setup {
      modes = { insert = true, command = false, terminal = false }, -- Disable command mode to avoid bracket conflicts
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { 'string' },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    }

    -- File explorer
    require('mini.files').setup {
      mappings = {
        go_in = 'l',
        go_in_plus = '<CR>',
        go_out = 'H',
        go_out_plus = 'h',
        reset = '<BS>',
        reveal_cwd = '.',
        show_help = 'g?',
        synchronize = 's',
        trim_left = '<',
        trim_right = '>',
      },

      windows = {
        preview = true,
        width_focus = 30,
        width_nofocus = 10,
        width_preview = 100,
      },

      options = {
        permanent_delete = false,
        use_as_default_explorer = true,
      },
    }

    -- Fix background color
    vim.api.nvim_set_hl(0, 'MiniFilesNormal', {
      bg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg or 'NONE',
    })
    vim.api.nvim_set_hl(0, 'MiniFilesBorder', {
      bg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg or 'NONE',
    })

    vim.keymap.set('n', '<leader>e', function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      local dir_name = vim.fn.fnamemodify(buf_name, ':p:h')

      if vim.fn.filereadable(buf_name) == 1 then
        require('mini.files').open(buf_name, true)
      elseif vim.fn.isdirectory(dir_name) == 1 then
        require('mini.files').open(dir_name, true)
      else
        require('mini.files').open(vim.uv.cwd(), true)
      end
    end, { noremap = true, silent = true, desc = 'MiniFiles (smart open)' })

    vim.keymap.set('n', '<leader>E', function()
      require('mini.files').open(vim.uv.cwd(), true)
    end, { noremap = true, silent = true, desc = 'MiniFiles (cwd)' })

    vim.keymap.set('n', '<Esc>', ':lua MiniFiles.close()<CR>', { noremap = true, silent = true, desc = 'Close MiniFiles' })

    local statusline = require 'mini.statusline'
    statusline.setup {
      use_icons = vim.g.have_nerd_font,
      set_vim_settings = false,
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
          local git = MiniStatusline.section_git { trunc_width = 40 }
          local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
          local location = MiniStatusline.section_location { trunc_width = 75 }

          local function get_modified_indicator()
            if vim.bo.modified then
              return vim.g.have_nerd_font and ' ●' or ' [+]'
            end
            return ''
          end

          -- Custom function to get just the file icon
          local function get_file_icon()
            local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
            if has_devicons and vim.g.have_nerd_font then
              local name = vim.fn.expand '%:t'
              local ext = vim.fn.expand '%:e'
              local icon = devicons.get_icon(name, ext, { default = true })
              return icon and (icon .. ' ') or ''
            end
            return ''
          end

          -- Custom function to get just filename
          local function get_filename()
            return vim.fn.expand '%:t'
          end

          return MiniStatusline.combine_groups {
            { hl = 'Normal', strings = { '  ' .. get_file_icon() .. get_filename() .. get_modified_indicator() } },
            '%=', -- End left alignment
            { hl = 'Normal', strings = { git, diagnostics } },
            { hl = 'Normal', strings = { location .. '  ' } },
          }
        end,
      },
    }
    
    vim.o.statusline = "%!v:lua.MiniStatusline.active()"
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%l:%L'
    end

    -- Indent scope visualization
    require('mini.indentscope').setup {
      draw = {
        delay = 0,
        animation = require('mini.indentscope').gen_animation.none(),
      },
    }

    -- Tabline that shows buffers as tabs
    -- require('mini.tabline').setup {
    --   -- Whether to show file icons (requires 'nvim-web-devicons')
    --   show_icons = vim.g.have_nerd_font,
    --   -- Function which formats the tab label
    --   -- Arguments: `buf_id`, `label`
    --   format = nil,
    --   -- Whether to set Vim's settings for tabline (make 'tabline' and
    --   -- 'showtabline' to be handled by this module). Set to `false` if you want
    --   -- to control this manually.
    --   set_vim_settings = true,
    --   -- Where to show tabpage section in case of multiple vim tabpages.
    --   -- One of 'left', 'right', 'none'.
    --   tabpage_section = 'right',
    -- }

    -- Buffer removal that handles edge cases properly
    require('mini.bufremove').setup()

    -- =============================================
    -- mini.pick — fuzzy finder (replaces fzf-lua)
    -- =============================================
    local pick = require 'mini.pick'

    -- Custom match function: spaces act as AND filters (order-independent)
    -- Typing "show track" matches the same as "track show"
    -- Each space-separated word is fuzzy matched independently
    local function match_unordered(stritems, inds, query)
      -- Split query on spaces into separate words
      local words = {}
      for word in query:gmatch '%S+' do
        table.insert(words, word)
      end
      if #words == 0 then return inds end

      -- For each word, get matching indices using default fuzzy
      local result_inds = inds
      for _, word in ipairs(words) do
        result_inds = pick.default_match(stritems, result_inds, word)
        if #result_inds == 0 then return {} end
      end
      return result_inds
    end

    pick.setup {
      mappings = {
        choose_marked = '<C-q>', -- Send marked items to quickfix (like ctrl-q in fzf-lua)
        mark = '<Tab>',
        mark_all = '<C-a>',
        toggle_preview = '<C-p>',
      },
      source = {
        match = match_unordered,
      },
      options = {
        use_cache = true,
      },
      window = {
        prompt_prefix = '❯ ',
        config = {
          border = 'rounded',
        },
      },
    }

    -- Make mini.pick the default vim.ui.select
    vim.ui.select = pick.ui_select

    -- mini.extra — additional pickers (keymaps, marks, diagnostics, colorschemes, etc.)
    require('mini.extra').setup()

    -- Helper function to get the monorepo root if we're in one
    -- You open neovim from fulcrum/, this bumps search up to tagntrac-infra/
    -- so you can find files across all engines
    local function get_search_root()
      local cwd = vim.fn.getcwd()
      if cwd:match '/tagntrac%-infra/fulcrum' then
        return cwd:match '(.*/tagntrac%-infra)'
      end
      return cwd
    end

    -- ── Search keymaps ─────────────────────────────────────
    vim.keymap.set('n', '<leader>sh', function() MiniExtra.pickers.hl_groups() end, { desc = '[S]earch [H]ighlight groups' })
    vim.keymap.set('n', '<leader>sc', function() MiniExtra.pickers.colorschemes() end, { desc = '[S]earch [C]olorscheme' })
    vim.keymap.set('n', '<leader>sk', function() MiniExtra.pickers.keymaps() end, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', function()
      pick.builtin.files({}, { source = { cwd = get_search_root() } })
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', function()
      local items = {
        'Files', 'Grep live', 'Buffers', 'Help', 'Keymaps', 'Colorschemes',
        'Diagnostics', 'Marks', 'Oldfiles', 'Resume', 'LSP references',
        'LSP definitions', 'LSP symbols', 'LSP workspace symbols',
        'Git commits', 'Git branches', 'Registers', 'Commands',
        'Explorer', 'Treesitter', 'Quickfix', 'Jumps',
      }
      vim.ui.select(items, { prompt = 'Pick a picker:' }, function(choice)
        if not choice then return end
        local map = {
          ['Files'] = function() pick.builtin.files({}, { source = { cwd = get_search_root() } }) end,
          ['Grep live'] = function() pick.builtin.grep_live({}, { source = { cwd = get_search_root() } }) end,
          ['Buffers'] = pick.builtin.buffers,
          ['Help'] = pick.builtin.help,
          ['Keymaps'] = MiniExtra.pickers.keymaps,
          ['Colorschemes'] = MiniExtra.pickers.colorschemes,
          ['Diagnostics'] = MiniExtra.pickers.diagnostic,
          ['Marks'] = MiniExtra.pickers.marks,
          ['Oldfiles'] = MiniExtra.pickers.oldfiles,
          ['Resume'] = pick.builtin.resume,
          ['LSP references'] = function() MiniExtra.pickers.lsp { scope = 'references' } end,
          ['LSP definitions'] = function() MiniExtra.pickers.lsp { scope = 'definition' } end,
          ['LSP symbols'] = function() MiniExtra.pickers.lsp { scope = 'document_symbol' } end,
          ['LSP workspace symbols'] = function() MiniExtra.pickers.lsp { scope = 'workspace_symbol' } end,
          ['Git commits'] = MiniExtra.pickers.git_commits,
          ['Git branches'] = MiniExtra.pickers.git_branches,
          ['Registers'] = MiniExtra.pickers.registers,
          ['Commands'] = MiniExtra.pickers.commands,
          ['Explorer'] = MiniExtra.pickers.explorer,
          ['Treesitter'] = MiniExtra.pickers.treesitter,
          ['Quickfix'] = function() MiniExtra.pickers.list { scope = 'quickfix' } end,
          ['Jumps'] = function() MiniExtra.pickers.list { scope = 'jump' } end,
        }
        if map[choice] then map[choice]() end
      end)
    end, { desc = '[S]earch [S]elect picker' })
    vim.keymap.set('n', '<leader>sw', function()
      pick.builtin.grep({ pattern = vim.fn.expand '<cword>' }, { source = { cwd = get_search_root() } })
    end, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function()
      pick.builtin.grep_live({}, { source = { cwd = get_search_root() } })
    end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', function()
      MiniExtra.pickers.diagnostic { scope = 'current' }
    end, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', pick.builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', function() MiniExtra.pickers.oldfiles() end, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', pick.builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', function()
      MiniExtra.pickers.buf_lines { scope = 'current' }
    end, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>s/', function()
      -- Search across all open buffer lines
      MiniExtra.pickers.buf_lines { scope = 'all' }
    end, { desc = '[S]earch [/] in Open Files' })
    vim.keymap.set('n', '<leader>sn', function()
      pick.builtin.files({}, { source = { cwd = vim.fn.stdpath 'config' } })
    end, { desc = '[S]earch [N]eovim files' })
    vim.keymap.set('n', '<leader>st', function() MiniExtra.pickers.treesitter() end, { desc = '[S]earch [T]reesitter nodes' })
    vim.keymap.set('n', '<leader>sm', function() MiniExtra.pickers.marks() end, { desc = '[S]earch [M]arks' })
    vim.keymap.set('n', '<leader>sj', function() MiniExtra.pickers.list { scope = 'jump' } end, { desc = '[S]earch [J]umps' })
    vim.keymap.set('n', '<leader>sq', function() MiniExtra.pickers.list { scope = 'quickfix' } end, { desc = '[S]earch [Q]uickfix' })
    vim.keymap.set('n', '<leader>sH', function() pick.builtin.help() end, { desc = '[S]earch [H]elp tags' })

    -- ── LSP keymaps via mini.pick ──────────────────────────
    vim.keymap.set('n', '<leader>lr', function()
      MiniExtra.pickers.lsp({ scope = 'references' })
    end, { desc = '[L]SP [R]eferences' })
    vim.keymap.set('n', '<leader>ld', function()
      MiniExtra.pickers.lsp({ scope = 'definition' })
    end, { desc = '[L]SP [D]efinitions' })
    vim.keymap.set('n', '<leader>li', function()
      MiniExtra.pickers.lsp({ scope = 'implementation' })
    end, { desc = '[L]SP [I]mplementations' })
    vim.keymap.set('n', '<leader>ls', function()
      MiniExtra.pickers.lsp({ scope = 'document_symbol' })
    end, { desc = '[L]SP Document [S]ymbols' })
    vim.keymap.set('n', '<leader>lw', function()
      MiniExtra.pickers.lsp({ scope = 'workspace_symbol' })
    end, { desc = '[L]SP [W]orkspace Symbols' })
  end,
}
