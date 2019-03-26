walk(
	if type == "object" and has("systemId") then
		. as $parent |
		[
			. +
			if has("functies") then {functies: (.functies | flatten | map(select(has("parents") | not) | .systemId))} else {} end +
			if has("organisaties") then {organisaties: (.organisaties | flatten | map(select(has("parents") | not) | .systemId))} else {} end +
			if has("medewerkers") then {medewerkers: (.medewerkers | flatten | map(select(has("parents") | not) | .systemId))} else {} end +
			if has("clusterOnderdelen") then {clusterOnderdelen: (.clusterOnderdelen | flatten | map(select(has("parents") | not) | .systemId))} else {} end
		] +
		(
			(
				(.functies //[]) +
				(.organisaties //[]) +
				(.medewerkers //[]) +
				(.clusterOnderdelen //[])
			) | flatten | map(.parents += [$parent.systemId])
		)
	else
		.
	end
) | flatten