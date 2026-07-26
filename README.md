# Agent Spec

A portable `.agents/` directory framework for organizing AI Agent skills and rules.

Any project can adopt this structure to manage team-shared and developer-private agent knowledge.

## Quick Start

Give your agent the URL `https://github.com/wxmlabs/agents-spec`, or just say `add agent-spec`.
The agent reads `AGENTS.md`, discovers the install instructions, and sets up the framework.

No CLI scripts needed. Your AI agent does the installation for you.

## What the Agent Will Do

1. Create the `.agents/` directory structure in your project.
2. Copy framework skills and rules.
3. Append `.agents/local/` to `.gitignore`.
4. Create `~/.agent/` user-level directories.
5. **Tell you to add a rule to your agent's entry point** so it loads skills/rules from all layers.

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
- **Agent entry point**: after installation, the agent MUST be told to load documents from all layers.

## Documentation

- `AGENTS.md` -- project-level agent guidance (includes install instructions for agents)
- `.agents/README.md` -- skill and rule inventory
- `.agents/skills/agents-spec/SKILL.md` -- full framework specification
