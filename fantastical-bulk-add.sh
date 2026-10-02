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

  local event_desc="$event_text"
  if (( sep >= 0 )); then
    local notes
    event_desc="$(trim "${event_text:0:sep}")"
    notes="$(trim "${event_text:sep+1}")"
    if [ -n "$notes" ]; then
      args+=(-n "$notes")
    fi
  fi

  # optional availability modifier at the end of the description,
  # e.g. ">>out-of-office" or '>> "out of office"'
  # (ignored if the ">>" falls inside double quotes, i.e. an odd number of quotes precede it)
  local avail_re='^(.*)>>[[:space:]]*("([[:alpha:] _-]+)"|([[:alpha:]_-]+))[[:space:]]*$'
  local quotes_before
  if [[ "$event_desc" =~ $avail_re ]] \
      && quotes_before="${BASH_REMATCH[1]//[^\"]/}" \
      && (( ${#quotes_before} % 2 == 0 )); then
    local availability
    event_desc="$(trim "${BASH_REMATCH[1]}")"
    availability="$(printf '%s' "${BASH_REMATCH[3]}${BASH_REMATCH[4]}" | tr -d ' _-' | tr '[:upper:]' '[:lower:]')"
    args+=(-a "$availability")
  fi

  args+=("$event_desc")

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
# usage: fantastical-cli [-h] [-n NOTES] [-c CALENDAR] [-a AVAILABILITY] [-g] [sentence ...]
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
#   -a {free,busy,tentative,outofoffice,workingelsewhere}, --availability ...
#                         Show the event as free, busy, tentative, outofoffice,
#                         or workingelsewhere
#   -g, --gui             Show the Fantastical UI to confirm before adding
#                         (default is immediate add)
