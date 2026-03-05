# Obsidian Skill

Write content to Obsidian vault.

## Usage

This skill allows OpenClaw to write markdown files to the Obsidian vault.

### Actions

- `write`: Write content to a file in the vault
- `append`: Append content to an existing file
- `read`: Read content from a file

### Configuration

The vault path is configured in the skill or defaults to the user's Obsidian vault.

## Examples

```bash
# Write a note
obsidian write "00-收件箱/素材/note.md" "# My Note\nContent here"

# Append to existing note
obsidian append "01-知识库/摄影/tips.md" "\n## New Tip\n..."
```
