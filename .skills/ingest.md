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
2. Add to the corresponding file in `wiki/actions/` using the format from `.schema/page-templates/action.md`
3. Include source reference back to the wiki page or raw file

#### 2d: Update knowledge network
Read `wiki/index.md` to understand the current knowledge landscape.

For each key concept, entity, or insight in the content:
1. **Check if a page exists** — search `_index.md` files for existing pages
2. **If page exists** — update it with new information from this source. Add to Source Notes section. Update Key Points if the new source adds or contradicts. Add cross-references.
3. **If page is new** — create it using the template from `.schema/page-templates/`. Fill in all sections.
4. **If cross-source insight emerges** — create a `wiki/syntheses/` page connecting the dots

Use templates from `.schema/page-templates/` for all new pages.
Follow frontmatter spec from `.schema/frontmatter.md`.

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
