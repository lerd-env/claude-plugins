# lerd-php

Gives Claude Code PHP code intelligence (definitions, references, callers, hover types) by starting `lerd lsp`, the language server lerd already ships for tinker. It understands Laravel's facades, Eloquent statics, local scopes and relations because it reads the project's `vendor/`.

Requires lerd on `PATH`. Install with:

```
/plugin marketplace add lerd-env/claude-plugins
/plugin install lerd-php@lerd
```
