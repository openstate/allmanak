-- Update all new stuff

INSERT INTO almanak.categorie c
	SELECT * FROM tmp_categorie
		ON CONFLICT (catnr)
		DO UPDATE
			SET naam = EXCLUDED.naam
		WHERE c.naam != EXCLUDED.naam;

INSERT INTO almanak.samenwerkingsvorm s
	SELECT * FROM tmp_samenwerkingsvorm
		ON CONFLICT (afkorting)
		DO UPDATE
			SET naam = EXCLUDED.naam
		WHERE s.naam != EXCLUDED.naam;

INSERT INTO almanak.overheidsorganisatie o
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
			classificaties = EXCLUDED.classificaties,
			contact = EXCLUDED.contact,
			contactEmail = EXCLUDED.contactEmail,
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
		WHERE row_to_json(
				ROW(s.naam, s.partij, s."type", s.categorie, s.citeertitel, s.aangeslotenBijPensioenfonds, s.aantalInwoners, s.aantekening, s.afkorting, s.afwijkendeBepaling, s.archiefzorgdrager, s.beleidsterreinen, s.beschrijving, s.bevoegdheden, s.bevoegdheidsverkrijgingen, s.classificaties, s.contact, s.contactEmail, s.datumInwerkingtreding, s.datumOpheffing, s.doel, s.eindDatum, s.geldendeCAO, s.ictuCode, s.installatie, s.instellingsbesluiten, s.inwonersPerKm2, s.kaderwetZboVanToepassing, s.kvkNummer, s.laatsteEvaluatie, s.omvatPlaats, s.oppervlakte, s.organisatiecode, s.partijFunctie, s.personeelsomvang, s.provincieAfkorting, s.rechtsvorm, s.registratiehouder, s.relatieMetMinisterie, s.resourceIdentifiers, s.samenwerkingsvorm, s.standplaats, s.startDatum, s.subnaam, s.subtype, s.taalcode, s.takenEnBevoegdheden, s.titel, s.totaalZetels, s.wettelijkeVoorschriften, s.zetels)
			)::text != row_to_json(
				ROW(EXCLUDED.naam, EXCLUDED.partij, EXCLUDED."type", EXCLUDED.categorie, EXCLUDED.citeertitel, EXCLUDED.aangeslotenBijPensioenfonds, EXCLUDED.aantalInwoners, EXCLUDED.aantekening, EXCLUDED.afkorting, EXCLUDED.afwijkendeBepaling, EXCLUDED.archiefzorgdrager, EXCLUDED.beleidsterreinen, EXCLUDED.beschrijving, EXCLUDED.bevoegdheden, EXCLUDED.bevoegdheidsverkrijgingen, EXCLUDED.classificaties, EXCLUDED.contact, EXCLUDED.contactEmail, EXCLUDED.datumInwerkingtreding, EXCLUDED.datumOpheffing, EXCLUDED.doel, EXCLUDED.eindDatum, EXCLUDED.geldendeCAO, EXCLUDED.ictuCode, EXCLUDED.installatie, EXCLUDED.instellingsbesluiten, EXCLUDED.inwonersPerKm2, EXCLUDED.kaderwetZboVanToepassing, EXCLUDED.kvkNummer, EXCLUDED.laatsteEvaluatie, EXCLUDED.omvatPlaats, EXCLUDED.oppervlakte, EXCLUDED.organisatiecode, EXCLUDED.partijFunctie, EXCLUDED.personeelsomvang, EXCLUDED.provincieAfkorting, EXCLUDED.rechtsvorm, EXCLUDED.registratiehouder, EXCLUDED.relatieMetMinisterie, EXCLUDED.resourceIdentifiers, EXCLUDED.samenwerkingsvorm, EXCLUDED.standplaats, EXCLUDED.startDatum, EXCLUDED.subnaam, EXCLUDED.subtype, EXCLUDED.taalcode, EXCLUDED.takenEnBevoegdheden, EXCLUDED.titel, EXCLUDED.totaalZetels, EXCLUDED.wettelijkeVoorschriften, EXCLUDED.zetels)
			)::text;

INSERT INTO almanak.medewerkers s
	SELECT * FROM tmp_medewerkers
		ON CONFLICT (systemId, persoonId)
		DO NOTHING;

INSERT INTO almanak.functies s
	SELECT * FROM tmp_functies
		ON CONFLICT (systemId, functieId)
		DO NOTHING;

INSERT INTO almanak.clusterOnderdelen s
	SELECT * FROM tmp_clusterOnderdelen
		ON CONFLICT (systemId, clusterOnderdeelId)
		DO NOTHING;

INSERT INTO almanak.organisaties s
	SELECT * FROM tmp_organisaties
		ON CONFLICT (systemId, organisatieId)
		DO NOTHING;

INSERT INTO almanak.deelnemendeOrganisaties s
	SELECT * FROM tmp_deelnemendeOrganisaties
		ON CONFLICT (systemId, organisatieId)
		DO UPDATE
			SET toetredingsDatum = EXCLUDED.toetredingsDatum,
			bronhouder = EXCLUDED.bronhouder
		WHERE s.toetredingsDatum != EXCLUDED.toetredingsDatum OR s.bronhouder != EXCLUDED.bronhouder;

INSERT INTO almanak.parents s
	SELECT * FROM tmp_parents
		ON CONFLICT (systemId, parentId)
		DO UPDATE
			SET ordering = EXCLUDED.ordering
		WHERE s.ordering != EXCLUDED.ordering;

-- Delete stuff no longer used

DELETE FROM almanak.categorie
	WHERE catnr NOT IN (SELECT catnr FROM tmp_categorie);
DELETE FROM almanak.samenwerkingsvorm
	WHERE afkorting NOT IN (SELECT afkorting FROM tmp_samenwerkingsvorm);
DELETE FROM almanak.overheidsorganisatie
	WHERE systemid NOT IN (SELECT systemid FROM tmp_overheidsorganisatie);
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

-- Commit
COMMIT;
