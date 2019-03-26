// //import data from './_data.js';
// // faster builds!
// import * as fs from 'fs';
// const d = fs.readFileSync('/home/bwb/projects/openstate/allmanak/frontend/src/routes/_data.json');
// const data = JSON.parse(d);

// export function get(req, res, next) {
// 	// the `systemId` parameter is available because
// 	// this file is called [systemId].json.js // [systemId([0-9]+)]
// 	const { systemId } = req.params;
// 	//const { systemId } = req.query;

// 	if (data[systemId]) {
// 		res.writeHead(200, {
// 			'Content-Type': 'application/json'
// 		});
// 		const o = {...data[systemId]}; // copy, not reference!
// 		if (o.parents) {
// 			o.parentNodes = o.parents.map(id => data[id]);
// 		}
// 		if (o.functies) {
// 			o.functiesNodes = o.functies.map(id => data[id]);
// 		}
// 		if (o.medewerkers) {
// 			o.medewerkersNodes = o.medewerkers.map(id => data[id]);
// 		}
// 		if (o.organisaties) {
// 			o.organisatiesNodes = o.organisaties.map(id => data[id]);
// 		}
// 		/*if (o.functies || o.medewerkers || o.organisaties) {
// 			//o.childNodes = Array.concat.apply([], [o.functies, o.medewerkers, o.organisaties].map(list => list ? list.map(id => data[id]) : []));
// 			o.childNodes = [o.functies, o.medewerkers, o.organisaties].map(list => list ? list.map(id => data[id]) : []).reduce((a,i)=>a.concat(i),[]);
// 		}*/

// 		res.end(JSON.stringify(o));
// 	} else {
// 		res.writeHead(404, {
// 			'Content-Type': 'application/json'
// 		});

// 		res.end(JSON.stringify({
// 			message: `Not found id=${systemId}`
// 		}));
// 	}
// }
