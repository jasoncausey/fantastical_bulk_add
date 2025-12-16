#!/usr/bin/env bash

if [ -z ${1} ]; then
  echo "File with events listed one per line required."
  exit 1
fi

EVENT_FILE="${1}"

CALENDAR=""

# Second argument is (optionally) calendar name
if [ ! -z ${2} ]; then
  CALENDAR="-c \"${2}\""
fi

# add Fantastical event given text using fantastical-cli
function do_add {
  local event_text="$1"
  local args=()

  if [[ "$event_text" == *"|"* ]]; then
    local event_desc="${event_text%|*}"
    local notes="${event_text#*|}"
    args+=(-n "$notes" "$event_desc")
  else
    args+=("$event_text")
  fi
  
  fantastical-cli $CALENDAR "${args[@]}"
}

while read event_text; do
  if [ -z "${event_text}" ]; then
    break
  fi
  echo "Adding event: \"${event_text}\""
  do_add "${event_text}"
done <"$EVENT_FILE"

[[ $? == 0 ]] && echo "Events added." || { echo "An error occurred."; exit 1; }


# REFERENCE FOR fantastical-cli
# usage: fantastical-cli [-h] [-n NOTES] [-c CALENDAR] [-g] [sentence ...]
#
# Add events to Fantastical using natural language input.
#
# positional arguments:
#   sentence              Natural language description of the event (e.g.,
#                         'Meeting with John tomorrow at 3pm')
#
# options:
#   -h, --help            show this help message and exit
#   -n NOTES, --notes NOTES
#                         Additional notes for the event
#   -c CALENDAR, --calendar CALENDAR
#                         Calendar to add the event to
#   -g, --gui             Show the Fantastical UI to confirm before adding
#                         (default is immediate add)
