#!/bin/sh
# Run from the repo root: sh tests/lsp-reminder.test.sh
set -e
hook="$PWD/plugins/lerd-php/hooks/lsp-reminder.sh"
dir=$(mktemp -d "$PWD/tests/.fixture.XXXXXX")
trap 'rm -rf "$dir"' EXIT

out=$(echo '{}' | CLAUDE_PROJECT_DIR="$dir" sh "$hook")
[ -z "$out" ] || { echo "FAIL: reminded outside a PHP project"; exit 1; }

touch "$dir/composer.json"
out=$(echo '{}' | CLAUDE_PROJECT_DIR="$dir" sh "$hook")
echo "$out" | python3 -c 'import json,sys; c=json.load(sys.stdin)["hookSpecificOutput"]; assert c["hookEventName"]=="PreToolUse" and "LSP tool" in c["additionalContext"] and "permissionDecision" not in c'
echo pass
