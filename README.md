# KoReader to Obsidian

This PowerShell script processes JSON highlight files exported from KoReader and converts them into Markdown files formatted for use in Obsidian. The script organizes highlights by chapters and includes metadata in the frontmatter for better integration with Obsidian.

## Workflow

1. **On KoReader:**
   - Export your highlights to a JSON file using KoReader's export functionality.

2. **On KoReader:**
   - Use the KoReader [SyncThing](https://github.com/jasonchoimtt/koreader-syncthing) plugin to sync the exported JSON files to your PC.

3. **On PC:**
   - Use SyncThing to fetch the JSON files from KoReader.

4. **On PC:**
   - Run this PowerShell script to process the JSON files and generate Markdown files for use in Obsidian.

## Usage

1. Clone or download this repository to your local machine.
2. Modify the script to match your environment:
   - Update the `$BookNotes` variable to point to the folder where your JSON files are stored.
   - Update the `$OutputFolder` variable to point to the folder where you want the Markdown files to be saved.
3. Open PowerShell and navigate to the directory containing the script.
4. Run the script:
   ```powershell
   .\KoReaderToObsidian.ps1

5. The script will process all JSON files in the specified folder, generate Markdown files, and save them to the output folder.

## Features
- Automatically skips files that have already been processed.
- Extracts book metadata (title, author, number of pages) and includes it in the Markdown frontmatter.
- Organizes highlights by chapters and formats them into a table.
- Converts multiline highlights and notes into a readable format for Markdown.
- Updates the JSON file to mark it as processed.

## Requirements
- PowerShell
- SyncThing (for syncing files between KoReader and your PC)

## Notes
Ensure that the JSON files exported from KoReader follow the expected structure used by the script.
The script assumes that the output folder exists. If it doesn't, create it manually or modify the script to handle folder creation.



⚠️This is a quick-and-dirty solution for a very niche problem that scratched my own itch.
Fair warning: I’m not actively watching issues or PRs… but feel free to open them! I might even look at them if the stars align.

---
Enjoy using your KoReader highlights in Obsidian!
