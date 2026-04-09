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
