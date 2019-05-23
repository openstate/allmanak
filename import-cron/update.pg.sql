-- Update all new stuff

INSERT INTO almanak.categorie AS c
	SELECT * FROM tmp_categorie
		ON CONFLICT (catnr)
		DO UPDATE
			SET naam = EXCLUDED.naam
		WHERE c.naam != EXCLUDED.naam;

INSERT INTO almanak.samenwerkingsvorm AS s
	SELECT * FROM tmp_samenwerkingsvorm
		ON CONFLICT (afkorting)
		DO UPDATE
			SET naam = EXCLUDED.naam
		WHERE s.naam != EXCLUDED.naam;

INSERT INTO almanak.overheidsorganisatie AS o
	SELECT * FROM tmp_overheidsorganisatie
		ON CONFLICT (systemid)
		DO UPDATE
			SET naam = EXCLUDED.naam,
			partij = EXCLUDED.partij,
			"type" = EXCLUDED."type",
			categorie = EXCLUDED.categorie,
			citeertitel = EXCLUDED.citeertitel,
			aangeslotenBijPensioenfonds = EXCLUDED.aangeslotenBijPensioenfonds,
			aantalInwoners = EXCLUDED.aantalInwoners,
			aantekening = EXCLUDED.aantekening,
			afkorting = EXCLUDED.afkorting,
			afwijkendeBepaling = EXCLUDED.afwijkendeBepaling,
			archiefzorgdrager = EXCLUDED.archiefzorgdrager,
			beleidsterreinen = EXCLUDED.beleidsterreinen,
			beschrijving = EXCLUDED.beschrijving,
			bevoegdheden = EXCLUDED.bevoegdheden,
			bevoegdheidsverkrijgingen = EXCLUDED.bevoegdheidsverkrijgingen,
			bronhouder = EXCLUDED.bronhouder,
			classificaties = EXCLUDED.classificaties,
			contact = EXCLUDED.contact,
			datumInwerkingtreding = EXCLUDED.datumInwerkingtreding,
			datumOpheffing = EXCLUDED.datumOpheffing,
			doel = EXCLUDED.doel,
			eindDatum = EXCLUDED.eindDatum,
			geldendeCAO = EXCLUDED.geldendeCAO,
			ictuCode = EXCLUDED.ictuCode,
			installatie = EXCLUDED.installatie,
			instellingsbesluiten = EXCLUDED.instellingsbesluiten,
			inwonersPerKm2 = EXCLUDED.inwonersPerKm2,
			kaderwetZboVanToepassing = EXCLUDED.kaderwetZboVanToepassing,
			kvkNummer = EXCLUDED.kvkNummer,
			laatsteEvaluatie = EXCLUDED.laatsteEvaluatie,
			omvatPlaats = EXCLUDED.omvatPlaats,
			oppervlakte = EXCLUDED.oppervlakte,
			organisatiecode = EXCLUDED.organisatiecode,
			partijFunctie = EXCLUDED.partijFunctie,
			personeelsomvang = EXCLUDED.personeelsomvang,
			provincieAfkorting = EXCLUDED.provincieAfkorting,
			rechtsvorm = EXCLUDED.rechtsvorm,
			registratiehouder = EXCLUDED.registratiehouder,
			relatieMetMinisterie = EXCLUDED.relatieMetMinisterie,
			resourceIdentifiers = EXCLUDED.resourceIdentifiers,
			samenwerkingsvorm = EXCLUDED.samenwerkingsvorm,
			standplaats = EXCLUDED.standplaats,
			startDatum = EXCLUDED.startDatum,
			subnaam = EXCLUDED.subnaam,
			subtype = EXCLUDED.subtype,
			taalcode = EXCLUDED.taalcode,
			takenEnBevoegdheden = EXCLUDED.takenEnBevoegdheden,
			titel = EXCLUDED.titel,
			totaalZetels = EXCLUDED.totaalZetels,
			wettelijkeVoorschriften = EXCLUDED.wettelijkeVoorschriften,
			zetels = EXCLUDED.zetels
		WHERE -- the row_to_json::text is easier with comparing null values
			row_to_json(
				ROW(o.naam, o.partij, o."type", o.categorie, o.citeertitel, o.aangeslotenBijPensioenfonds, o.aantalInwoners, o.aantekening, o.afkorting, o.afwijkendeBepaling, o.archiefzorgdrager, o.beleidsterreinen, o.beschrijving, o.bevoegdheden, o.bevoegdheidsverkrijgingen, o.bronhouder, o.classificaties, o.contact, o.datumInwerkingtreding, o.datumOpheffing, o.doel, o.eindDatum, o.geldendeCAO, o.ictuCode, o.installatie, o.instellingsbesluiten, o.inwonersPerKm2, o.kaderwetZboVanToepassing, o.kvkNummer, o.laatsteEvaluatie, o.omvatPlaats, o.oppervlakte, o.organisatiecode, o.partijFunctie, o.personeelsomvang, o.provincieAfkorting, o.rechtsvorm, o.registratiehouder, o.relatieMetMinisterie, o.resourceIdentifiers, o.samenwerkingsvorm, o.standplaats, o.startDatum, o.subnaam, o.subtype, o.taalcode, o.takenEnBevoegdheden, o.titel, o.totaalZetels, o.wettelijkeVoorschriften, o.zetels)
			)::text != row_to_json(
				ROW(EXCLUDED.naam, EXCLUDED.partij, EXCLUDED."type", EXCLUDED.categorie, EXCLUDED.citeertitel, EXCLUDED.aangeslotenBijPensioenfonds, EXCLUDED.aantalInwoners, EXCLUDED.aantekening, EXCLUDED.afkorting, EXCLUDED.afwijkendeBepaling, EXCLUDED.archiefzorgdrager, EXCLUDED.beleidsterreinen, EXCLUDED.beschrijving, EXCLUDED.bevoegdheden, EXCLUDED.bevoegdheidsverkrijgingen, EXCLUDED.bronhouder, EXCLUDED.classificaties, EXCLUDED.contact, EXCLUDED.datumInwerkingtreding, EXCLUDED.datumOpheffing, EXCLUDED.doel, EXCLUDED.eindDatum, EXCLUDED.geldendeCAO, EXCLUDED.ictuCode, EXCLUDED.installatie, EXCLUDED.instellingsbesluiten, EXCLUDED.inwonersPerKm2, EXCLUDED.kaderwetZboVanToepassing, EXCLUDED.kvkNummer, EXCLUDED.laatsteEvaluatie, EXCLUDED.omvatPlaats, EXCLUDED.oppervlakte, EXCLUDED.organisatiecode, EXCLUDED.partijFunctie, EXCLUDED.personeelsomvang, EXCLUDED.provincieAfkorting, EXCLUDED.rechtsvorm, EXCLUDED.registratiehouder, EXCLUDED.relatieMetMinisterie, EXCLUDED.resourceIdentifiers, EXCLUDED.samenwerkingsvorm, EXCLUDED.standplaats, EXCLUDED.startDatum, EXCLUDED.subnaam, EXCLUDED.subtype, EXCLUDED.taalcode, EXCLUDED.takenEnBevoegdheden, EXCLUDED.titel, EXCLUDED.totaalZetels, EXCLUDED.wettelijkeVoorschriften, EXCLUDED.zetels)
			)::text;

