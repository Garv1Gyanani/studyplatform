<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import AuthModal from '$lib/components/AuthModal.svelte';
	import { isAuthModalOpen } from '$lib/stores/auth';

	let { children } = $props();
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

<AuthModal bind:isOpen={$isAuthModalOpen} />

{@render children()}
