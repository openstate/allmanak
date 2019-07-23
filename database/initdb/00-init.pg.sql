\c allmanak;
-- Make sure to switch databases before starting a transaction!
-- Wrap all DDL in one transaction:
BEGIN;

REVOKE ALL ON SCHEMA PUBLIC FROM PUBLIC;
CREATE ROLE anonymous;
-- Note that role-specific defaults attached to roles without LOGIN privilege are fairly useless, since they will never be invoked.
CREATE USER pgrst PASSWORD 'anonymous';
-- ALTER ROLE anonymous SET statement_timeout = 10000; -- prevent weird queries to DoS the DB ^^^ doesn't work since we don't use it to login!
ALTER ROLE pgrst SET statement_timeout = 10000; -- prevent weird queries to DoS the DB, can be set higher after login?
GRANT anonymous TO pgrst;
---
CREATE SCHEMA almanak; -- data from almanak.overheid.nl
CREATE SCHEMA enrich; -- enrichment through scraping and linking
CREATE SCHEMA kiesraad; -- all EML data from kiesraad
---

CREATE TABLE almanak.categorie (
  catnr INTEGER PRIMARY KEY,
  naam VARCHAR(255) NOT NULL
);

CREATE TABLE almanak.samenwerkingsvorm (
  afkorting VARCHAR(255) PRIMARY KEY,
  naam VARCHAR(255)
);

CREATE TYPE almanak.subtype AS ENUM ('Afzonderlijke zbo', 'Cluster van zbo''s', 'Onderdeel van een cluster');

CREATE TYPE almanak.taalcode AS ENUM ('nl-NL');

CREATE TYPE almanak.registratiehouder AS ENUM ('Ministerie van Binnenlandse Zaken en Koninkrijksrelaties');

CREATE TYPE almanak.rechtsvorm AS ENUM (
  'Privaatrechtelijk - Overig',
  'Privaatrechtelijk - Stichting',
  'Publiekrechtelijk - Eigen rechtspersoonlijkheid',
  'Publiekrechtelijk - Onderdeel Staat der Nederlanden'
);

CREATE TYPE almanak.bevoegdheidsverkrijging AS ENUM (
  'Attributie',
  'Delegatie',
  'Mandaat'
);

--xmlstarlet sel -t -m '//p:type' -v 'text()' -n exportOO.xml | sort | uniq
CREATE TYPE almanak.ootype AS ENUM (
  'Adviescollege',
  'Caribisch Nederland',
  'Gemeenschappelijke regeling',
  'Gemeente',
  'Hoog College van Staat', -- Renamed since 2019-06-18 (oo-export 2.4.10) before 'Hoge Colleges van Staat'
  'Kabinet van de Koning', -- Added 2019-04-04 (since oo-export 2.4.9)
  'Koepelorganisatie', -- Added 2019-04-04 (since oo-export 2.4.9)
  'Ministerie',
  'Openbaar lichaam voor beroep en bedrijf', -- Added 2019-06-18 (oo-export 2.4.10)
  'Organisatie',
  'Organisatie met overheidsbemoeienis', -- Added 2019-06-19 (oo-export 2.4.10)
  'Organisatieonderdeel', -- Added 2019-07-17
  'Politie en brandweer',
  'Provincie',
  'Rechterlijke macht',
  'Regionaal samenwerkingsorgaan', -- Added 2019-07-17
  'Staten-Generaal',
  'Waterschap',
  'Zelfstandig bestuursorgaan'
);

