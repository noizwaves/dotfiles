---
name: verify-nvim-config
description: Use when editing Neovim config files under nvim/.config/nvim/ in the dotfiles repo to verify changes load and work correctly
---

# Verify Neovim Config Changes

After editing any file under `nvim/.config/nvim/`, verify changes by running a headless Neovim instance and querying its state.

## Workflow

```
nvim-server-start → dynamic checks → nvim-server-verify → nvim-server-stop
```

1. Start the server: `nvim-server-start` (prints socket path)
2. Run change-specific checks using `nvim --server <sock> --remote-expr 'luaeval("...")'`
3. Run baseline health check: `nvim-server-verify`
4. **Always** stop the server: `nvim-server-stop` (even if checks fail)

Helper scripts are in `.claude/skills/verify-nvim-config/bin/`. The socket path is stored in `/tmp/nvim-verify.state`.

## Dynamic Verification Patterns

Construct `luaeval` queries based on what you changed. Read the socket path from the `nvim-server-start` output.

**Important:** Always use the literal absolute socket path (e.g., `/tmp/nvim-verify-12345.sock`) directly in `nvim --server` commands. Do NOT store it in a shell variable like `$SOCK` — variable expansion triggers `simple_expansion` permission warnings.

### Plugin spec changed (`lua/plugins/<name>.lua`)

Extract the plugin's short name from the spec's first string (e.g., `"nvim-telescope/telescope.nvim"` → `telescope.nvim`).

```bash
# Check plugin is registered in lazy.nvim (works for all plugins, including lazy-loaded)
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("require(\"lazy.core.config\").plugins[\"telescope.nvim\"] ~= nil")'

# Check plugin is actually loaded (only true for non-lazy plugins or after trigger)
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("require(\"lazy.core.config\").plugins[\"telescope.nvim\"]._.loaded ~= nil")'

# Check a lazy-loaded command exists (if plugin uses cmd = ...)
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("vim.fn.exists(\":Telescope\") == 2")'
```

### Keymap changed (`lua/config/keymaps.lua` or plugin `keys = {}`)

```bash
# Check a normal-mode mapping exists
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("vim.fn.maparg(\"<leader>cc\", \"n\") ~= \"\"")'

# Get the mapping's rhs to verify it's correct
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("vim.fn.maparg(\"<S-h>\", \"n\")")'
```

### Autocmd changed (`lua/config/autocmds.lua`)

```bash
# Check an autocmd group has entries
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("#vim.api.nvim_get_autocmds({group=\"autoreload\"}) > 0")'
```

### Option changed (`init.lua`)

```bash
# Check a vim option value
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("vim.o.scrolloff")'
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("vim.o.number")'
```

### Colorscheme changed

```bash
nvim --server /tmp/nvim-verify-XXXXX.sock --remote-expr 'luaeval("vim.g.colors_name")'
```

## When Multiple Files Changed

If changes span multiple files, verify each changed area, then run `nvim-server-verify` for the baseline check. Don't skip dynamic checks just because you'll run the baseline.

## Error Handling

- If `nvim-server-start` fails (exit 2): config has a fatal error preventing startup. Check the error output, fix, and retry.
- If a `luaeval` query fails: the feature you changed may have a runtime error. The error message from nvim will indicate the problem.
- **Always run `nvim-server-stop`** at the end, even after failures.
