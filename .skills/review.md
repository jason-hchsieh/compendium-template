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
