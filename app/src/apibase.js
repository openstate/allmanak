export const apiBaseUri =
	process.browser ?
		document.location.href.indexOf('https://') == 0 ?
			'https://rest-api.allmanak.nl/v0' :	'/rest-api/v0' :
		'http://api-rest-v0:3000';