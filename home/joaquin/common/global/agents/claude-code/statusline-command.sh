#!/bin/bash

# https://code.claude.com/docs/en/statusline#display-multiple-lines

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '(.context_window.used_percentage // 0) | round')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

bar() {
  local pct=$1 width=${2:-10} color filled out="" i
  if [ "$pct" -ge 90 ]; then color="$RED"
  elif [ "$pct" -ge 70 ]; then color="$YELLOW"
  else color="$GREEN"; fi

  filled=$(((pct * width + 50) / 100))
  # Reserve the end cells for exactly 0% and 100%, so a near-empty or near-full bar never
  # reads as either.
  if [ "$pct" -le 0 ]; then filled=0
  elif [ "$pct" -ge 100 ]; then filled=$width
  elif [ "$filled" -lt 1 ]; then filled=1
  elif [ "$filled" -ge "$width" ]; then filled=$((width - 1)); fi

  for ((i = 0; i < width; i++)); do
    if [ "$i" -lt "$filled" ]; then out+="█"; else out+="░"; fi
  done
  printf '%b%s%b' "$color" "$out" "$RESET"
}

BAR=$(bar "$PCT")

elapsed() {
  local total=$(($1 / 1000)) d h m s
  d=$((total / 86400)); h=$((total % 86400 / 3600)); m=$((total % 3600 / 60)); s=$((total % 60))
  if [ "$d" -gt 0 ]; then printf '%dd %dh %dm' "$d" "$h" "$m"
  elif [ "$h" -gt 0 ]; then printf '%dh %dm' "$h" "$m"
  else printf '%dm %ds' "$m" "$s"; fi
}

ELAPSED=$(elapsed "$DURATION_MS")

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

LIMITS=""
if [ -n "$FIVE_H" ]; then
  FIVE_H_PCT=$(printf '%.0f' "$FIVE_H")
  LIMITS="5h:$(bar "$FIVE_H_PCT" 8) ${FIVE_H_PCT}%"
fi
if [ -n "$WEEK" ]; then
  WEEK_PCT=$(printf '%.0f' "$WEEK")
  LIMITS="${LIMITS:+$LIMITS | }7d:$(bar "$WEEK_PCT" 8) ${WEEK_PCT}%"
fi

echo -e "${CYAN}[$MODEL${EFFORT:+ · $EFFORT}]${RESET} 📁 ${DIR##*/}$BRANCH"
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${BAR} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${ELAPSED}${LIMITS:+ | $LIMITS}"

