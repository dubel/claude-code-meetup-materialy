#!/usr/bin/env bash
# Tworzy świeżą kopię projektu demo + lokalny "origin" (bare repo).
# Użycie: ./demo/hooki/setup.sh [katalog]   (domyślnie ~/meetup-demo)
#         FORCE=1 ./demo/hooki/setup.sh        (nadpisuje istniejący katalog — do prób)
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)/template"
dest="${1:-$HOME/meetup-demo}"
origin="${dest}-origin.git"

if [[ -e "$dest" || -e "$origin" ]]; then
  if [[ "${FORCE:-0}" == "1" ]]; then
    rm -rf "$dest" "$origin"
  else
    echo "Istnieje: $dest (lub $origin). Uruchom z FORCE=1, żeby nadpisać." >&2
    exit 1
  fi
fi

cp -R "$src/." "$dest"
cd "$dest"
mv gitignore.template .gitignore
chmod +x .claude/hooks/*.sh old_scripts/*.sh

git init -q -b main
git add -A
git -c user.name="Demo" -c user.email="demo@example.com" commit -q -m "Initial demo project"

git init -q --bare "$origin"
git remote add origin "$origin"
git push -q -u origin main

echo "Gotowe: $dest"
echo "Start:  cd $dest && claude --permission-mode auto"
