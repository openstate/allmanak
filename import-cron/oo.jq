def jsonify:if type == "null" then null else . | @json end;
def overheidsorganisatie: [
  .systeemId?,
  .naam,
  .partij,
  (.types?|if type != "array" then null else (.[] |if type == "array" then "{"+(join(","))+"}" else "{"+.+"}" end) end),
  (.categorie?|.catnr),
  .citeertitel?,
  .aangeslotenBijPensioenfonds?,
  .aantalInwoners?,
  .aantekening?,
  .afkorting?,
  (.afwijkendeBepaling?|jsonify),
  (.archiefzorgdrager?|.systeemId),
  (.beleidsterreinen?|jsonify),
  .beschrijving?,
  (.bevoegdheden?|if type == "null" then null else map(.kopArtikel + " " + .inhoudArtikel)|join(" ") end),
  (.bevoegdheidsverkrijgingen?|if type == "null" then null else "{" + (.|join(",")) + "}" end),
  (.bronhouder?|.systeemId),
  (.classificaties?|jsonify),
  (.contact?|jsonify),
  .datumInwerkingtreding?,
  .datumOpheffing?,
  .doel?,
  .eindDatum?,
  .geldendeCAO?,
  .ictuCode?,
  .installatie?,
  (.instellingsbesluiten?|if type == "null" then null else (.referentie |if type == "array" then map(gsub("'";"''")|@json)|"{"+join(",")+"}" else "{" + . +"}" end) end),
  .inwonersPerKm2?,
  .kaderwetZboVanToepassing?,
  .kvkNummer?,
  (.laatsteEvaluatie?|jsonify),
  .omvatPlaats?,
  .oppervlakte?,
  .organisatiecode?,
  .partijFunctie?,
  (.personeelsomvang?|jsonify),
  .provincieAfkorting?,
  .rechtsvorm?,
  .registratiehouder?,
  (.relatieMetMinisterie?|.systeemId),
  (.identificatiecodes.resourceIdentifier|jsonify),
  (.samenwerkingsvorm?|.afkorting?),
  .standplaats?,
  .startDatum?,
  .subnaam?,
  .subtype?,
  .taalcode?,
  .takenEnBevoegdheden?,
  .titel?,
  .raad.totaalZetels?,
  (.wettelijkeVoorschriften?|jsonify),
  (.raad.partijen|jsonify)
];
def overheidsorganisaties: . |overheidsorganisatie as $oo |if .functies? then (([.functies[] |overheidsorganisatie]) + ([.functies[] |.medewerkers[] |overheidsorganisatie]) + [$oo]) else [$oo] end;

map(overheidsorganisaties[] |walk(if type == "null" then "<<NULL>>" else . end))[]|@tsv|gsub("<<NULL>>";"\\N")
