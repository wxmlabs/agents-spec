---
name: agents-spec
description: |
  The reusable .agents/ directory framework for organizing AI Agent skills and rules.
  This skill defines the directory structure, shared vs local separation (git-tracked vs personal),
  encoding guidelines, and priority/conflict resolution between layers.
  Use this skill when setting up the .agents/ infrastructure in a new project,
  or when understanding how rules and skills interact in the existing project.
  Triggers include "set up agent skills", "create agent rules", ".agents directory",
  "agent framework", "skill priority", "rule priority", "add agents-spec",
  "install agent-spec", etc.
  Upstream: https://github.com/wxmlabs/agents-spec
  Version: see VERSION file at repo root or .agents/VERSION in installed projects.
---

# Agent Spec Skill

## Purpose

Define a portable `.agents/` directory framework for managing AI Agent skills and rules.
Any project can adopt this structure to organize team-shared and developer-private agent knowledge.

## Upstream

Repository: https://github.com/wxmlabs/agents-spec

To install this framework into a new project, agents should read the `AGENTS.md` at
the upstream repo root for the latest installation instructions.

## Version

The framework version is stored in a plain-text `VERSION` file at the repo root.
When installed into a project, it is copied to `.agents/VERSION`.

A `CHANGELOG.md` in the upstream repo records what changed in each version
and, critically, what upgrade actions the agent must take when moving
from the previous version.

### How Agents Check for Updates

An agent working in a project that has adopted agents-spec SHOULD periodically
check whether the installed version is the latest.

**Check timing:**
- At minimum, check at the start of the first conversation each day.
- Also check immediately when the user says "check agent-spec version",
  "is agents-spec up to date", "update agent-spec", or similar.

1. Read the installed version from `{project}/.agents/VERSION`.
   If this file does not exist, the installation predates versioning (treat as "0.0.0").

2. Fetch the latest version from the upstream repository:
   `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/VERSION`

3. Compare the two versions using semantic versioning rules:
   - If local < upstream: the framework is outdated. Proceed to the upgrade flow below.
   - If local == upstream: the framework is current.
   - If local > upstream: local is ahead (possibly a dev/pre-release). No action needed.

4. When local < upstream, proceed to the upgrade flow below.

### How Agents Perform Upgrades

When the installed version (V_local) is older than the upstream version (V_upstream),
the agent MUST NOT simply re-install from scratch -- it must perform an incremental
upgrade by following the changelog.

**Upgrade procedure:**

1. Fetch the changelog from the upstream repository:
   `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/CHANGELOG.md`

2. Parse the changelog to find all version entries between V_local (exclusive)
   and V_upstream (inclusive).

   The changelog format uses level-2 Markdown headings for each version:
   `## [X.Y.Z] - YYYY-MM-DD`

   Each version entry has an `### Upgrade Actions` section containing a numbered
   list of steps with concrete file operations.

3. Execute the Upgrade Actions of each intermediate version in ascending order
   (oldest first, newest last). For each step:
   - Follow the described file operation (fetch, create, delete, replace, append).
   - If a step conflicts with local modifications, warn the user and ask for guidance.
   - Do NOT skip steps unless the user explicitly approves.

4. After all upgrade actions are executed, update `.agents/VERSION` to the
   latest upstream version.

5. Report to the user what was changed during the upgrade.

6. After the upgrade is complete, run the Post-Install Validation checklist
   from `AGENTS.md` to confirm the framework is intact after the upgrade.

Example upgrade flow for going from 0.1.0 to 0.3.0:
- Fetch CHANGELOG.md
- Find entries for [0.2.0] and [0.3.0]
- Execute Upgrade Actions from [0.2.0]
- Execute Upgrade Actions from [0.3.0]
- Write "0.3.0" to `.agents/VERSION`
- Report summary to user

## Directory Structure

### Project-level (`.agents/`)

```
.agents/
  README.md                     # Project-level inventory of skills/rules
  rules/                        # Shared rules (committed to git, team-wide)
    ...                         # Coding standards, naming conventions, etc.
  skills/                       # Shared skills (committed to git, team-wide)
    ...                         # Domain knowledge, workflows, tool guides
  local/                        # Local-only (gitignored, NOT committed)
    rules/                      # Developer-private rules
      ...                       # IDE integration, personal preferences
    skills/                     # Developer-private skills
      ...                       # IDE-specific integrations, local workflows
```

