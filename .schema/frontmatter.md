# Frontmatter Specification

All `wiki/` pages (except `index.md` and `_index.md`) must include YAML frontmatter.
Action pages (`wiki/actions/*.md`) use a reduced frontmatter — see `.schema/page-templates/action.md`.

## Required Fields

```yaml
---
type: concept | entity | synthesis | action | review
title: "Page Title"
tags: [tag1, tag2]
sources: [raw/path/to/source.md]
related: [wiki/concepts/other-page.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum | Page type: `concept`, `entity`, `synthesis`, `action`, `review` |
| `title` | string | Human-readable page title |
| `tags` | string[] | Categorization tags for filtering and discovery |
| `sources` | string[] | Paths to `raw/` files this page is derived from |
| `related` | string[] | Paths to other `wiki/` pages with meaningful connections |
| `created` | date | Date the page was first created (YYYY-MM-DD) |
| `updated` | date | Date of last modification (YYYY-MM-DD) |

## Rules

1. `sources` paths must point to existing files in `raw/`
2. `related` paths must point to existing files in `wiki/`
3. When updating a page, always update the `updated` field
4. When adding a `related` link, add the reciprocal link on the target page
5. Tags should be lowercase, hyphenated (e.g., `machine-learning`, not `Machine Learning`)

## Capture Frontmatter (inbox/)

Files in `inbox/` use a different, simpler frontmatter:

```yaml
---
type: capture
date: YYYY-MM-DDTHH:MM:SS
attachments:
  - type: image | url | pdf | file
    path: inbox/attachments/filename.ext   # for local files
    url: https://example.com               # for URLs
---
```
