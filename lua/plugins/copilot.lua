return {
  'github/copilot.vim',
  config = function()
    local function toggle_copilot()
      if vim.g.copilot_enabled == false or vim.g.copilot_enabled == nil then
        vim.cmd 'Copilot enable'
        vim.g.copilot_enabled = true
        print 'Copilot enabled'
      else
        vim.cmd 'Copilot disable'
        vim.g.copilot_enabled = false
        print 'Copilot disabled'
      end
    end
    vim.keymap.set({ 'n', 'i' }, '<F12>', toggle_copilot, { desc = 'Toggle Copilot' })
  end,
}
