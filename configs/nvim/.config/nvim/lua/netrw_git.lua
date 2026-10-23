-- Git status signs in netrw listings. netrw has no git integration, so this
-- runs `git status` for the listed directory and marks each changed entry;
-- a directory gets the strongest status of what it contains.

local ns = vim.api.nvim_create_namespace 'netrw-git'

-- Higher rank wins when several changes roll up into one directory
local statuses = {
  untracked = { rank = 1, text = '?', hl = 'GitSignsUntracked' },
  added = { rank = 2, text = '+', hl = 'GitSignsAdd' },
  modified = { rank = 3, text = '~', hl = 'GitSignsChange' },
  conflict = { rank = 4, text = '!', hl = 'DiagnosticError' },
}

local function classify(xy)
  if xy == '??' then
    return statuses.untracked
  elseif xy:find 'U' or xy == 'AA' or xy == 'DD' then
    return statuses.conflict
  elseif xy:find '[ARC]' then
    return statuses.added
  end
  return statuses.modified
end

-- `git status --porcelain -z` output -> { [top-level entry name] = status }.
-- Paths are relative to the repo root, `prefix` is the listed directory's.
local function parse(output, prefix)
  local changes = {}
  local records = vim.split(output, '\0', { plain = true })
  local i = 1
  while i <= #records do
    local record = records[i]
    if #record > 3 then
      local xy, path = record:sub(1, 2), record:sub(4)
      local status = classify(xy)
      local name = path:sub(#prefix + 1):match '^[^/]+'
      if not changes[name] or status.rank > changes[name].rank then
        changes[name] = status
      end
      -- Renames and copies are followed by their source path
      if xy:find '[RC]' then
        i = i + 1
      end
    end
    i = i + 1
  end
  return changes
end

local function refresh(buf)
  local dir = vim.b[buf].netrw_curdir
  if not dir or vim.fn.isdirectory(dir) == 0 then
    return
  end

  local repo = vim.system({ 'git', 'rev-parse', '--show-prefix' }, { cwd = dir, text = true }):wait()
  if repo.code ~= 0 then
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    return
  end
  local prefix = vim.trim(repo.stdout)

  local cmd = { 'git', '--no-optional-locks', 'status', '--porcelain=v1', '-z', '--', '.' }
  vim.system(
    cmd,
    { cwd = dir, text = true },
    vim.schedule_wrap(function(obj)
      if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].netrw_curdir ~= dir then
        return
      end
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      if obj.code ~= 0 then
        return
      end

      local changes = parse(obj.stdout, prefix)
      for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        -- netrw suffixes directories with /, symlinks with @, executables with *
        local status = changes[line] or changes[line:sub(1, -2)]
        if status then
          vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, { sign_text = status.text, sign_hl_group = status.hl })
        end
      end
    end)
  )
end

vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
  desc = 'Show git status signs in netrw',
  group = vim.api.nvim_create_augroup('netrw-git', { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype == 'netrw' then
      -- netrw sets its filetype before writing the listing: wait for it
      vim.schedule(function()
        refresh(args.buf)
      end)
    end
  end,
})
