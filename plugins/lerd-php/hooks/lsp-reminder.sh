#!/bin/sh
# Instructions alone lose to the grep habit, so the reminder arrives at the moment of the search.
# It never blocks: grep is still right for strings, config and macros.
cat >/dev/null
[ -f "${CLAUDE_PROJECT_DIR:-.}/composer.json" ] || exit 0
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"This is a PHP project with the lerd-php language server. For where a class, method or function is defined, who calls it, what implements an interface or what type a value has, use the LSP tool (load it with ToolSearch if it is deferred) instead of grep; it follows facades and Eloquent statics. Grep is fine for strings, config, non-PHP files and macros."}}'
