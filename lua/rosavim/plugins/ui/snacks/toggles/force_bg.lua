local toggles = require 'rosavim.config.toggles'
local term_bg = require 'rosavim.helpers.term_bg'

local TOOL_KEY = { rosaterm = 'r', rosaai = 'i', yazi = 'y', lazygit = 'g' }

return function()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'yazi',
    callback = function()
      term_bg.define 'yazi'
    end,
  })

  Snacks.toggle({
    name = 'Force Dark Background: All (Light Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return term_bg.all_enabled 'light'
    end,
    set = function(state)
      term_bg.set_all('light', state)
    end,
  }):map '<leader>lqfa'

  Snacks.toggle({
    name = 'Force Dark Background: All (Dark Mode)',
    wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
    get = function()
      return term_bg.all_enabled 'dark'
    end,
    set = function(state)
      term_bg.set_all('dark', state)
    end,
  }):map '<leader>lqfA'

  for _, tool in ipairs(term_bg.order) do
    local spec = term_bg.tools[tool]
    local letter = TOOL_KEY[tool]
    for _, mode in ipairs { 'light', 'dark' } do
      local state_key = term_bg.key(tool, mode)
      Snacks.toggle({
        name = ('%s Dark Background (%s Mode)'):format(spec.name, mode == 'dark' and 'Dark' or 'Light'),
        wk_desc = { enabled = 'Use theme bg ', disabled = 'Force dark bg ' },
        get = function()
          return toggles.get(state_key)
        end,
        set = function(state)
          toggles.set(state_key, state)
          term_bg.refresh_tool(tool)
        end,
      }):map('<leader>lqf' .. (mode == 'dark' and letter:upper() or letter))
    end
  end
end
