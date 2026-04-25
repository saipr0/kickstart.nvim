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

    -- ── mini.icons — icon provider (replaces nvim-web-devicons) ──
    local icons = require 'mini.icons'
    icons.setup()
    icons.mock_nvim_web_devicons() -- make everything that uses nvim-web-devicons use mini.icons

    -- ── mini.notify — clean notification popups ──
    require('mini.notify').setup {
      window = {
        config = {
          border = 'rounded',
        },
        winblend = 0,
      },
    }
    vim.notify = MiniNotify.make_notify()

    -- Filter out noisy LSP messages
    local _notify = vim.notify
    vim.notify = function(msg, ...)
      if type(msg) == 'string' and msg:match 'cannot load such file' then return end
      return _notify(msg, ...)
    end

    -- ── mini.hipatterns — highlight patterns inline ──
    local hipatterns = require 'mini.hipatterns'
    hipatterns.setup {
      highlighters = {
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
        todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
        note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    -- ── mini.cursorword — highlight word under cursor ──
    require('mini.cursorword').setup()

    -- ── mini.jump — better f/t with highlights ──
    -- Disable ; and , keymaps so we can use ; for cmdline
    require('mini.jump').setup {
      mappings = {
        repeat_jump = '', -- Disable ; (we use it for :)
      },
    }

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
    -- NOTE: query is a table of single-character strings, e.g. {'s','h','o','w',' ','t','r','a','c','k'}
    local function match_unordered(stritems, inds, query)
      -- Split query characters into groups separated by spaces
      local words = {}
      local current_word = {}
      for _, char in ipairs(query) do
        if char == ' ' then
          if #current_word > 0 then
            table.insert(words, current_word)
            current_word = {}
          end
        else
          table.insert(current_word, char)
        end
      end
      if #current_word > 0 then
        table.insert(words, current_word)
      end

      -- If no spaces, fall back to default matching (single word = normal fuzzy)
      if #words <= 1 then
        return pick.default_match(stritems, inds, query, { sync = true })
      end

      -- For each word group, narrow down indices using default fuzzy match
      local result_inds = inds
      for _, word_chars in ipairs(words) do
        result_inds = pick.default_match(stritems, result_inds, word_chars, { sync = true })
        if #result_inds == 0 then return {} end
      end
      return result_inds
    end

    -- Dynamic engine tag colors for cwd subfolders
    -- Define custom highlight groups with explicit colors for consistent appearance
    local function setup_engine_tag_highlights()
      -- Define custom highlight groups with distinct, vibrant colors
      vim.api.nvim_set_hl(0, 'EngineTag1', { fg = '#82aaff' })  -- Blue
      vim.api.nvim_set_hl(0, 'EngineTag2', { fg = '#c3e88d' })  -- Green
      vim.api.nvim_set_hl(0, 'EngineTag3', { fg = '#ffcb6b' })  -- Yellow
      vim.api.nvim_set_hl(0, 'EngineTag4', { fg = '#f07178' })  -- Red
      vim.api.nvim_set_hl(0, 'EngineTag5', { fg = '#c792ea' })  -- Purple
      vim.api.nvim_set_hl(0, 'EngineTag6', { fg = '#89ddff' })  -- Cyan
      vim.api.nvim_set_hl(0, 'EngineTag7', { fg = '#f78c6c' })  -- Orange
      vim.api.nvim_set_hl(0, 'EngineTag8', { fg = '#ff5370' })  -- Pink
      vim.api.nvim_set_hl(0, 'EngineTag9', { fg = '#80cbc4' })  -- Teal
      vim.api.nvim_set_hl(0, 'EngineTag10', { fg = '#a5d6ff' }) -- Light Blue
      vim.api.nvim_set_hl(0, 'EngineTag11', { fg = '#7fdbca' }) -- Aqua
      vim.api.nvim_set_hl(0, 'EngineTag12', { fg = '#ffc777' }) -- Gold
      vim.api.nvim_set_hl(0, 'EngineTag13', { fg = '#c099ff' }) -- Lavender
      vim.api.nvim_set_hl(0, 'EngineTag14', { fg = '#ff757f' }) -- Coral
      vim.api.nvim_set_hl(0, 'EngineTag15', { fg = '#4fd6be' }) -- Mint
      vim.api.nvim_set_hl(0, 'EngineTag16', { fg = '#bb9af7' }) -- Violet
      vim.api.nvim_set_hl(0, 'EngineTag17', { fg = '#9ece6a' }) -- Lime
      vim.api.nvim_set_hl(0, 'EngineTag18', { fg = '#e0af68' }) -- Amber
      vim.api.nvim_set_hl(0, 'EngineTag19', { fg = '#7aa2f7' }) -- Sky Blue
      vim.api.nvim_set_hl(0, 'EngineTag20', { fg = '#f7768e' }) -- Rose
    end

    -- Call this after colorscheme loads
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = setup_engine_tag_highlights,
    })
    setup_engine_tag_highlights() -- Set up now too

    local color_palette = {
      'EngineTag1', 'EngineTag2', 'EngineTag3', 'EngineTag4', 'EngineTag5',
      'EngineTag6', 'EngineTag7', 'EngineTag8', 'EngineTag9', 'EngineTag10',
      'EngineTag11', 'EngineTag12', 'EngineTag13', 'EngineTag14', 'EngineTag15',
      'EngineTag16', 'EngineTag17', 'EngineTag18', 'EngineTag19', 'EngineTag20',
    }

    local engine_colors = nil -- lazily built on first use

    -- Simple hash function for strings
    local function hash_string(str)
      local hash = 0
      for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2147483647
      end
      return hash
    end

    local function build_engine_colors()
      if engine_colors then return engine_colors end
      engine_colors = {}
      local root = vim.fn.getcwd()
      local handle = vim.uv.fs_scandir(root)
      if not handle then return engine_colors end

      local dirs = {}
      while true do
        local name, typ = vim.uv.fs_scandir_next(handle)
        if not name then break end
        if typ == 'directory' and not name:match '^%.' then
          table.insert(dirs, name)
        end
      end

      -- Use hash-based assignment instead of sequential
      for _, dir in ipairs(dirs) do
        local hash = hash_string(dir)
        local color_idx = (hash % #color_palette) + 1
        engine_colors[dir] = color_palette[color_idx]
      end
      return engine_colors
    end

    -- Extract engine name from path (first folder in monorepo-relative path)
    local function get_engine_name(dir)
      return dir:match '^([^/]+)' or ''
    end

    -- Custom show: icon + filename left, [engine] + path right-aligned
    -- e.g. " show.html.erb                [track]  app/views/core/assets"
    local function show_filename_first(buf_id, items, query)
      local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
      local win_id = vim.api.nvim_get_current_win()
      local win_width = vim.api.nvim_win_get_width(win_id)
      local ns = vim.api.nvim_create_namespace 'mini_pick_filename_first'

      local lines = {}
      local highlights = {} -- store highlight info per line
      local colors = build_engine_colors()

      for _, item in ipairs(items) do
        local str = type(item) == 'table' and (item.text or item.path or vim.inspect(item)) or tostring(item)
        local filename = vim.fn.fnamemodify(str, ':t')
        local dir = vim.fn.fnamemodify(str, ':h')
        if dir == '.' then dir = '' end

        -- File icon
        local icon = ''
        local icon_hl = nil
        if has_devicons and vim.g.have_nerd_font then
          local ext = vim.fn.fnamemodify(filename, ':e')
          icon, icon_hl = devicons.get_icon(filename, ext, { default = true })
          icon = icon and (icon .. ' ') or ''
        end

        -- Engine tag
        local engine = get_engine_name(dir)
        local tag = ''
        local rest_dir = dir
        if engine ~= '' and colors[engine] then
          tag = '[' .. engine .. ']'
          -- Remove engine prefix from dir to avoid repetition
          rest_dir = dir:sub(#engine + 2) -- +2 for the "/"
          if rest_dir == '' then rest_dir = '' end
        end

        -- Build line: "icon filename ... [tag]  rest/of/path"
        local right = tag ~= '' and (tag .. '  ' .. rest_dir) or dir
        local left = icon .. filename
        local padding = win_width - #left - #right - 4
        if padding < 2 then padding = 2 end

        table.insert(lines, left .. string.rep(' ', padding) .. right)
        table.insert(highlights, {
          icon_len = #icon,
          icon_hl = icon_hl,
          filename_len = #filename,
          left_len = #left,
          tag = tag,
          tag_start = #left + padding,
          engine = engine,
        })
      end

      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)

      for i, hl in ipairs(highlights) do
        local row = i - 1
        -- Icon color
        if hl.icon_hl then
          vim.api.nvim_buf_add_highlight(buf_id, ns, hl.icon_hl, row, 0, hl.icon_len)
        end
        -- Dim everything after filename
        vim.api.nvim_buf_add_highlight(buf_id, ns, 'Comment', row, hl.left_len, -1)
        -- Engine tag color (override the Comment dim)
        if hl.tag ~= '' then
          local tag_hl = colors[hl.engine] or 'Comment'
          vim.api.nvim_buf_add_highlight(buf_id, ns, tag_hl, row, hl.tag_start, hl.tag_start + #hl.tag)
        end
      end
    end

    pick.setup {
      mappings = {
        choose_marked = '<C-q>',
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

    -- ── Search keymaps ─────────────────────────────────────
    vim.keymap.set('n', '<leader>sh', function() MiniExtra.pickers.hl_groups() end, { desc = '[S]earch [H]ighlight groups' })
    vim.keymap.set('n', '<leader>sc', function() MiniExtra.pickers.colorschemes() end, { desc = '[S]earch [C]olorscheme' })
    vim.keymap.set('n', '<leader>sk', function() MiniExtra.pickers.keymaps() end, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', function()
      pick.builtin.files({}, { source = { show = show_filename_first } })
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
          ['Files'] = function() pick.builtin.files({}, { source = { show = show_filename_first } }) end,
          ['Grep live'] = function() pick.builtin.grep_live() end,
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
      pick.builtin.grep({ pattern = vim.fn.expand '<cword>' })
    end, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function()
      pick.builtin.grep_live()
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
      pick.builtin.files({}, { source = { cwd = vim.fn.stdpath 'config', show = show_filename_first } })
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
