<!-- Wynik `claude -p "/doctor prompt-audit"` na demo/stare-nawyki/template (CLAUDE.md = wersja zarośnięta),
     Claude Code 2.1.330, Opus 5.5, 22.11.2026. Usunięto wiersze o lokalnej konfiguracji użytkownika. -->

# Prompt audit: Claude Code configuration for this project

**Scope:** only the Claude Code configuration that loads in this project. I proposed edits but didn't apply any, because the request didn't ask for that.
**Target model:** Claude Opus 5.5 (`claude-opus-5-5`), the model this session runs on. None of the audited files pins its own model.
**History:** the repository has one commit (`d3eec66 init`), so `git blame` can't show when or why any line was added. Every finding below relies on Opus 5.5's documented behaviour or on the repository's current contents.

## What I looked at

| Location | Result |
|---|---|
| `./CLAUDE.md` (33 lines) | **Audited.** It has no `@` imports. |
| Nested `CLAUDE.md` / `CLAUDE.local.md` / `AGENTS.md`, `.claude/CLAUDE.md`, `.claude/AGENTS.md`, `.claude/{rules,skills,commands,agents,output-styles}` | None exist. |

## Summary

`CLAUDE.md` is mostly prompting habits written for older models, and three things matter most:

1. **Two pairs of rules flatly contradict each other.** Line 14 says to always write a detailed docstring; line 15 says not to add docstrings unless necessary. Line 16 says to always ask when something is unclear; line 17 says never to ask. The model has to guess which rule wins each time. Only you can decide which one should stay.
2. **Line 11 asks for visible reasoning in `<scratchpad>` before every tool call.** On Opus 5.5, asking the model to write its reasoning into the reply can be refused (`reasoning_extraction`). Thinking is always on anyway, so the line adds risk and nothing else. Line 7 ("think step by step") is redundant for the same reason.
3. **Most other rules are shouted** ("CRITICAL", "NEVER EVER…!!!", "read EVERY file", "check it again"). On a model that follows instructions closely, this leads to over-reading, over-checking and rigid behaviour. The one real constraint, not modifying existing tests, should stay, written at normal volume.

**Findings by group:**
- **Group 1 (dated prompt text):** 9
- **Group 2 (configuration files):** 4
- **Group 3 (tool names in the prompt):** 1
- **Group 4 (request code):** not applicable, because the project never calls the API.

## Findings (highest confidence first)

| # | Location | Evidence | Pattern | Why it no longer fits | Confidence | Action |
|---|---|---|---|---|---|---|
| 1 | `CLAUDE.md:11` | "Before every tool call, write your reasoning in a `<scratchpad>` block." | 1b: `<scratchpad>` / "show your thinking" | Opus 5.5 always thinks. Asking it to repeat its reasoning in the reply can be refused (`reasoning_extraction`), and it clutters every turn. | High | remove |
| 2 | `CLAUDE.md:7` | "ALWAYS think step by step before doing anything. Think carefully and thoroughly." | 1b: "think step by step"; prose that steers how much the model thinks | Thinking is always on in Opus 5.5, and the effort setting controls how deep it goes. This isn't a keyword Claude Code acts on, so it's just prose. | High | remove |
| 3 | `CLAUDE.md:12` | "Use the TodoWrite tool for EVERY task, even trivial ones, and update it after every step." | Group 3: tool name in the prompt; 1f: fixed update cadence | There is no `TodoWrite` tool in this session, so the rule points at nothing. Forcing a task list for trivial tasks and updating it every step is scripting the model doesn't need. | High | remove |
| 4 | `CLAUDE.md:9` | "Be maximally thorough. Never skip anything. Consider every possible edge case." | 1a: "Be thorough. Do not be lazy." | Current models are thorough without being told. This line pushes toward scope creep, and "every possible edge case" also works against line 15 ("Keep the code minimal"). | High | remove |
| 5 | `CLAUDE.md:8` | "CRITICAL: Before making ANY change, read EVERY file in the repository…" | 1a: CRITICAL/MUST; 1c: over-specified method | The model reads what a change needs without being told. Taken literally, "every file" wastes context as soon as the repository grows. The goal is fine; the shouting and "every" are the problem. | High | rewrite: "Read the code a change touches, and its tests, before editing it." |
| 6 | `CLAUDE.md:13` | "NEVER EVER modify existing tests!!! This is EXTREMELY IMPORTANT." | 1a: several IMPORTANT/NEVER rules, `!!` | This is a real constraint, so it stays. The volume makes the model rigid in edge cases, such as when a test is genuinely wrong. | High | rewrite: "Don't modify existing tests. If one looks wrong, say so instead of changing it." (Add your reason if there is one.) |
| 7 | `CLAUDE.md:5` | "## IMPORTANT RULES (READ CAREFULLY!!!)" | 1a: emphasis in the heading | When every rule is "important", the label carries no information, and an anxious prompt produces cautious, hedging output. | High | rewrite: "## Rules" |
| 8 | `CLAUDE.md:14` vs `:15` | "YOU MUST ALWAYS write a detailed docstring for every function, including Args, Returns, Raises and Examples." vs "Do not add comments or docstrings unless absolutely necessary." | Group 2: rules that contradict each other | Opposite rules on the same point, and history can't say which is newer. `calc.py` follows neither strictly: `add` has no docstring and `percent` has a one-line one. | High (it is a conflict) | **flag.** You decide. Option A: "Keep docstrings short; add one where the behaviour isn't obvious from the signature" (matches `calc.py` today). Option B: keep the full Args/Returns/Raises/Examples rule and delete line 15. |
| 9 | `CLAUDE.md:16` vs `:17` | "If anything is unclear, ALWAYS ask the user before proceeding." vs "Never ask the user questions. Just proceed autonomously." | Group 2: rules that contradict each other | Opposite rules, and history can't order them. | High (it is a conflict) | **flag.** You decide. A common middle ground: "Make routine decisions yourself; ask before anything ambiguous that would be costly to undo." |
| 10 | `CLAUDE.md:33` | "ALWAYS run the tests. Run them before and after every change. Make sure they pass." | 1a: pressure language; 1c: scripted steps | The test command on line 32 is correct and stays. The shouting and "before and after every change" add nothing to the real requirement, which is that tests pass before the work is done. | Medium | rewrite: "Run the tests after a change; they must pass before you finish." |
| 11 | `CLAUDE.md:10` | "IMPORTANT: Double-check your work before finishing. Then check it again." | 1a: pressure; 1c: repetition as reinforcement | "Then check it again" invites over-checking. Running the tests (line 33) already covers verification. | Medium | remove |
| 12 | `CLAUDE.md:21` | "Python is a high-level, interpreted programming language." | Group 2: explaining things the model already knows | General knowledge the model already has. The first sentence on that line ("written in Python") is the useful part and stays. | Medium | remove (that sentence only) |
| 13 | `CLAUDE.md:3` | "…You write world-class, production-ready code." | 1c: generic virtues | Generic virtues add no information. A one-line role statement is fine on its own, so only the second sentence goes. | Medium | remove (second sentence only) |
| 14 | `CLAUDE.md:22-25` | "The project contains the following files:" | Group 2: facts that drift out of date | Every listed path exists. But the repository also tracks `CLAUDE.bloated.md`, `CLAUDE.lean.md` and `gitignore.template`, so "contains the following files" reads as a complete list and isn't one. Whether that matters is up to you. | Low | flag |

