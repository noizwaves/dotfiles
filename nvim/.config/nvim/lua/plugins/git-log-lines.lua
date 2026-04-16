-- Extract PR number from commit subject
local function extract_pr_number(subject)
  local pr = subject:match("Merge pull request #(%d+)")
  if pr then return pr end
  pr = subject:match("#(%d+)%)")
  return pr
end

-- Build base PR URL from git remote
local function get_remote_pr_url(git_root)
  local remote = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " remote get-url origin")[1]
  if not remote or remote == "" then return nil end
  local owner, repo = remote:match("github%.com[:/]([^/]+)/([^/%.]+)")
  if not owner then return nil end
  return string.format("https://github.com/%s/%s/pull/", owner, repo)
end

-- Build commit URL from hash
local function get_commit_url(git_root, hash)
  local remote = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " remote get-url origin")[1]
  if not remote or remote == "" then return nil end
  local owner, repo = remote:match("github%.com[:/]([^/]+)/([^/%.]+)")
  if not owner then return nil end
  return string.format("https://github.com/%s/%s/commit/%s", owner, repo, hash)
end

-- Parse git log -L output into structured commits
local function parse_log_output(raw_lines)
  local commits = {}
  local current = nil

  for _, line in ipairs(raw_lines) do
    if line == "COMMIT_SEP" then
      if current then
        table.insert(commits, current)
      end
      current = { hash = "", date = "", author = "", subject = "", pr_number = nil, diff_lines = {} }
    elseif current then
      local hash = line:match("^Hash: (.+)")
      local date = line:match("^Date: (.+)")
      local author = line:match("^Author: (.+)")
      local subject = line:match("^Subject: (.+)")

      if hash then
        current.hash = hash
      elseif date then
        current.date = date
      elseif author then
        current.author = author
      elseif subject then
        current.subject = subject
        current.pr_number = extract_pr_number(subject)
      else
        table.insert(current.diff_lines, line)
      end
    end
  end

  if current then
    table.insert(commits, current)
  end

  -- Trim leading empty lines from each commit's diff
  for _, c in ipairs(commits) do
    while #c.diff_lines > 0 and c.diff_lines[1] == "" do
      table.remove(c.diff_lines, 1)
    end
  end

  return commits
end

-- Define highlight groups (linked to colorscheme groups)
local function setup_highlights()
  vim.api.nvim_set_hl(0, "GitLogDate", { link = "Special", default = true })
  vim.api.nvim_set_hl(0, "GitLogAuthor", { link = "Identifier", default = true })
  vim.api.nvim_set_hl(0, "GitLogSubject", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "GitLogPR", { link = "Type", default = true })
  vim.api.nvim_set_hl(0, "GitLogHelp", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "GitLogHelpKey", { link = "Special", default = true })
end

