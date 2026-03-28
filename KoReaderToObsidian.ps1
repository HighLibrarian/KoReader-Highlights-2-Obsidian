# Modify these paths to match your environment.
$BookNotes =  Get-ChildItem -Recurse -Path "V:\Repositories\Personal\KoReader-Highlights-2-Obsidian" -Filter "*.json"
$OutputFolder = "V:\Obsidian Vaults\SynapseGarden\INBOX"

foreach ($BookNote in $BookNotes)
{
    $NoteContent = Get-Content -Path $BookNote.FullName -Raw | ConvertFrom-Json


    # check if our file has been proceses previously
    if ($NoteContent.processed -eq $true)
    {
        write-warning "skipping $($NoteContent.title) it has been processed already"
        continue
    }

    # Basic book info
    $BookAuthor = $NoteContent.author
    $BookTitle  = $NoteContent.title
    $BookPages  = $NoteContent.number_of_pages

    # Sanitize title for use as a filename (remove characters illegal in Windows paths)
    $SafeTitle = $BookTitle -replace '[\\/:*?"<>|]', '_'

    # Create output file
    $FullObsidianNotePath = Join-Path $OutputFolder "$SafeTitle.md"
    New-Item -Path $FullObsidianNotePath -ItemType File -Force | Out-Null

    try {
    # add our frontmatter
    Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -value @"
---
title: "$BookTitle"
synapse garden: false
aliases:
- "$BookTitle"
tags:
- Books/Notes
area: home
date: $(get-date -format "yyyy-MM-dd")
notetype: booknote
bookauthor: "$BookAuthor"
zkid: $(Get-Date -Format "yyyyMMddHHmmss")
timestamp: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
---
"@

    # add our title, author, and pages
    Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -value "# $BookTitle"
    Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -value "**Author**: $BookAuthor"
    Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -value "**Pages**: $BookPages `n"
    Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -value "---"


    # get our unique chapters so we can work on chapter basis
    $Chapters = $NoteContent.entries.chapter | Select-Object -Unique

    foreach ($Chapter in $Chapters)
    {
        # Chapter header
        Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -Value "## Chapter: $Chapter`n"

        # Table header
        Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -Value @"
| Highlight | Page | Date | Time | Note |
|----------|------|------|------|------|
"@

        # Entries for the chapter
        $ChapterEntries = $NoteContent.entries | Where-Object { $_.chapter -eq $Chapter } |Sort-Object { $_.time }

        foreach ($Entry in $ChapterEntries)
        {
            # Handle potential empty notes
            $EntryNote = if ($Entry.note) { $Entry.note } else { "N/A" }

            # Convert our unix time to date and time
            $Date = Get-Date -UnixTimeSeconds $Entry.time -Format "yyyy-MM-dd"
            $Time = Get-Date -UnixTimeSeconds $Entry.time -Format "HH:mm:ss"


            # Convert multiline highlights into <br> and escape table pipes
            $HighlightText = ($Entry.text -replace '\r?\n', '<br>') -replace '\|', '\|'

            # Same for notes if they can be multiline
            $SafeNote = ($EntryNote -replace '\r?\n', '<br>') -replace '\|', '\|'

            Add-Content -Path $FullObsidianNotePath -Encoding UTF8 -Value "| $HighlightText | $($Entry.page) | [[$Date]] | $Time | $SafeNote |"
        }
    }
    } catch {
        Write-Error "Failed to process '$BookTitle': $_"
        # Remove partial output file on failure
        Remove-Item -Path $FullObsidianNotePath -ErrorAction SilentlyContinue
        continue
    }

    # Update the object only after successful write
    $NoteContent | Add-Member -MemberType NoteProperty -Name "processed" -Value $true -Force

    # Save back to JSON
    $NoteContent | ConvertTo-Json -Depth 20 | Set-Content -Path $BookNote.FullName -Encoding UTF8

}
