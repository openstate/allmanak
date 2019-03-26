REVOKE ALL ON SCHEMA PUBLIC FROM PUBLIC;
CREATE USER pgrst PASSWORD 'anonymous';
CREATE ROLE anonymous;
-- Note that role-specific defaults attached to roles without LOGIN privilege are fairly useless, since they will never be invoked.
-- ALTER ROLE anonymous SET statement_timeout = 10000; -- prevent weird queries to DoS the DB ^^^ doesn't work since we don't use it to login!
ALTER ROLE pgrst SET statement_timeout = 10000; -- prevent weird queries to DoS the DB, can be set higher after login?
GRANT anonymous TO pgrst;
--CREATE DATABASE allmanak;
\c allmanak;
---
CREATE SCHEMA almanak;
---

-- CREATE SCHEMA allmanak;
-- systemId, gender, titel, initialen, voornamen, tussenvoegsel, achternaam[combi?], [meisjesnaam?]

CREATE TABLE almanak.categorie (
  catnr int PRIMARY KEY,
  naam varchar(255) NOT NULL
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

CREATE TYPE almanak.ootype AS ENUM (
  'Adviescollege',
  'Caribisch Nederland',
  'Gemeenschappelijke regeling',
  'Gemeente',
  'Hoge Colleges van Staat',
  'Ministerie',
  'Organisatie',
  'Politie en brandweer',
  'Provincie',
  'Rechterlijke macht',
  'Staten-Generaal',
  'Waterschap',
  'Zelfstandig bestuursorgaan'
);

CREATE TABLE almanak.overheidsorganisatie (
  systemId int PRIMARY KEY,
  naam varchar(1024),
  partij VARCHAR(255),
  "type" almanak.ootype,
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
  classificaties JSONB,
  contact JSONB,
  contactEmail VARCHAR(255),
  datumInwerkingtreding DATE,
  datumOpheffing DATE,
  doel TEXT,
  eindDatum DATE,
  geldendeCAO VARCHAR(255),
  ictuCode CHAR(5),
  installatie VARCHAR(255),
  instellingsbesluiten VARCHAR(1024)[],
  inwonersPerKm2 INTEGER,
  kaderwetZboVanToepassing BOOLEAN,
  kvkNummer CHAR(8),
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
  totaalZetels smallint,
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
	bronhouder BOOLEAN,
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
---
-- DROP TABLE almanak.dummy;
-- CREATE TABLE almanak.dummy (o int);
-- INSERT INTO almanak.dummy SELECT 1;

CREATE SCHEMA api;
COMMENT ON SCHEMA api IS 'Allmanak REST API v0';

-- DROP VIEW api.categorie;
-- DROP VIEW api.samenwerkingsvorm;
-- DROP VIEW api.overheidsorganisatie;
-- DROP VIEW api.medewerkers;
-- DROP VIEW api.functies;
-- DROP VIEW api.clusterOnderdelen;
-- DROP VIEW api.organisaties;
-- DROP VIEW api.deelnemendeOrganisaties;
-- DROP VIEW api.parents;

CREATE VIEW api.categorie AS
    SELECT almanak.categorie.* FROM almanak.categorie; -- the DISTINCT tricks the VIEW not begin an Updatable View (http://www.postgresqltutorial.com/postgresql-updatable-views/)

CREATE VIEW api.samenwerkingsvorm AS
    SELECT almanak.samenwerkingsvorm.* FROM almanak.samenwerkingsvorm;

CREATE VIEW api.overheidsorganisatie AS
    SELECT almanak.overheidsorganisatie.* FROM almanak.overheidsorganisatie; -- the DISTINCT tricks the VIEW not begin an Updatable View (http://www.postgresqltutorial.com/postgresql-updatable-views/)

CREATE VIEW api.medewerkers AS
    SELECT almanak.medewerkers.* FROM almanak.medewerkers;
CREATE VIEW api.functies AS
    SELECT almanak.functies.* FROM almanak.functies;
CREATE VIEW api.clusterOnderdelen AS
    SELECT almanak.clusterOnderdelen.* FROM almanak.clusterOnderdelen;
CREATE VIEW api.organisaties AS
    SELECT almanak.organisaties.* FROM almanak.organisaties;
CREATE VIEW api.deelnemendeOrganisaties AS
    SELECT almanak.deelnemendeOrganisaties.* FROM almanak.deelnemendeOrganisaties;
CREATE VIEW api.parents AS
    SELECT almanak.parents.* FROM almanak.parents;



--SELECT jsonb_object_agg(key, value) FROM JSON_EACH((SELECT row_to_json(o) FROM api.overheidsorganisatie o)) WHERE NOT value::jsonb <@ 'null'::jsonb


COMMENT ON VIEW api.categorie IS $$Categorie van organisaties.
Een organisatie valt onder maximaal één categorie.
$$;
COMMENT ON COLUMN api.categorie.catnr IS 'Nummer van de categorie (anders dan systemId)';
COMMENT ON COLUMN api.categorie.naam IS 'Naam van de categorie.';
-- ALTER VIEW api.categorie OWNER TO anonymous; DOING THIS WILL GIVE INSERT ETC rights!

--REVOKE USAGE ON SCHEMA almanak FROM anonymous;
GRANT USAGE ON SCHEMA api TO anonymous;
GRANT SELECT ON ALL TABLES IN SCHEMA api TO anonymous;
-- SELECT * FROM information_schema.role_table_grants WHERE grantee = 'anonymous';

--GRANT SELECT ON ALL TABLES IN SCHEMA almanak TO anonymous; --not needed?

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
