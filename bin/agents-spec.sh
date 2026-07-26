#!/bin/sh
# agents-spec - Manage the .agents/ framework (zero-dependency shell version)
# Usage: sh bin/agents-spec.sh init|validate|list [target-dir]

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMD="${1:-help}"
TARGET="${2:-.}"

# Resolve user-level agent directory
if [ -n "$HOME" ]; then
  USER_AGENT="$HOME/.agent"
elif [ -n "$USERPROFILE" ]; then
  USER_AGENT="$USERPROFILE/.agent"
else
  USER_AGENT="$HOME/.agent"
fi

# ---------- helpers ----------

init_user_level() {
  mkdir -p "$USER_AGENT/skills"
  mkdir -p "$USER_AGENT/rules"
  mkdir -p "$USER_AGENT/local/skills"
  mkdir -p "$USER_AGENT/local/rules"
  echo "  + Created user-level ~/.agent/ directories"
}

init_target() {
  TARGET_DIR="$(cd "$TARGET" 2>/dev/null && pwd || echo "")"
  if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target directory does not exist: $TARGET" >&2
    exit 1
  fi

  echo "Initializing .agents/ framework in $TARGET_DIR"

  # Create project-level directory structure
  mkdir -p "$TARGET_DIR/.agents/skills"
  mkdir -p "$TARGET_DIR/.agents/rules"
  mkdir -p "$TARGET_DIR/.agents/local/rules"
  mkdir -p "$TARGET_DIR/.agents/local/skills"

  # Copy shared skills from framework
  if [ -d "$ROOT/.agents/skills" ]; then
    for skill in "$ROOT/.agents/skills"/*/; do
      [ -d "$skill" ] || continue
      skill_name="$(basename "$skill")"
      if [ "$skill_name" != "local" ]; then
        cp -r "$skill" "$TARGET_DIR/.agents/skills/" 2>/dev/null || true
      fi
    done
  fi

  # Copy AGENTS.md
  if [ -f "$ROOT/AGENTS.md" ] && [ "$ROOT" != "$TARGET_DIR" ]; then
    cp "$ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  fi

  # Generate .agents/README.md inventory
  regenerate_inventory "$TARGET_DIR/.agents"

  # Append to .gitignore
  gitignore_add "$TARGET_DIR" ".agents/local/"

  # Create user-level directories
  init_user_level

  echo ""
  echo "Done! The .agents/ framework is now set up."
  echo ""
  echo "Next steps:"
  echo "  1. Review AGENTS.md for project-level guidance"
  echo "  2. Add team skills in .agents/skills/"
  echo "  3. Add team rules in .agents/rules/"
  echo "  4. Each dev adds local skills/rules in .agents/local/"
  echo "  5. Add cross-project skills/rules in ~/.agent/"
}

regenerate_inventory() {
  AGENTS_DIR="$1"
  inventory="$AGENTS_DIR/README.md"

  # Count skills
  skills=""
  if [ -d "$AGENTS_DIR/skills" ]; then
    for d in "$AGENTS_DIR/skills"/*/; do
      [ -d "$d" ] || continue
      skills="$skills  $(basename "$d")
"
    done
  fi

  # Count rules
  rules=""
  if [ -d "$AGENTS_DIR/rules" ]; then
    for f in "$AGENTS_DIR/rules"/*.md; do
      [ -f "$f" ] || continue
      rules="$rules  $(basename "$f" .md)
"
    done
  fi

  cat > "$inventory" << 'INVENTORY_EOF'
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

INVENTORY_EOF

  if [ -n "$skills" ]; then
    echo "| Skill | Path | Purpose |" >> "$inventory"
    echo "|-------|------|---------|" >> "$inventory"
    echo "$skills" | while IFS= read -r line; do
      [ -z "$line" ] && continue
      echo "| $line | \`skills/$line/\` | (see SKILL.md) |" >> "$inventory"
    done
  else
    echo "(none yet)" >> "$inventory"
  fi

  cat >> "$inventory" << 'INVENTORY_EOF'

### Shared Rules

INVENTORY_EOF

  if [ -n "$rules" ]; then
    echo "| Rule | Path | Purpose |" >> "$inventory"
    echo "|------|------|---------|" >> "$inventory"
    echo "$rules" | while IFS= read -r line; do
      [ -z "$line" ] && continue
      echo "| $line | \`rules/$line.md\` | (see file) |" >> "$inventory"
    done
  else
    echo "(none yet)" >> "$inventory"
  fi
}

gitignore_add() {
  TARGET_DIR="$1"
  PATTERN="$2"
  GI_FILE="$TARGET_DIR/.gitignore"

  if [ -f "$GI_FILE" ] && grep -qFx "$PATTERN" "$GI_FILE" 2>/dev/null; then
    return 0
  fi

  # Append with a blank line separator if file exists and is non-empty
  if [ -f "$GI_FILE" ] && [ -s "$GI_FILE" ]; then
    # Check if file ends with a newline
    last_char="$(tail -c 1 "$GI_FILE" 2>/dev/null || true)"
    if [ -n "$last_char" ]; then
      echo "" >> "$GI_FILE"
    fi
  fi

  echo "# Local-only agent files" >> "$GI_FILE"
  echo "$PATTERN" >> "$GI_FILE"
  echo "  + Added $PATTERN to .gitignore"
}

# ---------- validate ----------

validate_target() {
  TARGET_DIR="$(cd "$TARGET" 2>/dev/null && pwd || echo "")"
  AGENTS_DIR="$TARGET_DIR/.agents"

  if [ ! -d "$AGENTS_DIR" ]; then
    echo "Error: .agents/ directory not found in $TARGET_DIR" >&2
    echo 'Run "agents-spec init" first.' >&2
    exit 1
  fi

  errors=0

  # Check project-level directory structure
  for dir in rules skills local/rules local/skills; do
    if [ ! -d "$AGENTS_DIR/$dir" ]; then
      echo "  Missing directory: .agents/$dir" >&2
      errors=$((errors + 1))
    fi
  done

  # Check user-level directory structure
  for dir in rules skills local/rules local/skills; do
    if [ ! -d "$USER_AGENT/$dir" ]; then
      echo "  Missing user directory: ~/.agent/$dir" >&2
      errors=$((errors + 1))
    fi
  done

  # Check encoding (ASCII only) in .md files
  enc_errors=0
  for file in $(find "$AGENTS_DIR" -name "*.md" -not -path "*/local/*" 2>/dev/null); do
    # Detect non-ASCII bytes (0x80-0xFF)
    if awk '/[\x80-\xFF]/ { found=1; exit } END { exit !found }' "$file" 2>/dev/null; then
      rel="$(echo "$file" | sed "s|$AGENTS_DIR/||")"
      echo "  Non-ASCII char in .agents/$rel" >&2
      enc_errors=$((enc_errors + 1))
    fi
  done

  # Check AGENTS.md exists
  if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
    echo "  Missing AGENTS.md" >&2
    errors=$((errors + 1))
  fi

  if [ $errors -eq 0 ] && [ $enc_errors -eq 0 ]; then
    echo "All checks passed. The .agents/ framework is valid."
  else
    echo ""
    total=$((errors + enc_errors))
    echo "$total issue(s) found."
    exit 1
  fi
}

# ---------- list ----------

list_target() {
  TARGET_DIR="$(cd "$TARGET" 2>/dev/null && pwd || echo "")"
  AGENTS_DIR="$TARGET_DIR/.agents"

  if [ ! -d "$AGENTS_DIR" ]; then
    echo "Error: .agents/ directory not found." >&2
    exit 1
  fi

  list_category() {
    LABEL="$1"
    DIR="$2"
    if [ ! -d "$DIR" ]; then
      echo "  $LABEL (0)"
      return
    fi
    count=0
    names=""
    for entry in "$DIR"/*/; do
      [ -d "$entry" ] || continue
      name="$(basename "$entry")"
      count=$((count + 1))
      if [ -f "$entry/SKILL.md" ]; then
        names="$names    - $name (skill)
"
      else
        names="$names    - $name
"
      fi
    done
    echo "  $LABEL ($count):"
    if [ -n "$names" ]; then
      printf "%s" "$names"
    fi
  }

  echo "=== Project-level (.agents/) ==="
  echo ""
  list_category "Shared Skills" "$AGENTS_DIR/skills"
  list_category "Shared Rules" "$AGENTS_DIR/rules"
  list_category "Local Skills" "$AGENTS_DIR/local/skills"
  list_category "Local Rules" "$AGENTS_DIR/local/rules"

  # Also list .md rule files directly in rules/
  if [ -d "$AGENTS_DIR/rules" ]; then
    for f in "$AGENTS_DIR/rules"/*.md; do
      [ -f "$f" ] || continue
      echo "    - $(basename "$f" .md) (rule file)"
    done
  fi

  echo ""
  echo "=== User-level (~/.agent/) ==="
  echo ""
  list_category "User Skills" "$USER_AGENT/skills"
  list_category "User Rules" "$USER_AGENT/rules"
  list_category "User Local Skills" "$USER_AGENT/local/skills"
  list_category "User Local Rules" "$USER_AGENT/local/rules"
}

# ---------- main ----------

case "$CMD" in
  init)
    init_target
    ;;
  validate)
    validate_target
    ;;
  list)
    list_target
    ;;
  help|--help|-h|*)
    echo "agents-spec - Manage the .agents/ framework"
    echo ""
    echo "Usage:"
    echo "  sh bin/agents-spec.sh init [target-dir]     Initialize .agents/ in a project"
    echo "  sh bin/agents-spec.sh validate [target-dir]  Validate .agents/ setup"
    echo "  sh bin/agents-spec.sh list [target-dir]      List skills and rules"
    echo "  sh bin/agents-spec.sh help                   Show this help"
    echo ""
    echo "No Node.js required. Only sh + mkdir + cp + grep + awk."
    ;;
esac
