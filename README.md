# Roast by AI plugin marketplace

This repository is a Claude Code plugin marketplace with one plugin, `roastbyai`. It lives
in [`plugins/roastbyai`](plugins/roastbyai/README.md).

```
/plugin marketplace add roastbyai/claude-plugin
/plugin install roastbyai@roastbyai
```

To try a local checkout before publishing:

```
claude --plugin-dir ./plugins/roastbyai
claude plugin validate ./plugins/roastbyai
```

The plugin declares the hosted MCP server at `https://mcp.roastbyai.com/mcp` and ships the
`roast-loop` skill. Nothing in this repository is secret; the OAuth flow runs against the
hosted server.
