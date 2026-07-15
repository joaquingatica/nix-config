#!/usr/bin/env bash
# Claude Code statusLine command mirroring Starship default prompt

input=$(cat)

# --- Directory ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
if [ -n "$cwd" ]; then
  home="$HOME"
  short_cwd="${cwd/#$home/~}"
  # Show only last 3 path components (Starship default truncation_length = 3)
  IFS='/' read -ra parts <<< "$short_cwd"
  count=${#parts[@]}
  if [ "$count" -gt 3 ]; then
    short_cwd="…/${parts[$count-3]}/${parts[$count-2]}/${parts[$count-1]}"
  fi
fi

# --- Git branch & status ---
git_info=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" describe --tags --exact-match 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Git status indicators (mirrors Starship git_status defaults)
    indicators=""
    git_status=$(git -C "$cwd" status --porcelain 2>/dev/null)
    staged=$(echo "$git_status" | grep -c "^[MADRC]" 2>/dev/null || echo 0)
    unstaged=$(echo "$git_status" | grep -c "^.[MD]" 2>/dev/null || echo 0)
    untracked=$(echo "$git_status" | grep -c "^??" 2>/dev/null || echo 0)
    conflicted=$(echo "$git_status" | grep -c "^UU\|^AA\|^DD" 2>/dev/null || echo 0)

    [ "$conflicted" -gt 0 ] && indicators="${indicators}="
    [ "$staged" -gt 0 ]     && indicators="${indicators}+"
    [ "$unstaged" -gt 0 ]   && indicators="${indicators}!"
    [ "$untracked" -gt 0 ]  && indicators="${indicators}?"

    if [ -n "$indicators" ]; then
      git_info=" on  $branch [$indicators]"
    else
      git_info=" on  $branch"
    fi
  fi
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- Context remaining ---
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_info=""
if [ -n "$remaining" ]; then
  remaining_int=$(printf "%.0f" "$remaining")
  ctx_info=" ctx:${remaining_int}%"
fi

# --- Rate limits (Claude.ai) ---
rate_info=""
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five" ]; then
  rate_info=" 5h:$(printf '%.0f' "$five")%"
fi

# --- Assemble ---
# Colors: cyan for dir, purple for git, dim for meta
# Using ANSI escapes; status line renders in dim context
printf "\033[36m%s\033[0m" "${short_cwd}"
[ -n "$git_info" ] && printf "\033[35m%s\033[0m" "$git_info"
[ -n "$model" ]    && printf "\033[2m via %s\033[0m" "$model"
printf "\033[2m%s%s\033[0m" "$ctx_info" "$rate_info"
