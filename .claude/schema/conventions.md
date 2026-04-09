# Conventions

## File Naming

### inbox/
- Format: `YYYY-MM-DD-HH-MM-<slug>.md`
- Slug: lowercase, hyphens, derived from content (e.g., `attention-thought`)
- Example: `2026-04-09-14-30-attention-thought.md`

### raw/
- Subdirectories: lowercase, hyphens (e.g., `machine-learning/`)
- Files keep their original name when moved from inbox

### wiki/
- File names: lowercase, hyphens, descriptive (e.g., `transformer-architecture.md`)
- Must be unique across all wiki subdirectories

## Cross-References

Use relative paths from the repository root:
- `wiki/concepts/transformer.md` (not `../concepts/transformer.md`)
- `raw/resources/machine-learning/attention-paper.pdf`

## Index Files

### wiki/index.md (top-level)
```markdown
# Knowledge Index

## Stats
- Concepts: N | Entities: N | Syntheses: N
- Last updated: YYYY-MM-DD

## Concepts
Recently active: name1, name2, name3
Full list → concepts/_index.md

## Entities
Recently active: name1, name2, name3
Full list → entities/_index.md

## Syntheses
Recently added: name1, name2, name3
Full list → syntheses/_index.md

## Recent Activity
(Last 5 operations from log.jsonl)
```

### Sub-indexes (_index.md)
One entry per page:
```markdown
- [Page Title](filename.md) — one-line summary | tags: [t1, t2] | updated: YYYY-MM-DD
```

## log.jsonl Format

One JSON object per line. Fields:

| Field | Type | Present In | Description |
|-------|------|-----------|-------------|
| `ts` | string (ISO 8601) | all | Timestamp |
| `op` | string | all | Operation: `capture`, `ingest`, `query`, `review`, `lint` |
| `title` | string | all | Human-readable description |
| `source` | string | capture, ingest | Input file path |
| `dest` | string | ingest | Destination in `raw/` |
| `created` | string[] | ingest, query | New wiki pages created |
| `updated` | string[] | ingest, query, lint | Wiki pages modified |
| `actions` | object[] | ingest | Extracted actions: `[{"type": "next", "text": "..."}]` |
| `stats` | object | review, lint | Operation-specific statistics |
| `report` | string | review | Path to review report |

Example:
```json
{"ts":"2026-04-09T14:30:00","op":"ingest","title":"Attention Is All You Need","source":"inbox/attention-paper.pdf","dest":"raw/resources/machine-learning/","created":["wiki/entities/attention-is-all-you-need.md"],"updated":["wiki/concepts/transformer.md"],"actions":[{"type":"next","text":"Read the follow-up paper on multi-head attention"}]}
```
