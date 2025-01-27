#!/usr/bin/env bash

if [ -z ${1} ]; then
  echo "File with events listed one per line required."
  exit 1
fi

# add Fantastical event given text using AppleScript
function do_add {
  osascript <<END
      tell application "Fantastical"
          parse sentence "$@" with add immediately
      end tell
END
}

while read event_text; do
  if [ -z ${event_text} ]; then
    break
  fi
  echo "Adding event: \"${event_text}\""
  do_add "${event_text}"
done <"${1}"

[[ $? == 0 ]] && echo "Events added." || { echo "An error occurred."; exit 1; }
