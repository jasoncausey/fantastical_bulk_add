#!/usr/bin/env bash

if [ -z "${1}" ]; then
  echo "File with events listed one per line required."
  exit 1
fi

EVENT_FILE="${1}"

CALENDAR_ARGS=()

# Second argument is (optionally) calendar name
if [ -n "${2}" ]; then
  CALENDAR_ARGS=(-c "${2}")
fi

# strip leading and trailing whitespace
function trim {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# add Fantastical event given text using fantastical-cli
function do_add {
  local event_text="$1"
  local args=()
  local in_quotes=0 sep=-1 i ch

  # find the last pipe that is not inside double quotes
  for (( i = 0; i < ${#event_text}; i++ )); do
    ch="${event_text:i:1}"
    if [[ "$ch" == '"' ]]; then
      in_quotes=$(( !in_quotes ))
    elif [[ "$ch" == "|" && $in_quotes == 0 ]]; then
      sep=$i
    fi
  done

  if (( sep >= 0 )); then
    local event_desc notes
    event_desc="$(trim "${event_text:0:sep}")"
    notes="$(trim "${event_text:sep+1}")"
    if [ -n "$notes" ]; then
      args+=(-n "$notes")
    fi
    args+=("$event_desc")
  else
    args+=("$event_text")
  fi

  fantastical-cli "${CALENDAR_ARGS[@]}" "${args[@]}"
}

while read event_text || [ -n "${event_text}" ]; do
  # skip blank lines and comment lines
  if [[ -z "${event_text}" || "${event_text}" == \#* ]]; then
    continue
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
