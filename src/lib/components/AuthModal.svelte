<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { X, Mail, Lock, User, Github, Chrome, ArrowRight, Loader2, CheckCircle2, AlertCircle } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';

	import { isAuthModalOpen, authModalMode } from '$lib/stores/auth';
	import { invalidateAll } from '$app/navigation';

	let { isOpen = $bindable(false), onClose = () => {} } = $props();

	let mode = $state<'login' | 'signup' | 'success'>('login');

	// Sync store to local state when modal opens
	$effect(() => {
		if (isOpen) {
			mode = $authModalMode as 'login' | 'signup';
		}
	});

	let email = $state('');
	let password = $state('');
	let fullName = $state('');
	let loading = $state(false);
	let error = $state<string | null>(null);

	// Validation helpers
	const isValidEmail = (e: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);
	const isStrongPassword = (p: string) => p.length >= 6;

	async function handleSubmit() {
		error = null;

		// Client-side validation
		if (!isValidEmail(email)) {
			error = 'Please enter a valid email address.';
			return;
		}

		if (mode === 'signup') {
			if (fullName.trim().length < 2) {
				error = 'Please enter your full name.';
				return;
			}
			if (!isStrongPassword(password)) {
				error = 'Password must be at least 6 characters.';
				return;
			}
		}

		loading = true;

		try {
			if (mode === 'signup') {
				const { data, error: signupError } = await supabase.auth.signUp({
					email,
					password,
					options: {
						data: { 
							full_name: fullName,
							username: email.split('@')[0] // Default username
						}
					}
				});
				
				if (signupError) throw signupError;
				
				// Handle email confirmation requirement
				if (data.session === null) {
					mode = 'success';
				} else {
					close();
				}
			} else {
				const { error: loginError } = await supabase.auth.signInWithPassword({
					email,
					password
				});
				if (loginError) throw loginError;
				
				// Fetch profile to check role for redirection
				const { data: { user } } = await supabase.auth.getUser();
				if (user) {
					const { data: profile } = await supabase
						.from('profiles')
						.select('role')
						.eq('id', user.id)
						.single();
					
					if (profile?.role === 'admin') {
						window.location.href = '/admin';
						return;
					}
				}
				
				await invalidateAll();
				close();
			}
		} catch (e: any) {
			console.error('Auth error:', e);
			const message = e.message || '';
			
			if (message.includes('User already registered')) {
				error = 'This email is already registered. Try logging in instead.';
			} else if (message.includes('Invalid login credentials')) {
				error = 'Invalid email or password. Please try again.';
			} else if (message.includes('Email rate limit exceeded')) {
				error = 'Slow down! Too many requests. Please wait a few minutes before trying again or use social login.';
			} else if (message.includes('Database error')) {
				error = 'Service currently unavailable. Please try again later.';
			} else {
				error = message;
			}
		} finally {
			loading = false;
		}
	}

	async function signInWithProvider(provider: 'google' | 'github') {
		error = null;
		loading = true;
		const { error: providerError } = await supabase.auth.signInWithOAuth({
			provider,
			options: {
				redirectTo: window.location.origin
			}
		});
		if (providerError) {
			error = providerError.message;
			loading = false;
		}
	}

	function close() {
		isOpen = false;
		onClose();
		// Reset state
		setTimeout(() => {
			mode = 'login';
			error = null;
			email = '';
			password = '';
			fullName = '';
		}, 300);
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
					{#if mode === 'login'}
						Welcome Back!
					{:else if mode === 'signup'}
						Start Learning
					{:else}
						Almost There!
					{/if}
				</h2>
				<p class="mt-2 text-blue-100">
					{#if mode === 'login'}
						Continue your journey with Code Shiksha
					{:else if mode === 'signup'}
						Create an account to access premium content
					{:else}
						We've sent a confirmation link to your email.
					{/if}
				</p>
			</div>

			<!-- Body -->
			<div class="p-8">
				{#if mode === 'success'}
					<div class="text-center py-10 space-y-6" in:scale>
						<div class="inline-flex h-20 w-20 items-center justify-center rounded-full bg-green-100 text-green-600 shadow-inner">
							<CheckCircle2 size={40} />
						</div>
						<div class="space-y-2">
							<h3 class="text-xl font-bold text-slate-900">Check Your Inbox</h3>
							<p class="text-slate-500 font-medium">
								Please click the link in the email we sent to <strong>{email}</strong> to verify your account.
							</p>
						</div>
						<button
							onclick={close}
							class="w-full py-4 rounded-xl bg-slate-900 text-white font-bold hover:bg-black transition-all"
						>
							Got it, thanks!
						</button>
					</div>
				{:else}
					{#if error}
						<div class="mb-6 flex items-start gap-3 rounded-xl bg-red-50 p-4 text-sm font-medium text-red-600 ring-1 ring-red-100" in:fly={{ y: -10 }}>
							<AlertCircle size={18} class="shrink-0 mt-0.5" />
							<span>{error}</span>
						</div>
					{/if}

					<form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }} class="space-y-4">
						{#if mode === 'signup'}
							<div class="space-y-1">
								<label for="name" class="text-xs font-black uppercase tracking-widest text-slate-400 ml-1">Full Name</label>
								<div class="relative group">
									<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-300 group-focus-within:text-blue-500 transition-colors">
										<User size={18} />
									</div>
									<input
										id="name"
										type="text"
										bind:value={fullName}
										placeholder="e.g. John Doe"
										required={mode === 'signup'}
										class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3.5 pl-11 pr-4 text-sm font-bold placeholder:text-slate-300 placeholder:font-medium focus:border-blue-500 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/10 transition-all shadow-sm"
									/>
								</div>
							</div>
						{/if}

						<div class="space-y-1">
							<label for="email" class="text-xs font-black uppercase tracking-widest text-slate-400 ml-1">Email Address</label>
							<div class="relative group">
								<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-300 group-focus-within:text-blue-500 transition-colors">
									<Mail size={18} />
								</div>
								<input
									id="email"
									type="email"
									bind:value={email}
									placeholder="e.g. name@example.com"
									required
									class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3.5 pl-11 pr-4 text-sm font-bold placeholder:text-slate-300 placeholder:font-medium focus:border-blue-500 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/10 transition-all shadow-sm"
								/>
							</div>
						</div>

						<div class="space-y-1">
							<div class="flex items-center justify-between ml-1">
								<label for="password" class="text-xs font-black uppercase tracking-widest text-slate-400">Password</label>
								{#if mode === 'login'}
									<a href="/auth/forgot" onclick={close} class="text-[10px] font-black text-blue-600 hover:text-blue-700 uppercase tracking-widest">Forgot?</a>
								{/if}
							</div>
							<div class="relative group">
								<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-300 group-focus-within:text-blue-500 transition-colors">
									<Lock size={18} />
								</div>
								<input
									id="password"
									type="password"
									bind:value={password}
									placeholder="••••••••"
									required
									minlength="6"
									class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3.5 pl-11 pr-4 text-sm font-bold placeholder:text-slate-300 placeholder:font-medium focus:border-blue-500 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/10 transition-all shadow-sm"
								/>
							</div>
						</div>

						<div class="pt-2">
							<button
								type="submit"
								disabled={loading}
								class="flex w-full items-center justify-center gap-2 rounded-2xl bg-slate-900 py-4 text-basis font-black text-white shadow-xl shadow-slate-200 transition-all hover:bg-black hover:translate-y-[-2px] active:translate-y-[0px] disabled:opacity-50 disabled:translate-y-0"
							>
								{#if loading}
									<Loader2 size={20} class="animate-spin" />
									PROCESSING...
								{:else}
									{mode === 'login' ? 'SIGN IN' : 'CREATE ACCOUNT'}
									<ArrowRight size={20} />
								{/if}
							</button>
						</div>
					</form>

					<!-- Divider -->
					<div class="my-10 flex items-center gap-4">
						<div class="h-px flex-grow bg-slate-100"></div>
						<span class="text-[10px] font-black uppercase tracking-[0.2em] text-slate-300">Social Login</span>
						<div class="h-px flex-grow bg-slate-100"></div>
					</div>

					<!-- Providers -->
					<div class="grid grid-cols-2 gap-4">
						<button
							onclick={() => signInWithProvider('google')}
							disabled={loading}
							class="flex items-center justify-center gap-2 rounded-2xl border-2 border-slate-50 bg-white py-3 text-sm font-bold text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-100 disabled:opacity-50 shadow-sm"
						>
							<Chrome size={18} />
							Google
						</button>
						<button
							onclick={() => signInWithProvider('github')}
							disabled={loading}
							class="flex items-center justify-center gap-2 rounded-2xl border-2 border-slate-50 bg-white py-3 text-sm font-bold text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-100 disabled:opacity-50 shadow-sm"
						>
							<Github size={18} />
							GitHub
						</button>
					</div>

					<!-- Footer -->
					<p class="mt-10 text-center text-sm font-medium text-slate-500">
						{mode === 'login' ? "Don't have an account?" : "Already have an account?"}
						<button
							onclick={() => (mode = mode === 'login' ? 'signup' : 'login')}
							class="font-black text-blue-600 hover:text-blue-700 ml-1"
						>
							{mode === 'login' ? 'Sign up' : 'Log in'}
						</button>
					</p>
				{/if}
			</div>
		</div>
	</div>
{/if}
