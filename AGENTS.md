# AGENTS.md

agents-spec is a portable `.agents/` directory framework for organizing AI Agent skills and rules.
This file serves two purposes:
1. Guide agents installing this framework into a project.
2. Guide agents working in a project that has adopted this framework.

## Installation (for AI Agents)

When instructed to "add agents-spec", "install agent-spec", or given the URL
`https://github.com/wxmlabs/agents-spec`, install this framework into the target project.

### Method 1: Use the install script

On Unix / macOS / WSL / Git Bash:
```bash
git clone https://github.com/wxmlabs/agents-spec /tmp/agents-spec
sh /tmp/agents-spec/bin/agents-spec.sh init .
```

On Windows cmd / PowerShell:
```bat
git clone https://github.com/wxmlabs/agents-spec %TEMP%\agents-spec
%TEMP%\agents-spec\bin\agents-spec.bat init .
```

### Method 2: Copy from cloned repo

```bash
git clone https://github.com/wxmlabs/agents-spec /tmp/agents-spec
cp -r /tmp/agents-spec/.agents/ .
cp /tmp/agents-spec/AGENTS.md .
```

Then append to `.gitignore`:
```
.agents/local/
```

### Method 3: Create manually

1. Create `.agents/rules/` (empty directory)
2. Create `.agents/skills/agents-spec/` with `SKILL.md` from
   `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`
3. Create `.agents/local/rules/` and `.agents/local/skills/` (empty)
4. Create `.agents/README.md` listing the skill inventory
5. Write this `AGENTS.md` to the target project root
6. Append `.agents/local/` to the target's `.gitignore`
7. Create `~/.agent/rules/`, `~/.agent/skills/`, `~/.agent/local/rules/`,
   `~/.agent/local/skills/` (empty)

## Post-Install Validation

Run the validate script (pick the right one for your OS):

Unix: `sh bin/agents-spec.sh validate`
Windows: `bin\agents-spec.bat validate`

Manual check:
- `.agents/rules/` exists
- `.agents/skills/agents-spec/SKILL.md` exists
- `.agents/local/rules/` and `.agents/local/skills/` exist
- `AGENTS.md` exists at project root
- `.gitignore` contains `.agents/local/`
- `~/.agent/rules/` and `~/.agent/skills/` exist
- `~/.agent/local/rules/` and `~/.agent/local/skills/` exist

## Agent Skills & Rules

Agent skills and rules are stored in two layers:
- **Project-level** (`.agents/`) -- committed to the project repository
- **User-level** (`~/.agent/`) -- shared across all projects for the current user

For the full framework definition, read: `.agents/skills/agents-spec/SKILL.md`.

Agents MUST read and follow applicable skill/rule documents from ALL layers when
performing tasks. Documents are loaded in priority order (see below).

### Project-level (`.agents/`)

```
.agents/
  README.md                     # Project-level inventory of skills/rules
  rules/                        # Shared rules (committed to git, team-wide)
  skills/                       # Shared skills (committed to git, team-wide)
  local/                        # Local-only (gitignored, NOT committed)
    rules/                      # Developer-private rules
    skills/                     # Developer-private skills
```

### User-level (`~/.agent/`)

```
~/.agent/
  rules/                        # User-shared rules (across all projects)
  skills/                       # User-shared skills (across all projects)
  local/
    rules/                      # User-private rules
    skills/                     # User-private skills
```

## Priority / Conflict Resolution

When the same capability is defined in multiple layers, the following priority
applies (highest to lowest):

**Rules priority:**
1. Project shared rules (`.agents/rules/`) -- team conventions win
2. Project meta-rules (`AGENTS.md`, `.agents/README.md`)
3. Project local rules (`.agents/local/rules/`)
4. User shared rules (`~/.agent/rules/`)
5. User local rules (`~/.agent/local/rules/`)

**Skills priority:**
1. Project local skills (`.agents/local/skills/`)
2. Project shared skills (`.agents/skills/`)
3. User local skills (`~/.agent/local/skills/`)
4. User shared skills (`~/.agent/skills/`)

In summary: project-level always takes precedence over user-level.
Within each level: shared rules override local rules; local skills override shared skills.

## Encoding Rule (CRITICAL)

All Agent-facing documents (AGENTS.md, SKILL.md, README.md, rules)
MUST only contain ASCII characters. No emoji, no CJK characters, no Unicode symbols.
