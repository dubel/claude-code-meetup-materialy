#!/usr/bin/env bash
# PreToolUse(Bash) — trzy polityki: sekrety, rm, testy przed commitem.
# Odmowa = JSON z permissionDecision "deny"; powód trafia do Claude'a.
set -uo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
dir=${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // "."' <<<"$input")}

deny() {
  jq -n --arg r "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

# 1) Sekrety: żadnej komendy dotykającej .env (ale .env.example jest OK)
if grep -Eq '(^|[^A-Za-z0-9_.-])\.env($|[^A-Za-z0-9_.-])' <<<"$cmd"; then
  deny "POLITYKA sekrety: plik .env jest poza zasięgiem agenta. Strukturę konfiguracji znajdziesz w .env.example i config.py. Jeśli potrzebujesz wartości — poproś człowieka o weryfikację."
fi

# 2) Nieodwracalne usuwanie: zamiast rm przenieś do .trash/
if grep -Eq "(^|[[:space:];&|(\`\"'])(sudo[[:space:]]+)?(/usr)?(/bin/)?rm[[:space:]]" <<<"$cmd"; then
  deny "POLITYKA usuwanie: rm jest zablokowane (nieodwracalne). Przenieś pliki do kosza w repo: mkdir -p .trash && mv <ścieżka> .trash/"
fi

# 3) Commit tylko przy zielonych testach
if grep -Eq '(^|[[:space:];&|])git[[:space:]]+commit' <<<"$cmd"; then
  if ! out=$(cd "$dir" && python3 -m unittest -q 2>&1); then
    deny "POLITYKA testy: commit zablokowany — testy nie przechodzą. Napraw je i spróbuj ponownie. Ostatnie linie wyniku:
$(tail -n 15 <<<"$out")"
  fi
fi

exit 0
