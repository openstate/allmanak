<script context="module">
	export async function preload({ params, query }) {
		// if (process.browser) {
		// 	debugger;
		// get from global.search.json/js :)
		// }
		//const res = await this.fetch(`api.json?systemId=${params.systemId}`);
		//const res = await this.fetch(`${params.systemId}.json`);

		const res = await this.fetch(`${apiBaseUri}/overheidsorganisatie?systemid=eq.${params.systemId}&select=*,parents(parent:parentid(systemid,naam,citeertitel,titel,medewerkers(count))),functies(functie:functieid(systemid,naam,medewerkers(persoon:persoonid(systemid,naam,persoon(initialen,voornaam,tussenvoegsel,achternaam))))),medewerkers(persoon:persoonid(systemid,naam,persoon(initialen,voornaam,tussenvoegsel,achternaam))),organisaties(organisatie:organisatieid(systemid,naam)),photo(*),logo(*),persoon(initialen,voornaam,tussenvoegsel,achternaam),extracontact:contact(*),commissies:commissie(commissie,url)&parents.order=ordering.desc&commissies.order=commissie.asc`);

		const data = await res.json();
		// Overload emailadres etc.
		if (data[0].extracontact.length > 0) {
			const c = data[0].extracontact[0].contact;
			for (let k in c) {
				data[0].contact[k] = c[k];
			}
		}

		if (res.status === 200) {
			const ret = { entity: data[0] };
			const entityUrlname = urlname(name(ret.entity));
			// Redirect if name is incorrect:
			if (params.urlname != entityUrlname + '/' || Object.getOwnPropertyNames(query).length != 0) {
				this.redirect(301, `/${params.systemId}/${entityUrlname}/`);
			} else {
				return ret;
			}
		} else {
			this.error(res.status, data.message);
		}
	}
</script>

<script>
	import {apiBaseUri} from '../../apibase.js';
	import { urlname, name } from '../../utils.js';

	export let entity;

	import EntityView from '../../components/EntityView.svelte';
</script>

<EntityView entity={entity}/>