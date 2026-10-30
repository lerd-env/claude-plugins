# lerd-php

Gives Claude Code PHP code intelligence (definitions, references, callers, hover types) by starting `lerd lsp`, the language server lerd already ships for tinker. It understands Laravel's facades, Eloquent statics, local scopes and relations because it reads the project's `vendor/`.

In a project with a `composer.json`, a hook reminds Claude to use the language server instead of grep for definitions, callers and types. It never blocks the search.

Requires lerd on `PATH`. Install with:

```
/plugin marketplace add lerd-env/claude-plugins
/plugin install lerd-php@lerd
```
