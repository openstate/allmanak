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
	<link rel="stylesheet" type="text/css" href="/swagger-ui.css" >
	<script src="/swagger-ui-bundle.js" on:load={() => swaggerDep1Loaded = true}></script>
	<script src="/swagger-ui-standalone-preset.js" on:load={() => swaggerDep2Loaded = true}></script>
</svelte:head>
<div class="searchbar">
</div>
<div id="over">
	<div class="container">
		<article>
			<h2>API</h2>
			<p>De databron wie wij gebruiken is <a rel="noopener" target="_blank" href="http://almanak.overheid.nl/archive/">Overheidsorganisaties XML</a>, deze XML converteren en importeren wij in een database die we met een REST API (PostREST) toegankelijk stellen. De API kan zowel JSON als CSV terug sturen. Let op, met PostgREST zijn database intensieve queries te maken, daarom hebben we de query limiet op tien seconden gezet.</p>
			<p>De API heeft vele endpoints maar de overheidsorganisatie is de interessante, gezien alle objecten een overheidsorganisatie-object zijn, de andere endpoints zijn voor de onderlinge relaties, maar deze kunnen ook via PostgREST <a target="_blank" rel="noopener" href="https://postgrest.org/en/v5.2/api.html#resource-embedding">resource embedding</a> tot op zekere hoogte worden meegenomen in de overheidsorganisatie-call.
			<div bind:this={swaggerNode}></div>
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
        margin-bottom: 2rem;
    }
</style>