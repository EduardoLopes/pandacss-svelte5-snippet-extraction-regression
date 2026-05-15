#!/usr/bin/env bash
# Reports which .svelte files in src/ can be extracted by `panda cssgen`.
# Usage: scripts/report.sh [version]
#   - With a version argument, installs that @pandacss/dev release first.
#   - Without one, runs against whatever version is currently installed.
# Each file is tested in isolation by narrowing the `include` glob to it.
set -u

cd "$(dirname "$0")/.."

if [ "${1-}" != "" ]; then
	requested=$1
	current=$(node -p "require('./node_modules/@pandacss/dev/package.json').version" 2>/dev/null || echo '')
	if [ "$current" != "$requested" ]; then
		printf 'Installing @pandacss/dev@%s ...\n' "$requested"
		pnpm add -D "@pandacss/dev@$requested" >/dev/null 2>&1 || {
			printf 'Failed to install @pandacss/dev@%s\n' "$requested" >&2
			exit 2
		}
	fi
fi

version=$(node -p "require('./node_modules/@pandacss/dev/package.json').version")
printf '\n@pandacss/dev installed: %s\n\n' "$version"
printf '%-45s %s\n' 'File' 'panda cssgen'
printf '%-45s %s\n' '----' '------------'

cp panda.config.ts panda.config.ts.bak
trap 'mv panda.config.ts.bak panda.config.ts 2>/dev/null; rm -f panda.config.ts.tmp /tmp/panda-report-out.css' EXIT

pnpm panda codegen >/dev/null 2>&1

fail=0
pass=0

for file in src/*.svelte; do
	name=$(basename "$file")
	sed "s|'./src/\\*\\*/\\*.{ts,svelte}'|'./$file'|" panda.config.ts.bak > panda.config.ts

	rm -f /tmp/panda-report-out.css
	output=$(pnpm panda cssgen --outfile /tmp/panda-report-out.css 2>&1)
	if echo "$output" | grep -q 'Could not find source file'; then
		printf '%-45s ❌ throws "Could not find source file"\n' "$name"
		fail=$((fail + 1))
	elif [ -f /tmp/panda-report-out.css ]; then
		rules=$(grep -cE 'color: (red|green|blue|orange|purple|teal)' /tmp/panda-report-out.css || true)
		printf '%-45s ✅ extracted (%s color rule[s])\n' "$name" "$rules"
		pass=$((pass + 1))
	else
		printf '%-45s ⚠️  unknown failure\n' "$name"
		fail=$((fail + 1))
	fi
done

printf '\n%d ok, %d failing on @pandacss/dev@%s\n\n' "$pass" "$fail" "$version"
exit $fail
