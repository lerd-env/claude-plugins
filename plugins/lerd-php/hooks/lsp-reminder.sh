#!/bin/sh
# Context from this hook only reaches Claude with the grep's result, so 115 reminders in one real session
# produced no LSP call. Only a denied call stops it in time, and denying once keeps grep usable afterwards.
input=$(tr -d '\n')
[ -f "${CLAUDE_PROJECT_DIR:-.}/composer.json" ] || exit 0

# No jq or python here: neither is guaranteed on the machines lerd runs on.
field() {
	printf '%s' "$input" | sed -nE "s/.*\"$1\": *\"(([^\"\\\\]|\\\\.)*)\".*/\1/p"
}

# Output filters after a pipe, string searches and searches of other languages are all left alone.
searches_php_symbol() {
	awk '{
		gsub(/\\n|&&|\|\||;/, "\n")
		n = split($0, parts, "\n")
		for (i = 1; i <= n; i++) {
			c = parts[i]
			sub(/ \| .*/, "", c)
			sub(/^ +/, "", c)
			if (c !~ /^(grep|egrep|rg) /) continue
			php = c ~ /\.php| -t php/
			recursive = c ~ /^rg / || c ~ / -[a-zA-Z]*[rR]/
			narrowed = c ~ /--include|--glob| -g | -t /
			if (!php && (!recursive || narrowed)) continue
			gsub(/ -[^ ]*/, " ", c)
			gsub(/[^ "\047]*(\/|\.php)[^ "\047]*/, "", c)
			if (c ~ /[a-z0-9][A-Z]|->[a-zA-Z_]|::[a-zA-Z_]|(function|class|new|extends|implements|interface|trait|enum) +[a-zA-Z_]/) found = 1
		}
	}
	END { exit !found }'
}

session=$(field session_id)
[ -n "$session" ] || exit 0
marker="${TMPDIR:-/tmp}/lerd-php-lsp-$session"
[ ! -e "$marker" ] || exit 0

if [ "$(field tool_name)" = Grep ]; then
	type=$(field type) glob=$(field glob)
	search="rg ${type:+-t $type }${glob:+--glob=$glob }\"$(field pattern)\" $(field path)"
else
	search=$(field command)
fi
printf '%s\n' "$search" | searches_php_symbol || exit 0

touch "$marker"
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Use the LSP tool for this lookup before any more grep. It looks like a PHP symbol search and this project has the lerd-php language server. Load it now with ToolSearch select:LSP, then call it with filePath set to a .php file, never a folder (workspaceSymbol searches the whole project from any .php file). It answers where a class, method or function is defined, who calls it, what implements an interface and what type a value has; it lists only real calls and follows Eloquent statics and inheritance. For calls through a facade, ask references on the @method docblock line of the facade. After LSP, grep is a fair last check on callers, since calls on untyped properties such as $this->x in Pest tests are missed. This check runs once per session. Grep straight away only if this really was a string, config, non-PHP or macro search, or ToolSearch finds no LSP tool."}}'
