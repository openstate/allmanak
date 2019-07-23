<script>
	import {apiBaseUri} from '../apibase.js';

	let swaggerNode, swaggerDep1Loaded, swaggerDep2Loaded;
	$: {
		if (swaggerDep1Loaded && swaggerDep2Loaded) {
			SwaggerUIBundle({
				domNode: swaggerNode,
				// deepLinking: true,
				presets: [
				  SwaggerUIBundle.presets.apis,
				  SwaggerUIStandalonePreset
				],
				plugins: [
				  SwaggerUIBundle.plugins.DownloadUrl
				],
				layout: "BaseLayout",
				url: `${apiBaseUri}/`,
				validatorUrl: null,
			});
		}
	}
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
			<p>De databron wie wij gebruiken is <a rel="noopener" target="_blank" href="http://almanak.overheid.nl/archive/">Overheidsorganisaties XML</a>, deze XML converteren en importeren wij in een database die we met een REST API (PostREST) toegankelijk stellen. De API kan zowel JSON als CSV terug sturen. Let op, met PostgREST zijn database intensieve queries te maken, daarom hebben we de query limiet op tien seconden gezet.</p>
			<p>De API heeft vele endpoints maar de overheidsorganisatie is de interessante, gezien alle objecten een overheidsorganisatie-object zijn, de andere endpoints zijn voor de onderlinge relaties, maar deze kunnen ook via PostgREST <a target="_blank" rel="noopener" href="https://postgrest.org/en/v5.2/api.html#resource-embedding">resource embedding</a> tot op zekere hoogte worden meegenomen in de overheidsorganisatie-call.</p>
			<p>Zie onderaan deze pagina de <a href="api/#changelog">changelog</a> en <a href="api/#upgrade-v0-to-v1">upgrade instructie vanaf <code>v0</code></a>. Voor meer informatie over het tijdspad van versie upgrades van de API zie de <a href="api/#policy">deprecation policy</a>.</p>
			<div id="openapi" bind:this={swaggerNode}></div>
			<h2 id="changelog">Changelog</h2>
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
</style>