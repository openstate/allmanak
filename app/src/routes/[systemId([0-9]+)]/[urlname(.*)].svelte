<script context="module">
	export async function preload({ params, query }) {
		// if (process.browser) {
		// 	debugger;
		// get from global.search.json/js :)
		// }
		//const res = await this.fetch(`api.json?systemId=${params.systemId}`);
		//const res = await this.fetch(`${params.systemId}.json`);

		const res = await this.fetch(`${apiBaseUri}/overheidsorganisatie?systemid=eq.${params.systemId}&select=*,parents(parent:parentid(systemid,naam,citeertitel,titel,medewerkers(count))),functies(functie:functieid(systemid,naam,medewerkers(persoon:persoonid(systemid,naam)))),medewerkers(persoon:persoonid(systemid,naam)),organisaties(organisatie:organisatieid(systemid,naam)),photo(*),logo(*)`);

		const data = await res.json();

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
	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	import {apiBaseUri} from '../../apibase.js';
	import { urlname, name } from '../../utils.js';

	export let entity;

	import EntityView from '../../components/EntityView.svelte';
</script>

<EntityView entity={entity} on:report='{() => dispatch("report")}'/>