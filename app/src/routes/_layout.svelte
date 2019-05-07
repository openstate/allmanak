<script>
	import Nav from '../components/Nav.svelte';
	import Footer from '../components/Footer.svelte';
	import Modal from '../components/Modal.svelte';
	import ReportForm from '../components/ReportForm.svelte';

	import FontFaceObserver from 'fontfaceobserver';
	//import {categoriesApi} from './_categories.json.js';
	import categories from './_categories.json';
	import {apiBaseUri} from '../apibase.js';

	export let segment;
	let showModal = false;

	if (process.browser) {
		['montserratsemibold', 'montserratregular', 'open_sansbold', 'open_sansregular'].forEach(
			fontName => {
				const font = new FontFaceObserver(fontName);
				font.load().then(_ => {
					document.body.classList.add('fontloaded-' + fontName);
				}).catch(e => {
					console.log('Error lazy loading font', fontName, e);
				});
			}
		);
	}

</script>

{#if showModal}
<Modal on:close="{() => showModal = false}" showBackdropClose>
  <ReportForm on:close="{() => showModal = false}" />
</Modal>
{/if}
<Nav {segment} {categories} on:report='{() => showModal = true}'/>

<main>
	<slot></slot>
<!-- 	<svelte:component this={child.component} {...child.props} on:report='{() => showModal = true}'/> -->
</main>

<style>
	main {
		position: relative;
		background-color: white;
		box-sizing: border-box;
		/*max-width: 56em;
		padding: 2em;
		margin: 0 auto;*/
	}
</style>

<Footer {categories} on:report='{() => showModal = true}'/>