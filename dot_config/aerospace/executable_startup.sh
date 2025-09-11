#!/bin/bash

# Get the current day of the week (1-7, where 1 is Monday)
day_of_week=$(date +%u)

# Check if it's a weekday (1-5)
if [ "$day_of_week" -ge 1 ] && [ "$day_of_week" -le 5 ]; then
    sleep 15
    # Open applications
    open -a "Gmail"
    open -a "Google Calendar"
    open -a "Slack"
    open -a "Obsidian"
fi

# Check if it's Monday (1)
if [ "$day_of_week" -eq 1 ]; then
    # Run your Monday script here
    sleep 120
    cd ~/projects/user_tracker
    dd-auth -- go run .
fi
