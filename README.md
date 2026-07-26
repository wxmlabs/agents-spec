# Agent Spec

A portable `.agents/` directory framework for organizing AI Agent skills and rules.

Any project can adopt this structure to manage team-shared and developer-private agent knowledge.

## Quick Start

**Unix / macOS / WSL / Git Bash:**

```bash
git clone https://github.com/wxmlabs/agents-spec /tmp/agents-spec
sh /tmp/agents-spec/bin/agents-spec.sh init .
```

**Windows (cmd / PowerShell):**

```bat
git clone https://github.com/wxmlabs/agents-spec %TEMP%\agents-spec
%TEMP%\agents-spec\bin\agents-spec.bat init .
```

No runtime dependencies. Just `sh` (or `bat`) + standard system tools.

## Agent Auto-Install

Give your agent the URL `https://github.com/wxmlabs/agents-spec`, or just say `add agent-spec`.
The agent reads `AGENTS.md`, discovers the install instructions, and picks the right script for the OS.

## CLI Commands

| Command | Unix | Windows |
|---------|------|---------|
| init | `sh bin/agents-spec.sh init [dir]` | `bin\agents-spec.bat init [dir]` |
| validate | `sh bin/agents-spec.sh validate [dir]` | `bin\agents-spec.bat validate [dir]` |
| list | `sh bin/agents-spec.sh list [dir]` | `bin\agents-spec.bat list [dir]` |

## Structure

### Project-level (`.agents/`)

```
.agents/
  rules/          # Shared rules (committed, team-wide)
  skills/         # Shared skills (committed, team-wide)
  local/
    rules/        # Developer-private rules (gitignored)
    skills/       # Developer-private skills (gitignored)
```

### User-level (`~/.agent/`)

```
~/.agent/
  rules/          # User-shared rules (across all projects)
  skills/         # User-shared skills (across all projects)
  local/
    rules/        # User-private rules (per-machine)
    skills/       # User-private skills (per-machine)
```

## Key Principles

- **Rules** = "what to choose": tool priority, constraints, preferences.
- **Skills** = "how to use": workflows, patterns, tool parameter guides.
- **Encoding**: all agent documents MUST be ASCII only (no emoji, no CJK, no Unicode).
- **Priority**: project-level > user-level. Within each level: shared rules > local rules; local skills > shared skills.

## Documentation

- `AGENTS.md` -- project-level agent guidance (includes install instructions for agents)
- `.agents/README.md` -- skill and rule inventory
- `.agents/skills/agents-spec/SKILL.md` -- full framework specification

## Scripts

| Script | Platform | Depends on |
|--------|----------|------------|
| `bin/agents-spec.sh` | Unix, macOS, WSL, Git Bash | `sh`, `cp`, `mkdir`, `awk` |
| `bin/agents-spec.bat` | Windows cmd, PowerShell | `cmd`, `powershell` (for encoding check) |
