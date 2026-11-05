#!/bin/sh
# Run from the repo root: sh tests/lsp-reminder.test.sh
set -e
hook="$PWD/plugins/lerd-php/hooks/lsp-reminder.sh"
dir=$(mktemp -d "$PWD/tests/.fixture.XXXXXX")
trap 'rm -rf "$dir"' EXIT
session=0

# Encodes the input the way Claude Code does, so shell quoting and JSON escapes are both exercised.
run() { # session tool key value [key value...]
	id=$1 tool=$2
	shift 2
	python3 -c 'import json, sys
a = sys.argv[3:]
print(json.dumps({"session_id": sys.argv[1], "tool_name": sys.argv[2], "tool_input": dict(zip(a[::2], a[1::2]))}))' "$id" "$tool" "$@" |
		CLAUDE_PROJECT_DIR="$dir" TMPDIR="$dir" sh "$hook"
}

blocks() {
	session=$((session + 1))
	out=$(run "s$session" "$@")
	echo "$out" | python3 -c 'import json, sys
c = json.load(sys.stdin)["hookSpecificOutput"]
assert c["hookEventName"] == "PreToolUse" and c["permissionDecision"] == "deny"
assert all(w in c["permissionDecisionReason"] for w in ("ToolSearch", "once", "filePath"))' ||
		{ echo "FAIL: should block: $*"; exit 1; }
}

passes() {
	session=$((session + 1))
	out=$(run "s$session" "$@")
	[ -z "$out" ] || { echo "FAIL: should pass silently: $*"; exit 1; }
}

out=$(run outside Bash command 'grep -rn "getUser" app')
[ -z "$out" ] || { echo "FAIL: blocked outside a PHP project"; exit 1; }

touch "$dir/composer.json"

blocks Bash command 'grep -n "function enrollInGlobalGroups" -A40 app/Services/GroupService.php'
blocks Bash command 'cd /srv/site && grep -rln "RugbySyncService" tests | head'
blocks Bash command 'ls app; rg "->members\(" app'
blocks Bash command 'grep -rn "Team::where" app --include=*.php'
blocks Grep pattern 'class OrderPolicy'
blocks Grep pattern 'getUser' glob '*.php'
blocks Grep pattern 'getUser' type php
blocks Grep pattern 'getUser' path app/Models/User.php

passes Bash command 'gh run view 1 --log-failed | grep -E "FAIL|TestCase"'
passes Bash command 'php artisan route:list | grep -E "getUser"'
passes Bash command 'grep -rn "privacy" app --include=*.php'
passes Bash command 'grep -n "privacy" app/Services/GroupService.php'
passes Bash command 'grep -rniE "global|use_for_both" app'
passes Bash command 'grep -rln "<CheckBox" resources/js --include=*.vue'
passes Bash command 'grep -n "getUser" config.yaml'
passes Grep pattern 'getUser' glob '*.vue'
passes Grep pattern 'DB_HOST'

first=$(run repeat Bash command 'grep -rn "getUser" app')
[ -n "$first" ] || { echo "FAIL: first symbol search not blocked"; exit 1; }
second=$(run repeat Bash command 'grep -rn "getUser" app')
[ -z "$second" ] || { echo "FAIL: blocked twice in one session"; exit 1; }
other=$(run another Bash command 'grep -rn "getUser" app')
[ -n "$other" ] || { echo "FAIL: a new session should be blocked again"; exit 1; }

out=$(echo '{"tool_name":"Grep","tool_input":{"pattern":"getUser"}}' | CLAUDE_PROJECT_DIR="$dir" TMPDIR="$dir" sh "$hook")
[ -z "$out" ] || { echo "FAIL: blocked without a session to remember it in"; exit 1; }

echo pass
