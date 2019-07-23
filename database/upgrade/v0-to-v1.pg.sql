BEGIN;

DROP SCHEMA api CASCADE; -- since it depends on overheidsorganisatie.type and is replaced by api_v0 and api_v1

ALTER TABLE almanak.overheidsorganisatie
	RENAME COLUMN "type" TO "types";

ALTER TABLE almanak.overheidsorganisatie
	ALTER COLUMN "types" TYPE almanak.ootype[]
	USING array["types"]::almanak.ootype[];

-- (Re)Create API views
\ir ../shared/api_v0.pg.sql
\ir ../shared/api_v1.pg.sql
COMMIT;