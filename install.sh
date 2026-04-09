#!/usr/bin/env bash
# =============================================================================
# install.sh — Compendium Knowledge Management System
# =============================================================================
#
# Creates a complete, self-contained compendium instance from scratch.
# All file content is embedded directly in this script — no network downloads.
#
# Usage:
#   bash install.sh                  # installs to ./compendium
#   bash install.sh ~/my-kb          # installs to ~/my-kb
#   curl -fsSL https://raw.githubusercontent.com/jasonhch/compendium/main/install.sh | bash
#   curl -fsSL ...install.sh | bash -s -- ~/my-knowledge-base
#
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

TARGET_DIR="${1:-./compendium}"

# Resolve to absolute path
TARGET_DIR="$(cd "$(dirname "$TARGET_DIR")" 2>/dev/null && pwd)/$(basename "$TARGET_DIR")" || {
  # Parent dir doesn't exist yet — resolve manually
  TARGET_DIR="$(pwd)/$(basename "$TARGET_DIR")"
}

# ---------------------------------------------------------------------------
# Safety checks
# ---------------------------------------------------------------------------

if [ -e "$TARGET_DIR" ]; then
  echo "Error: target directory already exists: $TARGET_DIR" >&2
  echo "Remove it first, or choose a different target." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

print_step() {
  printf '  \033[1;34m%-12s\033[0m %s\n' "$1" "$2"
}

print_header() {
  echo ""
  printf '\033[1;32m%s\033[0m\n' "$1"
}

# ---------------------------------------------------------------------------
# Start
# ---------------------------------------------------------------------------

print_header "Compendium — Installation"
echo "  Target: $TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Create directory structure
# ---------------------------------------------------------------------------

print_step "mkdir" "creating directory structure..."

mkdir -p \
  "$TARGET_DIR/inbox/attachments" \
  "$TARGET_DIR/raw/projects" \
  "$TARGET_DIR/raw/areas" \
  "$TARGET_DIR/raw/resources" \
  "$TARGET_DIR/raw/archives" \
  "$TARGET_DIR/wiki/concepts" \
  "$TARGET_DIR/wiki/entities" \
  "$TARGET_DIR/wiki/syntheses" \
  "$TARGET_DIR/wiki/actions" \
  "$TARGET_DIR/wiki/reviews/weekly" \
  "$TARGET_DIR/wiki/reviews/monthly" \
  "$TARGET_DIR/.claude/skills/capture" \
  "$TARGET_DIR/.claude/skills/ingest" \
  "$TARGET_DIR/.claude/skills/query" \
  "$TARGET_DIR/.claude/skills/review" \
  "$TARGET_DIR/.claude/skills/lint" \
  "$TARGET_DIR/.claude/skills/status" \
  "$TARGET_DIR/.claude/schema/page-templates"

# ---------------------------------------------------------------------------
# 2. .gitkeep files for otherwise-empty directories
# ---------------------------------------------------------------------------

print_step "touch" "placing .gitkeep files..."

touch \
  "$TARGET_DIR/inbox/.gitkeep" \
  "$TARGET_DIR/inbox/attachments/.gitkeep" \
  "$TARGET_DIR/raw/projects/.gitkeep" \
  "$TARGET_DIR/raw/areas/.gitkeep" \
  "$TARGET_DIR/raw/resources/.gitkeep" \
  "$TARGET_DIR/raw/archives/.gitkeep" \
  "$TARGET_DIR/wiki/reviews/weekly/.gitkeep" \
  "$TARGET_DIR/wiki/reviews/monthly/.gitkeep"

# ---------------------------------------------------------------------------
# 3. log.jsonl  (empty — ready to receive entries)
# ---------------------------------------------------------------------------

print_step "write" "log.jsonl"
touch "$TARGET_DIR/log.jsonl"

# ---------------------------------------------------------------------------
# 4. .gitignore
# ---------------------------------------------------------------------------

print_step "write" ".gitignore"
cat << 'HEREDOC' > "$TARGET_DIR/.gitignore"
# OS
.DS_Store
Thumbs.db

# Editors
*.swp
*.swo
*~

# Superpowers brainstorm sessions
.superpowers/
HEREDOC

# ---------------------------------------------------------------------------
# 5. CLAUDE.md
# ---------------------------------------------------------------------------

