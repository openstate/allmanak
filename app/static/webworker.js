function intersect(a, b) {
      const setB = new Set(b);
      return [...new Set(a)].filter(x => setB.has(x));
}

const searchcache = new Map();

const options = {
	shouldSort: false,
	includeScore: true,
	threshold: 0.2,
	location: 0,
	distance: 100,
	maxPatternLength: 32,
	minMatchCharLength: 3,
	keys: [
		{
		    "name": "naam",
		    "weight": 1
		},
		{
		    "name": "types",
		    "weight": 0.6
		},
		{
		    "name": "afkorting",
		    "weight": 0.8
		},
		{
		    "name": "path",
		    "weight": 0.4
		},
		{
		    "name": "commissie",
		    "weight": 0.4
		},
		{
		    "name": "partij",
		    "weight": 0.4
		},
		{
		    "name": "functie",
		    "weight": 0.3
		}
	]
};
self.importScripts('fuse.min.js', 'fuseindex.js');
const fuse = new Fuse(fuseIndex, options);

onmessage = function(e) {
	const query = e.data;
	const parts = query.split(" ").filter(s=>s.length>0);
	if (parts.length == 0) {
		postMessage(false);
		return;
	}
	let rollup = null;
	let scores = null;
	const searches = [];
	for (const part of parts) {
		let search;
		if (!searchcache.has(part)) {
			search = fuse.search(part);
			searchcache.set(part, search);
		} else {
			search = searchcache.get(part);
		}
		searches.push(search);
		if (searches.length == 1) {
			rollup = search.map(x=>x.item.id);
			scores = new Map(search.map(x=>[x.item.id, x.score]));
		} else {
			const newScores = new Map(search.map(x=>[x.item.id, x.score]));
			rollup = intersect(rollup, search.map(x=>x.item.id));
			//console.log(rollup);
			for (const id of rollup) {
				scores.set(id, scores.get(id) * newScores.get(id));
			}
		}
	}
	const lookup = new Map(searches[0].map(x=>[x.item.id, x.item]));
	const result = [];
	for (const id of rollup) {
		const item = lookup.get(id);
		result.push({score: scores.get(id), item: item});
	}
	result.sort((a, b)=>a.score-b.score);
	postMessage(result);
}