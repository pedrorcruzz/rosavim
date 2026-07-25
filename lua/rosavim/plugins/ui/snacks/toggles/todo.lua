local toggles = require 'rosavim.config.toggles'

local function rosatodo()
  return require 'rosavim.rosa_plugins.rosatodo'
end

return function()
  Snacks.toggle({
    name = 'Todo Comments',
    get = function()
      return toggles.get 'todo_comments'
    end,
    set = function(state)
      rosatodo().set_enabled(state)
    end,
  }):map '<leader>lh'

  Snacks.toggle({
    name = 'Todo Background',
    get = function()
      return toggles.get 'todo_comments_bg'
    end,
    set = function(state)
      rosatodo().set_bg(state)
    end,
  }):map '<leader>lqcb'

  Snacks.toggle({
    name = 'Todo Foreground',
    get = function()
      return toggles.get 'todo_comments_fg'
    end,
    set = function(state)
      rosatodo().set_fg(state)
    end,
  }):map '<leader>lqcf'
end
