<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Search, 
		BookOpen, 
		Clock, 
		ArrowRight, 
		Loader2,
		Calendar,
		User as UserIcon,
		Tag
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let blogs = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('blogs')
			.select('*, profiles(username, avatar_url)')
			.eq('is_published', true)
			.order('published_at', { ascending: false });
		
		if (!error) blogs = data;
		loading = false;
	});

	let filteredBlogs = $derived(
		blogs.filter(b => b.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="px-4 sm:px-8 py-10 max-w-6xl mx-auto space-y-10">
	<!-- Hero Header -->
	<div class="space-y-6 text-center">
		<div class="inline-flex items-center gap-2 px-4 py-1.5 bg-blue-50 text-blue-600 rounded-full text-xs font-black uppercase tracking-widest border border-blue-100">
			<BookOpen size={14} /> Insights & Articles
		</div>
		<h1 class="text-6xl font-black text-slate-900 tracking-tight leading-tight">
			The Educator's <span class="bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Journal</span>
		</h1>
		<p class="text-xl text-slate-500 font-medium max-w-2xl mx-auto leading-relaxed">
			Deep dives into pedagogical strategies, student success stories, and the future of educational technology.
		</p>
		
		<div class="pt-6 flex justify-center">
			<div class="relative w-full max-w-xl">
				<Search size={20} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400" />
				<input 
					bind:value={searchQuery}
					placeholder="Search articles and topics..." 
					class="w-full pl-16 pr-8 py-5 rounded-[32px] bg-white border border-slate-200 shadow-xl shadow-slate-200/50 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all font-bold"
				/>
			</div>
		</div>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredBlogs.length === 0}
		<div class="py-20 text-center bg-white rounded-[40px] border border-slate-100">
			<p class="text-slate-400 font-black text-xl">No articles found matching your search</p>
		</div>
	{:else}
		<!-- Featured Post (First one) -->
		{#if filteredBlogs[0]}
			<a 
				href={`/blogs/${filteredBlogs[0].slug}`}
				class="group block relative bg-white rounded-[48px] overflow-hidden border border-slate-100 shadow-sm hover:shadow-2xl transition-all"
				in:fade
			>
				<div class="grid grid-cols-1 lg:grid-cols-2">
					<div class="aspect-video lg:aspect-square overflow-hidden bg-slate-100">
						{#if filteredBlogs[0].cover_image}
							<img src={filteredBlogs[0].cover_image} alt="" class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-105" />
						{:else}
							<div class="h-full w-full flex items-center justify-center text-slate-200 bg-gradient-to-br from-slate-50 to-slate-100">
								<BookOpen size={120} strokeWidth={0.5} />
							</div>
						{/if}
					</div>
					<div class="p-10 sm:p-16 flex flex-col justify-center space-y-8">
						<div class="flex items-center gap-4">
							<span class="px-4 py-1 bg-amber-50 text-amber-600 rounded-lg text-xs font-black uppercase tracking-widest border border-amber-100">Featured</span>
							<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
								<Calendar size={14} /> {new Date(filteredBlogs[0].published_at).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })}
							</div>
						</div>
						
						<h2 class="text-4xl sm:text-5xl font-black text-slate-900 leading-tight group-hover:text-blue-600 transition-colors">
							{filteredBlogs[0].title}
						</h2>
						
						<p class="text-lg text-slate-500 font-medium leading-relaxed line-clamp-3">
							{filteredBlogs[0].excerpt || 'In this article, we explore the core concepts and real-world implications of our latest educational research.'}
						</p>

						<div class="pt-8 border-t border-slate-50 flex items-center justify-between">
							<div class="flex items-center gap-3">
								<div class="h-10 w-10 rounded-full bg-slate-100 overflow-hidden">
									{#if filteredBlogs[0].profiles?.avatar_url}
										<img src={filteredBlogs[0].profiles.avatar_url} alt="" class="h-full w-full object-cover" />
									{:else}
										<div class="h-full w-full flex items-center justify-center text-slate-400"><UserIcon size={18} /></div>
									{/if}
								</div>
								<span class="text-sm font-bold text-slate-900">{filteredBlogs[0].profiles?.username || 'Code Shiksha Team'}</span>
							</div>
							<div class="flex items-center gap-1.5 text-basis font-black text-blue-600">
								Read Full Story <ArrowRight size={20} class="transition-transform group-hover:translate-x-2" />
							</div>
						</div>
					</div>
				</div>
			</a>
		{/if}

		<!-- Grid for other posts -->
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
			{#each filteredBlogs.slice(1) as blog}
				<a 
					href={`/blogs/${blog.slug}`}
					class="group flex flex-col bg-white rounded-[40px] border border-slate-100 shadow-sm hover:shadow-2xl transition-all"
					in:fly={{ y: 20 }}
				>
					<div class="aspect-[16/10] overflow-hidden rounded-t-[40px] bg-slate-50 relative">
						{#if blog.cover_image}
							<img src={blog.cover_image} alt="" class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110" />
						{:else}
							<div class="h-full w-full flex items-center justify-center text-slate-200"><BookOpen size={64} /></div>
						{/if}
						<div class="absolute top-6 left-6">
							<span class="px-3 py-1 bg-white/90 backdrop-blur-md rounded-lg text-[10px] font-black uppercase tracking-widest text-slate-900 shadow-sm border border-white/20">
								Pedagogy
							</span>
						</div>
					</div>

					<div class="p-8 flex flex-col flex-grow space-y-4">
						<div class="flex items-center gap-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">
							<div class="flex items-center gap-1"><Calendar size={12} /> {new Date(blog.published_at).toLocaleDateString()}</div>
							<div class="h-1 w-1 bg-slate-300 rounded-full"></div>
							<div class="flex items-center gap-1"><Clock size={12} /> 6m read</div>
						</div>
						
						<h3 class="text-2xl font-black text-slate-900 leading-tight group-hover:text-blue-600 transition-colors line-clamp-2">
							{blog.title}
						</h3>
						
						<p class="text-slate-500 font-medium line-clamp-2 text-sm leading-relaxed mb-4">
							{blog.excerpt || 'Discover new insights and methodologies to enhance your learning experience.'}
						</p>

						<div class="mt-auto pt-6 border-t border-slate-50 flex items-center justify-between">
							<div class="flex items-center gap-2">
								<div class="h-8 w-8 rounded-full bg-slate-100 overflow-hidden">
									<div class="h-full w-full flex items-center justify-center text-slate-400 bg-slate-200"><UserIcon size={14} /></div>
								</div>
								<span class="text-xs font-bold text-slate-600">{blog.profiles?.username || 'Admin'}</span>
							</div>
							<ArrowRight size={20} class="text-slate-300 group-hover:text-blue-600 transition-all group-hover:translate-x-1" />
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
