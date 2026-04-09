# LLM Wiki — Design Specification

A shareable application that helps users build a personal knowledge management system combining GTD (Getting Things Done), PARA (Projects/Areas/Resources/Archives), and LPKD (Living Personal Knowledge Database / Karpathy's LLM Wiki pattern).

## Goals & Priorities

1. **Action-oriented** — Extract actionable items from all inputs, surface next actions
2. **Connections & insights** — Automatically discover relationships across sources, generate syntheses
3. **Structured organization** — Classify and maintain knowledge using PARA taxonomy
4. **Search & recall** — Answer questions grounded in the user's own knowledge base

## Target Users

Start with technical users (comfortable with CLI, markdown, git). Lower the barrier over time to reach knowledge workers and general audiences.

## Interaction Model

- **Primary**: CLI via coding agents (Claude Code, Cursor, etc.)
- **Reading**: Obsidian or any markdown editor
- **Future**: Web UI for deeper analysis and visualization

## LLM Strategy

The application does not manage LLM calls directly. It is a well-structured set of markdown files, conventions, and a schema file (`CLAUDE.md`). Users interact through their coding agent of choice. The agent reads `CLAUDE.md` to understand how to behave.

---

## Architecture: Dual-Layer (Raw + Generated)

Human-curated sources and LLM-generated knowledge are strictly separated.

- `raw/` uses PARA structure for human curation
- `wiki/` is fully managed by the LLM
- `inbox/` is a temporary staging area (GTD capture)

### Directory Structure

```
llm-wiki/
├── CLAUDE.md                    # Lightweight entry point — system overview + pointers
├── .skills/                     # Detailed instructions per operation
│   ├── capture.md
│   ├── ingest.md
│   ├── query.md
│   ├── review.md
│   ├── lint.md
│   └── status.md
├── .schema/                     # Conventions and templates
│   ├── frontmatter.md           # Frontmatter spec
│   ├── page-templates/          # Templates per page type
│   │   ├── concept.md
│   │   ├── entity.md
│   │   ├── synthesis.md
│   │   └── action.md
│   └── conventions.md           # Naming, formatting, log format
│
├── inbox/                       # GTD capture — unprocessed inputs go here
│   └── attachments/             # Images, PDFs, etc. attached to captures
│
├── raw/                         # Human-curated sources (immutable by LLM)
│   ├── projects/                # PARA: active projects with deliverables/deadlines
│   ├── areas/                   # PARA: ongoing areas of responsibility
│   ├── resources/               # PARA: reference material by topic
│   └── archives/                # PARA: completed or paused items
│
├── wiki/                        # LLM-managed knowledge network (humans read, not edit)
│   ├── index.md                 # Top-level knowledge map
│   ├── concepts/                # Abstract ideas, methodologies, techniques
│   │   └── _index.md
│   ├── entities/                # Concrete things: people, companies, tools, papers
│   │   └── _index.md
│   ├── syntheses/               # Cross-source analyses, comparisons, insights
│   │   └── _index.md
│   ├── actions/                 # GTD action lists
│   │   ├── next.md
│   │   ├── waiting.md
│   │   ├── someday.md
│   │   └── delegated.md
│   └── reviews/                 # Automated review reports
│       ├── weekly/
│       └── monthly/
│
├── log.jsonl                    # Structured operation log (append-only)
└── .gitignore
```

### Key Rules

1. **`raw/` content is immutable** — the LLM never modifies the content of existing files in `raw/`. Structural operations (moving files from `inbox/` into `raw/`, moving completed projects to `archives/`) are allowed.
2. **`wiki/` is LLM-managed** — humans read via Obsidian but do not hand-edit
3. **`inbox/` is a staging area** — items are processed then moved to `raw/`
4. **Every operation updates `log.jsonl`**
5. **Every operation creates a git commit**
6. **Cross-references must be updated** when any wiki page changes

---

## Schema Design: Progressive Disclosure

`CLAUDE.md` is loaded at the start of every conversation. It must be lightweight — a table of contents, not an encyclopedia. Detailed instructions live in `.skills/` and `.schema/` and are loaded on demand.

### CLAUDE.md Content

```markdown
# LLM Wiki

Personal knowledge management system: GTD + PARA + LPKD.

## Structure
- `inbox/` — Unprocessed inputs (GTD capture)
- `raw/` — Human-curated sources (PARA structure, never modify)
- `wiki/` — LLM-managed knowledge network (humans don't edit)

## Golden Rules
1. Never modify the content of files in raw/ (structural moves like archiving are OK)
2. Update log.jsonl after every operation
3. Create a git commit after every operation
4. Update all affected cross-references when changing wiki pages

## Operations
Read the corresponding skill file before executing:
- `/capture` → .skills/capture.md
- `/ingest` → .skills/ingest.md
- `/query` → .skills/query.md
- `/review` → .skills/review.md
- `/lint` → .skills/lint.md
- `/status` → .skills/status.md

## Conventions
Page formats and templates → .schema/
```

---

## Core Operations

Six operations covering the full GTD cycle: capture → clarify → organize → reflect → engage.

### /capture

Quick, zero-friction input. The user drops any content (text, images, URLs, mixed) into the system.

**Trigger**: User invokes `/capture` or sends content to capture.

**Flow**:
1. Parse all elements in the message (text, images, URLs)
2. Create `inbox/YYYY-MM-DD-HH-MM-<slug>.md` with frontmatter listing attachments
3. Save attachments to `inbox/attachments/`
4. Ask user: ingest now or later?
5. Git commit

**Multi-format handling**: A single capture may contain multiple media types. The atomic unit is the message (thought), not the individual media. Example:

```yaml
---
type: capture
date: 2026-04-09T15:00:00
attachments:
  - type: image
    path: inbox/attachments/screenshot-2026-04-09.png
  - type: url
    url: https://example.com/article
---
[image] reminds me of selective attention — maybe related to https://example.com/article
```

**Git**: `[capture] <title>`

### /ingest

Process inbox items into the knowledge base. The main "compilation" operation.

**Trigger**: Manual (`/ingest` or `/ingest <file>`) or automated.

**Flow** (per inbox item):
1. Scan `inbox/` for unprocessed files (exclude `attachments/`)
2. For each item:
   a. **Parse** — read content, identify all elements (text, images, URLs). Fetch URL summaries. Describe image content.
   b. **Classify** — determine PARA category (projects/areas/resources) and subdirectory. Suggest new subdirectory if needed.
   c. **Extract actions** — if content contains todos, commitments, intentions → update `wiki/actions/` files.
   d. **Update knowledge network** — read `wiki/index.md` to find related pages. Update existing concept/entity pages. Create synthesis pages for cross-source insights. Use templates from `.schema/page-templates/`. Guideline: aim to touch ~10-15 pages per ingest, but let the content dictate scope.
   e. **Update index** — update `wiki/index.md` and relevant `_index.md` files.
   f. **Move source** — `inbox/xxx.md` → `raw/{para_category}/{topic}/` (with attachments).
   g. **Log** — append JSON entry to `log.jsonl`.
   h. **Git commit** — one commit per item (not batched), enabling precise `git revert`.
3. Output summary: items processed, pages created/updated, actions extracted.

**Git**: `[ingest] <title>` (one commit per inbox item)

### /query

Ask questions answered by the knowledge base.

**Trigger**: User invokes `/query <question>`.

**Flow**:
1. Read `wiki/index.md` to find relevant pages
2. Read relevant wiki pages (drill into `raw/` sources if needed)
3. Synthesize answer with source citations (paths to `raw/` and `wiki/` files)
4. If the answer has lasting insight value, save as a new `wiki/syntheses/` page
5. Git commit (only if a new page was created)

**Git**: `[query] add <synthesis title>` (only when writing back)

### /review

Automated periodic reviews.

**Trigger**: Manual (`/review weekly` or `/review monthly`) or scheduled.

**Weekly review**:
- Inbox backlog count
- Actions completed / added / deferred this week
- New knowledge summary (pages created/updated)
- Suggested focus for next week
- Report saved to `wiki/reviews/weekly/YYYY-WNN.md`

**Monthly review**:
- Knowledge growth trends
- PARA archival suggestions (which projects should move to archives)
- Long-term goal progress
- Knowledge gap analysis
- Report saved to `wiki/reviews/monthly/YYYY-MM.md`

Both review types read `log.jsonl` to analyze recent activity.

**Git**: `[review] weekly YYYY-WNN` or `[review] monthly YYYY-MM`

### /lint

Health check the knowledge base.

**Trigger**: Manual or scheduled.

**Checks**:
- **Contradictions**: Different pages make conflicting claims about the same concept
- **Stale info**: Newer sources supersede older claims
- **Orphan pages**: Wiki pages with no inbound links
- **Missing pages**: Referenced but nonexistent pages
- **Completed actions**: Expired or done items still in action lists
- **Archival candidates**: Projects in `raw/projects/` that appear completed

**Flow**:
1. Run all checks
2. Auto-fix what's safe (clean completed actions, add missing cross-references)
3. Report issues that need human judgment
4. Git commit with all fixes

**Git**: `[lint] fix <summary of changes>`

### /status

Quick dashboard of the current state.

**Trigger**: User invokes `/status`.

**Output**:
- Inbox backlog count
- Next actions count + top 5 items
- Last review date
- Lint issues count
- Knowledge base stats (total pages by type)

**Git**: No commit (read-only operation).

---

## Page Types

### Concepts
Abstract ideas, methodologies, techniques.

Examples: "transformer architecture", "GTD methodology", "spaced repetition"

Template sections: Definition → Key Points → Relations → Source Notes

### Entities
Concrete things with identity — people, companies, tools, papers.

Examples: "Andrej Karpathy", "Claude Code", "Attention Is All You Need"

Template sections: Basic Info → Key Points → Relations → Source Notes

### Syntheses
Cross-source analyses connecting multiple concepts/entities.

Examples: "RAG vs LPKD comparison", "How GTD and Zettelkasten complement each other"

Template sections: Core Insight → Comparative Analysis → Relations → Source Notes

### Actions
GTD action lists organized by status.

Files: `next.md`, `waiting.md`, `someday.md`, `delegated.md`

Each item: checkbox + description + source reference + date added

```markdown
- [ ] Read Posner 1980 paper | source: wiki/syntheses/attention-bio-vs-comp.md | added: 2026-04-09
- [x] Organize ML bookmarks | completed: 2026-04-07
```

---

## Frontmatter Spec

All `wiki/` pages must include:

```yaml
---
type: concept | entity | synthesis | action | review
title: Page Title
tags: [tag1, tag2]
sources: [raw/path/to/source.md]
related: [wiki/concepts/other.md]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

---

## Index Design: Hierarchical

To prevent context explosion as the knowledge base grows, the index is split into layers.

**Top-level `wiki/index.md`**:
```markdown
# Knowledge Index

## Stats
- Concepts: 23 | Entities: 15 | Syntheses: 8
- Last updated: 2026-04-09

## Concepts
Recently active: transformer, attention, GTD, ...
Full list → concepts/_index.md

## Entities
Recently active: Karpathy, Claude Code, ...
Full list → entities/_index.md

## Syntheses
Recently added: RAG vs LPKD, ...
Full list → syntheses/_index.md

## Recent Activity
(Last 5 ingest summaries; see log.jsonl for full history)
```

**Sub-indexes (`_index.md`)**: One entry per page with link + one-line summary + tags + last updated date.

Agent reads top-level index first, determines which sub-index to drill into, then reads specific pages.

---

## Structured Operation Log

`log.jsonl` — JSON Lines format, one entry per operation, append-only.

**Schema per entry**:

```jsonc
{
  "ts": "2026-04-09T14:30:00",     // ISO 8601 timestamp
  "op": "ingest",                   // operation type
  "title": "Attention Is All You Need",
  "source": "inbox/attention.pdf",  // input (capture/ingest)
  "dest": "raw/resources/ml/",      // destination in raw/ (ingest)
  "created": ["wiki/entities/..."], // new wiki pages
  "updated": ["wiki/concepts/..."], // modified wiki pages
  "actions": [                      // extracted actions (ingest)
    {"type": "next", "text": "..."}
  ],
  "stats": {},                      // operation-specific stats (review/lint)
  "report": "wiki/reviews/..."      // report path (review)
}
```

**Queryable via CLI**:
- `jq 'select(.op=="ingest")' log.jsonl` — filter by operation
- `jq '.op' log.jsonl | sort | uniq -c` — operation frequency
- Directly consumable by future Web UI

---

## Git Integration

Every skill includes a git commit as its final step. Commits use a structured message format for easy filtering.

**Commit message format**:
```
[operation] title

- created: file1.md, file2.md
- updated: file3.md, file4.md
- moved: inbox/xxx.md → raw/resources/yyy/
```

**Per-skill git behavior**:

| Skill | When to commit | Example message |
|-------|---------------|-----------------|
| `/capture` | After each capture | `[capture] selective attention thought` |
| `/ingest` | After each inbox item (not batched) | `[ingest] Attention Is All You Need` |
| `/query` | Only when writing back a synthesis | `[query] add RAG vs LPKD comparison` |
| `/review` | After report is saved | `[review] weekly 2026-W15` |
| `/lint` | After all fixes applied | `[lint] fix transformer year, clean 2 orphans` |
| `/status` | No commit (read-only) | — |

**Key principle**: `/ingest` commits per item, not per batch — enabling precise `git revert` of individual ingestions.

---

## Automation

| Mechanism | Use Case | Implementation |
|-----------|----------|----------------|
| Manual | All operations in MVP | User invokes `/capture`, `/ingest`, etc. |
| Cron + CLI | Weekly/monthly reviews, periodic lint | `crontab` → `claude -p "run /review weekly"` |
| Claude Code hooks | Auto-ingest on inbox changes | `settings.json` hook on file change |
| Git hooks | Pre-commit validation | Format checking |
| Claude Code `/schedule` | Remote scheduled agents | Built-in scheduling |

**MVP**: Manual only. Add automation after workflows stabilize.

---

## Future: Web UI

The architecture is Web-UI-ready by design:
- `wiki/` is a structured set of markdown files — easy to render
- `log.jsonl` is a ready-made API data source
- `wiki/index.md` + `_index.md` files serve as navigation data
- Git history provides full version control and diff viewing
- `wiki/actions/` provides GTD dashboard data