CREATE TABLE almanak.overheidsorganisatie (
  systemId INTEGER PRIMARY KEY,
  naam VARCHAR(1024),
  partij VARCHAR(255),
  types almanak.ootype[], -- Changed type -> types in oo-export 2.4.10
  categorie INTEGER REFERENCES almanak.categorie(catnr),
  citeertitel VARCHAR(1024),
  aangeslotenBijPensioenfonds VARCHAR(255),
  aantalInwoners INTEGER,
  aantekening TEXT,
  afkorting VARCHAR(255),
  afwijkendeBepaling JSONB,
  archiefzorgdrager INTEGER REFERENCES almanak.overheidsorganisatie(systemId),
  beleidsterreinen JSONB,
  beschrijving TEXT,
  bevoegdheden TEXT,
  bevoegdheidsverkrijgingen almanak.bevoegdheidsverkrijging[],
  bronhouder INTEGER REFERENCES almanak.overheidsorganisatie(systemId), -- Added in oo-export 2.4.9
  classificaties JSONB,
  contact JSONB,
--  contactEmail VARCHAR(255), -- Removed in oo-export 2.4.9
  datumInwerkingtreding DATE,
  datumOpheffing DATE,
  doel TEXT,
  eindDatum DATE,
  geldendeCAO VARCHAR(255),
  ictuCode VARCHAR(5),
  installatie VARCHAR(255),
  instellingsbesluiten VARCHAR(1024)[],
  inwonersPerKm2 INTEGER,
  kaderwetZboVanToepassing BOOLEAN,
  kvkNummer VARCHAR(8),
  laatsteEvaluatie JSONB,
  omvatPlaats VARCHAR(1024),
  oppervlakte NUMERIC(5,2),
  organisatiecode CHAR(4),
  partijFunctie VARCHAR(255),
  personeelsomvang JSONB,
  provincieAfkorting VARCHAR(255),
  rechtsvorm almanak.rechtsvorm,
  registratiehouder almanak.registratiehouder,
  relatieMetMinisterie INTEGER REFERENCES almanak.overheidsorganisatie(systemId),
  resourceIdentifiers JSONB,
  samenwerkingsvorm VARCHAR(255) REFERENCES almanak.samenwerkingsvorm(afkorting),
  standplaats VARCHAR(255),
  startDatum DATE,
  subnaam VARCHAR(255),
  subtype almanak.subtype,
  taalcode almanak.taalcode,
  takenEnBevoegdheden TEXT,
  titel VARCHAR(255),
  totaalZetels SMALLINT,
  wettelijkeVoorschriften JSONB,
  zetels JSONB
);

CREATE TABLE almanak.medewerkers (
	systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	persoonId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	PRIMARY KEY (systemId, persoonId),
	CONSTRAINT no_loops CHECK (systemId != persoonId)
);

CREATE TABLE almanak.functies (
	systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	functieId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	PRIMARY KEY(systemId, functieId),
	CONSTRAINT no_loops CHECK (systemId != functieId)
);

CREATE TABLE almanak.clusterOnderdelen (
	systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	clusterOnderdeelId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	PRIMARY KEY(systemId, clusterOnderdeelId),
	CONSTRAINT no_loops CHECK (systemId != clusterOnderdeelId)
);

CREATE TABLE almanak.organisaties (
	systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	organisatieId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	PRIMARY KEY(systemId, organisatieId),
	CONSTRAINT no_loops CHECK (systemId != organisatieId)
);

CREATE TABLE almanak.deelnemendeOrganisaties (
	systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	organisatieId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	toetredingsDatum DATE NOT NULL,
--  bronhouder BOOLEAN, -- Removed in oo-export 2.4.9
  verdeelsleutel NUMERIC(6,6),
  bestuursorganen JSONB,
	PRIMARY KEY(systemId, organisatieId),
	CONSTRAINT no_loops CHECK (systemId != organisatieId)
);

CREATE TABLE almanak.parents (
	systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	parentId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
	ordering SMALLINT NOT NULL,
	PRIMARY KEY(systemId, parentId),
	CONSTRAINT no_loops CHECK (systemId != parentId)
);

CREATE TABLE enrich.logo (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  url VARCHAR(4095) NOT NULL,
  license VARCHAR(255) NOT NULL,
  attributiontext VARCHAR(255),
  attributionurl VARCHAR(4095),
  source VARCHAR(4095) NOT NULL,
  backgroundcolor VARCHAR(255),
  PRIMARY KEY(systemId)
);

CREATE TABLE enrich.photo (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  url VARCHAR(4096) NOT NULL,
  license VARCHAR(255) NOT NULL,
  attributiontext VARCHAR(255),
  attributionurl VARCHAR(4095),
  source VARCHAR(4095) NOT NULL,
  PRIMARY KEY(systemId)
);

CREATE TYPE enrich.geslacht AS ENUM (
  'man',
  'vrouw',
  'X'
);

CREATE TYPE enrich.matchtype AS ENUM (
  'almanak-kiesraad-matcher',
  'manual'
);

CREATE TABLE enrich.persoon (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  geslacht enrich.geslacht,
  aanheftitel VARCHAR(255),
  initialen VARCHAR(255),
  voornaam VARCHAR(255),
  tussenvoegsel VARCHAR(255),
  achternaam VARCHAR(255),
  source VARCHAR(4095) NOT NULL,
  PRIMARY KEY(systemId)
);

CREATE TABLE enrich.contact (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  contact JSONB,
  source VARCHAR(4095) NOT NULL,
  PRIMARY KEY(systemId)
);

CREATE TABLE enrich.sociallink (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  "type" VARCHAR(255),
  source VARCHAR(4095) NOT NULL,
  url VARCHAR(4095)
);

