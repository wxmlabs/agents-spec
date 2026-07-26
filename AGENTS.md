# AGENTS.md

agents-spec is a portable `.agents/` directory framework for organizing AI Agent skills and rules.
This file is the agent entry point. It serves three purposes:
1. Define the loading protocol -- when an agent reads this file, it knows what to load.
2. Guide agents installing this framework into a project.
3. Guide agents working in a project that has adopted this framework.

## Agent Loading Protocol (READ THIS FIRST)

CRITICAL: When you read this file, you MUST execute the following loading protocol
before performing any task. This applies to agents working in this upstream repo
AND to agents working in any project that has installed agents-spec.

**Step 1: Load project shared rules**

List and read all files in `.agents/rules/`. These are team-wide conventions.

**Step 2: Load project shared skills**

List and read all files in `.agents/skills/`. These are team-wide workflows and guides.

**Step 3: Load project meta-rules**

Read `AGENTS.md` (this file) and `.agents/README.md`.

**Step 4: Load project local rules and skills**

List and read all files in `.agents/local/rules/` and `.agents/local/skills/`.
These are developer-private and NOT committed to git.

**Step 5: Load user-level rules and skills**

List and read all files in `~/.agents/rules/` and `~/.agents/skills/` (user-shared).
Then list and read all files in `~/.agents/local/rules/` and `~/.agents/local/skills/` (user-private).

**Step 6: If working in the upstream agents-spec repo**

Also read `DEV_RULES.md` at the project root for framework development conventions.

### Priority / Conflict Resolution

When the same capability is defined in multiple layers:

**Rules priority (highest to lowest):**
1. Project shared rules (`.agents/rules/`)
2. Project meta-rules (`AGENTS.md`, `.agents/README.md`)
3. Project local rules (`.agents/local/rules/`)
4. User shared rules (`~/.agents/rules/`)
5. User local rules (`~/.agents/local/rules/`)

**Skills priority (highest to lowest):**
1. Project local skills (`.agents/local/skills/`)
2. Project shared skills (`.agents/skills/`)
3. User local skills (`~/.agents/local/skills/`)
4. User shared skills (`~/.agents/skills/`)

In summary: project-level always takes precedence over user-level.
Within each level: shared rules override local rules; local skills override shared skills.

## Installation (for AI Agents)

When instructed to "add agents-spec", "install agent-spec", or given the URL
`https://github.com/wxmlabs/agents-spec`, install this framework into the target project.

### Pre-Install Check

Before installing, check whether the framework is already installed:
- If `.agents/VERSION` exists in the target project, skip installation and instead
  run the upgrade flow (see "How Agents Perform Upgrades" in
  `.agents/skills/agents-spec/SKILL.md` or fetch from
  `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`).
- If `.agents/VERSION` does NOT exist, proceed with a fresh installation below.

### Method 1: Fetch from upstream repo (recommended)

Fetch the latest framework files from the upstream repository and place them in the
target project root. Do NOT overwrite any files that already exist -- instead, warn
the user and let them decide.

Files to fetch:
- `.agents/skills/agents-spec/SKILL.md` from
  `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`
  (place in `{target}/.agents/skills/agents-spec/SKILL.md`)
- `VERSION` from
  `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/VERSION`
  (place in `{target}/.agents/VERSION`)
- This `AGENTS.md` itself, placed at `{target}/AGENTS.md`

Directories to create (if not exist):
- `{target}/.agents/rules/`
- `{target}/.agents/skills/`
- `{target}/.agents/skills/agents-spec/`
- `{target}/.agents/local/rules/`
- `{target}/.agents/local/skills/`
- `~/.agents/rules/`
- `~/.agents/skills/`
- `~/.agents/local/rules/`
- `~/.agents/local/skills/`

Then append to `{target}/.gitignore` (if not already present):
```
.agents/local/
```

Create or update `{target}/.agents/README.md` with a skill/rule inventory listing.

IMPORTANT: Generate the `.agents/README.md` content specific to the target project.
Do NOT copy the `.agents/README.md` from the upstream agents-spec repo -- that file
is the upstream repo's own inventory, not a framework template.

After all steps above are complete, run the Post-Install Validation checklist
(see below) to confirm everything is in place.

