<script>
	import { urlname } from '../utils.js';
	import VirtualList from '@sveltejs/svelte-virtual-list';
	import Select from 'svelte-select';
	import ResultItem from '../components/ResultItem.svelte';
	import partyListFilter from './_parties.json';
	//import fetch from 'node-fetch';
	//import {categoriesApi} from './_categories.json.js';
	//import {citiesApi} from './_cities.json.js';
	import { categories } from '../stores.js';
    //export let categories;
	import cities from './_cities.json';

	import Bar from '../components/Bar.svelte';
	import Report from '../components/Report.svelte';
	import BoxLinks from '../components/BoxLinks.svelte';

	const csvEscape = str => str ? '"' + str.replace(/"/g, '""') + '"' : '';
	const sparseCsvEscape = (str, separator) => typeof str !== "string" || str.indexOf('"') == -1 && str.indexOf(separator) == -1 && str.indexOf("\n") == -1 && str.indexOf("\r") == -1 ? str : csvEscape(str);
	const toDataUri = csv => 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv);

	const twoDigits = d => d < 10 ? '0' + d : d;
	const dateTimeFormat = (o, d, dt, t) => o.getFullYear() + d + twoDigits(o.getMonth() + 1) + d + twoDigits(o.getDate()) + dt + twoDigits(o.getHours()) + t + twoDigits(o.getMinutes());
	const nowStr = () => dateTimeFormat(new Date(), '-', '_', '.');

	const csv = (result, separator) => {
      let str = [
        'ID',
        'Partij',
        'Afkorting',
        'Naam',
        'Functie',
        'Type',
        'Plaats',
      ].join(separator) + '\r\n';
      for (const row of result) {
          str += [
            sparseCsvEscape(row.item.id),
            sparseCsvEscape(row.item.partij),
            sparseCsvEscape(row.item.afkorting),
            sparseCsvEscape(row.item.naam),
            sparseCsvEscape(row.item.functie),
            sparseCsvEscape((row.item.types || []).join(", ")),
            sparseCsvEscape(row.item.plaats),
            //sparseCsvEscape('\u00A0' + (phone.number || '')), // '\u00A0' is an Excel only fix, probably better to make 'uniform' add dash function
          ].join(separator) + '\r\n';
      }
      return str;
    };

	let search;
	let searchbutton;
	let results;
	let result = false;
	let filterType = new Set();
	let filterPath = new Set();
	let filterPlaats;
	let filterOrganisatie;
	let filterPartij;
	let q = "";
	let facetShow;
	const noOptionsMessage = 'Geen resultaten gevonden';
	let groupBy = (item) => item.group;
	let resultStart = 0;
	let resultEnd = 0;
	const useMsBlob = process.browser ? typeof navigator.msSaveOrOpenBlob !== 'undefined' : false;
	let dataUri = '';
	let filename = '';
	const separator = ';';
	const isWindowsMobile = process.browser ? navigator.userAgent.indexOf('IEMobile') !== -1 : false;

	const worker = process.browser ? new Worker('webworker.js') : false;
	if (worker) {
		worker.onmessage = updateResult;
	}

	function updateResult(event) {
		result = event.data;
	}

	let facetList;
	$: {
		if (!result) {
			facetList = {};
		} else {
			const types = new Map();
			const paths = new Map();
			for (const part of result) {
				const typearray = part.item.types||['Medewerker'];
				const path = (part.item.path||[null])[0];
				for (const type of typearray) {
					types.set(type, (types.get(type) || 0) + 1);
				}
				paths.set(path, (paths.get(path) || 0) + 1);
			}
			// window.debug = {
			// 	categories: [...types.entries()].sort((a,b)=>b[1]-a[1]),
			// 	paths: [...paths.entries()].sort((a,b)=>b[1]-a[1]),
			// };
			facetList = {
				categories: [...types.entries()].sort((a,b)=>b[1]-a[1]),
				paths: [...paths.entries()].filter(x=>x[0]!=null).sort((a,b)=>b[1]-a[1]),
			};
		}
	}

	let filteredResults;
	$: {
		if (result == false || filterType.size == 0 && filterPath.size == 0 && 
				(!filterPlaats || filterPlaats.length == 0) &&
				(!filterOrganisatie || filterOrganisatie.length == 0) &&
				(!filterPartij || filterPartij.length == 0)) {
			filteredResults = result;
		} else {
			const filterCity = new Set((filterPlaats||[]).map(x => x.value))
			const filterOrg = new Set((filterOrganisatie||[]).map(x => x.value))
			const filterParty = new Set((filterPartij||[]).map(x => x.value))

			filteredResults = result.filter(x => (filterType.size == 0 || (x.item.types||['Medewerker']).filter(x=>filterType.has(x)).length > 0) && (filterPath.size == 0 || filterPath.has((x.item.path||[null])[0]))
				 && (filterCity.size == 0 || filterCity.has((x.item.plaats||'').toUpperCase()))
				 && (filterParty.size == 0 || filterParty.has(x.item.partij)));
		}
	}

	$: organisatieFilter = $categories.map(x=>({value:x.catnr,label:x.naam}));
	$: cityListFilter = cities.map(x=>({value:x,label:x}));

	function presearch(query) {
		if (query.length == 1)
			return;
		filterType = new Set(), filterPath = new Set();
		worker.postMessage(query);
	}

	function _export(e, result) {//since export is a reserved word!
		filename = 'export-' + q.replace(/[^a-zA-Z0-9-]+/g, '-') + nowStr() + '.csv', dataUri = toDataUri(csv(result, ';'));
	}

	function msDownload() {
		if (navigator.msSaveOrOpenBlob) {
			navigator.msSaveOrOpenBlob(new Blob([(BOM ? '\uFEFF' : '') + __this.get('csv')], { type: 'text/csv' /*, endings: 'transparent'*/}), __this.get('filename'));
		}
	}

	function pageShortcuts(event) {
		if (event.ctrlKey && event.key === 'f' || event.key === '/') {
			search.focus();
			event.preventDefault(); // prevent the default Ctrl+F behavior: native search on the page
			event.stopPropagation(); // prevent other/more event handlers from being triggered
			return;
		}
    }

	function searchKey(event) {
		if (event.key === 'Escape') {
			event.target.blur();
			event.preventDefault();// prevent Chrome behavior of also clearing the input, or should be cancel/clear the input too?
			event.stopPropagation(); // prevent other/more event handlers from being triggered
			return;
		}
		if (event.ctrlKey && event.key === 'f') {
			event.preventDefault(); // prevent the default Ctrl+F behavior: native search on the page
			event.stopPropagation(); // prevent other/more event handlers from being triggered
			return;
		}
		event.stopPropagation(); // prevent other/more event handlers from being triggered
    }

	function toggleFilterType(value) {
    	console.log('toggleType',value);
    	if (filterType.has(value)) {
    		filterType.delete(value);
    	} else {
    		filterType.add(value);
    	}
    	filterType = filterType;
    }

	function toggleFilterPath(value) {
    	console.log('togglePath',value);
    	if (filterPath.has(value)) {
    		filterPath.delete(value);
    	} else {
    		filterPath.add(value);
    	}
    	filterPath = filterPath;
    }

