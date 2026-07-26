# Development Rules

Rules for agents developing the agents-spec framework itself.
These rules apply ONLY to this upstream repository and MUST NOT be installed
into user projects.

## Encoding

All agent-facing documents (AGENTS.md, SKILL.md, README.md, CHANGELOG.md,
DEV_RULES.md, rules, VERSION) MUST be written in plain, readable text that
AI agents can parse without ambiguity, garbled output, or confusion.
Use clear, well-structured Markdown. Avoid characters or formatting that
may not render correctly across different agent toolchains.

## File Pollution Prevention

CRITICAL: Development-only files for this repo MUST NOT be installed into user projects.

Installation white-list (these are the ONLY files an agent copies during install):
- `.agents/skills/agents-spec/SKILL.md`  ->  `{target}/.agents/skills/agents-spec/SKILL.md`
- `VERSION`                              ->  `{target}/.agents/VERSION`
- `AGENTS.md`                            ->  `{target}/AGENTS.md`

These files are created as EMPTY directories (no content copied):
- `{target}/.agents/rules/`
- `{target}/.agents/skills/`
- `{target}/.agents/local/rules/`
- `{target}/.agents/local/skills/`
- `~/.agent/rules/`
- `~/.agent/skills/`
- `~/.agent/local/rules/`
- `~/.agent/local/skills/`

Files that exist in this repo but are EXCLUDED from installation:
- `CHANGELOG.md`       -- framework version history, read by agents from upstream URL
- `DEV_RULES.md`       -- development rules for this repo only
- `README.md`          -- repo-level readme, not part of the framework
- `LICENSE`
- `.gitignore`
- `.agents/README.md`  -- auto-generated per-project inventory
- `.git/`, `.idea/`, `.vscode/`

When adding a new development-only file, verify it is NOT in the
AGENTS.md installation instructions.

When adding a new file that SHOULD be installed, explicitly add it to
the installation instructions in AGENTS.md.

## Version Bumping

When changes are made to the framework that affect installed projects,
bump the version following semantic versioning:

- **MAJOR** (X.0.0): Breaking changes. Installed projects require manual migration.
  - Removed or renamed directories/files that agents expect
  - Changed priority/conflict resolution rules
  - Changed the installation procedure

- **MINOR** (0.X.0): New features, backward-compatible.
  - New directories or optional files
  - New rules or skills
  - New documentation sections

- **PATCH** (0.0.X): Fixes, clarifications, non-functional changes.
  - Typo fixes
  - Encoding fixes
  - Documentation clarifications

### Release Procedure

When preparing a release with a version bump:

1. Update `VERSION` at repo root:
   ```
   echo "0.2.0" > VERSION
   ```

2. Update `CHANGELOG.md`:
   - Add a new `## [X.Y.Z] - YYYY-MM-DD` section at the top
   - List changes under `### Changes`
   - Write Upgrade Actions under `### Upgrade Actions`
   - Each upgrade action must be a concrete file operation the agent can execute:
     - `Fetch <URL> and write to <path>`
     - `Create directory <path>`
     - `Delete file <path>`
     - `In <file>, replace <old> with <new>`
     - `Append <content> to <file>`
     - `Update .agents/VERSION to <version>`

3. If `AGENTS.md` installation instructions changed, add upgrade actions
   to fetch and overwrite `{target}/AGENTS.md`.

4. If `SKILL.md` changed, add upgrade actions to fetch and overwrite
   `{target}/.agents/skills/agents-spec/SKILL.md`.

5. Commit with message: `release: bump version to X.Y.Z`

## Testing

Before committing changes, perform a quick validation:

1. Verify directory structure:
   ```
   .agents/
     README.md
     rules/
     skills/agents-spec/SKILL.md
     local/rules/
     local/skills/
   ```

2. Simulate an agent install into a temp project:
   - Create temp directory
   - Create the empty directories per install instructions
   - Copy the 3 white-listed files
   - Verify no development-only files leaked

3. Verify all required files are well-formed and readable.
