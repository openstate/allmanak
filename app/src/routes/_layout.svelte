<script>
	import Nav from '../components/Nav.svelte';
	import Footer from '../components/Footer.svelte';
	import Modal from '../components/Modal.svelte';
	import ReportForm from '../components/ReportForm.svelte';

	import FontFaceObserver from 'fontfaceobserver';
	import {apiBaseUri} from '../apibase.js';
	import { showReportModal } from '../stores.js';

	export let segment;

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

{#if $showReportModal}
<Modal on:close="{() => $showReportModal = false}" let:close showBackdropClose>
  <ReportForm {close} />
</Modal>
{/if}
<Nav {segment}/>

<main>
	<slot></slot>
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

<Footer />