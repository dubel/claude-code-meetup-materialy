#!/usr/bin/env bash
# Tworzy dwie świeże kopie projektu demo: z zarośniętym i z odchudzonym CLAUDE.md.
# Użycie: ./demo/stare-nawyki/setup.sh [katalog=~/meetup-zapas]   (FORCE=1 nadpisuje)
set -euo pipefail
src="$(cd "$(dirname "$0")" && pwd)/template"
base="${1:-$HOME/meetup-zapas}"
if [[ -e "$base" ]]; then
  [[ "${FORCE:-0}" == "1" ]] || { echo "Istnieje: $base (uruchom z FORCE=1, żeby nadpisać)" >&2; exit 1; }
  rm -rf "$base"
fi
for v in bloated lean; do
  d="$base/$v"; mkdir -p "$d"
  cp "$src/calc.py" "$src/test_calc.py" "$d/"
  cp "$src/CLAUDE.$v.md" "$d/CLAUDE.md"
  cp "$src/gitignore.template" "$d/.gitignore"
  (cd "$d" && git init -q -b main && git add -A && git -c user.name=Demo -c user.email=demo@example.com commit -qm "Initial demo project")
done
echo "Gotowe: $base/bloated  i  $base/lean"
