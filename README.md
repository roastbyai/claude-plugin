# Roast by AI for coding agents

A website critic in your coding loop. Roast a site that is not live yet, get findings with
locations, fix them, roast again, and watch the score move.

Two parts make that work, and every agent below uses both:

- **The MCP server** at `https://mcp.roastbyai.com/mcp` provides the roast tools. It signs you in
  with OAuth on first use, so there is no API key to copy. Any Roast by AI account works,
  including free accounts; every roast costs one credit.
- **The `roast-loop` skill** tells the agent how to run the loop: tunnel a local port, check the
  credit budget, roast, fix the highest-severity findings, re-roast, stop at a target score, and
  report.

## Claude Code

Install the plugin. It brings the MCP server and the skill in one step:

```
/plugin marketplace add roastbyai/claude-plugin
/plugin install roastbyai@roastbyai
/roastbyai:roast-loop 3000 target 80
```

Details are in [`plugins/roastbyai`](plugins/roastbyai/README.md).

## Cursor

1. Add the server to `~/.cursor/mcp.json` (or `.cursor/mcp.json` in one project). If the file
   already lists servers, add the `roastbyai` entry next to them:

   ```json
   {
     "mcpServers": {
       "roastbyai": {
         "url": "https://mcp.roastbyai.com/mcp"
       }
     }
   }
   ```

   Cursor opens a browser window to sign in the first time a Roast by AI tool is used.

2. Install the skill where Cursor and other agents look for personal skills:

   ```
   git clone --depth 1 https://github.com/roastbyai/claude-plugin.git /tmp/roastbyai-plugin
   mkdir -p ~/.agents/skills && cp -R /tmp/roastbyai-plugin/skills/roast-loop ~/.agents/skills/
   ```

   For a single project, copy it into that project's `.agents/skills/` or `.cursor/skills/`
   instead.

3. In Cursor's agent chat, run `/roast-loop 3000 target 80`, or ask it to roast the site on
   port 3000.

## Codex

1. Add the server and sign in:

   ```
   codex mcp add roastbyai --url https://mcp.roastbyai.com/mcp
   codex mcp login roastbyai
   ```

   Or add it to `~/.codex/config.toml` by hand and then run the login command:

   ```toml
   [mcp_servers.roastbyai]
   url = "https://mcp.roastbyai.com/mcp"
   ```

2. Install the skill. Codex reads personal skills from `~/.agents/skills`, the same folder as
   Cursor, so one copy serves both:

   ```
   git clone --depth 1 https://github.com/roastbyai/claude-plugin.git /tmp/roastbyai-plugin
   mkdir -p ~/.agents/skills && cp -R /tmp/roastbyai-plugin/skills/roast-loop ~/.agents/skills/
   ```

   For a single repository, copy it into that repository's `.agents/skills/` instead.

3. Ask Codex to roast the site on port 3000, or mention the skill explicitly with
   `$roast-loop 3000 target 80`.

## Other agents

Any agent that reads the [Agent Skills](https://agentskills.io) format and talks to remote MCP
servers can use the same two parts: add the server URL above, and copy
[`skills/roast-loop`](skills/roast-loop/SKILL.md) into the folder your agent reads skills from.

## Sites that are not live yet

Roast by AI crawls from its own servers, so `localhost` is out of reach. The skill exposes a
local port through a Cloudflare quick tunnel (`brew install cloudflared` on macOS), which needs
no account. While the tunnel runs, anyone with the random address can reach your dev server, so
the skill closes it when the loop ends and warns you first if the dev server exposes debug pages
such as the Symfony profiler or Django's debug mode.

## Data and services

- **Roast by AI** (the MCP connector) receives the URL you roast and your tool calls. It crawls
  that page, stores the roast with its page text and screenshots while your account is active,
  and analyses it with Anthropic's Claude and, for public sites, Google PageSpeed. Roasts on free
  accounts are public. See the [privacy policy](https://www.roastbyai.com/privacy).
- **Cloudflare** carries your dev server's traffic when the skill roasts a local port through a
  quick tunnel. The skill starts the tunnel only for that, and stops it when the loop ends.
- Nothing else: the skill reads and edits files in your repository and sends no other data off
  your machine.

## For maintainers

The Claude Code plugin's copy, `plugins/roastbyai/skills/roast-loop/SKILL.md`, is the source of
truth. After editing it, regenerate the portable copy and bump the version in
`plugins/roastbyai/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`:

```
scripts/build-portable-skill.sh
claude plugin validate ./plugins/roastbyai
claude plugin validate .
```
