#!/usr/bin/env bash
# PreToolUse(Read|Edit|Write|Grep) — blokuje dostęp do plików z sekretami.
set -uo pipefail

input=$(cat)
path=$(jq -r '.tool_input.file_path // .tool_input.path // ""' <<<"$input")
base=$(basename "$path" 2>/dev/null || true)

if [[ "$base" == ".env" || "$base" =~ ^\.env\.(local|prod|production|dev)$ ]]; then
  jq -n --arg r "POLITYKA sekrety: $base jest poza zasięgiem agenta. Użyj .env.example i config.py, a o wartości zapytaj człowieka." \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
fi
exit 0
