--- V1 / current

CREATE SCHEMA api_v1;
COMMENT ON SCHEMA api_v1 IS $$De databron wie wij gebruiken is [Overheidsorganisaties XML](http://almanak.overheid.nl/archive/), deze <abbr title="Extensible Markup Language">XML</abbr> converteren en importeren wij in een database die we met een <abbr title="Representational State Transfer">REST</abbr> <abbr title="Application Programming Interface">API</abbr> toegankelijk stellen (m.b.v. PostREST met <abbr title="Cross-Origin Resource Sharing">CORS</abbr>). De API kan zowel <abbr title="JavaScript Object Notation">JSON</abbr> als <abbr title="Comma-Separated Values">CSV</abbr> terug sturen.

De API heeft vele endpoints maar de `overheidsorganisatie` is de interessante, gezien praktisch alle objecten met inhoud een `overheidsorganisatie`-object zijn, de andere endpoints zijn voor de onderlinge relaties, maar deze kunnen via PostgREST [resource embedding](https://postgrest.org/en/v5.2/api.html#resource-embedding) tot op zekere hoogte worden meegenomen in de `overheidsorganisatie`-call. Indien je resource-embedding gebruikt is CSV output vaak niet meer echt bruikbaar (het werkt wel, maar de embedded resource zal als JSON in &eacute;&eacute;n CSV veld komen).

**Let op:** met PostgREST zijn database intensieve queries te maken, daarom hebben we de query limiet op tien seconden gezet, mocht je hier tegenaan lopen, neem dan vooral [contact](https://openstate.eu/nl/contact) met ons op dan gaan we een oplossing maken (bijv. een speciale view / API endpoint of uitzondering).
$$;

--<p>Zie onderaan deze pagina de <a href="api/#changelog">changelog</a> en <a href="api/#upgrade-v0-to-v1">upgrade instructie vanaf <code>v0</code></a>. Voor meer informatie over het tijdspad van versie upgrades van de API zie de <a href="api/#policy">deprecation policy</a>, indien mogelijk gebruik dan een <abbr title="HyperText Transfer Protocol">HTTP</abbr> User-Agent met contactgegevens, bijv. <code class="nowrap">User-Agent: Mozilla/5.0 (compatible; ApplicatieNaam/1.0; +https://link-naar-je-applicatie/)</code>.</p>


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


COMMENT ON VIEW api_v1.categorie IS $$Categorie van een overheidsorganisatie.
Een `overheidsorganisatie` valt onder maximaal één categorie.
**Opmerking:** het is vermoedelijk beter om naar `overheidsorganisatie`.`types` te kijken.
$$;
COMMENT ON COLUMN api_v1.categorie.catnr IS 'Nummer van de categorie (anders dan systemId)';
COMMENT ON COLUMN api_v1.categorie.naam IS 'Naam van de categorie.';

GRANT USAGE ON SCHEMA api_v1 TO anonymous;
GRANT SELECT ON ALL TABLES IN SCHEMA api_v1 TO anonymous;