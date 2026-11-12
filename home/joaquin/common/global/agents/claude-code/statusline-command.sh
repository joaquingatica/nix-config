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
  local pct=$1 width=${2:-10} color filled empty fill pad
  if [ "$pct" -ge 90 ]; then color="$RED"
  elif [ "$pct" -ge 70 ]; then color="$YELLOW"
  else color="$GREEN"; fi

  filled=$(((pct * width + 50) / 100)); [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  empty=$((width - filled))
  printf -v fill "%${filled}s"; printf -v pad "%${empty}s"
  printf '%b%s%b' "$color" "${fill// /█}${pad// /░}" "$RESET"
}

BAR=$(bar "$PCT")

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

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
echo -e "${BAR} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s${LIMITS:+ | $LIMITS}"

