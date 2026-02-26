<script lang="ts">
	import { page } from '$app/state';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Clock, 
		Calendar, 
		User, 
		ArrowLeft, 
		Share2, 
		Bookmark, 
		Loader2,
		Facebook,
		Twitter,
		Linkedin,
		ChevronRight,
        BookOpen,
        ArrowUpRight
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';
	import { openLogin } from '$lib/stores/auth';

	let slug = page.params.slug;
	let blog = $state<any>(null);
	let loading = $state(true);
	let user = $state<any>(null);
	let isBookmarked = $state(false);

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		user = sessionData.session?.user;

		const { data } = await supabase
			.from('blogs')
			.select('*, profiles(username, avatar_url)')
			.eq('slug', slug)
			.single();
		
		blog = data;

		if (user && data) {
			const { data: bMark } = await supabase
				.from('bookmarks')
				.select('*')
				.eq('user_id', user.id)
				.eq('content_id', data.id)
				.single();
			isBookmarked = !!bMark;
		}

		loading = false;
	});

	async function toggleBookmark() {
		if (!user) return openLogin();
		if (isBookmarked) {
			await supabase.from('bookmarks').delete().eq('user_id', user.id).eq('content_id', blog.id);
			isBookmarked = false;
		} else {
			await supabase.from('bookmarks').insert({ user_id: user.id, content_type: 'blog', content_id: blog.id });
			isBookmarked = true;
		}
	}
</script>

