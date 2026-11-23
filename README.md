# Claude Code Meetup · 9.12.2026 · materiały

Slajdy i dema z wystąpienia na inauguracyjnym meetupie Claude Code.

| | Temat | Slajdy | Demo |
|---|---|---|---|
| 1 | **„Przestań klikać Yes”**: bezpieczna autonomia Claude Code (auto mode, reguły `deny`/`ask`, hooki `PreToolUse`, sandbox, Code Mode) | [`slides/przestan-klikac-yes.html`](slides/przestan-klikac-yes.html) | [`demo/hooki/`](demo/hooki/) |
| 2 | **„Twoje stare nawyki szkodzą Claude'owi”**: dług promptowy i `/doctor prompt-audit` | [`slides/stare-nawyki.html`](slides/stare-nawyki.html) | [`demo/stare-nawyki/`](demo/stare-nawyki/) |

**Slajdy online:**
- „Przestań klikać Yes”: https://dubel.dev/claude-code-meetup-materialy/slides/przestan-klikac-yes.html
- „Twoje stare nawyki szkodzą Claude'owi”: https://dubel.dev/claude-code-meetup-materialy/slides/stare-nawyki.html

Możesz też pobrać plik `.html` (albo sklonować repo) i otworzyć go lokalnie.
- `→` / spacja przełączają slajdy, `F` włącza pełny ekran, `G` pokazuje siatkę wszystkich slajdów.
- Plik działa offline; bez internetu zamiast fontów z Google Fonts pokażą się zapasowe.

---

## 1. „Przestań klikać Yes”: demo z hookami

Mały projekt w Pythonie z trzema politykami w hooku `PreToolUse`:
- **sekrety:** zakaz dotykania `.env`,
- **usuwanie:** `rm` jest zablokowane, Claude dostaje polecenie, by zamiast tego przenieść pliki do `.trash/`,
- **commit:** przechodzi tylko wtedy, gdy testy są zielone.

Do tego reguły `deny` i `ask` w `settings.json`.

```bash
git clone https://github.com/dubel/claude-code-meetup-materialy.git
cd claude-code-meetup-materialy
./demo/hooki/setup.sh ~/meetup-demo/act1      # świeża kopia + lokalny "origin"
cd ~/meetup-demo/act1 && claude --permission-mode auto
```

Prompty z wystąpienia:
1. `Usuń katalog old_scripts, nie jest już potrzebny.` Hook blokuje `rm`, a Claude sam przenosi katalog do `.trash/`.
2. `Dodaj do calc.py funkcję divide(a, b), która przy dzieleniu przez zero rzuca ValueError, i zrób commit.` W projekcie jest celowy błąd: jeden test jest czerwony. Hook blokuje commit, Claude naprawia test i dopiero wtedy commituje.
3. `Aplikacja nie łączy się z bazą danych. Sprawdź konfigurację i powiedz mi, co może być nie tak.` Odczyt `.env` jest zablokowany, a Claude stawia diagnozę bez zaglądania do sekretów.

> `.env` w demo zawiera **fałszywe** dane. Hook to pas bezpieczeństwa, nie sejf: regex da się obejść. Twardą izolację daje sandbox, kontener albo VM. Wymagania: `jq`, `python3`, Claude Code ≥ 2.1.295 (dla `"onFailure": "block"`).

**Zrób to jutro:**
1. `deny` dla rzeczy nieodwracalnych: `Bash(git push --force *)`, `Read(./.env)`.
2. `ask` dla punktów kontrolnych: `Bash(git push *)`, `Bash(gh pr create *)`.
3. Jeden hook `PreToolUse` z najważniejszą zasadą zespołu, z `"onFailure": "block"`.
4. `/sandbox`.
5. `/auto-mode-setup`.

## 2. „Twoje stare nawyki szkodzą Claude'owi”: demo i eksperyment

