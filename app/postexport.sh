#!/bin/sh
set -u -o pipefail;

# Create a directory based on the TimeStamp
TS=$(date +%FT%H.%M.%S);

cd /app/__sapper__/export/;
mkdir -p 0 1 2 3 4 5 6 7 8 9;
# Find all /[1-9]*/*/index.html files and:
# move them to ID(-1)/ID.html (the ID(-1) is the last digit of the ID, taking the first would end up having a Log distribution (see https://en.wikipedia.org/wiki/Benford's_law))
# append line to systemid_urls.nginx with 'ID URL'
# remove old directories (except for the ones that are single digits)
find -name 'index.html' -path './[1-9]*' -type f -exec sh -c 'P=${0:2:-11};ID=${P%/*};URL=${P##*/};mv "$0" "./${ID:(-1)}/$ID.html";echo "$ID $URL;">>systemid_urls.nginx;rmdir "./$ID/$URL";if [ ${#ID} -gt 1 ]; then rmdir "$ID";fi;' {} \;
sort -n systemid_urls.nginx -o systemid_urls.nginx;

# Check for double systemId mappings, this will error nginx, so abort early
E=$(awk '$1==l{print "duplicate id:\n" $0 "\n" ll;e=1}{l=$1;ll=$0}END{exit(e)}' systemid_urls.nginx 2>&1);

if [ $? -ne 0 ]; then
	>&2 echo -e "Nginx mapping validation failed (found duplicate IDs)\n$E";
	exit 1;
fi;
echo "OK: no duplicate IDs found in Nginx mapping";

cd /app;

# Copy export artifacts
mv /app/__sapper__/export/ /web/$TS;

# Switch latest symbolic link
ln -nsf /web/$TS /web/latest;

# Set nginx to use static again
ln -nsf /etc/nginx/shared/static.conf /etc/nginx/conf.d/static-or-node;

# Update metadata so alpine inotifyd can catch it
touch /web/nginx_reload;
