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

Write the file with frontmatter per `.schema/frontmatter.md` (capture format):
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
- If "now": proceed to run `/ingest` on this file (read `.skills/ingest.md` first)
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