<div class="min-h-screen bg-white">
	{#if loading}
		<div class="flex h-[80vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if blog}
		<!-- Article Header -->
		<header class="relative py-20 bg-slate-50 border-b border-slate-100 overflow-hidden">
			<div class="absolute inset-0 bg-grid-slate-200 [mask-image:linear-gradient(0deg,#fff,rgba(255,255,255,0.6))]"></div>
			<div class="max-w-4xl mx-auto px-6 relative z-10 space-y-8">
				<a href="/blogs" class="inline-flex items-center gap-2 text-slate-500 hover:text-slate-900 font-bold text-sm mb-4 group">
					<ArrowLeft size={18} class="transition-transform group-hover:-translate-x-1" /> Back to Journal
				</a>

				<div class="space-y-6">
					<div class="flex items-center gap-4">
						<span class="px-3 py-1 bg-blue-600 text-[10px] font-black uppercase tracking-widest text-white rounded-lg">Pedagogy</span>
						<div class="flex items-center gap-4 text-xs font-bold text-slate-400">
							<div class="flex items-center gap-1.5"><Calendar size={14} /> {new Date(blog.published_at).toLocaleDateString()}</div>
							<div class="flex items-center gap-1.5"><Clock size={14} /> 6m read</div>
						</div>
					</div>
					<h1 class="text-5xl sm:text-6xl font-black text-slate-900 tracking-tight leading-tight">
						{blog.title}
					</h1>
					<p class="text-xl text-slate-500 font-medium leading-relaxed max-w-3xl">
						{blog.excerpt || 'An in-depth exploration of the methodologies and outcomes of our latest educational research.'}
					</p>
				</div>

				<div class="pt-10 flex items-center justify-between border-t border-slate-200">
					<div class="flex items-center gap-4">
						<div class="h-14 w-14 rounded-2xl bg-slate-200 overflow-hidden shadow-lg shadow-slate-200">
							{#if blog.profiles?.avatar_url}
								<img src={blog.profiles.avatar_url} alt="" class="h-full w-full object-cover" />
							{:else}
								<div class="h-full w-full flex items-center justify-center text-slate-400 font-bold bg-white">{blog.profiles?.username?.charAt(0) || 'E'}</div>
							{/if}
						</div>
						<div>
							<p class="text-basis font-black text-slate-900 leading-none">{blog.profiles?.username || 'Code Shiksha Team'}</p>
							<p class="text-xs font-bold text-slate-400 mt-1 uppercase tracking-widest">Senior Educator</p>
						</div>
					</div>

					<div class="flex items-center gap-3">
						<button 
							onclick={toggleBookmark}
							class={cn("h-12 w-12 rounded-2xl border-2 transition-all flex items-center justify-center", 
								isBookmarked ? "bg-slate-900 border-slate-900 text-white" : "bg-white border-slate-100 text-slate-400 hover:text-slate-900"
							)}
						>
							<Bookmark size={20} fill={isBookmarked ? 'currentColor' : 'none'} />
						</button>
						<button class="h-12 w-12 rounded-2xl bg-white border-2 border-slate-100 text-slate-400 hover:text-slate-900 flex items-center justify-center">
							<Share2 size={20} />
						</button>
					</div>
				</div>
			</div>
		</header>

		<!-- Article Content -->
		<article class="max-w-4xl mx-auto px-6 py-20 relative">
			<!-- Progress Bar (Vertical Floating) -->
			<div class="hidden xl:block absolute -left-20 top-20 sticky h-32 w-1 bg-slate-100 rounded-full overflow-hidden">
				<div class="bg-blue-600 w-full h-1/2 rounded-full"></div>
			</div>

			<div class="prose prose-slate prose-lg max-w-none prose-headings:font-black prose-headings:tracking-tight prose-p:leading-relaxed prose-p:text-slate-600 prose-strong:text-slate-900 prose-blockquote:border-blue-600 prose-blockquote:bg-blue-50/50 prose-blockquote:p-8 prose-blockquote:rounded-3xl prose-img:rounded-[40px] prose-img:shadow-2xl">
				{#if !user}
					<div class="relative">
						<div class="space-y-6 opacity-30 pointer-events-none filter blur-sm">
							<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>
							<div class="h-64 w-full bg-slate-100 rounded-[40px]"></div>
							<p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
						</div>

						<!-- Lazy Auth Wall -->
						<div class="absolute inset-0 flex flex-col items-center justify-center text-center p-8 bg-gradient-to-b from-transparent via-white/80 to-white">
							<div class="h-20 w-20 rounded-[32px] bg-blue-600 text-white flex items-center justify-center shadow-2xl mb-8 group overflow-hidden">
								<BookOpen size={32} class="transition-transform group-hover:scale-110" />
							</div>
							<h3 class="text-3xl font-black text-slate-900 tracking-tight">Unlock full article</h3>
							<p class="text-lg text-slate-500 font-medium max-w-md mt-2">Create a free account to read our premium educational journal and insights.</p>
							<button 
								onclick={openLogin}
								class="mt-10 px-12 py-5 bg-slate-900 text-white font-black rounded-2xl shadow-2xl shadow-slate-200 hover:bg-black transition-all active:scale-95"
							>
								Join for Free
							</button>
							<p class="mt-6 text-sm font-bold text-slate-400">Already have an account? <button onclick={openLogin} class="text-blue-600 underline">Sign in</button></p>
						</div>
					</div>
				{:else}
					<div class="whitespace-pre-wrap font-medium text-lg leading-relaxed text-slate-700">
						{blog.content}
					</div>
				{/if}
			</div>

			<!-- Interaction Footer -->
			{#if user}
				<div class="mt-20 pt-12 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-8">
					<div class="space-y-1">
						<h4 class="font-black text-slate-900 text-xl tracking-tight">Did you find this helpful?</h4>
						<p class="text-slate-400 font-bold text-sm uppercase tracking-widest">Share it with your colleagues</p>
					</div>
					<div class="flex items-center gap-3">
						<button class="h-12 w-12 rounded-2xl bg-slate-50 text-slate-900 flex items-center justify-center hover:bg-blue-600 hover:text-white transition-all"><Facebook size={20} fill="currentColor" /></button>
						<button class="h-12 w-12 rounded-2xl bg-slate-50 text-slate-900 flex items-center justify-center hover:bg-blue-400 hover:text-white transition-all"><Twitter size={20} fill="currentColor" /></button>
						<button class="h-12 w-12 rounded-2xl bg-slate-50 text-slate-900 flex items-center justify-center hover:bg-blue-800 hover:text-white transition-all"><Linkedin size={20} fill="currentColor" /></button>
					</div>
				</div>
			{/if}
		</article>

		<!-- Related Suggestions -->
		<section class="bg-slate-50 py-20">
			<div class="max-w-6xl mx-auto px-6 space-y-12">
				<div class="flex items-center justify-between">
					<h3 class="text-3xl font-black text-slate-900">Keep Reading</h3>
					<a href="/blogs" class="text-blue-600 font-black text-basis hover:underline flex items-center gap-1">
						View Library <ArrowUpRight size={20} />
					</a>
				</div>
				
				<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
					{#each Array(3) as _}
						<div class="bg-white rounded-[40px] p-8 border border-slate-200 shadow-sm hover:translate-y-[-4px] transition-all group">
							<span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Pedagogy</span>
							<h4 class="text-xl font-black text-slate-900 mt-2 line-clamp-2 leading-tight group-hover:text-blue-600 transition-colors">Digital Literacy in the Modern Classroom</h4>
							<p class="text-slate-500 font-medium text-sm mt-3 line-clamp-2">How teachers are adapting to the rapidly evolving technological landscape.</p>
							<div class="mt-8 flex items-center justify-between">
								<div class="flex items-center gap-2">
									<div class="h-8 w-8 rounded-full bg-slate-100"></div>
									<span class="text-xs font-bold text-slate-600">Admin</span>
								</div>
								<ChevronRight size={20} class="text-slate-300 group-hover:text-blue-600 group-hover:translate-x-1 transition-all" />
							</div>
						</div>
					{/each}
				</div>
			</div>
		</section>
	{/if}
</div>