Checked and fine: `python3 -m unittest -q` on line 32 does find `test_calc.py`, the default `test*.py` pattern (I read the files rather than running anything). The file and function descriptions on lines 23–28 match `calc.py`. The overlap between lines 23–24 and 27–28 is harmless repetition, so I left it alone.

## Proposed diff

Everything is in the project's `CLAUDE.md`. Nothing under `~/.claude` or in parent directories changes. There is one hunk per finding so you can take them separately. Findings 8, 9 and 14 are flagged and aren't in the diff.

```diff
# Finding 13 (CLAUDE.md:3)
-You are an expert senior Python developer with 20+ years of experience and deep knowledge of software engineering best practices. You write world-class, production-ready code.
+You are an expert senior Python developer with 20+ years of experience and deep knowledge of software engineering best practices.
```
```diff
# Finding 7 (CLAUDE.md:5)
-## IMPORTANT RULES (READ CAREFULLY!!!)
+## Rules
```
```diff
# Finding 2 (CLAUDE.md:7)
-- ALWAYS think step by step before doing anything. Think carefully and thoroughly.
```
```diff
# Finding 5 (CLAUDE.md:8)
-- CRITICAL: Before making ANY change, read EVERY file in the repository so you fully understand the codebase.
+- Read the code a change touches, and its tests, before editing it.
```
```diff
# Finding 4 (CLAUDE.md:9)
-- Be maximally thorough. Never skip anything. Consider every possible edge case.
```
```diff
# Finding 11 (CLAUDE.md:10)
-- IMPORTANT: Double-check your work before finishing. Then check it again.
```
```diff
# Finding 1 (CLAUDE.md:11)
-- Before every tool call, write your reasoning in a <scratchpad> block.
```
```diff
# Finding 3 (CLAUDE.md:12)
-- Use the TodoWrite tool for EVERY task, even trivial ones, and update it after every step.
```
```diff
# Finding 6 (CLAUDE.md:13)
-- NEVER EVER modify existing tests!!! This is EXTREMELY IMPORTANT.
+- Don't modify existing tests. If one looks wrong, say so instead of changing it.
```
```diff
# Finding 12 (CLAUDE.md:21)
-This project is written in Python. Python is a high-level, interpreted programming language.
+This project is written in Python.
```
```diff
# Finding 10 (CLAUDE.md:33)
-ALWAYS run the tests. Run them before and after every change. Make sure they pass.
+Run the tests after a change; they must pass before you finish.
```

If you take every hunk, the Rules section becomes three lines plus the two contradicting pairs (lines 14/15 and 16/17). Each pair should shrink to one line once you've chosen which rule to keep.

## Checking the changes

Removing a rule is a guess about what the model no longer needs, so check the contested ones. Give Claude a typical task in this repository (for example "add a `subtract` function") with the old and the new `CLAUDE.md`. Compare whether it touches tests, how it handles docstrings, and whether it asks questions. Lines 8–11 are the ones most likely to change behaviour.
