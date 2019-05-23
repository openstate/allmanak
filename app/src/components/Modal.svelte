<script>
	import { createEventDispatcher, onDestroy, onMount } from 'svelte';

	const dispatch = createEventDispatcher();

	const mainDom = process.browser ? document.querySelector('#sapper') : false;
	export let backdropClose = false;
	export let showBackdropClose = false;
	export let noModal = false;
	export let hideClose = false;
	let previousOverflowY;

	onMount(() => {
		previousOverflowY = document.body.style.overflowY || '';
		const x = document.body.offsetWidth;
		document.body.style.overflowY = 'hidden';
		mainDom.style.marginRight = (document.body.offsetWidth - x) + 'px';
	});

	onDestroy(() => {
		document.body.style.overflowY = previousOverflowY;
		if (previousOverflowY === '') {
			mainDom.style.marginRight = 0;
		}
	});
	function close(event) {
		dispatch('close');
	}
</script>

<div class="backdrop" on:click|stopPropagation="{_ => backdropClose ? close() : false}">
	{#if showBackdropClose}<button class="backdropClose" on:click|stopPropagation={close}>Sluiten</button>{/if}
	<div class="padding">
		<div class:modal='{!noModal}' on:click|stopPropagation="{_ => {}}">
			{#if !noModal && !hideClose}<button class="close" on:click|stopPropagation={close}>Sluiten</button>{/if}
			<slot {close}></slot>
		</div>
	</div>
</div>
<!-- <svelte:window on:keydown='pageShortcuts(event)' /> -->
<style>
.backdrop {
	z-index: 10;
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(0,0,0,0.666);
	display: flex;
	align-items: center;
	justify-content: center;
	overflow: auto;
}
.backdropClose {
	position: fixed;
	right: 1em;
	top: 1em;
	text-indent: -99999px;
	background: transparent url('data:image/svg+xml;utf8,<svg fill="%23FFF" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/><path d="M0 0h24v24H0z" fill="none"/></svg>') center no-repeat; /* Material icon 'close' */
	width: 24px;
	height: 24px;
	padding: 0.25rem;
	border: none;
	-webkit-appearance: none;
	color: #FFF;
	cursor: pointer;
	font-weight: bold;
}
.backdropClose:hover {

}
.padding {
	margin: auto;
	position: relative;
	max-width: 32em;
	padding: 2rem;
}
.close {
	text-indent: -99999px;
	position: absolute;
	top: 2.5rem;
	right: 2.5rem;
	background: transparent url('data:image/svg+xml;utf8,<svg fill="%23000" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/><path d="M0 0h24v24H0z" fill="none"/></svg>') center no-repeat; /* Material icon 'close' */
	width: 24px;
	height: 24px;
	padding: 0.25rem;
	border: none;
	-webkit-appearance: none;
	color: #000;
	cursor: pointer;
	font-weight: bold;
}
.close:hover {
	background: #000 url('data:image/svg+xml;utf8,<svg fill="%23FFF" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/><path d="M0 0h24v24H0z" fill="none"/></svg>') center no-repeat; /* Material icon 'close' */
	color: #FFF;
}
.modal {
	padding: 1rem;
	background: #FFF;
	min-height: 4rem;
	min-width: 8rem;
}
</style>