#!/usr/bin/env bash
# Mierzy to samo zadanie z różnymi wersjami CLAUDE.md.
# Użycie: ./demo/stare-nawyki/eksperyment.sh [liczba_przebiegów=3] [warianty...]
# Warianty: bloated (zarośnięty), noscratch (zarośnięty bez linii o <scratchpad>), lean (odchudzony)
# Koszt: ok. $0.13–0.20 za przebieg. Przebiegi idą równolegle.
set -uo pipefail

N="${1:-3}"; shift || true
VARIANTS=("${@:-bloated noscratch lean}")
read -r -a VARIANTS <<<"${VARIANTS[*]}"
T="$(cd "$(dirname "$0")" && pwd)/template"
OUT="$(mktemp -d -t claude-exp)"
PROMPT="Dodaj do calc.py funkcję divide(a, b), która przy dzieleniu przez zero rzuca ValueError, razem z testami."

for v in "${VARIANTS[@]}"; do
  for r in $(seq 1 "$N"); do
    d="$OUT/$v-$r"; mkdir -p "$d"
    cp "$T/calc.py" "$T/test_calc.py" "$d/"
    cp "$T/CLAUDE.$v.md" "$d/CLAUDE.md"
    ( cd "$d" && git init -q && git add -A && git -c user.name=d -c user.email=d@example.com commit -qm init \
      && claude -p "$PROMPT" --permission-mode auto --output-format json > "$OUT/$v-$r.json" 2>/dev/null ) &
  done
done
wait

printf "%-12s %6s %8s %6s %10s %8s %s\n" wariant tury koszt_usd czas_s tok_wejsc tok_wyjsc wynik
for f in "$OUT"/*-*.json; do
  name=$(basename "$f" .json); dir="$OUT/$name"
  if jq -e '.result | test("API Error")' "$f" >/dev/null 2>&1; then status="ZABLOKOWANE: $(jq -r '.result' "$f" | grep -o '\[[a-z_]*\]' | head -1)"
  elif (cd "$dir" && grep -q "def divide" calc.py && python3 -m unittest -q >/dev/null 2>&1); then status="OK"
  else status="NIE ZROBIONE"; fi
  jq -r --arg n "$name" --arg s "$status" \
    '[$n, .num_turns, (.total_cost_usd*1000|round/1000), (.duration_ms/1000|round),
      (.usage.input_tokens + .usage.cache_read_input_tokens + .usage.cache_creation_input_tokens),
      .usage.output_tokens, $s] | @tsv' "$f"
done | sort | awk -F'\t' '{printf "%-12s %6s %8s %6s %10s %8s %s\n",$1,$2,$3,$4,$5,$6,$7}'
echo "Katalogi przebiegów: $OUT"