### User-level (`~/.agents/`)

```
~/.agents/
  rules/                        # User-shared rules (across all projects)
    ...                         # Personal coding standards, preferences
  skills/                       # User-shared skills (across all projects)
    ...                         # Personal workflows, tool knowledge
  local/
    rules/                      # User-private rules (per-machine)
    skills/                     # User-private skills (per-machine)
```

## Layer Definitions

### Project-level

| Layer | Location | Git | Audience | Purpose |
|-------|----------|-----|----------|---------|
| Shared rules | `.agents/rules/` | Committed | Whole team | Coding standards, naming conventions |
| Shared skills | `.agents/skills/` | Committed | Whole team | Domain knowledge, workflows, tool guides |
| Local rules | `.agents/local/rules/` | Ignored | Individual dev | IDE integration rules, personal prefs |
| Local skills | `.agents/local/skills/` | Ignored | Individual dev | IDE-specific integrations, private tools |
| Project rules | `AGENTS.md`, `.agents/README.md` | Committed | Whole team | Project-level meta-rules |

### User-level

| Layer | Location | Git | Audience | Purpose |
|-------|----------|-----|----------|---------|
| User rules | `~/.agents/rules/` | N/A | Current user | Cross-project personal standards |
| User skills | `~/.agents/skills/` | N/A | Current user | Cross-project personal workflows |
| User local rules | `~/.agents/local/rules/` | N/A | Current user | Machine-specific rules |
| User local skills | `~/.agents/local/skills/` | N/A | Current user | Machine-specific skills |

## Priority / Conflict Resolution

When the same capability is defined in multiple layers, the following priority
applies (highest to lowest):

### Rules Priority

1. Project shared rules (`.agents/rules/`) -- team conventions win
2. Project meta-rules (`AGENTS.md`, `.agents/README.md`)
3. Project local rules (`.agents/local/rules/`)
4. User shared rules (`~/.agents/rules/`)
5. User local rules (`~/.agents/local/rules/`)

### Skills Priority

1. Project local skills (`.agents/local/skills/`)
2. Project shared skills (`.agents/skills/`)
3. User local skills (`~/.agents/local/skills/`)
4. User shared skills (`~/.agents/skills/`)

In summary: project-level always takes precedence over user-level.
Within each level: shared rules override local rules; local skills override shared skills.

## Encoding Rule

All files under `.agents/` (SKILL.md, README.md, rule files) MUST be written
in plain, readable text that AI agents can parse without ambiguity, garbled
output, or confusion. Use clear, well-structured Markdown.

## Skill File Format

Every skill requires a `SKILL.md` with YAML front matter:

```yaml
---
name: skill-name
description: |
  What this skill does and when to use it.
  Include trigger phrases here.
---
```

Optional: `references/` subdirectory for detailed tool parameter docs.

## Rule File Format

Rules are plain Markdown (`.md`) files without front matter.
They define constraints and priority directives, not workflows or how-to guides.

## Setting Up in a New Project

For full installation instructions, read the `AGENTS.md` file at the upstream
repo root:
`https://raw.githubusercontent.com/wxmlabs/agents-spec/master/AGENTS.md`

The AGENTS.md file contains the authoritative installation procedure, including
pre-install checks, three installation methods, post-install validation, and the
agent loading protocol. This SKILL.md is a supplementary reference and should
not override AGENTS.md on installation matters.

In brief, installation involves:
1. Creating the `.agents/` directory structure with all required subdirectories
2. Fetching `SKILL.md`, `VERSION`, and `AGENTS.md` from the upstream repository
3. Adding `.agents/local/` to `.gitignore`
4. Creating `~/.agents/` user-level directories
5. Running the Post-Install Validation checklist
6. Executing the Agent Loading Protocol to confirm all layers load correctly

## Rules vs Skills: Separation Principle

- **Rules** answer "what to choose": tool priority, constraints, preferences.
- **Skills** answer "how to use": workflows, patterns, tool parameter guides.
- Rules are prescriptive (DO / PREFER / AVOID); skills are descriptive (here is how X works).
- A single capability may span both: rules in `.agents/*/rules/` and skill docs in `.agents/*/skills/`.
