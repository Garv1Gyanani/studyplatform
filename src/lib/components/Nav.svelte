<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { 
		Search, 
		Bell, 
		Menu, 
		X, 
		User, 
		LogOut, 
		LayoutDashboard, 
		Settings, 
		Star,
		Zap,
		ChevronRight,
		Loader2,
		ShieldCheck,
		FileText,
		FileQuestion,
		BookOpen,
		Sparkles
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { onMount } from 'svelte';
	import { openLogin, openSignup } from '$lib/stores/auth';
	import { fade, fly, slide } from 'svelte/transition';
	import { page } from '$app/state';

	let isMenuOpen = $state(false);
	let isProfileOpen = $state(false);
	let isSearchOpen = $state(false);
	let user = $state<any>(null);
	let profile = $state<any>(null);
	let searchQuery = $state('');
	let searchResults = $state<any[]>([]);
	let searching = $state(false);

	onMount(() => {
		supabase.auth.getSession().then(({ data: { session } }) => {
			user = session?.user ?? null;
			if (user) fetchProfile();
		});

		const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
			user = session?.user ?? null;
			if (user) fetchProfile();
			else profile = null;
		});

		return () => subscription.unsubscribe();
	});

	async function fetchProfile() {
		const { data } = await supabase.from('profiles').select('*').eq('id', user.id).single();
		profile = data;
	}

	async function handleSearch() {
		if (searchQuery.length < 2) {
			searchResults = [];
			return;
		}
		searching = true;
		
		const [vRes, bRes, qRes, bkRes] = await Promise.all([
			supabase.from('videos').select('id, title').ilike('title', `%${searchQuery}%`).limit(3),
			supabase.from('blogs').select('id, slug, title').ilike('title', `%${searchQuery}%`).limit(3),
			supabase.from('quizzes').select('id, title').ilike('title', `%${searchQuery}%`).limit(3),
			supabase.from('books').select('id, title').ilike('title', `%${searchQuery}%`).limit(3)
		]);
		
		searchResults = [
			...(vRes.data?.map(v => ({ id: v.id, title: v.title, type: 'Video', url: `/courses/${v.id}` })) || []),
			...(bRes.data?.map(b => ({ id: b.slug, title: b.title, type: 'Blog', url: `/blogs/${b.slug}` })) || []),
			...(qRes.data?.map(q => ({ id: q.id, title: q.title, type: 'Quiz', url: `/quizzes/${q.id}` })) || []),
			...(bkRes.data?.map(bk => ({ id: bk.id, title: bk.title, type: 'Book', url: `/books` })) || [])
		];
		searching = false;
	}

	const navItems = [
		{ name: 'Courses', href: '/courses' },
		{ name: 'Quizzes', href: '/quizzes' },
		{ name: 'Leaderboard', href: '/leaderboard' },
		{ name: 'Blogs', href: '/blogs' },
		{ name: 'Games', href: '/games' },
		{ name: 'AI Hub', href: '/ai-hub' },
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
						<span class="text-xl font-bold">P</span>
					</div>
					<span class="text-xl font-bold tracking-tight text-slate-900">Programming<span class="text-blue-600">Tails</span></span>
				</a>

				<!-- Desktop Navigation -->
				<div class="hidden md:ml-8 md:flex md:items-center md:gap-1">
					{#each navItems as item}
						{@const isActive = page.url.pathname === item.href}
						<a
							href={item.href}
							class={cn(
								"relative rounded-lg px-4 py-2 text-sm font-bold transition-all",
								isActive 
									? "text-blue-600 bg-blue-50" 
									: "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
							)}
						>
							{item.name}
							{#if isActive}
								<span class="absolute -bottom-[1px] left-4 right-4 h-0.5 bg-blue-600 rounded-full" in:fade></span>
							{/if}
						</a>
					{/each}
				</div>
			</div>

			<!-- Right side: Search, Auth, User -->
			<div class="flex items-center gap-4">
				<button 
					onclick={() => isSearchOpen = true}
					class="hidden items-center gap-2 rounded-2xl border border-slate-100 bg-slate-50 px-4 py-2 text-sm font-bold text-slate-400 transition-all hover:bg-white hover:border-slate-200 lg:flex"
				>
					<Search size={16} />
					<span>Search...</span>
					<kbd class="ml-2 rounded bg-white px-1.5 py-0.5 text-[10px] text-slate-400 border border-slate-100 uppercase">⌘K</kbd>
				</button>

				{#if user}
					<div class="hidden items-center gap-2 rounded-full bg-slate-100 px-3 py-1.5 sm:flex">
						<Star size={14} class="text-amber-500" fill="currentColor" />
						<span class="text-xs font-black text-slate-900">{profile?.points || 0} XP</span>
					</div>

					<button class="relative rounded-full p-2 text-slate-500 transition-colors hover:bg-slate-100">
						<Bell size={20} />
						<span class="absolute right-1.5 top-1.5 h-2 w-2 rounded-full bg-blue-600 ring-2 ring-white"></span>
					</button>

					<div class="relative">
						<button
							onclick={() => (isProfileOpen = !isProfileOpen)}
							class="flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 bg-slate-50 p-1 ring-2 ring-transparent transition-all hover:ring-blue-100"
						>
							{#if profile?.avatar_url}
								<img src={profile.avatar_url} alt="Avatar" class="h-full w-full rounded-full object-cover" />
							{:else}
								<div class="h-full w-full rounded-full bg-blue-50 flex items-center justify-center text-blue-600 font-bold">
									{user.email.charAt(0).toUpperCase()}
								</div>
							{/if}
						</button>

						{#if isProfileOpen}
							<div 
								transition:fly={{ y: 10, duration: 150 }}
								class="absolute right-0 mt-3 w-64 origin-top-right rounded-[32px] border border-slate-100 bg-white p-2 shadow-2xl shadow-slate-200 focus:outline-none"
							>
								<div class="px-6 py-5">
									<p class="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-1">Signed in as</p>
									<p class="truncate text-basis font-black text-slate-900">{profile?.username || user.email.split('@')[0]}</p>
								</div>
								<div class="h-px bg-slate-50 mx-2"></div>
								<div class="p-2 space-y-1">
									{#if profile?.role === 'admin'}
										<a href="/admin" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-indigo-600 bg-indigo-50 transition-all hover:bg-indigo-100">
											<ShieldCheck size={18} /> Admin Center
										</a>
									{/if}
									<a href="/dashboard" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-slate-600 transition-all hover:bg-blue-50 hover:text-blue-600">
										<LayoutDashboard size={18} /> Dashboard
									</a>
									<a href="/ai-hub" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-indigo-600 bg-indigo-50/50 transition-all hover:bg-indigo-100">
										<Sparkles size={18} /> AI Study Hub
									</a>
									<a href="/bookmarks" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-slate-600 transition-all hover:bg-blue-50 hover:text-blue-600">
										<Zap size={18} /> Your Library
									</a>
									<a href="/settings" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-slate-600 transition-all hover:bg-blue-50 hover:text-blue-600">
										<Settings size={18} /> Settings
									</a>
								</div>
								<div class="h-px bg-slate-50 mx-2"></div>
								<div class="p-2">
									<button
										onclick={handleLogout}
										class="flex w-full items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-red-500 transition-all hover:bg-red-50"
									>
										<LogOut size={18} /> Sign out
									</button>
								</div>
							</div>
						{/if}
					</div>
				{:else}
					<div class="hidden items-center gap-3 sm:flex">
						<button 
							onclick={openLogin}
							class="text-sm font-black text-slate-600 hover:text-slate-900 px-4 py-2"
						>
							Sign in
						</button>
						<button
							onclick={openSignup}
							class="inline-flex items-center justify-center rounded-2xl bg-blue-600 px-6 py-3 text-sm font-black text-white shadow-xl shadow-blue-200 transition-all hover:bg-blue-700 hover:scale-105 active:scale-95"
						>
							Get Started
						</button>
					</div>
				{/if}

				<!-- Mobile menu button -->
				<button
					onclick={() => (isMenuOpen = !isMenuOpen)}
					class="inline-flex items-center justify-center rounded-2xl p-2 text-slate-500 hover:bg-slate-100 md:hidden transition-all"
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
		<div class="border-t border-slate-100 bg-white p-6 md:hidden" transition:slide>
			<div class="space-y-2">
				{#each navItems as item}
					<a
						href={item.href}
						class="block rounded-2xl px-5 py-4 text-basis font-black text-slate-700 transition-all hover:bg-slate-50 hover:text-blue-600"
						onclick={() => (isMenuOpen = false)}
					>
						{item.name}
					</a>
				{/each}
			</div>
			{#if !user}
				<div class="mt-6 flex flex-col gap-3 pt-6 border-t border-slate-100">
					<button 
						onclick={() => { isMenuOpen = false; openLogin(); }}
						class="flex h-14 items-center justify-center rounded-2xl bg-slate-50 text-sm font-black text-slate-700 hover:bg-slate-100 transition-all"
					>
						Login
					</button>
					<button 
						onclick={() => { isMenuOpen = false; openSignup(); }}
						class="flex h-14 items-center justify-center rounded-2xl bg-blue-600 text-sm font-black text-white shadow-xl shadow-blue-200"
					>
						Create Account
					</button>
				</div>
			{/if}
		</div>
	{/if}
</nav>

<!-- Global Search Overlay -->
{#if isSearchOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div 
		class="fixed inset-0 z-[100] bg-slate-900/40 backdrop-blur-sm flex items-start justify-center p-4 pt-20"
		onclick={() => isSearchOpen = false}
		transition:fade={{ duration: 150 }}
	>
		<div 
			class="w-full max-w-2xl bg-white rounded-[40px] shadow-2xl overflow-hidden" 
			onclick={e => e.stopPropagation()}
			transition:fly={{ y: -20, duration: 300 }}
		>
			<div class="relative p-6 border-b border-slate-100">
				<Search size={24} class="absolute left-10 top-1/2 -translate-y-1/2 text-slate-400" />
				<input 
					bind:value={searchQuery}
					oninput={handleSearch}
					placeholder="Search for courses, quizzes, or blogs..." 
					class="w-full pl-16 pr-12 py-5 text-xl font-bold text-slate-900 outline-none placeholder-slate-300"
					autofocus
				/>
				<button 
					onclick={() => isSearchOpen = false}
					class="absolute right-10 top-1/2 -translate-y-1/2 p-2 rounded-xl bg-slate-50 text-slate-400 hover:text-slate-900"
				>
					<X size={20} />
				</button>
			</div>
			
			<div class="max-h-[60vh] overflow-y-auto p-4">
				{#if searching}
					<div class="flex items-center justify-center py-12">
						<Loader2 size={32} class="animate-spin text-blue-600" />
					</div>
				{:else if searchResults.length > 0}
					<div class="space-y-2">
						{#each searchResults as result}
							<a 
								href={result.url}
								onclick={() => isSearchOpen = false} 
								class="w-full p-4 flex items-center justify-between rounded-3xl hover:bg-slate-50 transition-all text-left"
							>
								<div class="flex items-center gap-4">
									<div class="h-10 w-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
										{#if result.type === 'Video'}
											<Zap size={20} />
										{:else if result.type === 'Blog'}
											<FileText size={20} />
										{:else if result.type === 'Quiz'}
											<FileQuestion size={20} />
										{:else}
											<BookOpen size={20} />
										{/if}
									</div>
									<div>
										<p class="font-black text-slate-900 line-clamp-1">{result.title}</p>
										<span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">{result.type}</span>
									</div>
								</div>
								<ChevronRight size={20} class="text-slate-300" />
							</a>
						{/each}
					</div>
				{:else if searchQuery.length > 1}
					<div class="py-20 text-center">
						<p class="text-slate-400 font-bold">No results found for "{searchQuery}"</p>
					</div>
				{:else}
					<div class="p-8">
						<p class="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-6 px-4 text-center">Popular Searches</p>
						<div class="flex flex-wrap gap-2 justify-center">
							{#each ['React Masterclass', 'Python Basics', 'Quantum Physics', 'Creative Writing', 'Web Design'] as tag}
								<button 
									onclick={() => { searchQuery = tag; handleSearch(); }}
									class="px-4 py-2 rounded-xl bg-slate-50 border border-slate-100 text-sm font-bold text-slate-600 hover:bg-white hover:border-blue-600 hover:text-blue-600 transition-all"
								>
									{tag}
								</button>
							{/each}
						</div>
					</div>
				{/if}
			</div>
		</div>
	</div>
{/if}
