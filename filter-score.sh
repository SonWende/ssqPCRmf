#!/bin/bash

# run with: filter-score.sh file score
threshold=$2
awk 'NR % 2 == 1' $1 | while read line; do
  score=$(echo $line | awk -F "=" '{print $2}' | awk '{print $1}')
  if (( $(echo "$score > $threshold" | bc -l) )); then
    echo "$line"
  fi
done | grep -f - -A1 $1 
