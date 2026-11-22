# Wyniki eksperymentu (22.11.2026)

Claude Code 2.1.330, model domyślny Opus 5.5, `claude -p --permission-mode auto`, projekt `template/` (mini-kalkulator).
Zadanie: *„Dodaj do calc.py funkcję divide(a, b), która przy dzieleniu przez zero rzuca ValueError, razem z testami.”*
Powtórzenie: `./demo/stare-nawyki/eksperyment.sh 3`

| Wariant CLAUDE.md | Przebiegi | Wynik | Śr. koszt | Śr. czas | Śr. tokeny wyjściowe |
|---|---|---|---|---|---|
| **bloated** (271 słów, 13 „starych” reguł) | 3 | **3/3 ZABLOKOWANE** — `API Error: Opus 5.5's safeguards flagged this message … [reasoning_extraction]` | $0.125 (za nic) | 11 s | 142 |
| **noscratch** (bloated bez jednej linii o `<scratchpad>`) | 3 | 3/3 OK | $0.167 | 20 s | 1468 |
| **lean** (28 słów, 3 reguły) | 3 | 3/3 OK | $0.164 | 22 s | 1269 |

## Wnioski (uczciwie)

1. **Jedna linijka zabiła wszystko.** „Before every tool call, write your reasoning in a `<scratchpad>` block” — prośba o wypisywanie rozumowania — na Opus 5.5 uruchamia zabezpieczenie `reasoning_extraction`. Zero kodu, zapłacone tokeny. `/doctor prompt-audit` wskazał dokładnie tę linię jako finding #1 („can be refused (`reasoning_extraction`)”).
2. **Reszta balastu na tym zadaniu nic nie kosztowała, ale też nic nie dała.** Kod z `noscratch` i `lean` był praktycznie identyczny; koszt i czas w granicach szumu (n=3). Opus 5.5 sam zauważył sprzeczne reguły o docstringach i wybrał rozsądny środek.
3. **Ważne zastrzeżenie:** mały projekt i trywialne zadanie, n=3 — to anegdota, nie benchmark. Przy dużym repo reguła „przeczytaj KAŻDY plik” kosztowałaby realnie (Lance Martin pokazuje to na benchmarkach).
4. **Zachowanie modeli się zmienia.** Powtórz eksperyment dzień przed wystąpieniem.

Request ID zablokowanych przebiegów (dowód): `req_011ChJiiEKzHQ84968hXdVCn`, `req_011ChJiiDhXc9Twn6TYxovVe`.
