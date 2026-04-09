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