</script>

<svelte:head>
	<title>Allmanak - Zoeken naar contactgegevens overheden en politici</title>
</svelte:head>
<svelte:window on:keydown="{pageShortcuts}" />
<div class="searchbar">
	<div class="container">
		<div class="searchbox">
			<h2>Zoeken naar contactgegevens overheden en politici</h2>
			<input bind:value="{q}" autocomplete="off" autocorrect="off" bind:this={search} value="" on:keydown="{searchKey}" on:keyup="{() => presearch(q)}" id='query' placeholder='Zoeken naar persoon of organisatie' type='search'>
			<h3 on:click|stopPropagation="{() => facetShow = !facetShow}" class="facetstitle">Of zoeken met filters <span class="facetToggle" >{facetShow ? '\u00D7' : '\u22C1'}</span></h3>
			<div class="facets">
				<!-- <input placeholder='Plaats'> --><div class:show='{facetShow}'><Select bind:selectedValue="{filterPlaats}" items={cityListFilter} placeholder="Plaats" isMulti={true} isClearable={false} {noOptionsMessage}></Select></div>
				<!--input placeholder='Overheidsorganisatie'--><div class:show='{facetShow}'><Select bind:selectedValue="{filterOrganisatie}" items={organisatieFilter} isClearable={false} placeholder="Overheidsorganisatie" isMulti={true} {noOptionsMessage}></Select></div>
				<!-- <input placeholder='Politieke Partij'> --><div class:show='{facetShow}'><Select bind:selectedValue="{filterPartij}" items={partyListFilter} placeholder="Politieke Partij" isMulti={true} isClearable={false} {noOptionsMessage} {groupBy}></Select></div>
				<button bind:this={searchbutton}>Zoek</button>
			</div>
		</div>
	</div>
