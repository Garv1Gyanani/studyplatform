<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Newspaper, 
		Search, 
		Calendar, 
		ArrowRight, 
		Loader2,
		ExternalLink,
		Megaphone,
		Zap,
		ChevronRight,
		Tag
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let newsItems = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('news')
			.select('*')
			.eq('is_published', true)
			.order('published_at', { ascending: false });
		
		if (!error) newsItems = data;
		loading = false;
	});

	let filteredNews = $derived(
		newsItems.filter(n => n.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="px-4 sm:px-8 py-16 max-w-5xl mx-auto space-y-12">
	<div class="space-y-6 text-center">
		<div class="inline-flex h-16 w-16 items-center justify-center rounded-3xl bg-blue-600 text-white shadow-xl shadow-blue-200 mb-2">
			<Megaphone size={32} />
		</div>
		<h1 class="text-5xl font-black text-slate-900 tracking-tight">Education News</h1>
		<p class="text-lg text-slate-500 font-medium max-w-2xl mx-auto">
			Stay ahead of the curve with real-time updates on examinations, scholarship deadlines, and global EdTech trends.
		</p>
	</div>

	<!-- Search & Filter -->
	<div class="flex justify-center">
		<div class="relative w-full max-w-xl">
			<Search size={20} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400" />
			<input 
				bind:value={searchQuery}
				placeholder="Search news headlines..." 
				class="w-full pl-16 pr-8 py-4 rounded-[24px] bg-white border border-slate-200 shadow-sm focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all font-bold"
			/>
		</div>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredNews.length === 0}
		<div class="py-20 text-center bg-white rounded-[40px] border border-slate-100 italic font-bold text-slate-400">
			No news articles found
		</div>
	{:else}
		<div class="space-y-6">
			{#each filteredNews as item, i}
				<div 
					class="group relative bg-white rounded-[32px] border border-slate-100 p-8 shadow-sm hover:shadow-2xl hover:translate-y-[-2px] transition-all flex flex-col md:flex-row gap-8 items-start"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<div class="flex-grow space-y-4">
						<div class="flex items-center gap-4">
							<span class="px-3 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase tracking-widest rounded-lg border border-blue-100 flex items-center gap-1">
								<Tag size={12} /> {item.category}
							</span>
							<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
								<Calendar size={14} /> {new Date(item.published_at).toLocaleDateString()}
							</div>
						</div>
						
						<h2 class="text-2xl font-black text-slate-900 leading-tight group-hover:text-blue-600 transition-colors">
							{item.title}
						</h2>
						
						<p class="text-slate-500 font-medium leading-relaxed">
							{item.summary}
						</p>

						<div class="pt-4 flex items-center gap-4">
							<button class="px-6 py-2.5 rounded-xl bg-slate-900 text-white font-black text-xs hover:bg-black transition-all flex items-center gap-2">
								Read Full Story <ChevronRight size={16} />
							</button>
							{#if item.source_url}
								<a href={item.source_url} target="_blank" class="flex items-center gap-1.5 text-xs font-bold text-slate-400 hover:text-blue-600">
									Source <ExternalLink size={14} />
								</a>
							{/if}
						</div>
					</div>
					
					<div class="hidden sm:flex h-12 w-12 rounded-2xl bg-slate-50 text-slate-300 items-center justify-center shrink-0">
						<Newspaper size={24} />
					</div>
				</div>
			{/each}
		</div>
	{/if}

	<!-- Latest Update Sidebar Widget -->
	<div class="p-10 rounded-[40px] bg-gradient-to-br from-indigo-600 to-blue-700 text-white relative overflow-hidden shadow-2xl">
		<div class="absolute -right-20 -bottom-20 h-80 w-80 bg-white blur-[100px] opacity-20"></div>
		<div class="relative z-10 flex flex-col md:flex-row items-center justify-between gap-8">
			<div class="space-y-2">
				<div class="flex items-center gap-2 mb-2">
					<Zap size={20} fill="currentColor" class="text-amber-400" />
					<span class="text-xs font-black uppercase tracking-widest">Live Updates</span>
				</div>
				<h2 class="text-3xl font-black leading-tight">Subscribe to exam alerts</h2>
				<p class="text-indigo-100 font-medium">Get real-time notification on your dashboard for upcoming exam windows.</p>
			</div>
			<div class="flex w-full md:w-auto gap-2">
				<input placeholder="Enter your email" class="flex-grow md:w-64 px-6 py-4 rounded-2xl bg-white/10 border border-white/20 text-white placeholder-indigo-300 outline-none focus:bg-white/20" />
				<button class="px-8 py-4 bg-white text-indigo-600 rounded-2xl font-black shadow-xl hover:scale-105 active:scale-95 transition-all whitespace-nowrap">
					Notify Me
				</button>
			</div>
		</div>
	</div>
</div>
