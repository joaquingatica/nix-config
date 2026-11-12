# Deny state-changing terraform/tofu/terragrunt commands. Wired up as a PreToolUse hook on Bash in
# Claude Code and Codex, which share this payload and deny format, and called by an opencode
# plugin. Reads the hook payload on stdin; silence means allow.
#
# Wrapped by writeShellApplication, which supplies the shebang, `set -euo pipefail`, and a PATH
# carrying jq and grep.

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

# Anchored at command position (start of line, or after ; && || | $( ), so the binary name inside a
# quoted string or a grep pattern is not a match. Skips over sudo, env VAR=..., global flags, and
# terragrunt's run/run-all wrappers to reach the subcommand.
re='(^|[;&|]|\$\()[[:space:]]*(sudo[[:space:]]+)*(env[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(terraform|tofu|terragrunt)[[:space:]]+((-[^[:space:]]+|run|run-all|all)[[:space:]]+)*((plan|apply|destroy|import|taint|untaint|refresh|force-unlock)(-all)?|state[[:space:]]+(mv|rm|push|replace-provider))([[:space:]]|$)'

if printf '%s' "$cmd" | grep -Eq "$re"; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked by block-terraform.sh: terraform/tofu/terragrunt commands that change infrastructure or state (plan, apply, destroy, import, taint, refresh, force-unlock, state mv/rm/push/replace-provider) are not runnable by agents. Read-only subcommands (init, fmt, validate, show, output, state list/show) are fine."
    }
  }'
fi
exit 0
