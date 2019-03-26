#!/bin/sh
TMPPIDFILE=$(mktemp);
LOCKFILE="/var/lock/$(basename $0 .sh)";
if [ "$1" = "reboot" ]; then
	echo "$$: Import run because of docker start";
else
 	echo "$$: Import run based on cron";
fi;
set -eu pipefail;

# All xslt/xsd/jq/sql working files are in /work, instead of /root (workdir because of crond).
cd /work;

# Lockfile logic functions
lockcheck() {
	if ! ln -s "$TMPPIDFILE" "$LOCKFILE" 2> /dev/null; then
		PID=$(cat "$LOCKFILE");
		echo "$$: Lockfile file found with PID=$PID";
		if kill -0 $PID 2> /dev/null; then
			rm "$TMPPIDFILE";
			echo "$$: Exit bacause $PID is still running";
			exit 1;
		fi
		echo "$$: Removing lockfile since $PID is not running";
		rm -f "$LOCKFILE";
		lockcheck;
	fi;
}

cleanup() {
	rm "$TMPPIDFILE";
	rm "$LOCKFILE";
	echo "$$: End";
	if [ ! -z ${1+x} ]; then
		exit $1;
	fi;
	exit 0;
}

# Make sure we only have 1 importdata running at the same time by writing a lock file
echo "$$" > "$TMPPIDFILE";
lockcheck;

# Download the latest exportOO.xml in a temp file, using If-Modified-Since to only fetch if changed
FILE="exportOO.xml";
TMPFILE=$(mktemp);
CODE="$(curl -sSfRA 'Mozilla/5.0 (compatible; OpenStateBot/1.0; +https://openstate.eu/bot)' \
	--compressed \
	-w "%{http_code}" \
	-H "If-Modified-Since: $(date -r "$FILE" -u +"%a, %d %b %Y %T GMT" 2>/dev/null || echo "Thu, 01 Jan 1970 00:00:00 GMT")" \
	-o "$TMPFILE" \
	'https://almanak.overheid.nl/archive/exportOO.xml')";
if [ "$CODE" != "200" ]; then
	rm "$TMPFILE";
	echo "$$: Status code was $CODE != 200, exiting.";
	cleanup;
fi;
mv "$TMPFILE" "$FILE";
echo "$$: File $FILE fetched (new, Last-Modified: $(date -u +"%F %TZ" -r "$FILE"))";

# Validating the XML
# $ curl -sSfA 'Mozilla/5.0 (compatible; OpenStateBot/1.0; +https://openstate.eu/bot)' --compressed -o 'oo-export.xsd' https://almanak.overheid.nl/static/schema/oo/export/oo-export-2.4.8.xsd
E="$(xmllint --schema oo-export.xsd "$FILE" --noout 2>&1)";
if [ ! $? ]; then
	echo -e "$$: XMLlint validating $FILE: $E";
	cleanup 1;
else
	echo "$$: XMLlint $E";
fi;

# Convert the XML to JSON, then do some sed replacements (way faster with sed than in xslt 1.0 replace!):
# - Tabs => \t
# - Escape \x => \\x (Except for \t we just created or \" created by the xlst)
# - &amp; => &
E="$( (xsltproc autojson.xslt "$FILE" | sed -r -e 's/\t/\\t/g' -e 's/\\([^"t])/\\\\\1/g' -e 's/\&amp;/\&/g' > export.json) 2>&1)";
if [ ! $? ]; then
	echo -e "$$: xsltproc error: $E";
	cleanup 1;
fi;

# Check if the result is valid JSON without duplicate keys:
E="$(eslint export.json --rule '{no-dupe-keys:"error"}' --color 2>&1)"
if [ ! $? ]; then
	echo -e "$$: ESlint error on the generated JSON: $E";
	cleanup 1;
fi;
echo "$$: Converted to valid JSON (post lint)";

# Then use JQ to:
# - Remove empty arrays
# - Remove CDATA
# - Base64 decode contactEmail
# - Base64 decode emailadres
# - Base64 decode emailadres.value
# - Flatten the hierarchy structure
E="$( (jq -c 'walk(if type == "object" then with_entries(select(.value != [])) else . end)' export.json \
		| jq -c 'walk(if type=="string" and startswith("&lt;![CDATA[") and endswith("]]&gt;") then .[12:-6] else . end)' \
		| jq -c 'walk(if type=="object" and .contactEmail and (.contactEmail|contains("@")|not) and (.contactEmail|test("^[a-zA-Z0-9+/=]+$")) then .contactEmail|=(.|@base64d) else . end)' \
		| jq -c 'walk(if type=="object" and (.emailadres|type)=="string" and (.emailadres|contains("@")|not) and (.emailadres|test("^[a-zA-Z0-9+/=]+$")) then .emailadres|=(.|@base64d) else . end)' \
		| jq -c 'walk(if type=="object" and (.emailadres|type)=="object" and .emailadres.value and (.emailadres.value|contains("@")|not) and (.emailadres.value|test("^[a-zA-Z0-9+/=]+$")) then .emailadres.value|=(.|@base64d) else . end)' \
		| jq -c -f flatten-structure.jq > export-flat.json) 2>&1)";
