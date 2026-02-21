<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { X, Mail, Lock, User, Github, Chrome, ArrowRight, Loader2 } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let { isOpen = $bindable(false), onClose = () => {} } = $props();

	let mode = $state<'login' | 'signup'>('login');
	let email = $state('');
	let password = $state('');
	let fullName = $state('');
	let loading = $state(false);
	let error = $state<string | null>(null);

	async function handleSubmit() {
		loading = true;
		error = null;

		try {
			if (mode === 'signup') {
				const { error: signupError } = await supabase.auth.signUp({
					email,
					password,
					options: {
						data: { full_name: fullName }
					}
				});
				if (signupError) throw signupError;
				alert('Check your email for the confirmation link!');
			} else {
				const { error: loginError } = await supabase.auth.signInWithPassword({
					email,
					password
				});
				if (loginError) throw loginError;
			}
			isOpen = false;
			onClose();
		} catch (e: any) {
			error = e.message;
		} finally {
			loading = false;
		}
	}

	async function signInWithProvider(provider: 'google' | 'github') {
		const { error } = await supabase.auth.signInWithOAuth({
			provider,
			options: {
				redirectTo: window.location.origin
			}
		});
		if (error) alert(error.message);
	}

	function close() {
		isOpen = false;
		onClose();
	}
</script>

{#if isOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div
		transition:fade={{ duration: 200 }}
		class="fixed inset-0 z-[100] flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={close}
	>
		<div
			transition:fly={{ y: 20, duration: 300 }}
			class="w-full max-w-md overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-slate-900/5"
			onclick={(e) => e.stopPropagation()}
		>
			<!-- Header -->
			<div class="relative bg-gradient-to-br from-blue-600 to-indigo-700 px-8 py-10 text-white">
				<button
					onclick={close}
					class="absolute right-4 top-4 rounded-full bg-white/10 p-2 text-white/80 transition-colors hover:bg-white/20 hover:text-white"
				>
					<X size={20} />
				</button>
				<h2 class="text-3xl font-bold tracking-tight">
					{mode === 'login' ? 'Welcome Back!' : 'Start Learning'}
				</h2>
				<p class="mt-2 text-blue-100">
					{mode === 'login' ? 'Continue your journey with EduPlatform' : 'Create an account to access premium content'}
				</p>
			</div>

			<!-- Body -->
			<div class="p-8">
				{#if error}
					<div class="mb-6 rounded-xl bg-red-50 p-4 text-sm font-medium text-red-600 ring-1 ring-red-100">
						{error}
					</div>
				{/if}

				<form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }} class="space-y-4">
					{#if mode === 'signup'}
						<div class="space-y-1">
							<label for="name" class="text-xs font-bold uppercase tracking-wider text-slate-500">Full Name</label>
							<div class="relative">
								<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-400">
									<User size={18} />
								</div>
								<input
									id="name"
									type="text"
									bind:value={fullName}
									placeholder="John Doe"
									required
									class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3 pl-11 pr-4 text-sm font-medium focus:border-blue-500 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/10"
								/>
							</div>
						</div>
					{/if}

					<div class="space-y-1">
						<label for="email" class="text-xs font-bold uppercase tracking-wider text-slate-500">Email Address</label>
						<div class="relative">
							<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-400">
								<Mail size={18} />
							</div>
							<input
								id="email"
								type="email"
								bind:value={email}
								placeholder="name@example.com"
								required
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3 pl-11 pr-4 text-sm font-medium focus:border-blue-500 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/10"
							/>
						</div>
					</div>

					<div class="space-y-1">
						<div class="flex items-center justify-between">
							<label for="password" class="text-xs font-bold uppercase tracking-wider text-slate-500">Password</label>
							{#if mode === 'login'}
								<a href="/auth/forgot" class="text-xs font-bold text-blue-600 hover:text-blue-700">Forgot?</a>
							{/if}
						</div>
						<div class="relative">
							<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-400">
								<Lock size={18} />
							</div>
							<input
								id="password"
								type="password"
								bind:value={password}
								placeholder="••••••••"
								required
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3 pl-11 pr-4 text-sm font-medium focus:border-blue-500 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/10"
							/>
						</div>
					</div>

					<button
						type="submit"
						disabled={loading}
						class="flex w-full items-center justify-center gap-2 rounded-xl bg-blue-600 py-3.5 text-basis font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 disabled:opacity-70"
					>
						{#if loading}
							<Loader2 size={20} class="animate-spin" />
							Processing...
						{:else}
							{mode === 'login' ? 'Sign In' : 'Create Account'}
							<ArrowRight size={20} />
						{/if}
					</button>
				</form>

				<!-- Divider -->
				<div class="my-8 flex items-center gap-4">
					<div class="h-px flex-grow bg-slate-100"></div>
					<span class="text-xs font-bold uppercase tracking-widest text-slate-400">OR CONTINUE WITH</span>
					<div class="h-px flex-grow bg-slate-100"></div>
				</div>

				<!-- Providers -->
				<div class="grid grid-cols-2 gap-4">
					<button
						onclick={() => signInWithProvider('google')}
						class="flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white py-3 text-sm font-bold text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-300"
					>
						<Chrome size={18} />
						Google
					</button>
					<button
						onclick={() => signInWithProvider('github')}
						class="flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white py-3 text-sm font-bold text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-300"
					>
						<Github size={18} />
						GitHub
					</button>
				</div>

				<!-- Footer -->
				<p class="mt-8 text-center text-sm font-medium text-slate-500">
					{mode === 'login' ? "Don't have an account?" : "Already have an account?"}
					<button
						onclick={() => (mode = mode === 'login' ? 'signup' : 'login')}
						class="font-bold text-blue-600 hover:text-blue-700"
					>
						{mode === 'login' ? 'Sign up' : 'Log in'}
					</button>
				</p>
			</div>
		</div>
	</div>
{/if}
