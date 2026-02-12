return {
  'kawre/leetcode.nvim',
  build = ':TSUpdate html',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-treesitter/nvim-treesitter',
    {
      '3rd/image.nvim',
      opts = {
        backend = 'kitty',
        processor = 'magick_cli',
        integrations = {
          markdown = {
            enabled = true,
            download_remote_images = true,
          },
        },
        -- Enable auto-clearing when switching windows
        -- window_overlap_clear_enabled = true,
        -- editor_only_render_when_focused = true,
      },
    },
  },
  opts = {
    -- Use your preferred language (default is cpp)
    lang = 'ruby',

    -- Enable image support
    image_support = true,

    -- Hooks to disable LSP when entering leetcode
    hooks = {
      enter = {
        function()
          -- Create autocommand to stop LSP on buffer enter
          vim.api.nvim_create_autocmd({ 'BufEnter', 'LspAttach' }, {
            group = vim.api.nvim_create_augroup('LeetCodeDisableLSP', { clear = true }),
            callback = function(args)
              -- Check if we're in a leetcode buffer
              local bufname = vim.api.nvim_buf_get_name(args.buf)
              if bufname:match 'leetcode' then
                vim.schedule(function()
                  for _, client in pairs(vim.lsp.get_clients { bufnr = args.buf }) do
                    vim.lsp.stop_client(client.id, true)
                  end
                end)
              end
            end,
          })
        end,
      },
    },
  },
}
