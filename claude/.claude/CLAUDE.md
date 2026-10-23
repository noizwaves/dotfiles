# User Preferences

## PR Creation
- Always create PRs as drafts unless explicitly told not to
- Never add "Generated with Claude Code" or any Claude attribution to PR descriptions
- Do not use semantic prefixes (e.g., `feat:`, `fix:`) in PR titles
- PR titles describe a single change — never join clauses with "and" or list multiple changes. If the change genuinely spans several things, title it with the umbrella outcome and let the body enumerate
- Focus on *why*, not *what* — the diff already shows what changed; the PR body should explain motivation, trade-offs, and decisions. If sufficient "why" context is missing, ask clarifying questions before writing the description
- When a PR is for a Jira ticket, prefix the ticket number in the title (e.g., `[BUILD-123] Foo bar`) and link to the ticket in the Context section of the description
- If the repo has a PR template, use that structure first — add headings for any missing focus areas below
- If there is no PR template, structure the body with `##` headings for each focus area. **Within every section, lead with a single succinct paragraph, then optionally add a bulleted list of points if there is more important content to share** (do not pad sections that don't need bullets):
  - **Context**: relevant conversations, resources, or observations (e.g., links to Slack threads, Jira tickets, Jira links)
  - **Problem**: succinct description of the issue — include expected vs. actual behavior when applicable
  - **Solution**: *why* this approach was chosen, key trade-offs considered, and overall description of the changes
  - **Testing**: describe what was done to verify the fix — automated (new/updated tests, CI steps) or manual (commands run, actions taken locally)
- **50 words per section, hard cap.** A target to stay under, not approach — most sections are one or two sentences. Content that doesn't fit belongs in a code comment or a review reply, not the PR body
- **Cut anything the reviewer doesn't need in order to approve.** No explanations of how the framework or tool works, no recap of how you located the problem, no reasoning that led nowhere. If the change is obviously correct, "verified X" is the entire Testing section. Keep only: why this change, why this approach over the alternative, and what a reviewer should be suspicious of
- **Each fact stated once.** Do not duplicate companion-PR links, merge-order callouts, Jira/ticket references, or rollout notes across multiple sections — pick the section where each belongs and link back with a reference if needed elsewhere
- **Use tables to compare near-duplicate things** (e.g., two roles differing only by one field, multiple renamed steps, before/after queues) instead of restating each one in prose
- **Inline the "why not the alternative"** next to the decision it justifies, rather than giving alternatives their own section
- **Context stays lean**: a one-line paragraph framing the change, followed by a tight bulleted list of links (Jira, companion PRs, Slack threads). Save the narrative for Problem/Solution
- **Testing** follows the paragraph + optional bullets shape — never an incomplete/aspirational checklist

## Planning
- Always ask clarifying questions before finalizing a plan

## Git
- Do not use command substitution (`$(...)`) in git commit messages — pass the message directly with `-m`
- Always prefix new git branches with `an--` (e.g., `an--feature-name`)
- Use semantic commit messages with the format `type: message` (e.g., `feat: Add user auth`, `fix: Prevent duplicate submissions`)
- Commit messages should be succinct and explain *why* the change was made or what problem was fixed — not describe the diff
- For large diffs, a very high-level summary is acceptable
- When updating a branch to resolve merge conflicts, use `git merge` (not `git rebase`)
- To correct an already-pushed commit, make a new follow-up commit — do not `--amend` and force-push (avoid rewriting pushed history)
- Do not chain multiple git commands with `&&` in a single Bash call — run them as separate tool calls (in parallel when independent) instead

## Code Style
- Only write comments that are contextually useful — explain *why*, not *what*
- Comments should capture the real-world purpose and user-facing context, not just the technical mechanism (e.g., "Force a Touch ID confirmation" not "Force a fresh auth prompt")
- Never duplicate variable or function names in comments
- Comments and docs describe the interface, not the implementation: say what something does for the person using it (e.g., "set up dependencies"), not how it does it (e.g., "fetch the theme and install Hugo"). This applies to inline comments, README command annotations, docstrings and usage text

## MCP vs CLI Tools
- Prefer CLI tools over MCP equivalents whenever the CLI supports the task
- For GitHub operations, prefer `gh`, `rgh`, or `gh-file-view`
- Use MCP tools when a suitable CLI is unavailable or lacks the required functionality

## Searching Code
- Default to GitHub code search first — local repos may be out of date or in a WIP state
- Use `rgh <query>` or `gh search code --owner Gusto "search query"`. Fall back to the GitHub MCP `search_code` tool if the CLIs are unavailable or lack the required functionality
- For local search (only when exploring already-cloned repos): use the agent's content-search tool or `rg`, but be aware local copies may not reflect upstream
- To clone a repo after finding it: `gh repo clone Gusto/<repo-name> ~/workspace/<repo-name>`

## Shell & Tooling
- Use `fd` instead of `find` for shell-level file finding (`find` is blocked in Claude Code)
- Prefer the agent's built-in file-search and content-search tools when it has them; otherwise use `fd` for files and `rg` for content
- For JSON querying and manipulation: use `jq` for simple single-expression queries; use `node-safe` for anything more complex (multi-step logic, conditionals, transformations). Multi-line node scripts can be condensed to a single line with semicolons: `node-safe -e 'const x = ...; console.log(...)'`
- Always use `node-safe` to execute Node scripts or expressions — never invoke `node` directly
  - node-safe only has access to files under `$PWD`. Copy any required files (downloaded data, absolute-path inputs) into `./.tmp` before invoking node-safe, then reference them by their absolute path.
- Use `gh-file-view` to read remote files and `rgh` to search code

## Bug Fixes
- Fix data at the source, not downstream — prefer adjusting inputs over compensating after filtering/processing

## Sandbox
- If `git commit` fails with "could not create temporary file" inside the Claude Code sandbox, create the directory `TMPDIR` points at — the sandbox sets it without creating it, and SSH commit signing writes temp files there
