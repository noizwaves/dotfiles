# User Preferences

## PR Creation
- Always create PRs as drafts unless explicitly told not to
- Never add "Generated with Claude Code" or any Claude attribution to PR descriptions
- Do not use semantic prefixes (e.g., `feat:`, `fix:`) in PR titles
- Focus on *why*, not *what* — the diff already shows what changed; the PR body should explain motivation, trade-offs, and decisions. If sufficient "why" context is missing, ask clarifying questions before writing the description
- When a PR is for a Jira ticket, prefix the ticket number in the title (e.g., `[BUILD-123] Foo bar`) and link to the ticket in the Context section of the description
- If the repo has a PR template, use that structure first — add headings for any missing focus areas below
- If there is no PR template, structure the body with `##` headings for each focus area:
  - **Context**: relevant conversations, resources, or observations (e.g., links to Slack threads, Jira tickets, Jira links)
  - **Problem**: succinct description of the issue — include expected vs. actual behavior when applicable
  - **Solution**: *why* this approach was chosen, key trade-offs considered, and overall description of the changes
  - **Testing**: describe what was done to verify the fix — automated (new/updated tests, CI steps) or manual (commands run, actions taken locally). Write in prose or concise paragraphs, not an incomplete checklist

## Planning
- Always ask clarifying questions before finalizing a plan

## Git
- Do not use command substitution (`$(...)`) in git commit messages — pass the message directly with `-m`
- Always prefix new git branches with `an--` (e.g., `an--feature-name`)
- Use semantic commit messages with the format `type: message` (e.g., `feat: Add user auth`, `fix: Prevent duplicate submissions`)
- Commit messages should be succinct and explain *why* the change was made or what problem was fixed — not describe the diff
- For large diffs, a very high-level summary is acceptable
- When updating a branch to resolve merge conflicts, use `git merge` (not `git rebase`)
- Do not chain multiple git commands with `&&` in a single Bash call — run them as separate tool calls (in parallel when independent) instead

## Code Style
- Only write comments that are contextually useful — explain *why*, not *what*
- Comments should capture the real-world purpose and user-facing context, not just the technical mechanism (e.g., "Force a Touch ID confirmation" not "Force a fresh auth prompt")
- Never duplicate variable or function names in comments

## MCP vs CLI Tools
- For GitHub operations: prefer the GitHub MCP (`mcp__githubgusto__*`) over `gh` CLI commands
  - Fall back to `gh` CLI, `rgh`, or `gh-file-view` only if the MCP tool fails or lacks the specific functionality needed (e.g., `gh repo clone` has no MCP equivalent)
- For non-GitHub tools: prefer local CLI tools (e.g., `jq`, Bash commands) over MCP equivalents when available

## Searching Code
- Default to GitHub code search first — local repos may be out of date or in a WIP state
- Use the GitHub MCP `search_code` tool. Fallback: `rgh <query>` or `gh search code --owner Gusto "search query"`
- For local search (only when exploring already-cloned repos): use the Grep tool, but be aware local copies may not reflect upstream
- To clone a repo after finding it: `gh repo clone Gusto/<repo-name> ~/workspace/<repo-name>`

## Shell & Tooling
- **Never use `find`** — it is denied at the permissions level. Use `Glob` for file patterns, `Grep` for content search, and `fd` for any shell-level file finding
- Prefer the `Grep` tool over `fd ... -exec grep` or raw `rg` for content searches; prefer `Glob` over `fd` when a glob pattern suffices
- For JSON querying and manipulation: use `jq` for simple single-expression queries; use `node-safe` for anything more complex (multi-step logic, conditionals, transformations). Multi-line node scripts can be condensed to a single line with semicolons: `node-safe -e 'const x = ...; console.log(...)'`
- Always use `node-safe` to execute Node scripts or expressions — never invoke `node` directly
  - node-safe only has access to files under `$PWD`. Copy any required files (downloaded data, absolute-path inputs) into `./.tmp` before invoking node-safe, then reference them by their absolute path.
- Always use `python-safe` to execute Python scripts or expressions — never invoke `python` directly
  - python-safe only has access to files under `$PWD`. Copy any required files into `./.tmp` before invoking python-safe, then reference them by their absolute path.
  - Useful for CSV manipulation (`csvkit`), data processing (`polars`), and table formatting (`tabulate`)
  - Multi-line scripts can be condensed to a single line with semicolons: `python-safe -c 'import polars as pl; ...'`
- `gh-file-view` and `rgh` are available as CLI fallbacks for reading remote files and searching code if the GitHub MCP tools fail

## Bug Fixes
- Fix data at the source, not downstream — prefer adjusting inputs over compensating after filtering/processing

## Sandbox
- If `git commit` fails with "could not create temporary file" inside the sandbox, run `mkdir -p /tmp/claude` — the sandbox sets `TMPDIR=/tmp/claude` but doesn't pre-create it, and SSH commit signing needs that directory for temp files
