# User Preferences

## PR Creation
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
- Do not `cd` to the repo root before running git commands — run them from the current directory and reference file paths relatively. This applies to worktrees as well.

## Code Style
- Only write comments that are contextually useful — explain *why*, not *what*
- Never duplicate variable or function names in comments

## Shell & Tooling
- Use `jq` for JSON parsing, querying, and manipulation — do not use Python or Node one-liners for JSON tasks
- To run one-off Node scripts, write the script to a temp file in `<working-dir>/tmp/`, execute it with `node` (or `node-safe`), then remove the temp file — do not pass script contents as multi-line strings or heredocs

## Bug Fixes
- Fix data at the source, not downstream — prefer adjusting inputs over compensating after filtering/processing
