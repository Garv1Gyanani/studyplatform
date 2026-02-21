<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { Search, Bell, Menu, X, User, LogOut, LayoutDashboard, Settings } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { onMount } from 'svelte';
	import { openLogin, openSignup } from '$lib/stores/auth';

	let isMenuOpen = $state(false);
	let isProfileOpen = $state(false);
	let user = $state<any>(null);

	onMount(() => {
		supabase.auth.getSession().then(({ data: { session } }) => {
			user = session?.user ?? null;
		});

		const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
			user = session?.user ?? null;
		});

		return () => subscription.unsubscribe();
	});

	const navItems = [
		{ name: 'Courses', href: '/courses' },
		{ name: 'Quizzes', href: '/quizzes' },
		{ name: 'Leaderboard', href: '/leaderboard' },
		{ name: 'Blogs', href: '/blogs' },
		{ name: 'Games', href: '/games' },
	];

	async function handleLogout() {
		await supabase.auth.signOut();
		window.location.reload();
	}
</script>

<nav class="sticky top-0 z-50 w-full border-b border-slate-200 bg-white/80 backdrop-blur-md">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="flex h-16 items-center justify-between">
			<!-- Logo -->
			<div class="flex items-center gap-2">
				<a href="/" class="flex items-center gap-2 transition-transform hover:scale-105 active:scale-95">
					<div class="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-200">
						<span class="text-xl font-bold">E</span>
					</div>
					<span class="text-xl font-bold tracking-tight text-slate-900">Edu<span class="text-blue-600">Platform</span></span>
				</a>

				<!-- Desktop Navigation -->
				<div class="hidden md:ml-8 md:flex md:items-center md:gap-1">
					{#each navItems as item}
						<a
							href={item.href}
							class="rounded-lg px-4 py-2 text-sm font-medium text-slate-600 transition-colors hover:bg-slate-50 hover:text-blue-600"
						>
							{item.name}
						</a>
					{/each}
				</div>
			</div>

			<!-- Right side: Search, Auth, User -->
			<div class="flex items-center gap-4">
				<button class="hidden rounded-full p-2 text-slate-500 transition-colors hover:bg-slate-100 lg:block">
					<Search size={20} />
				</button>

				{#if user}
					<button class="rounded-full p-2 text-slate-500 transition-colors hover:bg-slate-100">
						<Bell size={20} />
					</button>

					<div class="relative">
						<button
							onclick={() => (isProfileOpen = !isProfileOpen)}
							class="flex h-9 w-9 items-center justify-center rounded-full border border-slate-200 bg-slate-50 p-1 ring-2 ring-transparent transition-all hover:ring-blue-100"
						>
							{#if user.user_metadata?.avatar_url}
								<img src={user.user_metadata.avatar_url} alt="Avatar" class="h-full w-full rounded-full object-cover" />
							{:else}
								<User size={20} class="text-slate-500" />
							{/if}
						</button>

						{#if isProfileOpen}
							<div class="absolute right-0 mt-2 w-56 origin-top-right rounded-2xl border border-slate-200 bg-white p-2 shadow-xl shadow-slate-200/50 ring-1 ring-black ring-opacity-5 focus:outline-none">
								<div class="px-4 py-3">
									<p class="text-xs font-medium text-slate-500">Signed in as</p>
									<p class="truncate text-sm font-semibold text-slate-900">{user.email}</p>
								</div>
								<div class="h-px bg-slate-100 my-1"></div>
								<a href="/dashboard" class="flex items-center gap-2 rounded-lg px-4 py-2 text-sm text-slate-700 transition-colors hover:bg-slate-50 hover:text-blue-600">
									<LayoutDashboard size={16} />
									Dashboard
								</a>
								<a href="/settings" class="flex items-center gap-2 rounded-lg px-4 py-2 text-sm text-slate-700 transition-colors hover:bg-slate-50 hover:text-blue-600">
									<Settings size={16} />
									Settings
								</a>
								<div class="h-px bg-slate-100 my-1"></div>
								<button
									onclick={handleLogout}
									class="flex w-full items-center gap-2 rounded-lg px-4 py-2 text-sm text-red-600 transition-colors hover:bg-red-50"
								>
									<LogOut size={16} />
									Sign out
								</button>
							</div>
						{/if}
					</div>
				{:else}
					<div class="hidden items-center gap-3 sm:flex">
						<button 
							onclick={openLogin}
							class="text-sm font-semibold text-slate-600 hover:text-slate-900"
						>
							Sign in
						</button>
						<button
							onclick={openSignup}
							class="inline-flex items-center justify-center rounded-xl bg-blue-600 px-5 py-2.5 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 hover:shadow-blue-300 active:scale-95"
						>
							Get Started
						</button>
					</div>
				{/if}

				<!-- Mobile menu button -->
				<button
					onclick={() => (isMenuOpen = !isMenuOpen)}
					class="inline-flex items-center justify-center rounded-lg p-2 text-slate-500 hover:bg-slate-100 md:hidden"
				>
					{#if isMenuOpen}
						<X size={24} />
					{:else}
						<Menu size={24} />
					{/if}
				</button>
			</div>
		</div>
	</div>

	<!-- Mobile Navigation -->
	{#if isMenuOpen}
		<div class="border-t border-slate-100 bg-white p-4 md:hidden">
			<div class="space-y-1">
				{#each navItems as item}
					<a
						href={item.href}
						class="block rounded-xl px-4 py-3 text-base font-semibold text-slate-700 transition-colors hover:bg-slate-50 hover:text-blue-600"
						onclick={() => (isMenuOpen = false)}
					>
						{item.name}
					</a>
				{/each}
			</div>
			{#if !user}
				<div class="mt-4 flex flex-col gap-2 pt-4 border-t border-slate-100">
					<button 
						onclick={() => { isMenuOpen = false; openLogin(); }}
						class="flex h-12 items-center justify-center rounded-xl bg-slate-50 text-sm font-bold text-slate-700"
					>
						Login
					</button>
					<button 
						onclick={() => { isMenuOpen = false; openSignup(); }}
						class="flex h-12 items-center justify-center rounded-xl bg-blue-600 text-sm font-bold text-white shadow-lg shadow-blue-200"
					>
						Create Account
					</button>
				</div>
			{/if}
		</div>
	{/if}
</nav>
