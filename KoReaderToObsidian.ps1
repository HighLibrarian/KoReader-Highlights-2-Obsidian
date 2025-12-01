# Modify these paths to match your environment.
$BookNotes =  Get-ChildItem -Recurse -Path "PathToYourExportsFolder" -Filter "*.json"
$OutputFolder = "PathToYourDestinationFolder"

foreach ($BookNote in $BookNotes)
{
    $NoteContent = Get-Content -Path $BookNote.FullName -Raw | ConvertFrom-Json

    # check if our file has been processed previously
    if ($NoteContent.processed -eq $true)
    {
        Write-Warning "skipping $($NoteContent.title) it has been processed already"
        continue
    }

    # Basic book info
    $BookAuthor = $NoteContent.author
    $BookTitle  = $NoteContent.title
    $BookPages  = $NoteContent.number_of_pages

    # Create output file
    $FullObsidianNotePath = "$OutputFolder\$($BookTitle).md"
    New-Item -Path $FullObsidianNotePath -ItemType File -Force | Out-Null

    # Add frontmatter
    Add-Content -Path $FullObsidianNotePath -Value @"
---
title: $BookTitle
synapse garden: false
aliases:
- $BookTitle
tags:
- Books/Notes
area: home
date: $(get-date -format "yyyy-MM-dd")
notetype: booknote
bookauthor: $BookAuthor
zkid: $(Get-Date -Format "yyyyMMddHHmmss")
timestamp: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
---
"@

    # Add title, author, and pages
    Add-Content -Path $FullObsidianNotePath -Value "# $BookTitle"
    Add-Content -Path $FullObsidianNotePath -Value "**Author**: $BookAuthor"
    Add-Content -Path $FullObsidianNotePath -Value "**Pages**: $BookPages `n"
    Add-Content -Path $FullObsidianNotePath -Value "---"

    # Unique chapters
    $Chapters = $NoteContent.entries.chapter | Get-Unique

    foreach ($Chapter in $Chapters)
    {
        Add-Content -Path $FullObsidianNotePath -Value "## Chapter: $Chapter`n"

        # HTML table with dark-mode styling changes the colors to your liking
        Add-Content -Path $FullObsidianNotePath -Value @"
<style>
table.booknotes {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1em;
  font-size: 0.9em;
}
table.booknotes th {
  background-color: #222;
  color: #eee;
  padding: 8px;
  border-bottom: 1px solid #444;
}
table.booknotes td {
  padding: 8px;
  border-bottom: 1px solid #333;
  vertical-align: top;
}
table.booknotes tr:nth-child(even) {
  background-color: #1a1a1a;
}
table.booknotes tr:nth-child(odd) {
  background-color: #111;
}
table.booknotes {
  border-radius: 6px;
  overflow: hidden;
  box-shadow: 0 0 6px rgba(0,0,0,0.4);
}
</style>

<table class="booknotes">
<thead>
<tr>
  <th>Highlight</th>
  <th>Page</th>
  <th>Date</th>
  <th>Time</th>
  <th>Note</th>
</tr>
</thead>
<tbody>
"@

        # Chapter entries sorted by timestamp
        $ChapterEntries = $NoteContent.entries | Where-Object { $_.chapter -eq $Chapter } | Sort-Object { $_.time }

        foreach ($Entry in $ChapterEntries)
        {
            # Handle empty notes
            $EntryNote = if ($Entry.note) { $Entry.note } else { "N/A" }

            # Convert unix timestamp
            $Date = Get-Date -UnixTimeSeconds $Entry.time -Format "yyyy-MM-dd"
            $Time = Get-Date -UnixTimeSeconds $Entry.time -Format "HH:mm:ss"

            # Fix multiline and escape HTML
            $HighlightText = ($Entry.text -replace '\r?\n', '<br>') -replace '\|', '\`|'
            $SafeNote      = ($EntryNote -replace '\r?\n', '<br>') -replace '\|', '\`|'

            # HTML table row
            Add-Content -Path $FullObsidianNotePath -Value "<tr><td>$HighlightText</td><td>$($Entry.page)</td><td>[[$Date]]</td><td>$Time</td><td>$SafeNote</td></tr>"
        }

        # Close table
        Add-Content -Path $FullObsidianNotePath -Value "</tbody></table>`n"
    }

    # Mark JSON as processed
    $NoteContent | Add-Member -MemberType NoteProperty -Name "processed" -Value $true -Force

    # Save back to JSON file
    $NoteContent | ConvertTo-Json -Depth 20 | Set-Content -Path $BookNote.FullName -Encoding UTF8
}