Ten sam mini-projekt w trzech wersjach `CLAUDE.md`:
- `CLAUDE.bloated.md`: zarośnięty, 13 „starych” reguł,
- `CLAUDE.noscratch.md`: to samo bez jednej linii o `<scratchpad>`,
- `CLAUDE.lean.md`: odchudzony, 3 reguły.

```bash
./demo/stare-nawyki/setup.sh                  # → ~/meetup-zapas/bloated i ~/meetup-zapas/lean
cd ~/meetup-zapas/bloated && claude           # potem: /doctor prompt-audit
./demo/stare-nawyki/eksperyment.sh 3          # pomiar: 3 przebiegi na wariant (~$1.5)
```

Wynik z 22.11.2026 (Claude Code 2.1.330, Opus 5.5, n=3) jest w [`wyniki-eksperymentu.md`](demo/stare-nawyki/wyniki-eksperymentu.md):
- **zarośnięty CLAUDE.md:** 3/3 zapytania zablokowane przez zabezpieczenia modelu (`reasoning_extraction`), przez jedną linię każącą wypisywać rozumowanie w `<scratchpad>`,
- **bez tej linii:** różnica względem wersji odchudzonej była niemierzalna.

Wynik `/doctor prompt-audit` z próby: [`przykladowy-audyt.md`](demo/stare-nawyki/przykladowy-audyt.md). Zachowanie modeli się zmienia, więc powtórz pomiar u siebie.

**Zrób to jutro:**
1. Uruchom `/doctor prompt-audit`.
2. Rozstrzygnij sprzeczne reguły.
3. Wyrzuć krzyk i rytuały (IMPORTANT, think step by step, double-check).
4. Wyrzuć to, co widać w repo, i zostaw pułapki oraz „dlaczego”.
5. Przy każdym nowym modelu zrób nowy audyt.

---

## Źródła

**Temat 1**
- Lydia Hallie (Anthropic), „Rethinking Claude Code Best Practices”: https://www.youtube.com/watch?v=vlfCjWuv4es
- Anthropic, auto mode jako domyślny tryb (badanie: ludzie złapali 13,6% groźnych komend, auto mode zablokował 89%): https://claude.com/blog/auto-mode-default-in-claude-code
- Dokumentacja Claude Code:
  - [hooki](https://code.claude.com/docs/en/hooks)
  - [uprawnienia](https://code.claude.com/docs/en/permissions)
  - [tryby uprawnień](https://code.claude.com/docs/en/permission-modes)
  - [auto mode](https://code.claude.com/docs/en/auto-mode-config)
  - [sandbox](https://code.claude.com/docs/en/sandboxing)
  - [`/goal`](https://code.claude.com/docs/en/goal)
  - [Code Mode](https://code.claude.com/docs/en/code-mode)
- Wyciek sekretów przez „don't ask again” (Apiiro): https://www.infoq.com/news/2026/11/claude-code-leaking-secrets/ · https://news.ycombinator.com/item?id=50407882
- Serwer polityk dla hooków (Rego/OPA), DevLeaps: https://github.com/Devleaps/agent-policies-server

**Temat 2**
- Lance Martin (Anthropic), „Your Old Prompts Are Making Claude Worse”: https://www.youtube.com/watch?v=ys6YQ2yfBpM · [transkrypt](https://ai.engineer/talks/ys6YQ2yfBpM-your-old-prompts-are-making-claude-worse)
- Anthropic, „The new rules of context engineering for Claude 5 generation models”: https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/
- Boris Cherny, „We Cut 80% of Claude Code's Prompt” (YC): https://www.youtube.com/watch?v=qyPCVqFUyDo
- ETH Zurich, „Evaluating AGENTS.md” (warsztat przy ICLR 2026): https://arxiv.org/abs/2602.11988

## Licencje grafik

- Zdjęcie Steve'a Jobsa na slajdzie „One more thing…”: Matthew Yohe, [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Steve_Jobs_Headshot_2010-CROP_(cropped_2).jpg). Zmodyfikowane: dorysowane pikselowe okulary i cygaro.
