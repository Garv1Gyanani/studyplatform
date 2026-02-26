<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import AuthModal from '$lib/components/AuthModal.svelte';
	import { isAuthModalOpen, authModalMode } from '$lib/stores/auth';
	import { onMount } from 'svelte';
	import { page } from '$app/state';

	let { children } = $props();

	onMount(() => {
		const authParam = page.url.searchParams.get('auth');
		if ((authParam === 'login' || authParam === 'signup') && !page.data.session) {
			$authModalMode = authParam;
			$isAuthModalOpen = true;
			
			// Clear the parameter from the URL without reloading
			const url = new URL(window.location.href);
			url.searchParams.delete('auth');
			window.history.replaceState({}, '', url);
		}
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>Programming Tails - Learn Smarter, Faster</title>
</svelte:head>

<AuthModal bind:isOpen={$isAuthModalOpen} />

{@render children()}
