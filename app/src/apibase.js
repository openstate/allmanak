export const apiBaseUri =
	process.browser ?
		document.location.href.indexOf('https://') == 0 ?
			'https://rest-api.allmanak.nl/v1' :	'/rest-api/v1' :
		'http://api-rest-v1:3000';