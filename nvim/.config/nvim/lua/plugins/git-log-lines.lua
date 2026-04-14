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

          local cmd = string.format("git --no-pager log --color=always -L %d,%d:%s", start_line, end_line, rel_path)

          local buf = vim.api.nvim_create_buf(false, true)
          local width = math.floor(vim.o.columns * 0.85)
          local height = math.floor(vim.o.lines * 0.85)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            col = math.floor((vim.o.columns - width) / 2),
            row = math.floor((vim.o.lines - height) / 2),
            style = "minimal",
            border = "rounded",
            title = " git log -L (line history) ",
            title_pos = "center",
          })

          vim.fn.termopen(cmd, { cwd = git_root })

          local function close() vim.api.nvim_win_close(win, true) end
          vim.keymap.set("n", "q", close, { buffer = buf })
          vim.keymap.set("n", "<Esc>", close, { buffer = buf })

          vim.cmd("stopinsert")
        end,
        mode = "x",
        desc = "Git: line history (git log -L)",
      },
    },
  },
}
