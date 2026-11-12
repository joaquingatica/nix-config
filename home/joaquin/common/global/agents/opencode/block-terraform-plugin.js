import { spawnSync } from "node:child_process";

// opencode 1.x named its shell tool "bash"; 2.x renamed it "shell".
const SHELL_TOOLS = new Set(["bash", "shell"]);

function denyReason(command) {
  if (typeof command !== "string") return undefined;
  const result = spawnSync("/etc/profiles/per-user/joaquin/bin/block-terraform", {
    input: JSON.stringify({ tool_input: { command } }),
    encoding: "utf8",
  });
  if (!result.stdout) return undefined;
  return JSON.parse(result.stdout).hookSpecificOutput?.permissionDecisionReason;
}

// opencode 1.x server hooks, kept so the plugin also loads on older versions.
const server = async () => ({
  "tool.execute.before": async (input, output) => {
    const reason = SHELL_TOOLS.has(input.tool) ? denyReason(output.args?.command) : undefined;
    if (reason) throw new Error(reason);
  },
});

export default {
  id: "block-terraform",
  server,
  async setup(ctx) {
    await ctx.tool.hook("execute.before", (event) => {
      const reason = SHELL_TOOLS.has(event.tool) ? denyReason(event.input?.command) : undefined;
      if (reason) throw new Error(reason);
    });
  },
};
