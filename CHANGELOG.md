# Changelog

All notable changes to agents-spec are documented in this file.

Each version entry includes **Upgrade Actions** -- machine-actionable steps
that an agent MUST execute when upgrading from the previous version.
An agent upgrading across multiple versions executes the upgrade actions
of each intermediate version in order.

Format:

```
## [X.Y.Z] - YYYY-MM-DD

### Changes
- **Added**: ...
- **Changed**: ...
- **Removed**: ...
- **Fixed**: ...

### Upgrade Actions (from previous version)
1. Action: <description>
   - <concrete file operation>
```

---

## [0.1.3] - 2026-07-27

### Changes

- **Fixed**: User-level directory renamed from `~/.agent/` to `~/.agents/` for consistency with project-level `.agents/`.

### Upgrade Actions

1. Update `.agents/VERSION` to 0.1.3.
2. Fetch `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/AGENTS.md`
   and overwrite `{target}/AGENTS.md`.
3. Fetch `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`
   and overwrite `{target}/.agents/skills/agents-spec/SKILL.md`.
4. If `~/.agent/` exists, rename it to `~/.agents/`.

---

## [0.1.2] - 2026-07-27

### Changes

- **Removed**: `.agents/VERSION` from the source repository (redundant with root `VERSION`).
- **Changed**: DEV_RULES.md release procedure simplified (removed `cp VERSION .agents/VERSION` step).
- **Fixed**: README.md encoding rule synced with other documents.
- **Fixed**: `.agents/README.md` stale VERSION references removed.

### Upgrade Actions

1. Update `.agents/VERSION` to 0.1.2.

No installed files changed in this release.

---

## [0.1.1] - 2026-07-27

### Changes

- **Fixed**: Installation Method 3 now explicitly creates `.agents/skills/` directory.
- **Fixed**: Upgrade procedure now includes Post-Install Validation (Step 6).
- **Fixed**: SKILL.md "Setting Up" section no longer duplicates AGENTS.md instructions; delegates to authoritative source.
- **Fixed**: CHANGELOG 0.1.0 wording ("No upgrade path" -> "Initial versioned release").
- **Changed**: Encoding rule relaxed from "ASCII only" to "plain, readable text" across all documents.
- **Changed**: Upgrade check timing clarified (first conversation each day + on explicit user request).
- **Changed**: DEV_RULES.md release procedure simplified (removed ASCII check step).

### Upgrade Actions

1. Update `.agents/VERSION` to 0.1.1.
2. Fetch `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/AGENTS.md`
   and overwrite `{target}/AGENTS.md`.
3. Fetch `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/.agents/skills/agents-spec/SKILL.md`
   and overwrite `{target}/.agents/skills/agents-spec/SKILL.md`.

---

## [0.1.0] - 2026-07-27

### Changes

- **Added**: Initial agents-spec framework.
  - `.agents/` directory structure (rules/, skills/, local/)
  - `~/.agents/` user-level directory structure
  - Skill file format with YAML front matter
  - Rule file format (plain Markdown)
  - Priority/conflict resolution rules
  - Encoding rule (plain readable text)
  - `AGENTS.md` -- agent installation and guidance
  - `.agents/README.md` -- skill/rule inventory
  - `.agents/skills/agents-spec/SKILL.md` -- full framework spec
  - `VERSION` and `.agents/VERSION` -- version tracking

### Upgrade Actions

Initial versioned release.

If the project has no `.agents/` directory, perform a fresh install by
following the installation instructions in `AGENTS.md`.

If the project has a pre-versioning `.agents/` setup (no `.agents/VERSION`):

1. Fetch `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/VERSION`
   and write the content to `{project}/.agents/VERSION`.
2. Compare local `{project}/AGENTS.md` with the upstream AGENTS.md.
   If they differ, ask the user whether to update.
3. Verify `.agents/skills/agents-spec/SKILL.md` exists.
   If not, fetch it from the upstream repository.