### Method 2: Clone and copy

```bash
git clone https://github.com/wxmlabs/agents-spec /tmp/agents-spec
# Copy framework files, skipping any that already exist in target
mkdir -p {target}/.agents/skills/agents-spec
cp -n /tmp/agents-spec/.agents/skills/agents-spec/SKILL.md {target}/.agents/skills/agents-spec/SKILL.md
cp -n /tmp/agents-spec/VERSION {target}/.agents/VERSION
cp -n /tmp/agents-spec/AGENTS.md {target}/AGENTS.md
```

Then create empty directories (including `~/.agents/` dirs), append `.gitignore`,
and create `README.md` as in Method 1. After all steps are complete, run the
Post-Install Validation checklist.

### Method 3: Create manually

1. Create `.agents/rules/` and `.agents/skills/` (empty directories)
2. Create `.agents/skills/agents-spec/` with `SKILL.md` from
   `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`
3. Create `.agents/VERSION` with content from
   `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/VERSION`
4. Create `.agents/local/rules/` and `.agents/local/skills/` (empty)
5. Create `.agents/README.md` listing the skill inventory
6. Write this `AGENTS.md` to the target project root
7. Append `.agents/local/` to the target's `.gitignore`
8. Create `~/.agents/rules/`, `~/.agents/skills/`, `~/.agents/local/rules/`,
   `~/.agents/local/skills/` (empty)

After all steps are complete, run the Post-Install Validation checklist.

### After Installation: For Agent Systems Without AGENTS.md Support

Many modern IDEs (VS Code with Copilot, Cursor, CodeBuddy, Windsurf, etc.)
auto-load `AGENTS.md` as project guidance. In those environments, the loading
protocol above is self-executing -- no extra configuration is needed.

If the user's agent system does NOT auto-load `AGENTS.md`, tell the user they
must add the loading protocol (from the "Agent Loading Protocol" section above)
to their agent's main entry point (system prompt, project rules, or equivalent).

## Post-Install Validation

CRITICAL: After completing installation, you MUST run this validation checklist.

**Validation checklist:**

Check that all required files and directories exist:
- `.agents/rules/` exists
- `.agents/skills/agents-spec/SKILL.md` exists
- `.agents/VERSION` exists
- `.agents/local/rules/` and `.agents/local/skills/` exist
- `AGENTS.md` exists at project root
- `.gitignore` contains `.agents/local/`
- `~/.agents/rules/` and `~/.agents/skills/` exist
- `~/.agents/local/rules/` and `~/.agents/local/skills/` exist

After the checklist passes, execute Steps 1 through 5 of the Agent Loading Protocol
above to confirm that all layers load without errors. Report any missing or
unreadable files to the user.

Note: User-level directories (`~/.agents/`) may be empty after a fresh install.
This is normal and should NOT be reported as an error. The directories merely
need to exist; content is added by the user over time.


## Framework Reference

### Project-level (`.agents/`)

```
.agents/
  VERSION                       # Framework version (for update checks)
  README.md                     # Project-level inventory of skills/rules
  rules/                        # Shared rules (committed to git, team-wide)
  skills/                       # Shared skills (committed to git, team-wide)
  local/                        # Local-only (gitignored, NOT committed)
    rules/                      # Developer-private rules
    skills/                     # Developer-private skills
```

### User-level (`~/.agents/`)

```
~/.agents/
  rules/                        # User-shared rules (across all projects)
  skills/                       # User-shared skills (across all projects)
  local/
    rules/                      # User-private rules
    skills/                     # User-private skills
```

For the full framework definition, read: `.agents/skills/agents-spec/SKILL.md`.

For the changelog and upgrade instructions, read the upstream `CHANGELOG.md`:
`https://raw.githubusercontent.com/wxmlabs/agents-spec/master/CHANGELOG.md`

## Encoding Rule

All Agent-facing documents (AGENTS.md, SKILL.md, README.md, rules, CHANGELOG.md)
MUST be written in plain, readable text that AI agents can parse without ambiguity,
garbled output, or confusion. Use clear, well-structured Markdown. Avoid characters
or formatting that may not render correctly across different agent toolchains.
