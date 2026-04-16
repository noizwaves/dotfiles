# Git Line History Viewer — Enhanced `<leader>gl`

## Context

The current `git-log-lines.lua` plugin opens a floating terminal that dumps raw `git log -L` output. While functional, it's hard to navigate — commits blend together, there's no way to jump between them, and no structured metadata (dates, authors, PR links) is surfaced. This redesign replaces that raw dump with a purpose-built split-pane viewer.

## Overview

A full-screen floating UI with a commit list on the left and a line-scoped diff preview on the right. Navigation keys move through commits, updating the diff preview. PR links are parsed from commit messages for quick access.

## Data Layer

### Single-pass parsing

`git log -L` always includes the diff (it ignores `--no-patch`), so we parse both metadata and diffs from a single command:

```
git log --format="COMMIT_SEP%nHash: %H%nDate: %as%nAuthor: %an%nSubject: %s" --no-color -L <start>,<end>:<file>
```

Parse the output by splitting on `COMMIT_SEP`. For each commit block:
1. Extract structured metadata (hash, date, author, subject) from the formatted header lines
2. Extract the diff hunks (everything after the first `@@` line)
3. Store both in a commits array: `{ hash, date, author, subject, pr_number, diff_lines }`

All data is available immediately — no lazy loading or secondary git calls needed.

### PR link extraction

Regex patterns against each commit's subject:
- `Merge pull request #(%d+)` — GitHub merge commits
- `%(#(%d+)%)` — Squash-merge convention (Lua patterns)

Build the base PR URL by parsing the first git remote URL:
- `git remote get-url origin` → extract `owner/repo` → `https://github.com/<owner>/<repo>/pull/`

## Window Architecture

Three floating windows composing a single visual unit:

1. **Backdrop float** — Full-screen, `style=minimal`, `border=rounded`, title `" git log -L (line history) "`. Empty buffer, provides the outer frame.
2. **Commit list float** — Positioned inside the backdrop area, left 30%. No border. Scratch buffer with formatted commit entries.
3. **Diff preview float** — Right 70% of the backdrop area. No border. Scratch buffer with `filetype=diff`.

A vertical separator is achieved by giving the diff preview float a left-only border: `border = {"", "", "", "", "", "", "", "│"}`.

### Window options

Both inner buffers:
- `buftype = "nofile"`, `modifiable = false`, `swapfile = false`
- `wrap = false` (diffs should not wrap)

Commit list buffer additionally:
- `cursorline = true` (highlight selected commit)

## Commit List Formatting

Each commit is a multi-line block separated by a blank line:

```
2024-03-15  jane
Refactor auth flow  PR #421

2024-03-10  bob
Fix token expiry  PR #418
```

- Line 1: date + author
- Line 2: commit subject + PR number (if detected)
- Blank line separator

### Highlight groups

| Element    | Highlight group       |
|------------|-----------------------|
| Date       | `GitLogDate` → links to `Special` |
| Author     | `GitLogAuthor` → links to `Normal` |
| Subject    | `GitLogSubject` → links to `Comment` |
| PR number  | `GitLogPR` → links to `Type` |
| Selected   | `CursorLine` (via window option) |

Highlight groups are defined with `vim.api.nvim_set_hl(0, ...)` using `link` so they inherit from the user's colorscheme.

## Keybindings

All buffer-local to the commit list buffer:

| Key       | Action |
|-----------|--------|
| `j` / `k` | Move to next/previous commit |
| `Enter`   | Open commit in browser (via git remote URL + hash) |
| `o`       | Open associated PR in browser |
| `q` / `Esc` | Close all floats |

### Cursor-to-commit mapping

Maintain a Lua table mapping line ranges to commit indices. On `CursorMoved` autocmd, determine which commit block the cursor is in and update the diff preview if the commit changed.

## Error Handling

- **File not tracked** — `vim.notify` warning, bail out (same as current)
- **No commits found** — Message in diff preview: "No commits found for these lines"
- **No remote URL** — PR numbers still displayed; `o` / `Enter` notify "No remote configured"
- **git command failure** — Catch non-zero exit, show notification with error message

## File Structure

Everything remains in a single file: `nvim/.config/nvim/lua/plugins/git-log-lines.lua` as a self-contained lazy.nvim plugin spec. Local functions handle parsing, window management, and rendering.

## Keybinding Changes

The `<leader>gl` visual-mode binding is replaced in-place. No new bindings added to the global keymap. `docs/neovim-keymap.md` should be updated to reflect the enhanced behavior.

## Verification

1. Open a file tracked by git in Neovim
2. Visually select a range of lines, press `<leader>gl`
3. Verify: full-screen float appears with commit list on left, diff on right
4. Press `j`/`k` — diff preview updates to show the selected commit's changes
5. Press `o` on a commit with a PR number — browser opens to the PR
6. Press `q` — all floats close cleanly, no orphaned buffers/windows
7. Run the `verify-nvim-config` skill to confirm the plugin loads without errors
