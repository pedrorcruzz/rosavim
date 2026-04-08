return {
  'b0o/incline.nvim',
  dependencies = {
    'echasnovski/mini.icons',
  },
  event = 'VeryLazy',
  config = function()
    local icons = require 'mini.icons'
    local rosapoon = require 'rosavim.rosa_plugins.rosapoon'
    local toggles = require 'rosavim.config.toggles'

    require('incline').setup {
      hide = { cursorline = true },
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 1 },
        placement = { vertical = 'bottom', horizontal = 'center' },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
          filename = '[No Name]'
        end

        local ft_icon, ft_hl = icons.get('file', filename)

        local modified = vim.bo[props.buf].modified and ' ●' or ''
        local res = {
          ft_icon and { ' ', ft_icon, ' ', guibg = nil, group = ft_hl } or '',
          ' ',
          { filename .. modified, gui = 'bold' },
          ' ',
          ' ',
        }

        local function get_rosapoon_items()
          local tags = rosapoon.tags()
          local current_file_path = vim.fn.expand '%:p'
          local label = {}
          local is_light = vim.o.background == 'light'

          for id, tag in ipairs(tags) do
            if tag == current_file_path then
              table.insert(label, { tostring(id) .. ' ', guifg = is_light and '#000000' or '#FFFFFF', gui = 'bold' })
            else
              table.insert(label, { tostring(id) .. ' ', guifg = is_light and '#a0a0a0' or '#434852' })
            end
          end

          if #label > 0 then
            table.insert(label, 1, { '󰛢 ', guifg = is_light and '#3a3a3a' or '#d4d4d4' })
          end
          return label
        end

        local rosapoon_items = get_rosapoon_items()
        for _, item in ipairs(rosapoon_items) do
          table.insert(res, item)
        end

        return res
      end,
    }

    if not toggles.get 'incline' then
      require('incline').disable()
    end
  end,
  -- Toggle keymap defined in snacks/toggles.lua
}