if [ ! $? ]; then
	echo -e "$$: JQ post processing error: $E";
	cleanup 1;
fi;
rm export.json;
echo "$$: Flattened JSON";

#Generate import.sql
# Begin transaction, clone almanak schema to a TEMP table format
echo 'BEGIN;' > import.pg.sql;
E="$( (psql -h db -U postgres -Xtf clone-schema.pg.sql allmanak >> import.pg.sql) 2>&1)";
if [ ! $? ]; then
	echo -e "$$: PSQL export schema error: $E";
	cleanup 1;
fi;

echo "$$: Writing categorie";
# Copy data to tmp tables
echo 'COPY tmp_categorie FROM STDIN;' >> import.pg.sql;
jq '(map(.categorie? //empty)|unique|map([.catnr,.naam])[]|@tsv)' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing samenwerkingsvorm";
echo 'COPY tmp_samenwerkingsvorm FROM STDIN;' >> import.pg.sql;
jq 'map(select(.samenwerkingsvorm)|.samenwerkingsvorm)|flatten|unique|.[]|[.afkorting,.naam]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing overheidsorganisatie";
echo 'COPY tmp_overheidsorganisatie FROM STDIN;' >> import.pg.sql;
jq 'def jsonify:if type == "null" then null else . | @json end;map([.systemId?,.naam,.partij,.type,(.categorie?|.catnr),.citeertitel?,.aangeslotenBijPensioenfonds?,.aantalInwoners?,.aantekening?,.afkorting?,(.afwijkendeBepaling?|jsonify),(.archiefzorgdrager?|.[0].systemId),(.beleidsterreinen?|jsonify),.beschrijving?,.bevoegdheden?,(.bevoegdheidsverkrijgingen?|if type != "null" then "{"+join(",")+"}" else . end),(.classificaties?|jsonify),(.contact?|jsonify),.contactEmail?,.datumInwerkingtreding?,.datumOpheffing?,.doel?,.eindDatum?,.geldendeCAO?,.ictuCode?,.installatie?,(.instellingsbesluiten?|if type != "null" then map(gsub('"\"'\";\"''\""')|@json)|"{"+join(",")+"}" else . end),.inwonersPerKm2?,.kaderwetZboVanToepassing?,.kvkNummer?,(.laatsteEvaluatie?|jsonify),.omvatPlaats?,.oppervlakte?,.organisatiecode?,.partijFunctie?,(.personeelsomvang?|jsonify),.provincieAfkorting?,.rechtsvorm?,.registratiehouder?,(.relatieMetMinisterie?|.[0].systemId),(.resourceIdentifiers?|jsonify),(.samenwerkingsvorm?|.afkorting?),.standplaats?,.startDatum?,.subnaam?,.subtype?,.taalcode?,.takenEnBevoegdheden?,.titel?,.totaalZetels?,(.wettelijkeVoorschriften?|jsonify),(.zetels|jsonify)]|walk(if type == "null" then "<<NULL>>" else . end))[]|@tsv|gsub("<<NULL>>";"\\N")' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing medewerkers";
echo 'COPY tmp_medewerkers FROM STDIN;' >> import.pg.sql;
jq '.[]|select(.medewerkers)|.systemId as $systemId|.medewerkers[]|[$systemId,.]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing functies";
echo 'COPY tmp_functies FROM STDIN;' >> import.pg.sql;
jq '.[]|select(.functies)|.systemId as $systemId|.functies[]|[$systemId,.]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing organisaties";
echo 'COPY tmp_organisaties FROM STDIN;' >> import.pg.sql;
jq '.[]|select(.organisaties)|.systemId as $systemId|.organisaties[]|[$systemId,.]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing parents";
echo 'COPY tmp_parents FROM STDIN;' >> import.pg.sql;
jq '.[]|select(.parents)|.systemId as $systemId|.parents|to_entries|.[]|[$systemId,.value,.key]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing clusteronderdelen";
echo 'COPY tmp_clusteronderdelen FROM STDIN;' >> import.pg.sql;
jq '.[]|select(.clusterOnderdelen)|.systemId as $systemId|.clusterOnderdelen[]|[$systemId,.]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

echo "$$: Writing deelnemendeorganisaties";
echo 'COPY tmp_deelnemendeorganisaties FROM STDIN;' >> import.pg.sql;
jq '.[]|select(.deelnemendeOrganisaties)|.systemId as $systemId|.deelnemendeOrganisaties[]|[$systemId,.organisatieId,.toetredingsDatum,.bronhouder]|@tsv' export-flat.json -r >> import.pg.sql;
echo '\.' >> import.pg.sql;

rm export-flat.json;

# UPSERT all data (and DELETE old)
cat update.pg.sql >> import.pg.sql;

echo "$$: Executing PostgreSQL import";

E="$( (psql -h db -U postgres -Xtf import.pg.sql allmanak) 2>&1)"
if [ ! $? ]; then
	echo -e "$$: PSQL run import error: $E";
	cleanup 1;
fi;

echo "Postgres result: $E";

rm import.pg.sql;

#Call webhook app:9000/export to generate export (that copies artifacts to $TS/ and changes `ln latest $TS/`)
touch /web/build_static;

cleanup;