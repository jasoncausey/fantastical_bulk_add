# fantastical-bulk-add

This is a quick and dirty script to add events in bulk to [Fantastical](https://flexibits.com/fantastical) on Mac if you have a Bash shell.  Just put the event descriptions one-per-line into a text file, then call the script as so:

```bash
fantastical-bulk-add.sh  my-events-file.txt
```

Each line should be in the [Fantastical event description format](https://flexibits.com/fantastical/help/adding-events-and-tasks).  Events will be immediately added to the calendar with no additional interaction.  A demo file `example-event-file.txt` is provided for reference.
