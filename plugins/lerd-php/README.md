# lerd-php

Gives Claude Code PHP code intelligence (definitions, references, callers, hover types) by starting `lerd lsp`, the language server lerd already ships for tinker. It understands Laravel's facades, Eloquent statics, local scopes and relations because it reads the project's `vendor/`.

In a project with a `composer.json`, a hook stops the first grep for a PHP symbol in each session and points Claude at the language server. Later searches run untouched, and strings, config and non-PHP files are never stopped.

Requires lerd on `PATH`. Install with:

```
/plugin marketplace add lerd-env/claude-plugins
/plugin install lerd-php@lerd
```
