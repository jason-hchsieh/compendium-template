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
