#!/bin/sh
LOCKDIR="/var/lock/";
LOCKFILE="$LOCKDIR$(basename $0 .sh)";
if [ "$1" = "reboot" ]; then
	echo "$$: Import run because of docker start";
elif [ "$1" = "cron" ]; then
	echo "$$: Import run based on cron";
else
	echo "$$: Import run started manually";
	if [ $# -lt 2 ]; then
		echo "$$: Note: to import a specific date, use the second argument to provide an XML filename, e.g. $ importdata.sh manual $(date +%Y%m%d.xml -d @$(( $(date +%s) - 86400)))";
	fi;
fi;
# The second argument provided can override an import
FILE="${2:-exportOO.xml}";
echo "$$: File to process \"$FILE\"";
set -u -o pipefail;

# All xslt/xsd/jq/sql working files are in /work, instead of /root (workdir because of crond).
cd /work;

# Lockfile logic functions
check_lock() {
	if [ ! -w  "$LOCKDIR" ]; then
		>&2 echo "$$: Directory $LOCKDIR is writable for LOCKFILE $LOCKFILE, aborting";
		exit 1;
	elif [ -e "$LOCKFILE" ]; then
		PID=$(cat "$LOCKFILE");
		echo "$$: Lockfile file found with PID=$PID";
		if kill -0 $PID 2> /dev/null; then
			>&2 echo "$$: LOCKFILE with $PID is still running, aborting";
			exit 1; # maybe error based on modify age of the lockfile (running for a few minutes is not bad, but for more than an hour is)
		fi;
		echo "$$: Removing lockfile since $PID is not running";
		rm -f "$LOCKFILE";
		lock_check;
	else
		if ! ( set -C; echo "$$" > "$LOCKFILE" ) 2>/dev/null; then
			>&2 echo "$$: LOCKFILE $LOCKFILE is present, aborting";
			exit 1;
		fi;
		trap 'remove_lock' EXIT;
	fi;
}

remove_lock() {
	rm -f "$LOCKFILE";
	echo "$$: End";
}

json2sql() {
	# Copy data to tmp tables
	echo "$$: Writing $1";
	echo "COPY tmp_$1 FROM STDIN;" >> import.pg.sql;
	E="$( (jq "$2" export-flat.json -r >> import.pg.sql) 2>&1)";
	check_error 'JQ json2sql error';
	echo '\.' >> import.pg.sql;
}

check_error() {
	if [ $? -ne 0 ]; then
		>&2 echo -e "$$: $1: $E, aborting";
		exit 1;
	fi;
}

# Make sure we only have 1 importdata running at the same time by writing a lock file
check_lock;

# Download the latest exportOO.xml (or manually provided $FILE name) in a temp file, using If-Modified-Since to only fetch if changed
TMPFILE=$(mktemp);
CODE="$(curl -sSfRA 'Mozilla/5.0 (compatible; OpenStateBot/1.0; +https://openstate.eu/bot)' \
	--compressed \
	-w "%{http_code}" \
	-H "If-Modified-Since: $(date -r "$FILE" -u +"%a, %d %b %Y %T GMT" 2>/dev/null || echo "Thu, 01 Jan 1970 00:00:00 GMT")" \
	-o "$TMPFILE" \
	"https://organisaties.overheid.nl/archive/$FILE")";
if [ "$CODE" != "200" ]; then
	rm "$TMPFILE";
	if [ "$CODE" == "304" ]; then
		echo "$$: Status code was 304, so nothing changed, exiting.";
		exit 0;
	else
		>&2 echo -e "$$: Status code was $CODE, aborting";
		exit 1;
	fi;
fi;
mv "$TMPFILE" "$FILE";
echo "$$: File $FILE fetched (new, Last-Modified: $(date -u +"%F %TZ" -r "$FILE"))";

# Validating the XML
# $ curl -sSfA 'Mozilla/5.0 (compatible; OpenStateBot/1.0; +https://openstate.eu/bot)' --compressed -o 'import-cron/oo-export.xsd' https://almanak.overheid.nl/static/schema/oo/export/oo-export-2.4.10.xsd
E="$(xmllint --schema oo-export.xsd "$FILE" --noout 2>&1)";
check_error 'XMLlint validating';
echo "$$: XMLlint $E";

# Convert the XML to JSON, then do some sed replacements (way faster with sed than in xslt 1.0 replace!):
# - Tabs => \t
# - Escape \x => \\x (Except for \t we just created or \" created by the xlst)
# - &amp; => &
E="$( (xsltproc autojson.xslt "$FILE" | sed -r -e 's/\t/\\t/g' -e 's/\\([^"t])/\\\\\1/g' -e 's/\&amp;/\&/g' > export.json) 2>&1)";
check_error 'xsltproc error';

