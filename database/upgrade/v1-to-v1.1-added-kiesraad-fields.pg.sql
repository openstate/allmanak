BEGIN;

DROP SCHEMA api_v1 CASCADE; -- since we change the kiesraad schema, just drop & recreate

ALTER TABLE kiesraad.verkiezing
	ADD COLUMN "voorkeurdrempel" SMALLINT NOT NULL DEFAULT -1,
	ADD COLUMN "opgeroepen" INTEGER,
	ADD COLUMN "geldigeStemmen" INTEGER,
	ADD COLUMN "blanco" INTEGER,
	ADD COLUMN "ongeldig" INTEGER;

ALTER TABLE kiesraad.verkiezing
	ALTER COLUMN "voorkeurdrempel" DROP DEFAULT;

ALTER TABLE kiesraad.kandidaat
	ADD COLUMN "verkozen" BOOLEAN,
	ADD COLUMN "verkozenpositie" SMALLINT,
	ADD COLUMN "voorkeurdrempel" BOOLEAN;

-- (Re)Create API views
\ir ../shared/api_v1.pg.sql
COMMIT;