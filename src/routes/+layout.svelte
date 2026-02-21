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
		if (authParam === 'login' || authParam === 'signup') {
			$authModalMode = authParam;
			$isAuthModalOpen = true;
		}
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>EduPlatform - Learn Smarter, Faster</title>
</svelte:head>

<AuthModal bind:isOpen={$isAuthModalOpen} />

{@render children()}
