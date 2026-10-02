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

The script reports any event that `fantastical-cli` fails to send and exits with a non-zero status.  It cannot detect an event that Fantastical receives but declines to add, so check your calendar after a bulk add.

Each line should be in the [Fantastical event description format](https://flexibits.com/fantastical/help/adding-events-and-tasks).  Events will be immediately added to the calendar with no additional interaction.  Blank lines and lines beginning with `#` (comments) are ignored.  A demo file `example-event-file.txt` is provided for reference.

## Notes

To attach notes to an event, follow the event description with a pipe (`|`) and the note text:

```text
tomorrow at 9:00am: TEST EVENT ONE | this is a note on event 1
```

Spaces around the separator are trimmed.  If a line contains more than one `|`, the last one is used as the separator, and any `|` inside double quotes (`"..."`) is ignored.  A demo file `example-event-file-with-notes.txt` is provided for reference.
