#!/bin/sh
find "$(pwd)" ! -readable -prune -o -iname '*.yml' -print -o -iname '*.yaml' -print \
| xargs grep -E '^\s*(#force-check)?\s*image:.+#check-outdated.*$' -h \
| sed -r 's@^\s*(#force-check)?\s*image:\s*((\S+)/)?(\S+):(\S+)\s*#check-outdated(:\s*(\S+))?\s*$@\3/\4\t{\5,\7}@g;s@^/@library/@g;s/,\}$/,latest}/g;' \
| sort | uniq \
| xargs -L 1 sh -c 'TOKEN=$(curl -sSf "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$0:pull" | jq -r .token);\
curl -sSf --compressed -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "https://index.docker.io/v2/$0/manifests/$1" \
| jq "map(.config.digest)|if (.[0] | startswith(\"sha256:\")) and .[0] == .[1] then \"$0 is up to date\" else error(\"$0 $1 outdated\") end" -rs 2> /dev/null \
|| (echo -n "$0 is outdated, update to tag: ";SEARCH="${1##*,}";SEARCH="${SEARCH%\}}";if [ "$SEARCH" = "latest" ]; then FILTER=""; else FILTER="$SEARCH"; fi; \
TAGS="$(curl -sSf --compressed "https://registry.hub.docker.com/v2/repositories/$0/tags/?page_size=30" | jq -r ".results|map(select(.name|endswith(\$filter))|.name)|join(\",\")" --arg filter "$FILTER")"; \
curl -sH "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "https://index.docker.io/v2/$0/manifests/{$TAGS}" \
| jq -s "[map(.config.digest),(\$tags|split(\",\"))]|transpose|map({tag:.[1],digest:.[0]})|group_by(.digest)|map({tags:map(.tag),digest:.[0].digest})|map(select(.tags|any(.==\$search))|.tags|sort_by(length)|reverse|join(\", \"))[]" -r --arg tags "$TAGS" --arg search "$SEARCH")'