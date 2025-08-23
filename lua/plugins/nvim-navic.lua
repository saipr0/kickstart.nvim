return {
  'SmiteshP/nvim-navic',
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  config = function()
    require('nvim-navic').setup {
      lsp = {
        auto_attach = true,
      },
      highlight = true,
      separator = ' > ',
      depth_limit = 0,
      depth_limit_indicator = '..',
    }
    -- Make winbar transparent
    vim.api.nvim_set_hl(0, 'WinBar', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'WinBarNC', { bg = 'NONE' })

    -- Clear navic highlight backgrounds
    local navic_highlights = {
      'NavicIconsFile',
      'NavicIconsModule',
      'NavicIconsNamespace',
      'NavicIconsPackage',
      'NavicIconsClass',
      'NavicIconsMethod',
      'NavicIconsProperty',
      'NavicIconsField',
      'NavicIconsConstructor',
      'NavicIconsEnum',
      'NavicIconsInterface',
      'NavicIconsFunction',
      'NavicIconsVariable',
      'NavicIconsConstant',
      'NavicIconsString',
      'NavicIconsNumber',
      'NavicIconsBoolean',
      'NavicIconsArray',
      'NavicIconsObject',
      'NavicIconsKey',
      'NavicIconsNull',
      'NavicIconsEnumMember',
      'NavicIconsStruct',
      'NavicIconsEvent',
      'NavicIconsOperator',
      'NavicIconsTypeParameter',
      'NavicText',
      'NavicSeparator',
    }

    for _, group in ipairs(navic_highlights) do
      local hl = vim.api.nvim_get_hl(0, { name = group })
      if hl then
        hl.bg = nil -- Remove background only
        vim.api.nvim_set_hl(0, group, hl)
      end
    end
  end,
}
