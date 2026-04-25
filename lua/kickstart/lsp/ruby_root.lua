local M = {}

function M.find_root(fname)
  if fname:find('/tagntrac%-infra/', 1, true) then
    local monorepo_root = fname:match('(.*/tagntrac%-infra)')
    if monorepo_root then
      local fulcrum_path = monorepo_root .. '/fulcrum'
      local stat = vim.uv.fs_stat(fulcrum_path)
      if stat and stat.type == 'directory' then
        return fulcrum_path
      end
    end
  end

  local util = require 'lspconfig.util'
  return util.root_pattern('Gemfile', '.git')(fname)
end

return M
