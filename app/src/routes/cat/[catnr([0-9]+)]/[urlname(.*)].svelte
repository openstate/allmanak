<script context="module">
	import {apiBaseUri} from '../../../apibase.js';

	export async function preload({ params, query }) {
		//http://localhost:80/rest-api/v1/overheidsorganisatie?categorie=cs.{1}&select=systemid,naam,titel,parents(count)&einddatum=eq.null
		//const res = await this.fetch(`cat/${params.id}.json`);
		const categorie2type = [
			{"catnr":53,"naam":"Adviescolleges","type":'Adviescollege'},
			{"catnr":51123,"naam":"Caribisch Nederland (BES-eilanden)","type":'Caribisch Nederland'},
			{"catnr":23699905,"naam":"Gemeenschappelijke regelingen","type":'Gemeenschappelijke regeling'},
			{"catnr":1,"naam":"Gemeenten","type":'Gemeente'},
			{"catnr":44,"naam":"Hoge Colleges van Staat","type":'Hoog College van Staat'},
			{"catnr":45,"naam":"Ministeries","type":'Ministerie'},
			{"catnr":55,"naam":"Politie en brandweer","type":'Politie en brandweer'},
			{"catnr":31,"naam":"Provincies","type":'Provincie'},
			{"catnr":54,"naam":"Rechterlijke macht","type":'Rechterlijke macht'},
			{"catnr":43,"naam":"Staten-Generaal","type":'Staten-Generaal'},
			{"catnr":32,"naam":"Waterschappen","type":'Waterschap'},
			{"catnr":26140391,"naam":"Zelfstandige bestuursorganen","type":'Zelfstandig bestuursorgaan'}
		];
		const ootype = categorie2type.filter(x => x.catnr == params.catnr)[0].type;
		const res = await this.fetch(`${apiBaseUri}/overheidsorganisatie?types=cs.{${encodeURIComponent(ootype)}}&select=systemid,naam,citeertitel,titel,parents(count)&einddatum=is.null&order=naam,citeertitel,titel`);
		const data = await res.json();

		if (res.status === 200) {
			return { list: data.filter(x => x.parents[0].count == 0), catnr: params.catnr };
		} else {
			this.error(res.status, data.message);
		}
	}
</script>

<script>
	import {makeurl, name} from '../../../utils.js';
	import categories from '../../_categories.json';
	export let catnr;
	export let list;

	export let catnaam;
	$: catnaam = categories.filter(x => x.catnr == catnr)[0].naam;
</script>

<svelte:head>
	<title>{catnaam}</title>
</svelte:head>


<div class="container">
	<h1>{catnaam}</h1>
	<div class='content'>
		{#each list as item}
			<a href="{makeurl(item)}">{name(item)}</a><br>
		{/each}
	</div>
</div>

<style>
	.content :global(h2) {
		font-size: 1.4em;
		font-weight: 500;
	}

	.content :global(pre) {
		background-color: #f9f9f9;
		box-shadow: inset 1px 1px 5px rgba(0,0,0,0.05);
		padding: 0.5em;
		border-radius: 2px;
		overflow-x: auto;
	}

	.content :global(pre) :global(code) {
		background-color: transparent;
		padding: 0;
	}

	.content :global(ul) {
		line-height: 1.5;
	}

	.content :global(li) {
		margin: 0 0 0.5em 0;
	}
</style>