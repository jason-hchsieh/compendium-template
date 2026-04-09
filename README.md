# compendium

A coding-agent-driven personal knowledge management system combining GTD, PARA, and Karpathy's LLM Wiki pattern.

## What is this

Compendium is a structured set of markdown files, conventions, and skill instructions that turns a coding agent (Claude Code, Cursor, etc.) into a personal knowledge base maintainer. You capture raw inputs; the agent ingests them into a living wiki it fully controls. The system enforces GTD's capture-clarify-organize-reflect-engage cycle on top of a PARA directory taxonomy, with the wiki layer growing automatically as new material arrives.

## Architecture

```
                    you
                     |
                 /capture
                     |
              inbox/ (staging)
                     |
                 /ingest
                /        \
          raw/             wiki/
    (PARA structure)   (LLM-managed)
    (you curate,       (you read,
     LLM never edits)   LLM writes)
    |                  |
    projects/          concepts/
    areas/             entities/
    resources/         syntheses/
    archives/          actions/
                       reviews/
```

Both layers are plain markdown. `log.jsonl` records every operation. Every operation ends with a git commit.

## Quick Start

```bash
# Install into ./compendium (no network dependencies, all content embedded)
bash install.sh

# Or pipe directly
curl -fsSL https://raw.githubusercontent.com/jasonhch/compendium/main/install.sh | bash
```

Open the directory in your coding agent, then:

```
/status          # see the current state of the knowledge base
/capture <text>  # drop anything in — text, URLs, images
/ingest          # process inbox items into the wiki
```

## Operations

| Operation  | Description                                                        |
|------------|--------------------------------------------------------------------|
| `/capture` | Zero-friction input — saves any content to `inbox/`               |
| `/ingest`  | Compiles inbox items into wiki pages, extracts actions, moves sources to `raw/` |
| `/query`   | Answers questions grounded in your knowledge base, with source citations |
| `/review`  | Generates weekly or monthly review reports in `wiki/reviews/`      |
| `/lint`    | Health check — finds contradictions, orphans, stale info, fixes what it can |
| `/status`  | Read-only dashboard: inbox count, top actions, last review, page stats |

Each operation reads its detailed instructions from `.skills/<operation>.md` before executing.

## Directory Structure

```
compendium/
├── CLAUDE.md                # System overview — loaded at every conversation start
├── .skills/                 # Per-operation instructions
│   ├── capture.md
│   ├── ingest.md
│   ├── query.md
│   ├── review.md
│   ├── lint.md
│   └── status.md
├── .schema/                 # Frontmatter spec, page templates, naming conventions
├── inbox/                   # GTD capture — unprocessed inputs land here
│   └── attachments/
├── raw/                     # Human-curated sources (LLM never edits content)
│   ├── projects/
│   ├── areas/
│   ├── resources/
│   └── archives/
├── wiki/                    # LLM-managed knowledge network (humans read, don't edit)
│   ├── index.md
│   ├── concepts/
│   ├── entities/
│   ├── syntheses/
│   ├── actions/             # GTD lists: next, waiting, someday, delegated
│   └── reviews/
└── log.jsonl                # Append-only structured operation log
```

## How It Works

1. **Capture** — drop anything into `inbox/`: a thought, a URL, a PDF, a screenshot.
2. **Ingest** — the agent reads each inbox item, classifies it under PARA, extracts next actions, updates or creates wiki pages (concepts, entities, syntheses), then moves the source into `raw/` and commits.
3. **Wiki grows** — `wiki/` accumulates interconnected pages the agent maintains. Cross-references stay consistent. Contradictions surface during `/lint`.
4. **Query / Review** — ask questions grounded in your own knowledge base, or run weekly/monthly reviews that pull from `log.jsonl` and the wiki to surface what matters next.

The agent is the maintainer. You stay on the input and reading side.

## Inspired By

Andrej Karpathy's LLM Wiki — the idea of using an LLM as the sole writer of a personal knowledge base, with humans only reading the output.

