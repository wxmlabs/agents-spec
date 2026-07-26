# .agents Directory

Stores AI Agent skills and rules for this project.
For the full framework definition, see the skill: `skills/agents-spec/SKILL.md`.

Upstream: https://github.com/wxmlabs/agents-spec

## Directory Structure

```
.agents/
  README.md
  rules/
  skills/
    agents-spec/
  local/
    rules/
    skills/
```

## This Project's Inventory

### Shared Skills

| Skill | Path | Purpose |
|-------|------|---------|
|   agents-spec   | `skills/agents-spec/` | (see SKILL.md) |

### Shared Rules

(none yet)

### Repo-Level Development Files

These files exist at the repo root and are NOT installed into user projects.
They guide agents developing THIS upstream repository.

| File | Purpose |
|------|---------|
|   `DEV_RULES.md`   | Development conventions: version bumping, changelog, testing, encoding, file pollution prevention |
|   `CHANGELOG.md`   | Version history with agent-actionable upgrade actions |
