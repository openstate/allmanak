<script>
	import { createEventDispatcher } from 'svelte';
	import Bar from './Bar.svelte';
	import Report from './Report.svelte';
	import BoxLinks from './BoxLinks.svelte';

	const dispatch = createEventDispatcher();

	import {makeurl, name} from '../utils.js';
	const title = new Map([
		["telefoon",		"Telefoon"],
		["fax",				"Fax"],
		["emailadres",		"Email"],
		["bezoekAdres",		"Bezoek adres"],
		["postAdres",		"Postadres"],
		["internet",		"Website"],
		["contactpaginas",	"Contactformulier"],
	]);
	export let entity;

	const show = (key) => {
		return ['systemId', 'categorie', 'naam', 'afkorting', 'type'].indexOf(key) == -1;
	};

	const showname = (key) => {
		return title.get(key) || key;
	};

	function url(obj) {
		if (!obj || obj.length == 0) {
			return false;
		}
		return obj[0].url;
	}

	const azn = (a,b) => a.name.localeCompare(b.name);

</script>

<svelte:head>
	<title>{name(entity)} - Allmanak</title>
</svelte:head>
<div class="imagebar" alt="" style="background-image: url({url(entity.photo) || (entity.type == 'Gemeente' ? 'landschap.jpg' : 'gebouw.jpg')})"></div>
<div class="headerbar">
	<div class="breadcrumb">
		<div class="container">
			<img alt="" src="{url(entity.logo) || (entity.parents && entity.parents[entity.parents.length -1] && entity.parents[entity.parents.length -1].parent.medewerkers[0].count > 0 ? 'noprofile.svg' : 'missinglogo.svg')}">
			<div class="path">
				{#if entity.parents}
					{#each entity.parents as node}
						{#if node.parent.medewerkers[0].count == 0}
						<a href="{makeurl(node.parent)}">{name(node.parent)}</a>
						<span>&nbsp;&gt;&nbsp;</span>{/if
					}{/each
					}{#if entity.parents[entity.parents.length -1] && entity.parents[entity.parents.length -1].parent.medewerkers[0].count > 0}{entity.parents[entity.parents.length -1].parent.naam}{/if}
					{name(entity)}
				{:else}
					{name(entity)}
				{/if}
			</div>
		</div>
	</div>
</div>
<div class="container main">
	<div class="content">
		<h1>{name(entity)}</h1>
		<p>
			{#if entity.type}
				<div class="keyvalue"><div class="key">Type</div><div class="values">{entity.type}</div></div>
			{/if}
			{#if entity.partij}
				<div class="keyvalue"><div class="key">Partij</div><div class="values">{entity.partij}</div></div>
			{/if}
			{#if entity.parents && entity.parents[entity.parents.length -1] && entity.parents[entity.parents.length -1].parent.medewerkers[0].count > 0}
				<div class="keyvalue"><div class="key">Functie</div><div class="values">{entity.parents[entity.parents.length -1].parent.naam}</div></div>
			{/if}
			{#if entity.contact}
				{#each Object.keys(entity.contact) as key}
					{#if show(key)}
						<div class="keyvalue"><div class="key">{showname(key)}</div><div class="values">
							{#each (Array.isArray(entity.contact[key]) ? entity.contact[key] : [entity.contact[key]]) as item}
								<div>
								{#if typeof item == "string" }
									{#if key == "internet" || key == "contactpaginas"}
										<a href="{item}">{item}</a>
									{:else if key == "emailadres" || key == "contactEmail"}
										<a href="mailto:{item}">{item}</a>
									{:else}
										{item}
									{/if}
								{:else if typeof item.value == "string" }
									{#if key == "internet" || key == "contactpaginas"}
										<a href="{item.value}">{item.value}</a> {#if item.label}({item.label}){/if}
									{:else if key == "emailadres" || key == "contactEmail"}
										<a href="mailto:{item.value}">{item.value}</a> {#if item.label}({item.label}){/if}
									{:else}
										{item.value} {#if item.label}({item.label}){/if}
									{/if}
								{:else if typeof item.contactpaginaUrl== "string" }
									<a href="{item.contactpaginaUrl}" target='_blank' rel='noopener'>{item.contactpaginaUrl}</a>
								{:else if key == "postAdres" || key == "bezoekAdres" }
									{#if item.straat}
										{item.straat || ''} {item.huisnummer || ''}<br>
										{item.postcode || ''} {item.plaats || ''}
									{:else}
										{item.postbus || ''}<br>
										{item.postcode || ''} {item.plaats || ''}
									{/if}
								{:else}
									{JSON.stringify(item)}
								{/if}
								</div>
							{/each}
						</div></div>
					{/if}
				{/each}
			{/if}
			{#if entity.beschrijving}
				<h2>Beschrijving</h2>
				{#each entity.beschrijving.split('$') as text}
					{text}<br>
				{/each}
			{/if}
		</p>
	</div>
	<aside>
		<Report on:report='{() => dispatch("report")}' />
	</aside>
</div>
	{#if entity.medewerkers.length > 0}
<Bar>
	<span slot="header"><strong>{name(entity)}</strong> medewerkers</span>
	<div slot="body"><BoxLinks items={entity.medewerkers.map(x=>({link:makeurl(x.persoon), name:name(x.persoon) + (x.persoon.partij ? ` (${x.persoon.partij})` : '')})).sort(azn)}/></div>
</Bar>
	<!--div class="content">
		<h2>Medewerkers</h2>
		{#each entity.medewerkersNodes as item}
			<a href="/{item.systemId}/-">{item.naam || item.citeertitel || item.titel}</a><br>
		{/each}
	</div-->
	{/if}
	{#if entity.functies.length > 0}
<Bar>
	<span slot="header">Functies</span>
	<div slot="body"><BoxLinks items={entity.functies.map(x=>x.functie.medewerkers.length == 1 ? {link:makeurl(x.functie.medewerkers[0].persoon), name:name(x.functie) + " " + name(x.functie.medewerkers[0].persoon)} : {link:makeurl(x.functie), name:name(x.functie) + ` (${x.functie.medewerkers.length})`}).sort(azn)}/></div>
</Bar>
	<!--div class="content">
		<h2>Functies</h2>
		{#each entity.functiesNodes as item}
			<a href="/{item.systemId}/-">{item.naam || item.citeertitel || item.titel}</a><br>
		{/each}
	</div-->
	{/if}
	{#if entity.organisaties.length > 0}
<Bar>
	<span slot="header">Organisatie-onderdelen</span>
	<div slot="body"><BoxLinks items={entity.organisaties.map(x=>({link: makeurl(x.organisatie), name:name(x.organisatie)})).sort(azn)}/></div>
</Bar>
	<!--div class="content">
		<h2>Organisaties</h2>
		{#each entity.organisatiesNodes as item}
			<a href="/{item.systemId}/-">{item.naam || item.citeertitel || item.titel}</a><br>
		{/each}
	</div-->
	{/if}
	<!--{JSON.stringify(entity)}-->
<style>
	.imagebar {
		background: no-repeat 40%;
		background-size: cover;
		min-height: 200px;
	}
	.headerbar {
		color: #076776;
		background-color: #f2f2f2;
		position: relative;
		height: 6rem;
	}
	.breadcrumb {
		background-color: #076776;
		color: #FFF;
		min-height: 3rem;
		overflow: visible;
	}
	.breadcrumb > .container {
		padding-top: 0;
		padding-bottom: 0;
	}
	.breadcrumb > .container > .path {
		text-align: right;
		padding-top: 0.5rem;
		padding-bottom: 0.5rem;
		padding-left: 0.5rem;
	}
	.breadcrumb > .container > img {
		float: left;
		max-height: 14rem;
		max-width: 40vw;
		padding: 1rem;
		background-color: #FFF;
	}
	.keyvalue {
		margin-bottom: 1rem;
	}
	.key {
		min-width: 15rem;
		/*display: inline-block;*/
		font-weight: bold;
	}
	.main {
		clear: both;
	}
/*	.values {
		width: 20rem;
		display: inline-block;
	}*/
	@media (min-width: 768px) {
		.keyvalue {
			display: flex;
			flex-wrap: wrap;
		}
		.imagebar {
			min-height: 400px;
		}
		.headerbar {
			height: 14rem;
		}
		.breadcrumb > .container > img {
			max-width: 20vw;
			max-height: 14rem;
		}
		.main {
			display: grid;
			grid-template-columns: 1fr 20%;
			grid-gap: 0.5rem;
		}
	}
</style>