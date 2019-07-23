--- V1 / current

CREATE SCHEMA api_v1;
COMMENT ON SCHEMA api_v1 IS 'Allmanak REST API v1';

CREATE VIEW api_v1.categorie AS
    SELECT almanak.categorie.* FROM almanak.categorie;

CREATE VIEW api_v1.samenwerkingsvorm AS
    SELECT almanak.samenwerkingsvorm.* FROM almanak.samenwerkingsvorm;

CREATE VIEW api_v1.overheidsorganisatie AS
    SELECT almanak.overheidsorganisatie.* FROM almanak.overheidsorganisatie;

CREATE VIEW api_v1.medewerkers AS
    SELECT almanak.medewerkers.* FROM almanak.medewerkers;
CREATE VIEW api_v1.functies AS
    SELECT almanak.functies.* FROM almanak.functies;
CREATE VIEW api_v1.clusterOnderdelen AS
    SELECT almanak.clusterOnderdelen.* FROM almanak.clusterOnderdelen;
CREATE VIEW api_v1.organisaties AS
    SELECT almanak.organisaties.* FROM almanak.organisaties;
CREATE VIEW api_v1.deelnemendeOrganisaties AS
    SELECT almanak.deelnemendeOrganisaties.* FROM almanak.deelnemendeOrganisaties;
CREATE VIEW api_v1.parents AS
    SELECT almanak.parents.* FROM almanak.parents;

CREATE VIEW api_v1.logo AS
    SELECT enrich.logo.* FROM enrich.logo;
CREATE VIEW api_v1.photo AS
    SELECT enrich.photo.* FROM enrich.photo;

CREATE VIEW api_v1.persoon AS
    SELECT enrich.persoon.* FROM enrich.persoon;
CREATE VIEW api_v1.contact AS
    SELECT enrich.contact.* FROM enrich.contact;
CREATE VIEW api_v1.sociallink AS
    SELECT enrich.sociallink.* FROM enrich.sociallink;
CREATE VIEW api_v1.commissie AS
    SELECT enrich.commissie.* FROM enrich.commissie;

CREATE VIEW api_v1.verkiezing AS
    SELECT kiesraad.verkiezing.* FROM kiesraad.verkiezing;
CREATE VIEW api_v1.kieslijst AS
    SELECT kiesraad.kieslijst.* FROM kiesraad.kieslijst;
CREATE VIEW api_v1.kandidaat AS
    SELECT kiesraad.kandidaat.* FROM kiesraad.kandidaat;

CREATE VIEW api_v1.partij AS
    SELECT enrich.partij.* FROM enrich.partij;
CREATE VIEW api_v1.partijmatch AS
    SELECT enrich.partijmatch.* FROM enrich.partijmatch;
CREATE VIEW api_v1.kandidaatmatch AS
    SELECT enrich.kandidaatmatch.* FROM enrich.kandidaatmatch;


COMMENT ON VIEW api_v1.categorie IS $$Categorie van organisaties.
Een organisatie valt onder maximaal één categorie.
$$;
COMMENT ON COLUMN api_v1.categorie.catnr IS 'Nummer van de categorie (anders dan systemId)';
COMMENT ON COLUMN api_v1.categorie.naam IS 'Naam van de categorie.';

GRANT USAGE ON SCHEMA api_v1 TO anonymous;
GRANT SELECT ON ALL TABLES IN SCHEMA api_v1 TO anonymous;