</div>
{#if result}
<div class="resultbar">
	<div class="facets2">
		{#if facetList}
			Filter op type:
			<div class="facetgroup">
			{#each facetList.categories.slice(0,4) as type}
				<div class="facetbutton"><div class:active='{filterType.has(type[0])}' on:click='{() => toggleFilterType(type[0])}'><div class='name'>{type[0]}</div><div class='count'>{type[1]}</div></div></div>
			{/each}
			</div>
			Binnen organisatie:
			<div class="facetgroup">
			{#each facetList.paths.slice(0,4) as path}
				<div class="facetbutton"><div class:active='{filterPath.has(path[0])}' on:click='{() => toggleFilterPath(path[0])}'><div class='name'>{path[0]}</div><div class='count'>{path[1]}</div></div></div>
			{/each}
			</div>
		{/if}
	</div>
	<div class="resultcontainer">
		{#if result.length == 0}
			{noOptionsMessage}
		{:else}
			{filteredResults.length} resulta{filteredResults.length == 1 ? 'at' : 'ten'}:
			<div bind:this={results}> <!-- don't ask me why, but without this 'useless' div iOS doesn't always show a scrollbar -->
			<VirtualList items={filteredResults} let:item height="400px" bind:start={resultStart} bind:end={resultEnd} itemHeight={78}>
				<ResultItem {...item.item}/>
			</VirtualList>
			<!-- another bug, without itemHeight, the whole thing doesn't work -->
			</div>
			<div class="shown">Getoond {resultStart + 1}-{resultEnd}</div>
			<button class="export" on:click="{e => _export(e, filteredResults)}"><a href="{ useMsBlob ? '#' : dataUri }" download="{ filename }" on:click="{msDownload}">Exporteer</a></button>
		{/if}
	</div>
	<div></div>
</div>
{/if}
<div id="over">
	<div class="container main">
		<article>
			<h2>Over deze website</h2>
			<p>Op deze website staan de namen, adressen en andere contactgegevens van de Nederlandse overheidsorganisaties. Ook de persoonsgegevens van (voornamelijk) leidinggevende personen binnen de Nederlandse overheid zijn opgenomen. Publicatie geschiedt in opdracht van het ministerie van Binnenlandse Zaken en Koninkrijksrelaties, op basis van een Koninklijk Besluit van 16 juli 1859.<br><br>
			De organisaties zijn zelf verantwoordelijk voor de volledigheid, juistheid en actualiteit van de gegevens.</p>
		</article>
		<aside>
			<Report />
		</aside>
	</div>
</div>
<Bar>
	<span slot="header">Zoek op categorie in <strong>Overheids&shy;organisaties</strong></span>
	<div slot="body"><BoxLinks items={$categories.map(x=>({link:`cat/${x.catnr}/${urlname(x.naam)}`, name:x.naam}))}/></div>
</Bar>

<style>
	.searchbar {
		background: url(/denhaag-binnenhof.jpg) no-repeat 40%;
		background-size: cover;
		min-height: 400px;
	}
	.searchbox {
		margin-top: 20%;
		background-color: #f2f2f2;
		color: #3d4a4c;
		padding: 2rem;
	}
	.facetstitle {
		margin-top: 0.5rem;
		display: inline-block;
	}
	.facets {
		/*display: flex;
		flex-direction: row;
		flex-wrap: nowrap;
		justify-content: space-between;*/
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr));
        grid-gap: 1rem;
	}
	.facets > div {
		display: none;
	}
	.facets > div.show {
		display: block;
	}
	.facetgroup {
		height: 40px;
		overflow: scroll;
		white-space: nowrap;
	}
	.facetbutton {
		display: inline-block;
	}
	.facetbutton > div {
	    background: #EBEDEF;
	    cursor: pointer;
	    margin-right: 5px;
	    border-radius: 16px;
	    line-height: 32px;
	    display: inline-flex;
	    cursor: default;
	    height: 32px;
	    margin-top: 5px;
	    padding: 0 10px 0 15px;
	}
	.facetbutton > div.active, .facetbutton > div:hover  {
	    background-color: #00938f;
	    color: #fff;
	    cursor: pointer;
	}
	.facetbutton > div > .name {
		margin-right: 5px;
	}
	.facetbutton > div > .count {
	    border-radius: 16px;
	    background: #52616F;
	    min-width: 16px;
	    height: 16px;
	    position: relative;
	    top: 8px;
	    text-align: center;
	    padding: 1px 2px;
	    line-height: 16px;
	    font-size: 0.5em;
	    color: white;
	    font-weight: bold;
	    right: 0px;
	}
	.facetbutton > div.active > .count, .facetbutton > div:hover > .count  {
		background-color: #fff;
		color: #52616F;
	}
	.facets > :global(div), .facets button /*.facets > input*/ {
		/*display: block;*/
		align-self: start;
		/*width: 24%;*/
		/*box-sizing: border-box;*/
	}
	.shown {
		color: #666;
	}
	/*.facets * {
		width: 22%;
		box-sizing: border-box;
		margin-left: 2%;
	}
	.singleline:first-child {
		margin-left: 0;
	}*/
	#query {
		width: 100%;
	}
	.searchbox input {
		background-color: #fff;
		border-radius: 0.5rem;
		border: none;
		padding: 0.5rem;
		appearance: none;
	}
	:global(div.selectContainer.multiSelect) {
		background-color: #fff;
		border-radius: 0.5rem;
		border: none;
	}
	.searchbox button {
		background-color: #00938f;
		color: #FFF;
		font-weight: bold;
		border: none;
		border-radius: 0.5rem;
		padding: 0.5rem;
		display: block;
	}
	@media (min-width: 768px) {
		.main {
			display: grid;
			grid-template-columns: 1fr 20%;
			grid-gap: 0.5rem;
		}
	}
	:global(body.fontloaded-montserratsemibold) .reporterrorbox, :global(body.fontloaded-montserratsemibold) .reporterrorbox button {
		font-family: 'montserratsemibold';
	}
	/*.categories,*/ .resultbar {
		background-color: #f2f2f2;
	}
	.resultbar {
		padding: 1rem;
	}

	@media (min-width: 768px) {
		.facetbutton {
			display: block;
		}
		.facetgroup {
			height: auto;
			overflow: visible;
			white-space: normal;
		}
		.facetgroup {
			white-space: wrap;
		}
		.resultbar {
			padding: 0;
			display: grid;
		    grid-template-columns: 1fr minmax(10rem,70rem) 1fr;
		}
	}
	button.export {
		float: right;
		background-color: #00938f;
		color: #FFF;
		font-weight: bold;
		border: none;
		border-radius: 0.5rem;
		padding: 0.5rem;
		font-weight: 600;
		cursor: pointer;
	}
	/*ref:results {*/
		/*border: 1px solid #CCC;*/
		/*border: 1px solid red;*/
	/*}*/
	/*
	ol.searchresult {
		list-style-type: none;
	}
	ol.searchresult > li {
		margin: 0;
		margin-bottom: 1rem;
		padding: 0;
	}
	ol.searchresult > li > a {
		display: block;
		text-decoration: none;
	}
	ol.searchresult > li > a > h6 {
		font-size: 1rem;
		font-weight: bold;
	}*/
	.facetToggle {
		display: inline-block;
		float: right;
		margin-left: 0.5rem;
		font-size: 0.75rem;
		font-weight: bold;
		line-height: 1.5rem;
	}
	.facetstitle {
		cursor: pointer;
	}
	@media (min-width: 768px) {
		.facets > div {
			display: block;
		}
		.facetstitle {
			cursor: default;
		}
		.facetToggle {
			display: none;
		}
	}

</style>