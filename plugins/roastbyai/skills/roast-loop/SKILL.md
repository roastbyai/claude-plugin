---
name: roast-loop
description: Roast a website that is not live yet (localhost through a tunnel, a staging server, or a preview deployment), fix the highest-severity findings in the code, re-roast, and repeat until the score clears a target. Use when the user asks to roast, review, critique, QA or improve a site they are building, or mentions Roast by AI. Arguments: a URL or a local port, optionally "target <score>" (default 80) and "max <iterations>" (default 5).
allowed-tools: mcp__plugin_roastbyai_roastbyai__check_credits mcp__plugin_roastbyai_roastbyai__roast_and_wait mcp__plugin_roastbyai_roastbyai__reroast_and_wait mcp__plugin_roastbyai_roastbyai__get_roast mcp__plugin_roastbyai_roastbyai__roast_history Read Edit Write Grep Glob Bash
---

# Roast loop

You are running a fix-and-retest loop against Roast by AI, a website critic that scores a
page in eight categories (design/UX, copy, SEO, performance, accessibility, conversion,
mobile, trust signals) and returns findings with locations. Each roast costs one credit.
The user's arguments: `$ARGUMENTS`.

Parse the arguments first:

- A URL (`https://...`) is roasted as is. A bare port (`3000`) or `localhost:3000` means a
  dev server on this machine that must be tunnelled first.
- `target <n>` sets the overall score to reach (default 80). `max <n>` caps the number of
  roasts (default 5).

## 1. Reach the site

Roast by AI crawls from its own servers. It cannot reach `localhost`, private IPs, or
Docker service names, and it refuses them with an explanation. For a local port:

1. Check the dev server answers: `curl -sS -o /dev/null -w '%{http_code}' http://localhost:PORT/`.
   If it does not, tell the user to start it and stop.
2. Check `cloudflared` is installed (`command -v cloudflared`). If not, print the install
   line for their platform (`brew install cloudflared` on macOS; packages exist for Linux and
   Windows) and stop. Do not fall back to ngrok's free tier: it puts a warning page in front
   of browser visits, so screenshots would show the warning instead of the site.
3. Start the tunnel in the background and capture its output:
   `cloudflared tunnel --url http://localhost:PORT > /tmp/roastbyai-tunnel.log 2>&1 &`
   Then poll the log (up to 30 seconds) for a line containing `https://` and
   `.trycloudflare.com`. That address is the roast target.
4. Verify the tunnel serves the site: `curl -sS -o /dev/null -w '%{http_code}' <tunnel url>`.
   A `403` or a "Blocked request" body usually means the dev server rejects unknown host
   names. Tell the user which setting to change and stop:
   - Vite: `server.allowedHosts: true` (or add the `.trycloudflare.com` host) in `vite.config`.
   - Rails: add the host to `config.hosts` in `config/environments/development.rb`.
   - Django: add it to `ALLOWED_HOSTS`.
   - Next.js and plain static servers need nothing.

While the tunnel runs, anyone with the random address can reach the dev server. Say so once,
and stop the tunnel when the loop ends (`kill` the background process).

## 2. Check the budget

Call `check_credits`. Each iteration costs one credit. If the balance is below three, tell
the user how many iterations that buys and ask whether to continue before spending anything.
Never spend more credits than the user agreed to.

## 3. First roast

Call `roast_and_wait` with the target URL. For a tunnel host pass `pagespeed: false`;
Google's PageSpeed cannot measure a temporary tunnel and the server skips it anyway, but
being explicit saves a round trip. For a public staging or preview URL leave PageSpeed on.

Keep the returned `id`. Every later iteration re-roasts that id so the versions chain and
the deltas are computed for you.

Read `structuredContent.findings`. Each finding has an `id` (stable across iterations, such
as `seo-2`), a `category`, a `severity` (high, medium, low), a `title`, a `description`, a
`location` (a CSS selector, a section name, or the visible text of the element) and
`evidence` (the issues the critic saw in that category).

## 4. Pick what to fix

Take the high-severity findings first, then medium. For each one, map the `location` to a
file in this repository with Grep on the selector, the visible text or the section name.
Skip a finding when:

- it cannot be mapped to code you can edit here (third-party widgets, hosting-level
  performance such as server response time, CDN or caching);
- it needs content only the user can provide (real testimonials, pricing, legal pages).
  List those for the user at the end instead of inventing content.

Aim for three to five fixes per iteration. Small, real fixes beat sweeping rewrites.

## 5. Fix

Edit the code. Stay inside this repository. Keep the site's existing style and stack. After
editing, run whatever check the project already has (`npm run lint`, `npm run build`, a type
check) and confirm the dev server still answers on the port. Do not re-roast broken pages.

## 6. Re-roast

Call `reroast_and_wait` with the saved id. Compare `overall_score`,
`overall_score_delta` and `category_deltas` with the previous iteration. If the server does
not offer `reroast_and_wait`, fall back to `roast_and_wait` on the same URL; the loop still
works, only the deltas are lost.

## 7. Stop when

- the overall score is at or above the target, or
- the number of roasts reached `max`, or
- the score did not improve for two iterations in a row, or
- credits ran out (the tool returns an "insufficient credits" error).

Never re-roast without having changed something since the last roast.

## 8. Report

Stop the tunnel. Then print:

1. A table with one row per version: version, overall score, delta, and the per-category
   deltas that moved.
2. The list of findings you fixed, with the file you changed for each.
3. The findings you skipped and why, especially the ones that need the user's input.
4. Credits spent, and the current balance from `check_credits`.
5. The critic's roast text from the last version, verbatim. It is the part people share.

If the account is on the free tier, mention once that the roast is public by default and can
be made private with a Professional subscription, and link to https://roastbyai.com/pricing.
