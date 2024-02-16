#!/bin/bash

# Get top 5 processes by memory usage
top_processes=$(ps -eo pid,comm,%mem,args --sort=-%mem | head -n 6)

# Print header
printf "%-10s %-20s %-10s %-50s\n" "PID" "SERVICE" "MEM %" "PATH"

# Iterate through the processes
while IFS= read -r line; do
    # Skip the header line
    if [[ $line == *"PID"* ]]; then
        continue
    fi

    # Extract process information
    pid=$(echo "$line" | awk '{print $1}')
    service=$(echo "$line" | awk '{print $2}')
    mem=$(echo "$line" | awk '{print $3}')
    path=$(echo "$line" | awk '{$1=""; $2=""; $3=""; print $0}')

    # Print process information
    printf "%-10s %-20s %-10s %-50s\n" "$pid" "$service" "$mem" "$path"
done <<< "$top_processes"

#save this to logfile and then restart mongoser service.
