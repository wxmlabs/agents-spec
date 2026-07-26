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

## [0.1.0] - 2026-07-27

### Changes

- **Added**: Initial agents-spec framework.
  - `.agents/` directory structure (rules/, skills/, local/)
  - `~/.agent/` user-level directory structure
  - Skill file format with YAML front matter
  - Rule file format (plain Markdown)
  - Priority/conflict resolution rules
  - Encoding rule (ASCII only)
  - `AGENTS.md` -- agent installation and guidance
  - `.agents/README.md` -- skill/rule inventory
  - `.agents/skills/agents-spec/SKILL.md` -- full framework spec
  - `VERSION` and `.agents/VERSION` -- version tracking

### Upgrade Actions

Initial release. No upgrade path from a prior version.

If the project has no `.agents/` directory, perform a fresh install by
following the installation instructions in `AGENTS.md`.

If the project has a pre-versioning `.agents/` setup (no `.agents/VERSION`):

1. Fetch `https://raw.githubusercontent.com/wxmlabs/agents-spec/master/VERSION`
   and write the content to `{project}/.agents/VERSION`.
2. Compare local `{project}/AGENTS.md` with the upstream AGENTS.md.
   If they differ, ask the user whether to update.
3. Verify `.agents/skills/agents-spec/SKILL.md` exists.
   If not, fetch it from the upstream repository.