INSERT INTO almanak.medewerkers
	SELECT * FROM tmp_medewerkers
		ON CONFLICT (systemId, persoonId)
		DO NOTHING;

INSERT INTO almanak.functies
	SELECT * FROM tmp_functies
		ON CONFLICT (systemId, functieId)
		DO NOTHING;

INSERT INTO almanak.clusterOnderdelen
	SELECT * FROM tmp_clusterOnderdelen
		ON CONFLICT (systemId, clusterOnderdeelId)
		DO NOTHING;

INSERT INTO almanak.organisaties
	SELECT * FROM tmp_organisaties
		ON CONFLICT (systemId, organisatieId)
		DO NOTHING;

INSERT INTO almanak.deelnemendeOrganisaties AS d
	SELECT * FROM tmp_deelnemendeOrganisaties
		ON CONFLICT (systemId, organisatieId)
		DO UPDATE
			SET toetredingsDatum = EXCLUDED.toetredingsDatum,
			verdeelsleutel = EXCLUDED.verdeelsleutel,
  			bestuursorganen = EXCLUDED.bestuursorganen
		WHERE -- the row_to_json::text is easier with comparing null values
			row_to_json(
				ROW(d.toetredingsDatum, d.verdeelsleutel, d.bestuursorganen)
			)::text != row_to_json(
				ROW(EXCLUDED.toetredingsDatum, EXCLUDED.verdeelsleutel, EXCLUDED.bestuursorganen)
			)::text;

INSERT INTO almanak.parents AS p
	SELECT * FROM tmp_parents
		ON CONFLICT (systemId, parentId)
		DO UPDATE
			SET ordering = EXCLUDED.ordering
		WHERE p.ordering != EXCLUDED.ordering;

-- Delete stuff no longer used, the order is important here since there are foreign key constraints

DELETE FROM almanak.medewerkers
	WHERE (systemId, persoonId) NOT IN (SELECT systemId, persoonId FROM tmp_medewerkers);
DELETE FROM almanak.functies
	WHERE (systemId, functieId) NOT IN (SELECT systemId, functieId FROM tmp_functies);
DELETE FROM almanak.organisaties
	WHERE (systemId, organisatieId) NOT IN (SELECT systemId, organisatieId FROM tmp_organisaties);
DELETE FROM almanak.parents
	WHERE (systemId, parentId) NOT IN (SELECT systemId, parentId FROM tmp_parents);
DELETE FROM almanak.clusteronderdelen
	WHERE (systemId, clusterOnderdeelId) NOT IN (SELECT systemId, clusterOnderdeelId FROM tmp_clusteronderdelen);
DELETE FROM almanak.deelnemendeorganisaties
	WHERE (systemId, organisatieId) NOT IN (SELECT systemId, organisatieId FROM tmp_deelnemendeorganisaties);
DELETE FROM almanak.overheidsorganisatie
	WHERE systemid NOT IN (SELECT systemid FROM tmp_overheidsorganisatie);
DELETE FROM almanak.categorie
	WHERE catnr NOT IN (SELECT catnr FROM tmp_categorie);
DELETE FROM almanak.samenwerkingsvorm
	WHERE afkorting NOT IN (SELECT afkorting FROM tmp_samenwerkingsvorm);

-- Commit
COMMIT;

-- Analyze (mainly needed on first import!)
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
