<script context="module">
	import {apiBaseUri} from '../apibase.js';
	export async function preload() {
		// TODO: do parallel with Promise.all
		const all = await this.fetch(`${apiBaseUri}/overheidsorganisatie?select=count&types=cs.{Gemeente}`);
		const alljson = await all.json();
		const current = await this.fetch(`${apiBaseUri}/overheidsorganisatie?select=count&types=cs.{Gemeente}&einddatum=is.null`);
		const currentjson = await current.json();
		const notcurrent = await this.fetch(`${apiBaseUri}/overheidsorganisatie?select=naam:afkorting&types=cs.{Gemeente}&einddatum=not.is.null&limit=3`);
		const notcurrentjson = await notcurrent.json();
		const firstSample = notcurrentjson.map(item => item.naam);
		const lastSample = firstSample.splice(-1);

		return {
			allMunicipalityCount: alljson[0].count,
			currentMunicipalityCount: currentjson[0].count,
			notCurrentSample: {firsts: firstSample, last: lastSample},
		};
	}
</script>
<script>
	import {apiBaseBrowser} from '../apibase.js';
	export let allMunicipalityCount = '.. loading ..';
	export let currentMunicipalityCount = '.. loading ..';
	export let notCurrentSample = {firsts: ['.. loading ..'], last: '.. loading ..'};

	let swaggerNode, swaggerDep1Loaded, swaggerDep2Loaded;
	$: {
		if (swaggerDep1Loaded && swaggerDep2Loaded) {
			SwaggerUIBundle({
				defaultModelExpandDepth: 7,
				defaultModelsExpandDepth: 5,
				domNode: swaggerNode,
				// deepLinking: true,
				layout: "BaseLayout",
				presets: [
				  SwaggerUIBundle.presets.apis,
				  SwaggerUIStandalonePreset
				],
				plugins: [
				  SwaggerUIBundle.plugins.DownloadUrl
				],
				showExtensions: true,
				showCommonExtensions: true,
				url: `${apiBaseUri}/`,
				validatorUrl: null,
			});
		}
	}
	const docsBaseUri = 'https://postgrest.org/en/v6.0/api.html';
	const exampleMunicipality = 'Amsterdam';
	const exampleElectionMunicipality = 'Lingewaard';
	const exampleElectionCode = `GR2018_${exampleElectionMunicipality.replace(/[^a-zA-Z]/g,'')}`;
</script>

<svelte:head>
	<title>API</title>
	<link rel="stylesheet" type="text/css" href="swagger-ui.css" >
	<script src="swagger-ui-bundle.js" on:load={() => swaggerDep1Loaded = true}></script>
	<script src="swagger-ui-standalone-preset.js" on:load={() => swaggerDep2Loaded = true}></script>
