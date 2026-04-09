# Entity Page Template

Use this template when creating a new `wiki/entities/` page.
Entities represent concrete things with identity: people, companies, tools, papers.

## Template

```yaml
---
type: entity
title: "Entity Name"
tags: []
sources: []
related: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Basic Info
- **Type**: person | company | tool | paper | other
- **Key facts**: Brief identifying information

## Key Points
- Key point derived from sources
- Each point should cite its source: (source: raw/path/to/file.md)

## Relations
- [Related Concept](wiki/concepts/related.md) — how this entity relates to the concept
- [Related Entity](wiki/entities/related.md) — relationship description

## Source Notes
### From: [Source Title](raw/path/to/source.md)
Key takeaways from this specific source.
