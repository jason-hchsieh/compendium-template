---
type: concept
title: "LLM Wiki Pattern"
tags: [knowledge-management, llm, pkm, automation]
sources: [raw/resources/knowledge-management/2026-04-09-15-04-llm-wiki-pattern.md]
related: [wiki/entities/andrej-karpathy.md]
created: 2026-04-09
updated: 2026-04-09
---

## Definition
The LLM Wiki Pattern is a personal knowledge management approach where a human curates raw sources and asks questions, while an LLM handles all maintenance and compilation of a structured wiki. It combines GTD, PARA, and LLM-driven automation (LPKD — LLM-powered knowledge distillation).

## Key Points
- The human's role is to curate sources (adding URLs, notes, files) and ask questions — not to maintain the wiki itself. (source: raw/resources/knowledge-management/2026-04-09-15-04-llm-wiki-pattern.md)
- The LLM's role is to compile raw inputs into a structured knowledge network: creating, updating, and cross-referencing pages. (source: raw/resources/knowledge-management/2026-04-09-15-04-llm-wiki-pattern.md)
- The pattern separates concerns cleanly: `inbox/` for human input, `raw/` for preserved sources, `wiki/` for LLM-managed output. (source: raw/resources/knowledge-management/2026-04-09-15-04-llm-wiki-pattern.md)
- Key operations are `/capture` (zero-friction input), `/ingest` (LLM compilation), `/query` (retrieval), and `/review` (maintenance). (source: raw/resources/knowledge-management/2026-04-09-15-04-llm-wiki-pattern.md)

## Relations
- [Andrej Karpathy](wiki/entities/andrej-karpathy.md) — original author who proposed and documented this pattern

## Source Notes
### From: [LLM Wiki Pattern capture](raw/resources/knowledge-management/2026-04-09-15-04-llm-wiki-pattern.md)
Karpathy's gist describes using LLMs as the "librarian" of a personal wiki: the human feeds in sources, the LLM maintains structure, cross-references, and distillation. The core insight is the division of labor — humans are good at curation and judgment, LLMs are good at tireless maintenance.
