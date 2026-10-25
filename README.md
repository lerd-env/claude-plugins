<h1 align="center">Lerd Claude Code Plugins</h1>

<p align="center">
  The Claude Code plugin marketplace for <a href="https://lerd.sh">Lerd</a>.<br>
  Give Claude Code what Lerd already knows about your PHP projects.
</p>

<p align="center">
  <a href="https://lerd.sh"><img src="https://img.shields.io/badge/part%20of-lerd-ff2d20" alt="Part of Lerd"></a>
  <a href="https://lerd.sh/features/mcp#php-code-intelligence"><img src="https://img.shields.io/badge/docs-lerd.sh-blue" alt="Docs"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
</p>

Lerd talks to AI assistants through its MCP server, which covers sites, services, databases, workers and logs. Some things an assistant needs are not tools at all, though: Claude Code reads code through language servers, and that wiring ships as a plugin. This repo is where those plugins live, so `claude plugin marketplace add` pulls a few kilobytes instead of the whole Lerd repository.

`lerd mcp:enable-global` adds this marketplace and installs its plugins for you, and `lerd mcp:disable-global` takes them back out. Nothing here does anything without Lerd on your `PATH`.

## What the plugins power

- 🔎 **Go to definition** across your app and `vendor/`, including Laravel facades, Eloquent statics, local scopes and relations
- 🧭 **Find references and callers** of a method or class, exactly, instead of grepping for a name
- 🏷️ **Hover types**, so a query chain reads as `Collection<int, Feedback>` rather than a guess
- ⚡ **No setup per project**: the language server is the one Lerd already ships for tinker, started with `lerd lsp`

## Available plugins

| Plugin | What it adds | Runs |
|---|---|---|
| `lerd-php` | PHP code intelligence for `.php` files | `lerd lsp` |

## Usage

Let Lerd do it:

```bash
lerd mcp:enable-global
```

Or install by hand from inside Claude Code:

```
/plugin marketplace add lerd-env/claude-plugins
/plugin install lerd-php@lerd
```

Restart Claude Code afterwards so the LSP tool appears.

## Contributing

A plugin is an entry in `.claude-plugin/marketplace.json` plus a folder under `plugins/` with its README. Keep each one a thin pointer at a `lerd` command, so the behaviour lives in Lerd and every plugin keeps working across Lerd releases. Run `claude plugin validate .` before opening a pull request.

## License

MIT
