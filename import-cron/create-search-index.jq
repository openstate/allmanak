map(
	select(.medewerkers[0].count==0) |
	{
		id,
		naam: (if (.persoon|length>0) then (.persoon[0]|.voornaam + " " + if .tussenvoegsel != null then .tussenvoegsel + " " else "" end + .achternaam) else .naam // .titel end)
	} +
	if .afkorting != null then {afkorting} else {} end +
	if .bezoek != null or .post!= null then {plaats:(.bezoek // .post)} else {} end +
	if .types != null then {types} else {} end +
	if .partij != null then {partij} else {} end +
	if (.parents|length > 0) then {path: (.parents|map(.parent.naam // .parent.titel ))} else {} end +
	if (.commissie|length > 0) then {commissie: .commissie|map(.commissie)} else {} end +
	if (.parents[-1].parent.medewerkers[0].count > 0) then {functie: .parents[-1].parent.naam} else {} end
	|
	if .functie!=null then .path=.path[:-1] else . end
)