print_step "write" "CLAUDE.md"
cat << 'HEREDOC' > "$TARGET_DIR/CLAUDE.md"
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
- `/capture` → `.claude/skills/capture/SKILL.md`
- `/ingest` → `.claude/skills/ingest/SKILL.md`
- `/query` → `.claude/skills/query/SKILL.md`
- `/review` → `.claude/skills/review/SKILL.md`
- `/lint` → `.claude/skills/lint/SKILL.md`
- `/status` → `.claude/skills/status/SKILL.md`

## Conventions
Page formats, frontmatter spec, and templates → `.claude/schema/`

## Git
Every operation ends with a structured commit:

```
[operation] title

- created: file1.md, file2.md
- updated: file3.md, file4.md
- moved: inbox/xxx.md → raw/category/topic/
```

Stage only files changed by the operation. Do not use `git add -A`.
HEREDOC

# ---------------------------------------------------------------------------
# 6. .claude/schema/frontmatter.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/schema/frontmatter.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/schema/frontmatter.md"
# Frontmatter Specification

All `wiki/` pages (except `index.md` and `_index.md`) must include YAML frontmatter.
Action pages (`wiki/actions/*.md`) use a reduced frontmatter — see `.claude/schema/page-templates/action.md`.

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
HEREDOC

# ---------------------------------------------------------------------------
# 7. .claude/schema/conventions.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/schema/conventions.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/schema/conventions.md"
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
HEREDOC

# ---------------------------------------------------------------------------
# 8. .claude/schema/page-templates/concept.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/schema/page-templates/concept.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/schema/page-templates/concept.md"
# Concept Page Template

Use this template when creating a new `wiki/concepts/` page.
Concepts represent abstract ideas, methodologies, or techniques.

## Template

```yaml
---
type: concept
title: "Concept Name"
tags: []
sources: []
related: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Definition
A concise definition of the concept in 1-3 sentences.

## Key Points
- Key point derived from sources
- Each point should cite its source: (source: raw/path/to/file.md)

## Relations
- [Related Concept](wiki/concepts/related.md) — how this concept relates
- [Related Entity](wiki/entities/related.md) — how this entity uses/implements this concept

## Source Notes
### From: [Source Title](raw/path/to/source.md)
Key takeaways from this specific source.
HEREDOC

# ---------------------------------------------------------------------------
# 9. .claude/schema/page-templates/entity.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/schema/page-templates/entity.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/schema/page-templates/entity.md"
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
HEREDOC

# ---------------------------------------------------------------------------
# 10. .claude/schema/page-templates/synthesis.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/schema/page-templates/synthesis.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/schema/page-templates/synthesis.md"
# Synthesis Page Template

Use this template when creating a new `wiki/syntheses/` page.
Syntheses are cross-source analyses that connect multiple concepts and entities.

## Template

```yaml
---
type: synthesis
title: "Synthesis Title"
tags: []
sources: []
related: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Core Insight
The main takeaway from connecting these sources — what did combining them reveal?

## Comparative Analysis
| Aspect | Source/Concept A | Source/Concept B |
|--------|-----------------|-----------------|
| ...    | ...             | ...             |

Or use prose if a table doesn't fit the analysis.

## Relations
- [Related Concept](wiki/concepts/related.md) — relevance
- [Related Entity](wiki/entities/related.md) — relevance

## Source Notes
### From: [Source Title](raw/path/to/source.md)
How this source contributed to the synthesis.
HEREDOC

# ---------------------------------------------------------------------------
# 11. .claude/schema/page-templates/action.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/schema/page-templates/action.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/schema/page-templates/action.md"
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
HEREDOC

# ---------------------------------------------------------------------------
# 12. .claude/skills/capture/SKILL.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/skills/capture/SKILL.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/skills/capture/SKILL.md"
---
name: capture
description: Quick, zero-friction input. Save any content into the inbox for later processing. Use when the user wants to capture a thought, article, URL, image, or any content.
---
# /capture

Quick, zero-friction input. Save any content into the inbox for later processing.

## Usage
- `/capture` — capture the content in the current message
- `/capture <text>` — capture the given text

## Flow

### Step 1: Parse the message
Identify all elements in the user's input:
- **Text**: The main thought or note
- **Images**: Any attached or referenced images
- **URLs**: Any web links mentioned
- **Files**: Any referenced local files (PDFs, etc.)

