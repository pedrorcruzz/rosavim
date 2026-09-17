--- Shared machinery for the RosaAI and Rosaterm title-chip bars.
--- Module-level functions are stateless utilities; `new()` builds one bar
--- instance owning its extmark namespace, tracked windows and clock timer.
local M = {}

local api = vim.api

--- Clock glyph used by the banner layouts.
M.CLOCK = '󰥔'

--- Format a numeric highlight color as '#rrggbb', or nil when unset.
function M.hex(n)
  if not n then
    return nil
  end
  return string.format('#%06x', n)
end

--- Current wall-clock time as hh:mm (what the chip clock shows).
function M.get_time()
  return os.date '%H:%M'
end

--- Read a toggle value, falling back to `default` when the toggles module
--- is unavailable or the key is unset.
function M.toggle(key, default)
  local ok, toggles = pcall(require, 'rosavim.config.toggles')
  if not ok then
    return default
  end
  local v = toggles.get(key)
  if v == nil then
    return default
  end
  return v
end

--- Concatenate the plain text of a { text, hl_group } segment list.
function M.segs_text(segs)
  local s = ''
  for _, seg in ipairs(segs) do
    s = s .. seg[1]
  end
  return s
end

--- Create one bar instance. `opts.ns` names the extmark namespace.
function M.new(opts)
  local bar = {
    ns = api.nvim_create_namespace(opts.ns),
    tracked = {}, -- win -> { buf, refresh, ... }
    timer = nil,
  }

  --- Apply segment highlights as extmarks over row `row` of `buf`.
  function bar.apply_segs(buf, row, segs)
    local col = 0
    for _, seg in ipairs(segs) do
      local end_col = col + #seg[1]
      api.nvim_buf_set_extmark(buf, bar.ns, row, col, {
        end_row = row,
        end_col = end_col,
        hl_group = seg[2],
      })
      col = end_col
    end
  end

  --- Clear all of this bar's extmarks from `buf`.
  function bar.clear(buf)
    api.nvim_buf_clear_namespace(buf, bar.ns, 0, -1)
  end

  --- Replace the buffer content with the segments' plain text on row 0
  --- and highlight it -- the single-line chip case both bars share.
  function bar.write_line(buf, segs)
    api.nvim_buf_set_lines(buf, 0, -1, false, { M.segs_text(segs) })
    bar.apply_segs(buf, 0, segs)
  end

  --- Start the shared clock timer for this bar if it is not running.
  --- The first tick lands on the next minute boundary; the clock only
  --- shows minutes, so a 60s interval from there keeps it exact. The
  --- timer stops itself once no tracked window is valid anymore.
  local function ensure_timer()
    if bar.timer then
      return
    end
    bar.timer = vim.uv.new_timer()
    local delay = (60 - os.time() % 60) * 1000
    bar.timer:start(
      delay,
      60000,
      vim.schedule_wrap(function()
        local any = false
        for win, info in pairs(bar.tracked) do
          if api.nvim_win_is_valid(win) then
            any = true
            if info.refresh then
              info.refresh()
            end
          else
            bar.tracked[win] = nil
          end
        end
        if not any then
          bar.stop_timer()
        end
      end)
    )
  end

  function bar.stop_timer()
    if bar.timer then
      pcall(function()
        bar.timer:stop()
        bar.timer:close()
      end)
      bar.timer = nil
    end
  end

  --- Track a window (info must carry `refresh`) and keep the timer alive.
  function bar.track(win, info)
    bar.tracked[win] = info
    ensure_timer()
  end

  function bar.untrack(win)
    bar.tracked[win] = nil
  end

  return bar
end

return M