# Check if the result is valid JSON without duplicate keys:
E="$(eslint export.json --rule '{no-dupe-keys:"error"}' --color 2>&1)"
check_error 'ESlint error on the generated JSON';
echo "$$: Converted to valid JSON (post lint)";

# Then use JQ to:
# - Remove empty arrays
# - Remove CDATA
# #- Base64 decode contactEmail, Removed in oo export 2.4.9:		| jq -c 'walk(if type=="object" and .contactEmail and (.contactEmail|contains("@")|not) and (.contactEmail|test("^[a-zA-Z0-9+/=]+$")) then .contactEmail|=(.|@base64d) else . end)' \
# - Base64 decode emailadres
# - Base64 decode emailadres.value
# - Flatten the hierarchy structure
E="$( (jq -c 'walk(if type == "object" then with_entries(select(.value != [])) else . end)' export.json \
		| jq -c 'walk(if type=="string" and startswith("&lt;![CDATA[") and endswith("]]&gt;") then .[12:-6] else . end)' \
		| jq -c 'walk(if type=="object" and (.emailadres|type)=="string" and (.emailadres|contains("@")|not) and (.emailadres|test("^[a-zA-Z0-9+/=]+$")) then .emailadres|=(.|@base64d) else . end)' \
		| jq -c 'walk(if type=="object" and (.emailadres|type)=="object" and .emailadres.value and (.emailadres.value|contains("@")|not) and (.emailadres.value|test("^[a-zA-Z0-9+/=]+$")) then .emailadres.value|=(.|@base64d) else . end)' \
		| jq -c -f flatten-structure.jq > export-flat.json) 2>&1)";
check_error 'JQ post processing error';
rm export.json;
echo "$$: Flattened JSON";

# Generate import.sql
# Begin transaction, clone almanak schema to a TEMP table format
echo 'BEGIN;' > import.pg.sql;
E="$( (psql -h db -U postgres -Xtf clone-schema.pg.sql allmanak >> import.pg.sql) 2>&1)";
check_error 'PSQL export schema error';

