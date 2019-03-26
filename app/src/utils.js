import { removeDiacritics } from './removeDiacritics.js';

export function makeurl(obj) {
	return `${obj.systemid}/${urlname(name(obj))}/`;
}

export function name(obj) {
    return obj.naam || obj.citeertitel || obj.titel || '-';
}

// Replace diacritics to their ASCII equivalence,
// Replace non letter/digits/dots/dashes (e.g. spaces) to underscore (_)
// Strip/remove prefix underscores/dots/dashes
// Strip/remove trailing underscores/dots/dashes
// Name empty entries as dash
export function urlname(str) {
	return removeDiacritics(str).replace(/[^a-zA-Z0-9.-]+/g, '_').replace(/^[_.-]+/, '').replace(/[_.-]+$/, '').replace(/^$/, '-');
}
