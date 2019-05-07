<script>
	import {urlname} from '../utils.js';

	export let id;
	export let naam;
	export let partij = null;
	export let afkorting = null;
	export let functie = null;
	export let type = null;
	export let plaats = null;
	export let path = null;
</script>

<div><a href="{id}/{urlname(naam)}">
	<h6>{naam} {#if partij}({partij}){/if}</h6>
	{afkorting || functie || type}<br>
	<!--{plaats || ''}-->
	{(path || []).join(" > ")}<br>
</a></div>

<style>
div {
	margin: 0;
	/*margin-bottom: 1rem;*/
	padding: 0;
	height: 78px;
	overflow: hidden;
	box-sizing: border-box;
}
div > a {
	display: block;
	text-decoration: none;
}
div > a > h6 {
	font-size: 1rem;
	margin-bottom: 0;
	font-weight: bold;
}
</style>