# fantastical-bulk-add

This is a quick and dirty script to add events in bulk to [Fantastical](https://flexibits.com/fantastical) on Mac if you have a Bash shell.  Just put the event descriptions one-per-line into a text file, then call the script as so:

```bash
fantastical-bulk-add.sh  my-events-file.txt
```

To add the events to a specific calendar, pass the calendar name as an optional second argument:

```bash
fantastical-bulk-add.sh  my-events-file.txt  "Work"
```

The script requires `fantastical-cli` to be installed and available on your `PATH`.

Each line should be in the [Fantastical event description format](https://flexibits.com/fantastical/help/adding-events-and-tasks).  Events will be immediately added to the calendar with no additional interaction.  Blank lines and lines beginning with `#` (comments) are ignored.  A demo file `example-event-file.txt` is provided for reference.

## Notes

To attach notes to an event, follow the event description with a pipe (`|`) and the note text:

```text
tomorrow at 9:00am: TEST EVENT ONE | this is a note on event 1
```

Spaces around the separator are trimmed.  If a line contains more than one `|`, the last one is used as the separator, and any `|` inside double quotes (`"..."`) is ignored.  A demo file `example-event-file-with-notes.txt` is provided for reference.

## Availability

To set how an event shows your availability, add `>>` followed by the availability at the end of the event description, before the notes separator (`|`) if there is one:

```text
tomorrow at 9:00am: TEST EVENT ONE >>busy
Dec 22 - Jan 2: Vacation >> out-of-office | back on the 3rd
Dec 22 - Jan 2: Vacation >> "Out of Office" | back on the 3rd
```

Accepted values are `free`, `busy`, `tentative`, `outofoffice`, and `workingelsewhere`.  Case, hyphens, underscores, and spaces after `>>` are ignored, so `>>out-of-office`, `>> Out_Of_Office`, and `>>outofoffice` are all equivalent.  To use spaces in the value, wrap it in double quotes (e.g. `>> "out of office"`).  A `>>` that falls inside double quotes is not treated as a modifier.  The modifier is optional; without it, Fantastical uses its default.  An invalid value is rejected by `fantastical-cli` and that event is not added.  `outofoffice` and `workingelsewhere` only take effect on calendar accounts that support them (e.g. Exchange, Google).
