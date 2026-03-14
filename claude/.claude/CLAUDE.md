# User Preferences

## PR Creation
- Do NOT include a "Test plan" section in PR descriptions
- Never add "Generated with Claude Code" or any Claude attribution to PR descriptions
- Do not use semantic prefixes (e.g., `feat:`, `fix:`) in PR titles

## Planning
- Always ask clarifying questions before finalizing a plan

## Git
- Do not use command substitution (`$(...)`) in git commit messages — pass the message directly with `-m`
- Always prefix new git branches with `an--` (e.g., `an--feature-name`)
- Use semantic commit messages with the format `type: message` (e.g., `feat: Add user auth`, `fix: Prevent duplicate submissions`)
- Commit messages should be succinct and explain *why* the change was made or what problem was fixed — not describe the diff
- For large diffs, a very high-level summary is acceptable
- When updating a branch to resolve merge conflicts, use `git merge` (not `git rebase`)

## Code Style
- Only write comments that are contextually useful — explain *why*, not *what*
- Never duplicate variable or function names in comments

## Bug Fixes
- Fix data at the source, not downstream — prefer adjusting inputs over compensating after filtering/processing
