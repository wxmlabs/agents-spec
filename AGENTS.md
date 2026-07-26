# AGENTS.md

agents-spec is a portable `.agents/` directory framework for organizing AI Agent skills and rules.
This file serves two purposes:
1. Guide agents installing this framework into a project.
2. Guide agents working in a project that has adopted this framework.

## Installation (for AI Agents)

When instructed to "add agents-spec", "install agent-spec", or given the URL
`https://github.com/wxmlabs/agents-spec`, install this framework into the target project.

### Method 1: Fetch from upstream repo (recommended)

Fetch the latest framework files from the upstream repository and place them in the
target project root. Do NOT overwrite any files that already exist -- instead, warn
the user and let them decide.

Files to fetch:
- `.agents/skills/agents-spec/SKILL.md` from
  `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`
  (place in `{target}/.agents/skills/agents-spec/SKILL.md`)
- This `AGENTS.md` itself, placed at `{target}/AGENTS.md`

Directories to create (if not exist):
- `{target}/.agents/rules/`
- `{target}/.agents/skills/`
- `{target}/.agents/local/rules/`
- `{target}/.agents/local/skills/`

Then append to `{target}/.gitignore` (if not already present):
```
.agents/local/
```

Create or update `{target}/.agents/README.md` with a skill/rule inventory listing.

### Method 2: Clone and copy

```bash
git clone https://github.com/wxmlabs/agents-spec /tmp/agents-spec
# Copy framework files, skipping any that already exist in target
mkdir -p {target}/.agents/skills/agents-spec
cp -n /tmp/agents-spec/.agents/skills/agents-spec/SKILL.md {target}/.agents/skills/agents-spec/SKILL.md
cp -n /tmp/agents-spec/AGENTS.md {target}/AGENTS.md
```

Then create empty directories, append `.gitignore`, and create `README.md` as in Method 1.

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

### After Installation: Modify Agent Entry Point

CRITICAL: After installing the framework, tell the user they MUST add a rule to
their agent's main entry point (e.g., the agent's system prompt, project rules,
or equivalent configuration) instructing the agent to load and follow skill/rule
documents from all layers. The rule should state:

```
Before performing any task, read and follow applicable skill/rule documents from:
1. .agents/skills/ and .agents/rules/ (project shared)
2. AGENTS.md and .agents/README.md (project meta-rules)
3. .agents/local/skills/ and .agents/local/rules/ (project local)
4. ~/.agent/skills/ and ~/.agent/rules/ (user shared)
5. ~/.agent/local/skills/ and ~/.agent/local/rules/ (user local)

Priority: project-level > user-level.
For rules: shared rules > local rules.
For skills: local skills > shared skills.
```

## Post-Install Validation

Manual check that all required files and directories exist:
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