# Copy data to tmp tables
json2sql 'categorie' '(map(.categorie? //empty)|unique|map([.catnr,.naam])[]|@tsv)';
json2sql 'samenwerkingsvorm' 'map(select(.samenwerkingsvorm)|.samenwerkingsvorm)|flatten|unique|.[]|[.afkorting,.naam]|@tsv';
json2sql 'overheidsorganisatie' 'def jsonify:if type == "null" then null else . | @json end;map([.systemId?,.naam,.partij,(.types?|if type != "null" then "{"+join(",")+"}" else . end),(.categorie?|.catnr),.citeertitel?,.aangeslotenBijPensioenfonds?,.aantalInwoners?,.aantekening?,.afkorting?,(.afwijkendeBepaling?|jsonify),(.archiefzorgdrager?|.[0].systemId),(.beleidsterreinen?|jsonify),.beschrijving?,.bevoegdheden?,(.bevoegdheidsverkrijgingen?|if type != "null" then "{"+join(",")+"}" else . end),(.bronhouder?|.[0].systemId),(.classificaties?|jsonify),(.contact?|jsonify),.datumInwerkingtreding?,.datumOpheffing?,.doel?,.eindDatum?,.geldendeCAO?,.ictuCode?,.installatie?,(.instellingsbesluiten?|if type != "null" then map(gsub('"\"'\";\"''\""')|@json)|"{"+join(",")+"}" else . end),.inwonersPerKm2?,.kaderwetZboVanToepassing?,.kvkNummer?,(.laatsteEvaluatie?|jsonify),.omvatPlaats?,.oppervlakte?,.organisatiecode?,.partijFunctie?,(.personeelsomvang?|jsonify),.provincieAfkorting?,.rechtsvorm?,.registratiehouder?,(.relatieMetMinisterie?|.[0].systemId),(.resourceIdentifiers?|jsonify),(.samenwerkingsvorm?|.afkorting?),.standplaats?,.startDatum?,.subnaam?,.subtype?,.taalcode?,.takenEnBevoegdheden?,.titel?,.totaalZetels?,(.wettelijkeVoorschriften?|jsonify),(.zetels|jsonify)]|walk(if type == "null" then "<<NULL>>" else . end))[]|@tsv|gsub("<<NULL>>";"\\N")';
json2sql 'medewerkers' '.[]|select(.medewerkers)|.systemId as $systemId|.medewerkers[]|[$systemId,.]|@tsv';
json2sql 'functies' '.[]|select(.functies)|.systemId as $systemId|.functies[]|[$systemId,.]|@tsv';
json2sql 'organisaties' '.[]|select(.organisaties)|.systemId as $systemId|.organisaties[]|[$systemId,.]|@tsv';
json2sql 'parents' '.[]|select(.parents)|.systemId as $systemId|.parents|to_entries|.[]|[$systemId,.value,.key]|@tsv';
json2sql 'clusteronderdelen' '.[]|select(.clusterOnderdelen)|.systemId as $systemId|.clusterOnderdelen[]|[$systemId,.]|@tsv';
json2sql 'deelnemendeorganisaties' 'def jsonify:if type == "null" then null else . | @json end;.[]|select(.deelnemendeOrganisaties)|.systemId as $systemId|.deelnemendeOrganisaties[]|[$systemId,.organisatieId,.toetredingsDatum,.verdeelsleutel?,(.bestuursorganen?|jsonify)]|walk(if type == "null" then "<<NULL>>" else . end)|@tsv|gsub("<<NULL>>";"\\N")';
rm export-flat.json;

# UPSERT all data (and DELETE old)
echo "\ir update.pg.sql" >> import.pg.sql;

echo "$$: Executing PostgreSQL import";

E="$( (psql -h db -U postgres -Xtf import.pg.sql allmanak) 2>&1)"
check_error 'PSQL run import error';

echo "$$: Postgres result: $E";

rm import.pg.sql;

echo "$$: API fetch to build new search index";
TMPFILE=$(mktemp);
CODE="$(curl -sSfRA 'importdata.sh' \
	--compressed \
	-w "%{http_code}" \
	-o "$TMPFILE" \
	'http://api-rest-v1:3000/overheidsorganisatie?einddatum=is.null&select=id:systemid,naam,persoon(voornaam,tussenvoegsel,achternaam),titel,afkorting,bezoek:contact->bezoekAdres->plaats,post:contact->postAdres->plaats,types,partij,medewerkers(count),parents(parent:parentid(naam,citeertitel,titel,medewerkers(count))),commissie(commissie)&parents.order=ordering.desc&commissie.order=commissie.asc')";
if [ "$CODE" != "200" ]; then
	rm "$TMPFILE";
	>&2 echo -e "$$: Status code was $CODE, aborting";
	exit 1;
fi;

TMPFILE2=$(mktemp);
E="$(jq -cjf create-search-index.jq "$TMPFILE" > "$TMPFILE2")";
if [ $? -ne 0 ]; then
	rm "$TMPFILE" "$TMPFILE2";
	>&2 echo -e "$$: JQ converting API to search index error, aborting";
	exit 1;
fi;
rm "$TMPFILE";

LENGTH="$(jq -r 'length' "$TMPFILE2")";
if [ "$LENGTH" -lt 10000 ]; then
	rm "$TMPFILE2";
	>&2 echo -e "$$: Search index size is $LENGTH < 10000, so abort overwriting";
	exit 1;
fi;
(echo -n "var fuseIndex="; cat "$TMPFILE2"; echo -n ";") > '/app/static/fuseindex.js';
rm "$TMPFILE2";

# Set nginx to use node (since there is new data)
ln -nsf node.conf /etc/nginx/shared/static-or-node;

# Update metadata so alpine inotifyd can catch it
touch /web/nginx_reload;

# Update metadata so alpine inotifyd can catch it & start a new sapper export
touch /web/build_static;
