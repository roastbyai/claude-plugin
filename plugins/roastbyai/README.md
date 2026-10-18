# Roast by AI for Claude Code

A critic in your coding loop. Roast a site that is not live yet, get findings with
locations, fix them, roast again, and watch the score move.

```
/plugin marketplace add roastbyai/claude-plugin
/plugin install roastbyai@roastbyai
```

Then, in a project with a dev server running on port 3000:

```
/roastbyai:roast-loop 3000 target 80
```

Claude starts a tunnel with `cloudflared`, roasts the site, fixes the highest-severity
findings in your code, re-roasts, and stops when the score clears 80, after five roasts, or
when nothing moves for two rounds. The report lists every version with its deltas, what was
fixed and where, and what needs your input.

Using Cursor or Codex? The same MCP server and skill work there too; setup is in the
[repository README](../../README.md).

## What you need

- Claude Code and a free Roast by AI account. The first tool call opens a browser window to
  sign in; there is no API key to manage. New accounts start with credits to try the loop,
  and every roast costs one credit.
- `cloudflared` for local sites: `brew install cloudflared` on macOS. Public staging and
  preview URLs need no tunnel.

## Tools the plugin adds

| Tool | What it does |
|---|---|
| `roast_and_wait` | Roast a URL and wait for the result (30 to 90 seconds) |
| `reroast_and_wait` | Roast the same project again; the result carries deltas versus the previous version |
| `get_roast` | Fetch a roast by id |
| `roast_history` | Every version of a roast with its deltas |
| `roast_url`, `reroast`, `batch_roast` | The non-blocking variants |
| `check_credits` | Balance and plan |

Results come back as text for you and as structured data for Claude: a severity-ordered
`findings` list where each entry has an id that stays stable across re-roasts, a category, a
title, a description, a `location` (CSS selector, section name or visible text) and the
evidence behind it.

## Sites that are not live yet

Roast by AI crawls from its own servers, so `localhost` is not reachable. The skill exposes a
local port through a Cloudflare quick tunnel, which needs no account and shows no warning
page. PageSpeed is skipped automatically for tunnel hosts, since Google cannot measure a
temporary tunnel, so a roast finishes in under a minute.

While the tunnel runs, anyone with the random address can reach your dev server. The skill
stops the tunnel when the loop ends. Do not tunnel a server that exposes secrets or an
unauthenticated admin.

Some dev servers refuse unknown host names. Vite needs `server.allowedHosts`, Rails needs the
host in `config.hosts`, Django needs it in `ALLOWED_HOSTS`. The skill detects the refusal and
tells you which one.

## Data and services

- **Roast by AI** (the MCP connector) receives the URL you roast and your tool calls. It crawls
  that page, stores the roast with its page text and screenshots while your account is active,
  and analyses it with Anthropic's Claude and, for public sites, Google PageSpeed. Roasts on free
  accounts are public. See the [privacy policy](https://www.roastbyai.com/privacy).
- **Cloudflare** carries your dev server's traffic when the skill roasts a local port through a
  quick tunnel. The skill starts the tunnel only for that, and stops it when the loop ends.
- Nothing else: the skill reads and edits files in your repository and sends no other data off
  your machine.

## Privacy

Roasts on free accounts are public by default and can appear in the public gallery. A
Professional subscription makes them private. The skill mentions this once per loop.

## Links

- Documentation: https://roastbyai.com/mcp/claude-code
- API reference: https://roastbyai.com/api/doc
- Pricing: https://roastbyai.com/pricing