### Step 2: Create the capture file
Create `inbox/YYYY-MM-DD-HH-MM-<slug>.md` where:
- Date/time is current UTC
- Slug is a 2-4 word lowercase hyphenated summary of the content

Write the file with frontmatter per `.claude/schema/frontmatter.md` (capture format):
```yaml
---
type: capture
date: YYYY-MM-DDTHH:MM:SS
attachments:
  - type: image | url | pdf | file
    path: inbox/attachments/filename.ext
    url: https://example.com
---
```

Body: the user's original text, preserved as-is.

### Step 3: Handle attachments
For each attachment:
- **Images**: Copy/save to `inbox/attachments/` with descriptive filename
- **URLs**: Record in frontmatter (do NOT fetch yet — that happens during ingest)
- **Files**: Copy to `inbox/attachments/`

### Step 4: Ask about ingest
Ask the user: "Captured. Ingest now or later?"
- If "now": proceed to run `/ingest` on this file (read `.claude/skills/ingest/SKILL.md` first)
- If "later" or no response: done

### Step 5: Log
Append to `log.jsonl`:
```json
{"ts":"<now>","op":"capture","title":"<slug>","source":"inbox/<filename>.md"}
```

### Step 6: Git commit
```bash
git add inbox/<filename>.md inbox/attachments/<any attachments> log.jsonl
git commit -m "[capture] <slug title>

- created: inbox/<filename>.md"
```
HEREDOC

# ---------------------------------------------------------------------------
# 13. .claude/skills/ingest/SKILL.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/skills/ingest/SKILL.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/skills/ingest/SKILL.md"
---
name: ingest
description: Process inbox items into the knowledge base. Compiles raw inputs into wiki pages, extracts actions, classifies into PARA. Use when the user wants to process inbox items.
---
# /ingest

Process inbox items into the knowledge base. This is the core "compilation" operation.

## Usage
- `/ingest` — process all items in inbox/
- `/ingest <file>` — process a specific inbox file

## Flow

### Step 1: Scan inbox
List all `.md` files in `inbox/` (exclude `attachments/` directory and `.gitkeep`).
If empty, report "Inbox is empty." and stop.

### Step 2: Process each item
For each item, run steps 2a through 2h. Process one item fully before starting the next.

#### 2a: Parse content
Read the capture file. For each element:
- **Text**: Extract key ideas, claims, facts, questions, and action items
- **URLs**: Fetch the URL content and summarize it
- **Images**: Describe the visual content
- **PDFs/files**: Read and summarize

