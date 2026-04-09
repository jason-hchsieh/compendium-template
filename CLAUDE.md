# LLM Wiki

Personal knowledge management system: GTD + PARA + LPKD.

## Structure
- `inbox/` — Unprocessed inputs (GTD capture)
- `raw/` — Human-curated sources (PARA structure, never modify content)
- `wiki/` — LLM-managed knowledge network (humans read, don't edit)

## Golden Rules
1. Never modify the content of files in `raw/` (structural moves like archiving are OK)
2. Update `log.jsonl` after every operation
3. Create a git commit after every operation (see Git section below)
4. Update all affected cross-references when changing wiki pages

## Operations
Read the corresponding skill file **before** executing any operation:
- `/capture` → `.skills/capture.md`
- `/ingest` → `.skills/ingest.md`
- `/query` → `.skills/query.md`
- `/review` → `.skills/review.md`
- `/lint` → `.skills/lint.md`
- `/status` → `.skills/status.md`

## Conventions
Page formats, frontmatter spec, and templates → `.schema/`

## Git
Every operation ends with a structured commit:

```
[operation] title

- created: file1.md, file2.md
- updated: file3.md, file4.md
- moved: inbox/xxx.md → raw/category/topic/
```

Stage only files changed by the operation. Do not use `git add -A`.