</svelte:head>
<div class="searchbar">
</div>
<div id="over">
	<div class="container">
		<article>
			<h2>API</h2>
			<p>De databron wie wij gebruiken is <a rel="noopener" target="_blank" href="http://almanak.overheid.nl/archive/">Overheidsorganisaties XML</a>, deze <abbr title="Extensible Markup Language">XML</abbr> converteren en importeren wij in een database die we met een <abbr title="Representational State Transfer">REST</abbr> <abbr title="Application Programming Interface">API</abbr> toegankelijk stellen (m.b.v. PostREST met <abbr title="Cross-Origin Resource Sharing">CORS</abbr>). De API kan zowel <abbr title="JavaScript Object Notation">JSON</abbr> als <abbr title="Comma-Separated Values">CSV</abbr> terug sturen. Let op, met PostgREST zijn database intensieve queries te maken, daarom hebben we de query limiet op tien seconden gezet, mocht je hier tegenaan lopen, neem dan vooral contact met ons op dan gaan we een oplossing maken (bijv. een speciale view / API endpoint of uitzondering).</p>
			<p>De API heeft vele endpoints maar de <code>overheidsorganisatie</code> is de interessante, gezien alle objecten een <code>overheidsorganisatie</code>-object zijn, de andere endpoints zijn voor de onderlinge relaties, maar deze kunnen ook via PostgREST <a target="_blank" rel="noopener" href="{docsBaseUri}#resource-embedding">resource embedding</a> tot op zekere hoogte worden meegenomen in de <code>overheidsorganisatie</code>-call.</p>
			<p>Zie onderaan deze pagina de <a href="api/#changelog">changelog</a> en <a href="api/#upgrade-v0-to-v1">upgrade instructie vanaf <code>v0</code></a>. Voor meer informatie over het tijdspad van versie upgrades van de API zie de <a href="api/#policy">deprecation policy</a>, indien mogelijk gebruik dan een <abbr title="HyperText Transfer Protocol">HTTP</abbr> User-Agent met contactgegevens, bijv. <code class="nowrap">User-Agent: Mozilla/5.0 (compatible; ApplicatieNaam/1.0; +https://link-naar-je-applicatie/)</code>.</p>

			<h2 id="examples">Voorbeelden</h2>
			<h3 id="example-municipality">Gemeente</h3>
			<p>
				Het makkelijkste is om de API uit te leggen op basis van voorbeelden. Stel je wilt gegevens hebben van gemeente {exampleMunicipality}, dan kan je hier zo naar zoeken:<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?naam=eq.{encodeURIComponent('Gemeente '+exampleMunicipality)}" target="_blank">/overheidsorganisatie?<strong>naam=<abbr title="equal">eq</abbr>.Gemeente {exampleMunicipality}</strong></a></code><br>
				Waarbij <code>eq</code> staat voor <code>equal</code> (gelijk), er is een hele <a href="{docsBaseUri}#horizontal-filtering-rows" target="_blank" rel="noopener">lijst met filter operaties</a>.
			</p>
			<p>
				Stel je wilt nu een lijst met alle gemeenten, dan kan je alle organisaties die in <codes>types</codes> de waarde <code>Gemeente</code> bevatten selecteren:<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?types=cs.&#123;Gemeente&#125;" target="_blank">/overheidsorganisatie?<strong>types=<abbr title="contains">cs</abbr>.&#123;Gemeente&#125;</strong></a></code><br>
				Waarbij <code>cs</code> staat voor <code>contains</code> (bevat), en de <code>&#123;&#125;</code> een lijst (array) notatie is, in dit geval van slechts &eacute;&eacute;n element, een lijst kan meerdere gescheiden worden met een komma (<code>,</code>).
			</p>
			<p>
				Als je in de JSON output enkel de <code>afkorting</code> (de gemeentenaam zonder "Gemeente " ervoor), <code>ictucode</code> (een code die voor gemeenten gelijk is aan de <a href="https://nl.wikipedia.org/wiki/Gemeentenummer#CBS-codering" target="_blank" rel="noopener">CBS codering voor gemeenten</a>, met een extra voorloop nul):<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?types=cs.&#123;Gemeente&#125;&amp;select=afkorting,ictucode" target="_blank">/overheidsorganisatie?types=<abbr title="contains">cs</abbr>.&#123;Gemeente&#125;&amp;<strong>select=afkorting,ictucode</strong></a></code><br>
				Zie ook <a href="{docsBaseUri}#vertical-filtering-columns" target="_blank" rel="noopener">meer documentatie</a> over het filteren van velden. Zo kunnen we het veld <code>afkorting</code> hernoemen naar gemeente door <code>gemeente:afkorting</code> en van het veld <code>ictucode</code> omzetten in een getal (welke geen voorloopnullen heeft) met <code>ictucode::int</code>:<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?types=cs.&#123;Gemeente&#125;&amp;select=gemeente:afkorting,ictucode::int" target="_blank">/overheidsorganisatie?types=cs.&#123;Gemeente&#125;&amp;select=<strong>gemeente:</strong>afkorting,ictucode<strong>::int</strong></a></code>
			</p>
			<p>
				Als je nu oplet zie je dat er {allMunicipalityCount} gemeenten zijn, terwijl dit er {currentMunicipalityCount} zouden moeten zijn. Dit komt omdat er ook gemeenten in staan zoals {notCurrentSample.firsts.join(", ")} en {notCurrentSample.last} welke allen reeds zijn opgeheven. Dit is te zien aan het <code>einddatum</code> veld, voor huidige gemeente moet dit veld niet zijn gevuld, ofwel op <code>null</code> staan:<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?types=cs.&#123;Gemeente&#125;&amp;select=gemeente:afkorting,ictucode::int&amp;einddatum=is.null" target="_blank">/overheidsorganisatie?types=<abbr title="contains">cs</abbr>.&#123;Gemeente&#125;&amp;select=gemeente:afkorting,ictucode::int&amp;<strong>einddatum=is.null</strong></a></code><br>
				Dit is wel een lijst van {currentMunicipalityCount} gemeenten. Misschien wil je de lijst nu nog sorteren, dit kan met <code>order=veldnaam</code> dus:<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?types=cs.&#123;Gemeente&#125;&amp;select=gemeente:afkorting,ictucode::int&amp;einddatum=is.null&amp;order=afkorting" target="_blank">/overheidsorganisatie?types=<abbr title="contains">cs</abbr>.&#123;Gemeente&#125;&amp;select=gemeente:afkorting,ictucode::int&amp;einddatum=is.null&amp;<strong>order=afkorting</strong></a></code>
			</p>
			<p>
				Vervolgens zouden we nog wat contactinformatie kunnen toevoegen bijv. telefoonnummer(s) en internetpagina(s) maar niet de (post)adressen:<br>
				<code><a href="{apiBaseBrowser}/overheidsorganisatie?types=cs.&#123;Gemeente&#125;&amp;einddatum=is.null&amp;order=afkorting&amp;select=gemeente:afkorting,ictucode::int,contact->telefoon,contact->internet" target="_blank">/overheidsorganisatie?types=<abbr title="contains">cs</abbr>.&#123;Gemeente&#125;&amp;einddatum=is.null&amp;order=afkorting&amp;select=gemeente:afkorting,ictucode::int,<strong>contact->telefoon</strong>,<strong>contact->internet</strong></a></code><br>
				Het <code>contact</code>-veld is een JSON veld met een flexibele structuur, zo is het internet en telefoon veld optioneel, en kan het een enkele waarde bevatten of een lijst (array), een waarde kan zowel een simpele tekst bestaan als een <code>&#123;"label": "..", "value": ".."&#125;</code>-object.
			</p>
			<h3 id="example-election">Verkiezing</h3>
			<p>
				Ook hebben we de recente kandidatenlijsten en uitslagen van de Kiesraad ingeladen:<br>
				<code><a href="{apiBaseBrowser}/verkiezing" target="_blank">/verkiezing</a></code><br>
				Voor het voorbeeld kunnen we het beste even een filter maken en &eacute;&eacute;n verkiezing &amp; gemeente bekijken, bijv. {exampleElectionMunicipality} welke voor de gemeenteraadsverkiezingen van 2018 dan de code <code>{exampleElectionCode}</code> heeft.<br>
				<code><a href="{apiBaseBrowser}/verkiezing?code=eq.{exampleElectionCode}" target="_blank">/verkiezing<strong>?code=eq.{exampleElectionCode}</strong></a></code><br>
				Met de API kunnen we ook in &eacute;&eacute;n bevraging gerelateerde data opvragen, zoals bijv. de kieslijsten:<br>
				<code><a href="{apiBaseBrowser}/verkiezing?code=eq.{exampleElectionCode}&select=*,kieslijst(*)" target="_blank">/verkiezing?code=eq.{exampleElectionCode}<strong>&select=*,kieslijst(*)</strong></a></code><br>
				Waar we vervolgens ook de kandidatlijsten aan kunnen koppelen:<br>
				<code><a href="{apiBaseBrowser}/verkiezing?code=eq.{exampleElectionCode}&select=naam,verkiezingsdatum,zetels,kieslijst(lijstnummer,naam,verkozenzetels,kandidaat(kandidaatnummer,voornaam,tussenvoegsel,achternaam,voorkeurstemmen))" target="_blank">/verkiezing?code=eq.{exampleElectionCode}&select=naam,verkiezingsdatum,zetels,kieslijst(lijstnummer,naam,verkozenzetels,<strong>kandidaat(kandidaatnummer,voornaam,tussenvoegsel,achternaam,voorkeurstemmen)</strong>)</a></code>
			</p>

			<div id="openapi" bind:this={swaggerNode}></div>
			<h2 id="changelog">Changelog</h2>
			<h3 id="changelog-v1.1"><code>v1.1</code></h3>
			<p>
				Onder de Kiesraad groep zijn bij <code>verkiezing</code> de volgende velden toegevoegd: <code>voorkeurdrempel</code> (in procenten van <code>kiesdeler = ceil(geldigeStemmen / zetels)</code>), <code>opgeroepen</code>, <code>geldigeStemmen</code>, <code>blanco</code> en <code>ongeldig</code>. Bij <code>kandidaat</code> zijn deze toegevoegd: <code>verkozen</code> (<code>true</code> of <code>NULL</code>), <code>verkozenpositie</code> en <code>voorkeurdrempel</code> (<code>true</code>: <code>voorkeurstemmen &ge; verkiezing.voorkeurdrempel &times; kiesdeler / 100</code>, <code>false</code>: verkozen door lijst of <code>NULL</code>: niet verkozen). De positie kan veranderen als iemand lager op de lijst de <code>voorkeurdrempel</code> heeft behaald, zie ook de uitleg van de Kiesraad over de <a href="https://www.kiesraad.nl/verkiezingen/gemeenteraden/uitslagen/kiesdrempel-kiesdeler-en-voorkeurdrempel" target="_blank" rel="noopener">voorkeurdrempel</a>. De velden zijn niet toegevoegd aan <code>v0</code>.
			</p>
			<h3 id="changelog-v1"><code>v1</code></h3>
			<p>Door de Overheids Almanak wijzigingen in 2.4.10 "meerdere organisatietypes mogelijk per organisatie" moest ook de Allmanak API een nieuwe versie krijgen.</p>
			<ul>
				<li><code>type</code> van enum <code>ootype</code> is hernoemt naar <code>types</code> van enum array <code>ootype[]</code>, zie <a href="api/#upgrade-v0-to-v1">upgrade instructie</a></li>
			</ul>
			<h4>Features:</h4>
			<ul>
				<li>Upgrade van PostgREST 5.2.0 naar 6.0.0 met <a rel="noopener" target="_blank" href="https://github.com/openstate/postgrest/tree/enum-arrays">onze eigen enum array support</a>, de enum array syntax kan mogelijk afwijken van de OpenAPI standaard, zie issue <a rel="noopener" target="_blank" href="https://github.com/PostgREST/postgrest/issues/1353">#1353</a></li>
			</ul>
			<h4>Opgeloste bugs:</h4>
			<ul>
				<li><code>beleidsterreinen</code>, <code>resourceidentifiers</code> en <code>wettelijkevoorschriften</code> zitten niet meer in een dubbele array, maar een enkele</li>
			</ul>
			<h2 id="policy">Deprecation Policy</h2>
			<p>De API zal door dataformaat aanpassingen van de Overheids Almanak soms een update krijgen, brekende updates zullen een nieuwe versie krijgen. Als een oud API endpoint deprecated is, zal de <code><a rel="noopener" target="_blank" href="https://tools.ietf.org/html/draft-dalal-deprecation-header-00">Deprecation</a></code> header worden toegevoegd (tesamen met een <code><a rel="noopener" target="_blank" href="https://tools.ietf.org/html/rfc8594">Sunset</a></code> en successor-version link). Indien mogelijk houden we na een upgrade de oude API nog 6 maanden online met deze headers. Na deze 6 maanden zullen we de HTTP status code wijzigen naar <code>207 Multi-Status</code> en na een maand naar <code>301 Moved Permanently</code> welke we naar de nieuwe API zullen redirecten, waarna we na enige tijd de oude API <code>410 Gone</code> zullen laten retourneren.</p>
			<h3 id="deprecation-v0">Vervallen <code>v0</code></h3>
			<p><code>v0</code> kan nog worden gebruikt, maar deze pakt enkel het eerste type uit de array, wat kan leiden tot onvolledige resultaten.</p>
			<p id="upgrade-v0-to-v1">Upgrades naar <code>v1</code>: waar eerder <code>type=eq.Gemeente</code> werd gebruikt kan nu <code>types=cs.&#123;Gemeente&#125;</code> worden gebruikt.</p>
			<h3>Tijdspad:</h3>
			<ul>
				<li><strong>vrijdag 31 januari 2020</strong> 23:59:59 GMT: de HTTP Status zal op <code>207 Multi-Status</code> worden gezet (buiten de HTTP status zal de API blijven functioneren)</li>
				<li><strong>vrijdag 28 februari 2020</strong> 23:59:59 GMT: de API verwijst d.m.v. HTTP Status <code>301 Moved Permanently</code> naar <code>v1</code> (de <code>v0</code> API zal niet meer te bereiken zijn)</li>
				<li><strong>dinsdag 31 maart 2020</strong> 23:59:59 GMT: de <code>v0</code> API zal antwoorden met HTTP Status <code>410 Gone</code></li>
			</ul>
			<p>Indien er meer formaatswijzigingen komen aan de Overheids Almanak kan het zijn dat het tijdspad wordt ingekort.</p>

		</article>
	</div>
</div>
<style>
	.searchbar {
		background: url(/denhaag-binnenhof.jpg) no-repeat;
		background-size: 225%;
		background-position: center 25%;
		min-height: 400px;
	}
	@media (min-width: 400px) {
		.searchbar {
			background-size: 200%;
		}
	}
	@media (min-width: 500px) {
		.searchbar {
			background-position: center 40%;
			background-size: 175%;
		}
	}
	@media (min-width: 768px) {
		.searchbar {
			background-size: 150%;
		}
	}
	@media (min-width: 1024px) {
		.searchbar {
			background-size: 125%;
		}
	}
	@media (min-width: 1280px) {
		.searchbar {
			background-position: center 42%;
			background-size: cover;
			min-height: 440px;
		}
	}

    :global(body.fontloaded-montserratsemibold) .categorybar, :global(body.fontloaded-montserratsemibold) h2 strong {
        font-family: 'montserratsemibold';
    }
    :global(body.fontloaded-montserratregular) h2 {
        font-family: 'montserratregular';
    }
    :global(.swagger-ui .wrapper) {
    	padding: 0 !important;
    }
    h2 {
        font-size: 2rem;
        font-weight: normal;
    }
    .nowrap {
    	white-space: nowrap;
    }
</style>