-- Render commit list into buffer, returns line_to_commit mapping
local function render_commit_list(buf, commits)
  local lines = {}
  local highlights = {} -- { line_idx (0-based), col_start, col_end, hl_group }
  local line_to_commit = {} -- 1-based line number -> commit index
  local commit_first_line = {} -- commit index -> 1-based first line of that block

  for i, c in ipairs(commits) do
    local line1 = c.date .. "  " .. c.author
    local base = #lines

    table.insert(lines, line1)
    table.insert(highlights, { base, 0, #c.date, "GitLogDate" })
    table.insert(highlights, { base, #c.date + 2, #line1, "GitLogAuthor" })

    table.insert(lines, c.subject)
    table.insert(highlights, { base + 1, 0, #c.subject, "GitLogSubject" })

    -- Map content lines to this commit
    line_to_commit[base + 1] = i
    line_to_commit[base + 2] = i
    commit_first_line[i] = base + 1

    -- Blank separator (except after last commit)
    if i < #commits then
      local sep_line = #lines
      table.insert(lines, "")
      line_to_commit[sep_line + 1] = i
    end
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local ns = vim.api.nvim_create_namespace("git_log_lines")
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1], hl[2], hl[3])
  end

  return line_to_commit, commit_first_line
end

-- Update diff preview buffer with a commit's diff
local function update_diff_preview(buf, commit)
  vim.bo[buf].modifiable = true
  if not commit or #commit.diff_lines == 0 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "No diff available for this commit" })
  else
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, commit.diff_lines)
  end
  vim.bo[buf].modifiable = false
end

-- Show/hide help as a floating window anchored to the top of the viewer
local function toggle_help(state)
  if state.help_visible then
    if state.help_win and vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
    end
    if state.help_buf and vim.api.nvim_buf_is_valid(state.help_buf) then
      vim.api.nvim_buf_delete(state.help_buf, { force = true })
    end
    state.help_win = nil
    state.help_buf = nil
    state.help_visible = false
    vim.api.nvim_set_current_win(state.list_win)
    return
  end

  local help_entries = {
    { "j/k", "navigate commits" },
    { "p", "toggle diff preview" },
    { "Enter", "open PR in browser" },
    { "o", "open commit in browser" },
    { "h", "toggle this help" },
    { "Esc", "close" },
  }

  local lines = {}
  local highlights = {}
  for _, entry in ipairs(help_entries) do
    local line = "  " .. entry[1] .. "  " .. entry[2]
    table.insert(lines, line)
    local key_end = 2 + #entry[1]
    table.insert(highlights, { #lines - 1, 2, key_end, "GitLogHelpKey" })
    table.insert(highlights, { #lines - 1, key_end + 2, #line, "GitLogHelp" })
  end

  local help_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[help_buf].buftype = "nofile"
  vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, lines)
  vim.bo[help_buf].modifiable = false

  local ns = vim.api.nvim_create_namespace("git_log_help")
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(help_buf, ns, hl[4], hl[1], hl[2], hl[3])
  end

  -- Position at top of the viewer, spanning its full width
  local help_w = state.inner_w
  local help_h = #lines
  local help_win = vim.api.nvim_open_win(help_buf, false, {
    relative = "editor",
    width = help_w,
    height = help_h,
    col = state.inner_col,
    row = state.inner_row,
    style = "minimal",
    border = { "", "", "", "", "─", "─", "─", "" },
    zindex = 60,
  })

  state.help_buf = help_buf
  state.help_win = help_win
  state.help_visible = true

  -- Keep focus on commit list
  vim.api.nvim_set_current_win(state.list_win)
end

-- Set up cleanup: when list_win closes (by any means), tear down everything else

-- Show or hide the diff preview panel
local function toggle_preview(state)
  if state.preview_visible then
    -- Hide: close diff window and expand commit list to full width
    if state.diff_win and vim.api.nvim_win_is_valid(state.diff_win) then
      vim.api.nvim_win_close(state.diff_win, true)
    end
    state.diff_win = nil
    local full_w = state.inner_w
    vim.api.nvim_win_set_width(state.list_win, full_w)
    state.preview_visible = false
  else
    -- Show: shrink commit list and open diff window
    local list_w = math.floor(state.inner_w * 0.3)
    local diff_w = state.inner_w - list_w - 1
    vim.api.nvim_win_set_width(state.list_win, list_w)

    local diff_buf = state.diff_buf
    if not vim.api.nvim_buf_is_valid(diff_buf) then
      diff_buf = vim.api.nvim_create_buf(false, true)
      vim.bo[diff_buf].buftype = "nofile"
      vim.bo[diff_buf].swapfile = false
      vim.bo[diff_buf].filetype = "diff"
      state.diff_buf = diff_buf
    end

    state.diff_win = vim.api.nvim_open_win(diff_buf, false, {
      relative = "editor",
      width = diff_w,
      height = state.inner_h,
      col = state.inner_col + list_w + 1,
      row = state.inner_row,
      style = "minimal",
      border = { "", "", "", "", "", "", "", "│" },
      zindex = 50,
    })
    vim.wo[state.diff_win].wrap = false

    -- Update with current commit's diff
    local c = state.commits[state.current_commit_idx]
    if c then
      update_diff_preview(diff_buf, c)
    end

    state.preview_visible = true
    -- Keep focus on commit list
    vim.api.nvim_set_current_win(state.list_win)
  end
end

-- Create the viewer layout (starts with commit list only, diff hidden)
local function create_viewer(commits, git_root, rel_path, start_line, end_line)
  setup_highlights()

  local editor_w = vim.o.columns
  local editor_h = vim.o.lines

  -- Backdrop: full screen with border and title
  local backdrop_buf = vim.api.nvim_create_buf(false, true)
  local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative = "editor",
    width = editor_w - 2,
    height = editor_h - 4,
    col = 0,
    row = 0,
    style = "minimal",
    border = "rounded",
    title = " git log -L (line history) ",
    title_pos = "center",
    zindex = 40,
  })

  -- Inner dimensions (inside the backdrop border)
  local inner_w = editor_w - 4
  local inner_h = editor_h - 6
  local inner_col = 1
  local inner_row = 1

  -- Commit list: starts at full width (diff hidden by default)
  local list_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[list_buf].buftype = "nofile"
  vim.bo[list_buf].swapfile = false

  local list_win = vim.api.nvim_open_win(list_buf, true, {
    relative = "editor",
    width = inner_w,
    height = inner_h,
    col = inner_col,
    row = inner_row,
    style = "minimal",
    border = "none",
    zindex = 50,
  })
  vim.wo[list_win].wrap = false
  vim.wo[list_win].cursorline = true

  -- Diff preview buffer (created now, window opened on toggle)
  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[diff_buf].buftype = "nofile"
  vim.bo[diff_buf].swapfile = false
  vim.bo[diff_buf].filetype = "diff"

  local state = {
    backdrop_buf = backdrop_buf,
    backdrop_win = backdrop_win,
    list_buf = list_buf,
    list_win = list_win,
    diff_buf = diff_buf,
    diff_win = nil,
    commits = commits,
    git_root = git_root,
    rel_path = rel_path,
    start_line = start_line,
    end_line = end_line,
    current_commit_idx = 0,
    autocmd_id = nil,
    preview_visible = false,
    help_visible = false,
    inner_w = inner_w,
    inner_h = inner_h,
    inner_col = inner_col,
    inner_row = inner_row,
  }

  -- Render commit list
  local line_to_commit, commit_first_line = render_commit_list(list_buf, commits)
  state.line_to_commit = line_to_commit
  state.commit_first_line = commit_first_line

  -- Select first commit
  if #commits > 0 then
    state.current_commit_idx = 1
    update_diff_preview(diff_buf, commits[1])
  end

  -- Show diff preview by default
  toggle_preview(state)

  -- CursorMoved: update diff when cursor moves to a different commit
  state.autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = list_buf,
    callback = function()
      local cursor_line = vim.api.nvim_win_get_cursor(list_win)[1]
      local idx = line_to_commit[cursor_line]
      if idx and idx ~= state.current_commit_idx then
        state.current_commit_idx = idx
        if state.preview_visible and state.diff_win and vim.api.nvim_win_is_valid(state.diff_win) then
          update_diff_preview(diff_buf, commits[idx])
          vim.api.nvim_win_set_cursor(state.diff_win, { 1, 0 })
        end
      end
    end,
  })

  -- Keybindings

  local pr_base_url = get_remote_pr_url(git_root)

  local function jump_commit(direction)
    local target = state.current_commit_idx + direction
    if target >= 1 and target <= #commits then
      local line = commit_first_line[target]
      if line then
        vim.api.nvim_win_set_cursor(list_win, { line, 0 })
        -- Update state directly — CursorMoved doesn't reliably fire from API calls
        state.current_commit_idx = target
        if state.preview_visible and state.diff_win and vim.api.nvim_win_is_valid(state.diff_win) then
          update_diff_preview(diff_buf, commits[target])
          vim.api.nvim_win_set_cursor(state.diff_win, { 1, 0 })
        end
      end
    end
  end

  local opts = { buffer = list_buf, nowait = true }
  vim.keymap.set("n", "<Esc>", function()
    -- Close all floating windows to ensure full cleanup
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end, opts)
  vim.keymap.set("n", "j", function() jump_commit(1) end, opts)
  vim.keymap.set("n", "k", function() jump_commit(-1) end, opts)
  vim.keymap.set("n", "p", function() toggle_preview(state) end, opts)
  vim.keymap.set("n", "h", function() toggle_help(state) end, opts)

  vim.keymap.set("n", "<CR>", function()
    local c = commits[state.current_commit_idx]
    if not c or not c.pr_number then
      vim.notify("No PR link for this commit", vim.log.levels.INFO)
      return
    end
    if not pr_base_url then
      vim.notify("No remote URL configured", vim.log.levels.WARN)
      return
    end
    vim.ui.open(pr_base_url .. c.pr_number)
  end, opts)

  vim.keymap.set("n", "o", function()
    local c = commits[state.current_commit_idx]
    if not c then return end
    local url = get_commit_url(git_root, c.hash)
    if url then
      vim.ui.open(url)
    else
      vim.notify("No remote URL configured", vim.log.levels.WARN)
    end
  end, opts)

  -- Redirect focus back to commit list if backdrop gets focus
  vim.api.nvim_create_autocmd("WinEnter", {
    buffer = backdrop_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(list_win) then
        vim.api.nvim_set_current_win(list_win)
      end
    end,
  })

  vim.cmd("stopinsert")
  return state
end

return {
  {
    dir = ".",
    keys = {
      {
        "<leader>gl",
        function()
          local v_start = vim.fn.getpos("v")[2]
          local v_end = vim.fn.getpos(".")[2]
          local start_line = math.min(v_start, v_end)
          local end_line = math.max(v_start, v_end)

          local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
          local rel_path = vim.fn.systemlist(
            "git ls-files --full-name " .. vim.fn.shellescape(vim.fn.expand("%:p"))
          )[1]

          if not rel_path or rel_path == "" then
            vim.notify("File is not tracked by git", vim.log.levels.WARN)
            return
          end

          -- Exit visual mode before opening the viewer
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

          local cmd = string.format(
            'git --no-pager log --format="COMMIT_SEP%%nHash: %%H%%nDate: %%as%%nAuthor: %%an%%nSubject: %%s" --no-color -L %d,%d:%s',
            start_line, end_line, rel_path
          )
          local raw = vim.fn.systemlist(cmd, nil)

          if vim.v.shell_error ~= 0 then
            vim.notify("git log failed: " .. table.concat(raw, "\n"), vim.log.levels.ERROR)
            return
          end

          local commits = parse_log_output(raw)
          if #commits == 0 then
            vim.notify("No commits found for these lines", vim.log.levels.INFO)
            return
          end

          create_viewer(commits, git_root, rel_path, start_line, end_line)
        end,
        mode = "x",
        desc = "Git: line history (git log -L)",
      },
    },
  },
}
