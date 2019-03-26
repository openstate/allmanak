//import data from './_data.js';
// faster builds!
// import * as fs from 'fs';
// const d = fs.readFileSync('/home/bwb/projects/openstate/allmanak/frontend/src/routes/_data.json');
// const data = JSON.parse(d);

// const categories = new Map();
// for (let key of Object.keys(data)) {
// 	if (data[key].categorie && (data[key].categorie.catnr == 53 || !data[key].parents)) {
// 		const id = data[key].categorie.catnr;
// 		const list = categories.get(id) || [];
// 		list.push({systemId: data[key].systemId, naam: data[key].naam || data[key].titel});
// 		categories.set(id, list);
// 	}
// }
// for (let entry of categories) {
// 	entry[1].sort((a, b) => a.naam.localeCompare(b.naam));
// }

// export function get(req, res, next) {
// 	//console.log(req);
// 	const { id } = req.params;

// 	// const list = [];
// 	// for (let key of Object.keys(data)) {
// 	// 	if (data[key].categorie && data[key].categorie.catnr == id && (id == 53 || !data[key].parents)) {
// 	// 		list.push({systemId: data[key].systemId, naam: data[key].naam || data[key].titel});
// 	// 	}
// 	// }
// 	res.writeHead(200, {
// 		'Content-Type': 'application/json'
// 	});
// 	// res.end(JSON.stringify(list.sort((a, b) => a.naam.localeCompare(b.naam))));
// 	res.end(JSON.stringify(categories.get(Number.parseInt(id))||[]));
// 	//res.end(JSON.stringify([]));
// }