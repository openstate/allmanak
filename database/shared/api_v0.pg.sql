-- V0 (just v1 with type instead of types in overheidsorganisatie, taking just the first of types)

CREATE SCHEMA api_v0;
COMMENT ON SCHEMA api_v0 IS 'Allmanak REST API v0 (deprecated!)';

CREATE VIEW api_v0.categorie AS
    SELECT almanak.categorie.* FROM almanak.categorie;

CREATE VIEW api_v0.samenwerkingsvorm AS
    SELECT almanak.samenwerkingsvorm.* FROM almanak.samenwerkingsvorm;

-- V0 vs V1:
-- almanak.overheidsorganisatie.types[1] AS "type"
-- CASE WHEN almanak.overheidsorganisatie.beleidsterreinen IS NOT NULL THEN jsonb_build_array(almanak.overheidsorganisatie.beleidsterreinen) END AS "beleidsterreinen"
-- CASE WHEN almanak.overheidsorganisatie.resourceIdentifiers IS NOT NULL THEN jsonb_build_array(almanak.overheidsorganisatie.resourceIdentifiers) END AS "resourceidentifiers"
-- CASE WHEN almanak.overheidsorganisatie.wettelijkeVoorschriften IS NOT NULL THEN jsonb_build_array(almanak.overheidsorganisatie.wettelijkeVoorschriften) END AS "wettelijkevoorschriften"
CREATE VIEW api_v0.overheidsorganisatie AS
    SELECT almanak.overheidsorganisatie.systemId,almanak.overheidsorganisatie.naam,almanak.overheidsorganisatie.partij,almanak.overheidsorganisatie.types[1] AS "type",almanak.overheidsorganisatie.categorie,almanak.overheidsorganisatie.citeertitel,almanak.overheidsorganisatie.aangeslotenBijPensioenfonds,almanak.overheidsorganisatie.aantalInwoners,almanak.overheidsorganisatie.aantekening,almanak.overheidsorganisatie.afkorting,almanak.overheidsorganisatie.afwijkendeBepaling,almanak.overheidsorganisatie.archiefzorgdrager,CASE WHEN almanak.overheidsorganisatie.beleidsterreinen IS NOT NULL THEN jsonb_build_array(almanak.overheidsorganisatie.beleidsterreinen) END AS "beleidsterreinen",almanak.overheidsorganisatie.beschrijving,almanak.overheidsorganisatie.bevoegdheden,almanak.overheidsorganisatie.bevoegdheidsverkrijgingen,almanak.overheidsorganisatie.bronhouder,almanak.overheidsorganisatie.classificaties,almanak.overheidsorganisatie.contact,almanak.overheidsorganisatie.datumInwerkingtreding,almanak.overheidsorganisatie.datumOpheffing,almanak.overheidsorganisatie.doel,almanak.overheidsorganisatie.eindDatum,almanak.overheidsorganisatie.geldendeCAO,almanak.overheidsorganisatie.ictuCode,almanak.overheidsorganisatie.installatie,almanak.overheidsorganisatie.instellingsbesluiten,almanak.overheidsorganisatie.inwonersPerKm2,almanak.overheidsorganisatie.kaderwetZboVanToepassing,almanak.overheidsorganisatie.kvkNummer,almanak.overheidsorganisatie.laatsteEvaluatie,almanak.overheidsorganisatie.omvatPlaats,almanak.overheidsorganisatie.oppervlakte,almanak.overheidsorganisatie.organisatiecode,almanak.overheidsorganisatie.partijFunctie,almanak.overheidsorganisatie.personeelsomvang,almanak.overheidsorganisatie.provincieAfkorting,almanak.overheidsorganisatie.rechtsvorm,almanak.overheidsorganisatie.registratiehouder,almanak.overheidsorganisatie.relatieMetMinisterie,CASE WHEN almanak.overheidsorganisatie.resourceIdentifiers IS NOT NULL THEN jsonb_build_array(almanak.overheidsorganisatie.resourceIdentifiers) END AS "resourceidentifiers",almanak.overheidsorganisatie.samenwerkingsvorm,almanak.overheidsorganisatie.standplaats,almanak.overheidsorganisatie.startDatum,almanak.overheidsorganisatie.subnaam,almanak.overheidsorganisatie.subtype,almanak.overheidsorganisatie.taalcode,almanak.overheidsorganisatie.takenEnBevoegdheden,almanak.overheidsorganisatie.titel,almanak.overheidsorganisatie.totaalZetels,CASE WHEN almanak.overheidsorganisatie.wettelijkeVoorschriften IS NOT NULL THEN jsonb_build_array(almanak.overheidsorganisatie.wettelijkeVoorschriften) END AS "wettelijkevoorschriften",almanak.overheidsorganisatie.zetels FROM almanak.overheidsorganisatie;

CREATE VIEW api_v0.medewerkers AS
    SELECT almanak.medewerkers.* FROM almanak.medewerkers;
CREATE VIEW api_v0.functies AS
    SELECT almanak.functies.* FROM almanak.functies;
CREATE VIEW api_v0.clusterOnderdelen AS
    SELECT almanak.clusterOnderdelen.* FROM almanak.clusterOnderdelen;
CREATE VIEW api_v0.organisaties AS
    SELECT almanak.organisaties.* FROM almanak.organisaties;
CREATE VIEW api_v0.deelnemendeOrganisaties AS
    SELECT almanak.deelnemendeOrganisaties.* FROM almanak.deelnemendeOrganisaties;
CREATE VIEW api_v0.parents AS
    SELECT almanak.parents.* FROM almanak.parents;

CREATE VIEW api_v0.logo AS
    SELECT enrich.logo.* FROM enrich.logo;
CREATE VIEW api_v0.photo AS
    SELECT enrich.photo.* FROM enrich.photo;

CREATE VIEW api_v0.persoon AS
    SELECT enrich.persoon.* FROM enrich.persoon;
CREATE VIEW api_v0.contact AS
    SELECT enrich.contact.* FROM enrich.contact;
CREATE VIEW api_v0.sociallink AS
    SELECT enrich.sociallink.* FROM enrich.sociallink;
CREATE VIEW api_v0.commissie AS
    SELECT enrich.commissie.* FROM enrich.commissie;

CREATE VIEW api_v0.verkiezing AS
    SELECT kiesraad.verkiezing.* FROM kiesraad.verkiezing;
CREATE VIEW api_v0.kieslijst AS
    SELECT kiesraad.kieslijst.* FROM kiesraad.kieslijst;
CREATE VIEW api_v0.kandidaat AS
    SELECT kiesraad.kandidaat.* FROM kiesraad.kandidaat;

CREATE VIEW api_v0.partij AS
    SELECT enrich.partij.* FROM enrich.partij;
CREATE VIEW api_v0.partijmatch AS
    SELECT enrich.partijmatch.* FROM enrich.partijmatch;
CREATE VIEW api_v0.kandidaatmatch AS
    SELECT enrich.kandidaatmatch.* FROM enrich.kandidaatmatch;

GRANT USAGE ON SCHEMA api_v0 TO anonymous;
GRANT SELECT ON ALL TABLES IN SCHEMA api_v0 TO anonymous;