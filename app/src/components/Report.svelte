<script>
	import { showReportModal } from '../stores.js';
</script>

<div class="reporterrorbox">
	<p>We horen het graag als onze informatie niet correct of onvolledig is.</p>
	<button on:click='{() => $showReportModal=true}'>Meld een fout</button>
</div>

<style>
	.reporterrorbox {
		border: 1px #f2f2f2 solid;
		padding: 0.5rem 1rem;
		text-align: left;
		font-weight: 600;
	}
	.reporterrorbox button {
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