#### 2b: Classify (PARA)
Determine where this belongs in `raw/`:
- `projects/` — if related to an active project with clear deliverables
- `areas/` — if related to an ongoing area of responsibility
- `resources/` — if it's reference material on a topic of interest (most common)
- `archives/` — rarely used during ingest (items don't arrive pre-archived)

Decide the subdirectory (e.g., `resources/machine-learning/`). If the topic is new, create the subdirectory.

#### 2c: Extract actions
Scan for anything actionable: todos, commitments, intentions, things to follow up on.
For each action found:
1. Determine the type: `next` (do soon), `waiting` (blocked on someone/something), `someday` (maybe later)
2. Add to the corresponding file in `wiki/actions/` using the format from `.claude/schema/page-templates/action.md`
3. Include source reference back to the wiki page or raw file

#### 2d: Update knowledge network
Read `wiki/index.md` to understand the current knowledge landscape.

For each key concept, entity, or insight in the content:
1. **Check if a page exists** — search `_index.md` files for existing pages
2. **If page exists** — update it with new information from this source. Add to Source Notes section. Update Key Points if the new source adds or contradicts. Add cross-references.
3. **If page is new** — create it using the template from `.claude/schema/page-templates/`. Fill in all sections.
4. **If cross-source insight emerges** — create a `wiki/syntheses/` page connecting the dots

Use templates from `.claude/schema/page-templates/` for all new pages.
Follow frontmatter spec from `.claude/schema/frontmatter.md`.

Guideline: aim to touch ~10-15 pages per ingest, but let the content dictate scope. A simple bookmark might touch 2-3 pages. A dense research paper might touch 20+.

#### 2e: Update indexes
1. Update `wiki/index.md` — stats, recently active lists, recent activity
2. Update relevant `_index.md` files — add entries for new pages, update summaries for modified pages

#### 2f: Move source
Move the original file from `inbox/` to its PARA location in `raw/`:
```bash
# Example
mv inbox/2026-04-09-14-30-attention-thought.md raw/resources/machine-learning/
mv inbox/attachments/screenshot.png raw/resources/machine-learning/
```

If attachments were referenced, update the paths in the moved file's frontmatter.

#### 2g: Log
Append to `log.jsonl`:
```json
{"ts":"<now>","op":"ingest","title":"<descriptive title>","source":"inbox/<filename>.md","dest":"raw/<para>/<topic>/","created":["wiki/concepts/new-page.md"],"updated":["wiki/concepts/existing.md"],"actions":[{"type":"next","text":"action description"}]}
```

#### 2h: Git commit
Stage only the files changed by THIS item:
```bash
git add raw/<dest>/ wiki/ log.jsonl
git commit -m "[ingest] <descriptive title>

- created: wiki/concepts/new-page.md, ...
- updated: wiki/concepts/existing.md, ...
- moved: inbox/<file> → raw/<dest>/"
```

One commit per inbox item. Not batched.

### Step 3: Summary
After all items are processed, output:
- Items processed: N
- Pages created: N (list them)
- Pages updated: N (list them)
- Actions extracted: N (list them)
HEREDOC

# ---------------------------------------------------------------------------
# 14. .claude/skills/query/SKILL.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/skills/query/SKILL.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/skills/query/SKILL.md"
---
name: query
description: Answer questions using the knowledge base. Searches the wiki index, reads relevant pages, and synthesizes answers with source citations. Use when the user asks a question about their knowledge base.
---
# /query

Ask questions answered by the knowledge base.

## Usage
- `/query <question>` — search the knowledge base and synthesize an answer

## Flow

### Step 1: Search the index
Read `wiki/index.md` to get an overview. Based on the question, determine which categories are relevant (concepts, entities, syntheses).

### Step 2: Drill into sub-indexes
Read the relevant `_index.md` files to find specific pages that relate to the question.

### Step 3: Read relevant pages
Read the identified wiki pages. If a page references `raw/` sources that would help answer the question more precisely, read those too.

### Step 4: Synthesize answer
Compose an answer that:
- Directly addresses the question
- Cites sources using paths: (source: wiki/concepts/page.md) or (source: raw/path/file.md)
- Notes any gaps or contradictions found in the knowledge base
- Suggests related pages the user might want to explore

### Step 5: Decide whether to write back
If the answer reveals a **new insight** worth preserving (a non-obvious connection, a novel comparison, a synthesis that doesn't exist yet):

1. Create a new `wiki/syntheses/` page using `.claude/schema/page-templates/synthesis.md`
2. Update cross-references on related pages
3. Update `wiki/syntheses/_index.md` and `wiki/index.md`
4. Append to `log.jsonl`:
```json
{"ts":"<now>","op":"query","title":"<synthesis title>","created":["wiki/syntheses/new-page.md"],"updated":["wiki/index.md"]}
```
5. Git commit:
```bash
git add wiki/ log.jsonl
git commit -m "[query] add <synthesis title>

- created: wiki/syntheses/new-page.md
- updated: wiki/index.md, wiki/syntheses/_index.md"
```

If the answer is straightforward (just retrieving known information), skip the write-back. No log entry. No commit.
HEREDOC

# ---------------------------------------------------------------------------
# 15. .claude/skills/review/SKILL.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/skills/review/SKILL.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/skills/review/SKILL.md"
---
name: review
description: Generate weekly or monthly review reports. Analyzes log.jsonl, actions progress, and knowledge growth. Use when the user wants a periodic review.
---
# /review

Run periodic reviews to reflect on progress and plan ahead.

## Usage
- `/review weekly` — generate a weekly review
- `/review monthly` — generate a monthly review

## Weekly Review

### Step 1: Gather data
Read `log.jsonl` and filter for entries from the past 7 days.

### Step 2: Analyze
Calculate:
- **Inbox**: current backlog count (files in `inbox/`)
- **Ingested**: count of ingest operations this week
- **Actions completed**: count of items checked off in `wiki/actions/` this week (check git log for changes to action files)
- **Actions added**: new items added to action files this week
- **Actions deferred**: items moved to `someday.md` this week
- **Pages created**: new wiki pages this week (from log.jsonl `created` fields)
- **Pages updated**: modified wiki pages this week (from log.jsonl `updated` fields)

### Step 3: Generate report
Create `wiki/reviews/weekly/YYYY-WNN.md`:

```yaml
---
type: review
title: "Weekly Review YYYY-WNN"
tags: [review, weekly]
sources: []
related: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Report sections:
1. **Summary** — one paragraph overview of the week
2. **Inbox** — backlog count, any stale items (older than 7 days)
3. **Actions** — completed, added, deferred counts with details
4. **Knowledge Growth** — new pages, updated pages, notable new connections
5. **Focus Suggestions** — recommended priorities for next week based on patterns

### Step 4: Update indexes
Update `wiki/index.md` Recent Activity section.

### Step 5: Log
```json
{"ts":"<now>","op":"review","title":"Weekly Review YYYY-WNN","report":"wiki/reviews/weekly/YYYY-WNN.md","stats":{"inbox_backlog":N,"ingested":N,"actions_completed":N,"actions_added":N,"pages_created":N,"pages_updated":N}}
```

### Step 6: Git commit
```bash
git add wiki/reviews/weekly/YYYY-WNN.md wiki/index.md log.jsonl
git commit -m "[review] weekly YYYY-WNN

- created: wiki/reviews/weekly/YYYY-WNN.md
- updated: wiki/index.md"
```

## Monthly Review

### Step 1: Gather data
Read `log.jsonl` for the past 30 days. Also read all weekly reviews from this month.

### Step 2: Analyze
Calculate everything in weekly review, plus:
- **Knowledge growth trends** — compare page counts week over week
- **PARA archival candidates** — projects in `raw/projects/` with no recent ingest activity (>30 days)
- **Long-term patterns** — most active topics, emerging themes
- **Knowledge gaps** — topics referenced but with thin wiki coverage

### Step 3: Generate report
Create `wiki/reviews/monthly/YYYY-MM.md`:

```yaml
---
type: review
title: "Monthly Review YYYY-MM"
tags: [review, monthly]
sources: []
related: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Report sections:
1. **Summary** — one paragraph overview of the month
2. **Knowledge Growth** — trends, new themes, page count progression
3. **Actions Overview** — completion rate, chronic deferrals, stale items
4. **PARA Health** — archival suggestions, areas needing attention
5. **Gaps & Opportunities** — thin areas worth researching, promising connections to explore

### Step 4: Apply PARA maintenance
For each archival candidate:
- Move the project directory from `raw/projects/` to `raw/archives/`
- Update any wiki pages that reference the moved paths

### Step 5: Update indexes and log
Same as weekly review steps 4-5, with `monthly` in the log entry.

### Step 6: Git commit
```bash
git add wiki/reviews/monthly/YYYY-MM.md wiki/index.md raw/ log.jsonl
git commit -m "[review] monthly YYYY-MM

- created: wiki/reviews/monthly/YYYY-MM.md
- updated: wiki/index.md
- moved: raw/projects/done-project/ → raw/archives/done-project/"
```
HEREDOC

# ---------------------------------------------------------------------------
# 16. .claude/skills/lint/SKILL.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/skills/lint/SKILL.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/skills/lint/SKILL.md"
---
name: lint
description: Health check the knowledge base. Finds contradictions, orphans, stale info, missing pages, and completed actions. Use when the user wants to maintain wiki quality.
---
# /lint

Health check the knowledge base. Find and fix issues.

## Usage
- `/lint` — run all checks
- `/lint --dry-run` — report issues without fixing

## Checks

### 1. Orphan pages
Wiki pages with no inbound links from other wiki pages or index files.

How to check:
- For each `.md` file in `wiki/concepts/`, `wiki/entities/`, `wiki/syntheses/`
- Search all other wiki files for references to this file's path
- If no references found (other than `_index.md`), flag as orphan

Fix: Add the page to relevant `related:` fields in connected pages, or remove if truly irrelevant.

### 2. Missing pages
Pages referenced in `related:` frontmatter or markdown links that don't exist.

How to check:
- Extract all internal links and `related:` paths from wiki pages
- Check if each referenced file exists

Fix: Create stub pages for important missing references, or remove broken links.

### 3. Contradictions
Different pages making conflicting claims about the same topic.

How to check:
- For each concept, read all pages that reference it
- Look for conflicting dates, definitions, or claims
- Flag for human review (do not auto-fix)

Report: List the conflicting pages and the specific claims.

### 4. Stale information
Pages whose source material has been superseded by newer sources.

How to check:
- For each wiki page, check if any `sources:` file has a newer version in `raw/`
- Check if `updated` date is significantly older than related pages

Report: List stale pages with suggestions.

### 5. Completed actions
Checked-off items in `wiki/actions/` files older than 30 days.

How to check:
- Parse action files for `- [x]` items
- Check the `completed:` date

Fix: Remove items completed more than 30 days ago.

### 6. Archival candidates
Projects in `raw/projects/` with no ingest activity in the past 30 days.

How to check:
- For each directory in `raw/projects/`
- Search `log.jsonl` for recent `ingest` entries with matching `dest` path

Report: List candidates for human decision.

## Output

Print a report:
```
Lint Report — YYYY-MM-DD
========================
Orphan pages:     N found, N fixed
Missing pages:    N found, N fixed
Contradictions:   N found (requires human review)
Stale info:       N found
Completed actions: N cleaned
Archival candidates: N found

Details:
[... specifics for each issue ...]
```

## Log
```json
{"ts":"<now>","op":"lint","title":"Lint YYYY-MM-DD","stats":{"orphans":N,"missing":N,"contradictions":N,"stale":N,"cleaned_actions":N,"archival_candidates":N},"updated":["wiki/actions/next.md"]}
```

## Git commit
Only commit if changes were made (not for `--dry-run`):
```bash
git add wiki/ log.jsonl
git commit -m "[lint] fix <summary>

- updated: wiki/actions/next.md, ...
- fixed: N orphans, N missing links, N completed actions"
```
HEREDOC

# ---------------------------------------------------------------------------
# 17. .claude/skills/status/SKILL.md
# ---------------------------------------------------------------------------

print_step "write" ".claude/skills/status/SKILL.md"
cat << 'HEREDOC' > "$TARGET_DIR/.claude/skills/status/SKILL.md"
---
name: status
description: Quick read-only dashboard showing inbox count, top actions, last review date, and knowledge base stats. Use when the user wants an overview.
---
# /status

Quick read-only dashboard of the knowledge base state.

## Usage
- `/status` — show current status

## Flow

### Step 1: Count inbox
Count `.md` files in `inbox/` (exclude `attachments/` and `.gitkeep`).

### Step 2: Read actions
Read `wiki/actions/next.md`. Count unchecked items. Extract the top 5.

### Step 3: Read review history
Read `log.jsonl` and find the most recent `review` entry.

### Step 4: Count lint issues
Read `log.jsonl` and find the most recent `lint` entry. Sum the `stats` fields.

### Step 5: Count wiki pages
Count `.md` files (excluding `_index.md` and `index.md`) in:
- `wiki/concepts/`
- `wiki/entities/`
- `wiki/syntheses/`

### Step 6: Output

```
LLM Wiki Status
================
Inbox:          N items pending
Next Actions:   N items
  1. First action
  2. Second action
  3. Third action
  4. Fourth action
  5. Fifth action
Last Review:    YYYY-MM-DD (weekly/monthly)
Lint Issues:    N open
Knowledge Base: N concepts | N entities | N syntheses
```

## Git
No commit. This is a read-only operation.
HEREDOC

# ---------------------------------------------------------------------------
# 18. wiki/index.md  (empty-state version)
# ---------------------------------------------------------------------------

print_step "write" "wiki/index.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/index.md"
# Knowledge Index

## Stats
- Concepts: 0 | Entities: 0 | Syntheses: 0
- Last updated: —

## Concepts
Recently active: —
Full list → concepts/_index.md

## Entities
Recently active: —
Full list → entities/_index.md

## Syntheses
Recently added: —
Full list → syntheses/_index.md

## Recent Activity
No activity yet. Run `/capture` to add your first note.
HEREDOC

# ---------------------------------------------------------------------------
# 19. wiki/concepts/_index.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/concepts/_index.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/concepts/_index.md"
# Concepts Index

No concepts yet. Run `/ingest` to populate from your inbox.
HEREDOC

# ---------------------------------------------------------------------------
# 20. wiki/entities/_index.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/entities/_index.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/entities/_index.md"
# Entities Index

No entities yet. Run `/ingest` to populate from your inbox.
HEREDOC

# ---------------------------------------------------------------------------
# 21. wiki/syntheses/_index.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/syntheses/_index.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/syntheses/_index.md"
# Syntheses Index

No syntheses yet. Syntheses are created automatically when `/ingest` or `/query`
discovers a cross-source insight worth preserving.
HEREDOC

# ---------------------------------------------------------------------------
# 22. wiki/actions/next.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/actions/next.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/actions/next.md"
---
type: action
title: "Next Actions"
updated: YYYY-MM-DD
---

<!-- Items added here by /ingest. Format: -->
<!-- - [ ] Action description | source: wiki/path/or/raw/path | added: YYYY-MM-DD -->
HEREDOC

# ---------------------------------------------------------------------------
# 23. wiki/actions/waiting.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/actions/waiting.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/actions/waiting.md"
---
type: action
title: "Waiting For"
updated: YYYY-MM-DD
---

<!-- Items added here by /ingest when blocked on someone/something. Format: -->
<!-- - [ ] Action description | source: wiki/path/or/raw/path | added: YYYY-MM-DD -->
HEREDOC

# ---------------------------------------------------------------------------
# 24. wiki/actions/someday.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/actions/someday.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/actions/someday.md"
---
type: action
title: "Someday/Maybe"
updated: YYYY-MM-DD
---

<!-- Items added here by /ingest (low-priority) or moved here by /review. Format: -->
<!-- - [ ] Action description | source: wiki/path/or/raw/path | added: YYYY-MM-DD -->
HEREDOC

# ---------------------------------------------------------------------------
# 25. wiki/actions/delegated.md
# ---------------------------------------------------------------------------

print_step "write" "wiki/actions/delegated.md"
cat << 'HEREDOC' > "$TARGET_DIR/wiki/actions/delegated.md"
---
type: action
title: "Delegated"
updated: YYYY-MM-DD
---

<!-- Items delegated to others. Format: -->
<!-- - [ ] Action description | source: wiki/path/or/raw/path | added: YYYY-MM-DD -->
HEREDOC

# ---------------------------------------------------------------------------
# 26. git init + initial commit
# ---------------------------------------------------------------------------

print_step "git init" "initialising repository..."

git -C "$TARGET_DIR" init --quiet

print_step "git add" "staging all files..."

git -C "$TARGET_DIR" add \
  CLAUDE.md \
  .gitignore \
  log.jsonl \
  .claude/ \
  wiki/ \
  inbox/.gitkeep \
  inbox/attachments/.gitkeep \
  raw/projects/.gitkeep \
  raw/areas/.gitkeep \
  raw/resources/.gitkeep \
  raw/archives/.gitkeep

print_step "git commit" "creating initial commit..."

git -C "$TARGET_DIR" \
  -c user.name="${GIT_AUTHOR_NAME:-compendium}" \
  -c user.email="${GIT_AUTHOR_EMAIL:-compendium@localhost}" \
  commit --quiet -m "[init] bootstrap compendium instance

- created: CLAUDE.md, .gitignore, log.jsonl
- created: .claude/schema/ (frontmatter.md, conventions.md, page-templates/)
- created: .claude/skills/ (capture, ingest, query, review, lint, status)
- created: wiki/ (index.md, concepts/, entities/, syntheses/, actions/, reviews/)
- created: inbox/, raw/ directory scaffolding"

# ---------------------------------------------------------------------------
# 27. Summary
# ---------------------------------------------------------------------------

FILE_COUNT=$(git -C "$TARGET_DIR" ls-files | wc -l | tr -d ' ')

print_header "Installation complete!"
echo ""
echo "  Location : $TARGET_DIR"
echo "  Files    : $FILE_COUNT files tracked in git"
echo ""
echo "  Directory layout:"
echo "    inbox/          ← drop notes here (/capture)"
echo "    raw/            ← PARA-organised source material"
echo "    wiki/           ← LLM-managed knowledge network"
echo "    .claude/schema/ ← frontmatter spec, conventions, templates"
echo "    .claude/skills/ ← operation playbooks for the LLM"
echo "    log.jsonl       ← append-only operation log"
echo ""
echo "  Next steps:"
echo "    1. cd $TARGET_DIR"
echo "    2. Open in Claude Code (or any Claude interface)"
echo "    3. Run /capture to add your first note"
echo "    4. Run /ingest to compile it into the wiki"
echo ""
echo "  Quick reference:"
echo "    /capture  — save a note"
echo "    /ingest   — process inbox into wiki"
echo "    /query    — ask a question"
echo "    /status   — dashboard"
echo "    /review   — weekly or monthly review"
echo "    /lint     — health check"
echo ""
