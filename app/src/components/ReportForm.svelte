<script>
	import Select from 'svelte-select';

	export let close;

	let errortype = 'content';
	let contenterrortype = [];
	const errortypes = ['Naam onjuist', 'Organisatie / Persoon ontbreekt', 'Organisatie / persoon niet meer actief'].map(x=>({value:x,label:x}));
	const noOptionsMessage = 'Geen resultaten gevonden, u kunt een ook opmerking achterlaten';
	let correctname = '';
	let comment = '';

	function check() {
		close();
	}
</script>

<div class="main" on:click|stopPropagation="{() => console.log()}">
	<h2>Fout melden</h2>
	<div class="choose">
		Betreft het een technische fout van de website? Inhoudelijke fouten kunnen momenteel voorkomen omdat deze website niet meer up to date wordt gehouden. Correcties hierop zijn helaas niet mogelijk.
		<div class="line">
			<label class:disabled='{errortype=="content"}'><input bind:group={errortype} type=radio value=content>Inhoudelijke fout</label>
			<label class:active='{errortype=="tech"}'><input bind:group={errortype} type=radio value=tech>Technische fout</label>
		</div>
	</div>
	<div>
	{#if errortype == 'content'}
		<div class=errortype>
			Wat is er fout? (kies één of meerdere fouten uit de selectie)<br />
			<Select bind:selectedValue="{contenterrortype}" items={errortypes} isClearable={false} placeholder="Fout type" isMulti={true} {noOptionsMessage}></Select>
		</div>
		{#if contenterrortype.filter(x=>x.value=='Naam onjuist').length > 0}
			<label>Weet u de correcte naam?<br>
			<input bind:value="{correctname}" type="text"></label>
		{/if}
		<textarea bind:value="{comment}" class="comment" name="comment" placeholder="Overige toevoeging / opmerkingen"></textarea>
	{/if}
	{#if errortype == 'tech'}
		Graag horen we van u wat er mis gaat:<br>
		<textarea bind:value="{comment}" class="comment" name="comment" placeholder="Beschrijf hier uw probleem"></textarea>
	{/if}
	</div>
	<button on:click="{check}">Versturen</button>
</div>

<style>
	.main {

	}
	:global(.errortype div.selectContainer.multiSelect) {
		background-color: #EFEFEF !important;
	}
	:global(.errortype .multiSelectItem){
		background-color: #00938f !important;
		color: #FFF !important;
	}
	:global(.errortype .multiSelectItem:hover){
		background-color: #FFF !important;
		color: #000 !important;
	}
	.line, .errortype {
		padding: 1rem 0;
	}
	.choose > div > label {
		background: #CCC;
		padding: 0.5rem;
		color: #000;
	}
	.choose > div > label.active {
		background: #c2178a;
		color: #FFF;
	}
	.choose > div > label > input {
		display: none;
	}
	.comment {
		width: 100%;
		height: 8rem;
	}
	button {
		width: 100%;
		color: #FFF;
		background-color: #c2178a;
		border: none;
		border-radius: 0.5rem;
		padding: 0.5rem;
		font-weight: 600;
		cursor: pointer;
	}
</style>
