--- RosaAI snapshot - Git-baseline backend for reviewing AI changes
--- Captures a snapshot of the working tree BEFORE the AI edits so a later
--- diff shows exactly what the AI touched. HEAD is unusable as a baseline
--- here: the git worktree spans the whole ~/.dotfiles tree and commits are
--- manual and infrequent. Instead we use `git stash create`, which prints a
--- dangling commit SHA capturing the current index + working tree WITHOUT
--- modifying the index, the working tree, or the stash list. On a clean tree
--- it prints nothing, so we fall back to the HEAD SHA — that way current()
--- always returns a valid ref once a baseline has been captured.
---
--- The review is git-based on purpose (git is opt-in): outside a repository
--- this module stays SILENT and simply reports nil. The user-facing "you need
--- a git repo" message is the review layer's job, shown only when the user
--- actually tries to use the review.
local M = {}

local fn = vim.fn

local root_cache = nil -- cached absolute path of the git worktree root
local baseline = nil -- active baseline commit SHA, or nil
local ai_content = nil -- map abs path -> lines, the AI's result frozen at turn end

--- Trim surrounding whitespace/newlines from git output; nil-safe.
local function trim(s)
  if type(s) ~= 'string' then
    return nil
  end
  s = s:gsub('%s+$', ''):gsub('^%s+', '')
  if s == '' then
    return nil
  end
  return s
end

--- Run a git command asynchronously at the repo root and hand its trimmed
--- stdout (or nil on failure/empty) to `done`. Guarded so a failure never
--- crashes the editor. `use_root` controls whether cwd is pinned to the
--- worktree root (repo_root discovery itself must not require it). Silent
--- outside a repo — callers decide whether to surface a message.
local function git(args, done, use_root)
  local opts = { text = true }
  if use_root ~= false then
    local root = M.repo_root()
    if not root then
      done(nil)
      return
    end
    opts.cwd = root
  end
  local ok = pcall(vim.system, args, opts, function(res)
    if res and res.code == 0 then
      done(trim(res.stdout))
    else
      done(nil)
    end
  end)
  if not ok then
    done(nil)
  end
end

--- Cached absolute path of the git worktree root, discovered once via
--- `git rev-parse --show-toplevel`. Re-discovers if the cache is nil.
--- Returns nil when the editor's cwd is not inside a git repository.
function M.repo_root()
  if root_cache then
    return root_cache
  end
  local ok, out = pcall(fn.systemlist, { 'git', 'rev-parse', '--show-toplevel' })
  if ok and vim.v.shell_error == 0 and out and out[1] and out[1] ~= '' then
    root_cache = out[1]
    return root_cache
  end
  return nil
end

--- Whether the editor is currently inside a git repository.
function M.has_git()
  return M.repo_root() ~= nil
end

--- The active baseline commit SHA, or nil if none is set.
function M.current()
  return baseline
end

--- Capture a fresh baseline: `git stash create` snapshots the working tree +
--- index without side effects. On a clean tree it returns nothing, so fall
--- back to the HEAD SHA. Calls `cb(sha|nil)` (optional) when done. Async.
--- Silent outside a repo (cb(nil)).
local function capture(cb)
  cb = cb or function() end
  if not M.repo_root() then
    cb(nil)
    return
  end
  -- A fresh baseline starts a new AI cycle, so any frozen AI result is stale.
  ai_content = nil
  git({ 'git', 'stash', 'create' }, function(sha)
    if sha then
      baseline = sha
      cb(sha)
      return
    end
    -- Clean tree: stash create produced nothing, use HEAD as the baseline.
    git({ 'git', 'rev-parse', 'HEAD' }, function(head)
      baseline = head
      cb(head)
    end)
  end)
end

--- Ensure a baseline exists: if one is already active, keep it; otherwise
--- capture one now. `cb` optional, called with (sha|nil). Async-safe.
function M.ensure(cb)
  cb = cb or function() end
  if baseline then
    cb(baseline)
    return
  end
  capture(cb)
end

--- Always capture a fresh baseline now, replacing any existing one.
--- `cb` optional, called with (sha|nil). Async-safe.
function M.mark(cb)
  capture(cb)
end

--- Drop the active baseline (set it to nil).
function M.clear()
  baseline = nil
end

--- cb(list) with `{ path = <abs>, new = <bool> }` for every file differing
--- between `base` (any git ref) and the working tree: tracked changes plus
--- untracked new files (new=true). De-duped, existing regular files only.
local function changed_vs(base, cb)
  cb = cb or function() end
  local root = M.repo_root()
  if not base or not root then
    cb({})
    return
  end

  local seen = {} -- relative path -> true, for de-duplication
  local list = {} -- { { path = abs, new = bool }, ... }

  local function collect(out, new)
    if not out then
      return
    end
    for line in out:gmatch '[^\r\n]+' do
      local rel = trim(line)
      if rel and not seen[rel] then
        seen[rel] = true
        local abs = root .. '/' .. rel
        -- Keep only paths that currently exist as regular files.
        if fn.filereadable(abs) == 1 then
          list[#list + 1] = { path = abs, new = new }
        end
      end
    end
  end

  -- Tracked changes vs the base ref, then untracked new files.
  git({ 'git', 'diff', '--name-only', base, '--' }, function(diff_out)
    collect(diff_out, false)
    git({ 'git', 'ls-files', '--others', '--exclude-standard' }, function(others_out)
      collect(others_out, true)
      vim.schedule(function()
        cb(list)
      end)
    end)
  end)
end

--- Changed files vs the active AI baseline (RosaAI Review). cb({}) with none.
function M.changed_files(cb)
  changed_vs(baseline, cb)
end

--- Changed files vs an arbitrary git ref (e.g. 'HEAD' for the Git Review).
function M.changed_files_vs(base, cb)
  changed_vs(base, cb)
end

--- Drop the frozen AI result.
function M.clear_ai()
  ai_content = nil
end

--- The AI-result lines captured for `path`, or nil if none was frozen.
function M.ai_content_of(path)
  return ai_content and ai_content[path] or nil
end

--- Set of absolute paths the AI touched (frozen at the last capture_ai).
function M.ai_paths()
  local set = {}
  if ai_content then
    for p in pairs(ai_content) do
      set[p] = true
    end
  end
  return set
end

--- Freeze the AI's result: read from disk the current content of every file
--- changed vs the baseline (so untracked new files are captured too). Called
--- at the AI-turn boundary, before the user edits. Replaces prior capture.
function M.capture_ai(cb)
  cb = cb or function() end
  if not baseline or not M.repo_root() then
    cb(nil)
    return
  end
  M.changed_files(function(files)
    local map = {}
    for _, f in ipairs(files) do
      local ok, lines = pcall(fn.readfile, f.path)
      if ok and lines then
        map[f.path] = lines
      end
    end
    ai_content = map
    cb(map)
  end)
end

return M
