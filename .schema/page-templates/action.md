# Action Page Template

Use this template for GTD action list pages in `wiki/actions/`.
There are four action files: `next.md`, `waiting.md`, `someday.md`, `delegated.md`.

## Template

```yaml
---
type: action
title: "Next Actions" | "Waiting For" | "Someday/Maybe" | "Delegated"
updated: YYYY-MM-DD
---
```

## Items

Each action item follows this format:
```markdown
- [ ] Action description | source: wiki/path/or/raw/path | added: YYYY-MM-DD
```

Completed items:
```markdown
- [x] Action description | source: wiki/path/or/raw/path | completed: YYYY-MM-DD
```

## Rules
1. New actions extracted during `/ingest` go to the appropriate file
2. `/review` moves stale items to `someday.md` and suggests completions
3. `/lint` cleans completed items older than 30 days
4. Keep items sorted: unchecked first, then checked (most recent first)