CREATE TABLE enrich.commissie (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  commissie VARCHAR,
  url VARCHAR(4095),
  source VARCHAR(4095) NOT NULL
);

CREATE TABLE kiesraad.verkiezing (
  id INTEGER GENERATED ALWAYS AS IDENTITY,
  code VARCHAR(255) NOT NULL, -- GR2018_Delft
  ictuCode INTEGER, -- 0503
  verkiezingsdatum DATE NOT NULL, -- 2018-03-22
  naam VARCHAR(255) NOT NULL,
  zetels SMALLINT NOT NULL,
  PRIMARY KEY(code),
  UNIQUE(id)
);

CREATE TABLE kiesraad.kieslijst (
  id INTEGER GENERATED ALWAYS AS IDENTITY,
  verkiezing INTEGER REFERENCES kiesraad.verkiezing(id) NOT NULL,
  lijstnummer SMALLINT NOT NULL,
  kieskring VARCHAR(255) NOT NULL,
  naam VARCHAR(255) NOT NULL,
  verkozenzetels SMALLINT,
  PRIMARY KEY(verkiezing, lijstnummer, kieskring),
  UNIQUE(id)
);

CREATE TABLE kiesraad.kandidaat (
  id INTEGER GENERATED ALWAYS AS IDENTITY,
  kieslijst INTEGER REFERENCES kiesraad.kieslijst(id) NOT NULL,
  kandidaatnummer SMALLINT NOT NULL,
  initialen VARCHAR(255),
  voornaam VARCHAR(255),
  tussenvoegsel VARCHAR(255),
  achternaam VARCHAR(255),
  woonplaats VARCHAR(255),
  geslacht enrich.geslacht,
  voorkeurstemmen INT,
  PRIMARY KEY(kieslijst, kandidaatnummer),
  UNIQUE(id)
);

CREATE TABLE enrich.partij (
  id INTEGER GENERATED ALWAYS AS IDENTITY,
  ictuCode INTEGER,
  kiesraadnaam VARCHAR(255) NOT NULL,
  logourl VARCHAR(4095),
  PRIMARY KEY(ictuCode, kiesraadnaam),
  UNIQUE(id)
);

CREATE TABLE enrich.partijmatch (
  id INTEGER REFERENCES enrich.partij(id) NOT NULL,
  ictuCode VARCHAR(5) NOT NULL,-- REFERENCES almanak.overheidsorganisatie(ictuCode) NOT NULL,
  almanaknaam VARCHAR(255),
  PRIMARY KEY(ictuCode, almanaknaam)
);

CREATE TABLE enrich.kandidaatmatch (
  systemId INTEGER REFERENCES almanak.overheidsorganisatie(systemId) NOT NULL,
  kandidaat INTEGER REFERENCES kiesraad.kandidaat(id) NOT NULL,
  matchtype enrich.matchtype NOT NULL,
  matchscore REAL,
  PRIMARY KEY(systemId, kandidaat, matchtype)
);

DO $$
DECLARE
  tbl RECORD;
  schemaName VARCHAR := 'almanak';
BEGIN
  FOR tbl IN (SELECT t.relname::varchar AS name
                FROM pg_class t
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE t.relkind = 'r' and n.nspname::varchar = schemaName
                ORDER BY 1)
  LOOP
    RAISE NOTICE 'ANALYZE %.%', schemaName, tbl.name;
    EXECUTE 'ANALYZE ' || schemaName || '.' || tbl.name;
  END LOOP;
END
$$;

DO $$
DECLARE
  tbl RECORD;
  schemaName VARCHAR := 'enrich';
BEGIN
  FOR tbl IN (SELECT t.relname::varchar AS name
                FROM pg_class t
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE t.relkind = 'r' and n.nspname::varchar = schemaName
                ORDER BY 1)
  LOOP
    RAISE NOTICE 'ANALYZE %.%', schemaName, tbl.name;
    EXECUTE 'ANALYZE ' || schemaName || '.' || tbl.name;
  END LOOP;
END
$$;

DO $$
DECLARE
  tbl RECORD;
  schemaName VARCHAR := 'kiesraad';
BEGIN
  FOR tbl IN (SELECT t.relname::varchar AS name
                FROM pg_class t
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE t.relkind = 'r' and n.nspname::varchar = schemaName
                ORDER BY 1)
  LOOP
    RAISE NOTICE 'ANALYZE %.%', schemaName, tbl.name;
    EXECUTE 'ANALYZE ' || schemaName || '.' || tbl.name;
  END LOOP;
END
$$;

-- Create API views
\ir ../shared/api_v0.pg.sql
\ir ../shared/api_v1.pg.sql

COMMIT;