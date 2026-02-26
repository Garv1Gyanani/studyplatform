<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Search, 
		Filter, 
		PlayCircle, 
		Clock, 
		Star, 
		Loader2,
		ChevronRight,
		Youtube,
		Video,
		ArrowRight
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let videos = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');
	let selectedCategory = $state('All');

	onMount(async () => {
		const { data, error } = await supabase
			.from('videos')
			.select('*, categories(name)')
			.eq('is_published', true)
			.order('created_at', { ascending: false });
		
		if (!error) videos = data;
		loading = false;
	});

	let filteredVideos = $derived(
		videos.filter(v => 
			(selectedCategory === 'All' || v.categories?.name === selectedCategory) &&
			(v.title.toLowerCase().includes(searchQuery.toLowerCase()))
		)
	);

	const categories = ['All', 'Computer Science', 'Mathematics', 'Science', 'Language', 'Art'];
</script>

<div class="px-4 sm:px-8 py-12 max-w-7xl mx-auto space-y-12">
	<div class="flex flex-col md:flex-row md:items-end justify-between gap-8">
		<div class="space-y-4">
			<h1 class="text-5xl font-black text-slate-900 tracking-tight">Expand your <span class="text-blue-600 underline underline-offset-8 decoration-blue-100">Knowledge</span></h1>
			<p class="text-lg text-slate-500 font-medium max-w-2xl leading-relaxed">
				World-class education from top instructors, available anywhere, anytime. Browse our collection of video courses and start learning.
			</p>
		</div>
		
		<div class="flex items-center gap-3">
			<div class="relative w-full sm:w-80">
				<Search size={20} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
				<input 
					bind:value={searchQuery}
					placeholder="What do you want to learn?" 
					class="w-full pl-12 pr-4 py-4 rounded-2xl bg-white border border-slate-200 shadow-sm focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all font-bold text-sm"
				/>
			</div>
		</div>
	</div>

	<!-- Categories Strip -->
	<div class="flex items-center gap-2 overflow-x-auto pb-4 scrollbar-hide">
		{#each categories as cat}
			<button 
				onclick={() => selectedCategory = cat}
				class={cn("px-6 py-2.5 rounded-full text-sm font-bold border transition-all whitespace-nowrap", 
					selectedCategory === cat 
						? "bg-slate-900 border-slate-900 text-white shadow-xl shadow-slate-200" 
						: "bg-white border-slate-200 text-slate-500 hover:border-slate-300 hover:text-slate-900"
				)}
			>
				{cat}
			</button>
		{/each}
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredVideos.length === 0}
		<div class="bg-white rounded-[40px] border-2 border-dashed border-slate-100 p-32 text-center">
			<p class="text-slate-400 font-black text-xl">No courses found matching your criteria</p>
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
			{#each filteredVideos as video, i}
				<a 
					href={`/courses/${video.id}`}
					class="group relative bg-white rounded-[40px] border border-slate-100 overflow-hidden shadow-sm hover:shadow-2xl hover:shadow-slate-200/50 hover:translate-y-[-4px] transition-all"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<!-- Thumbnail Container -->
					<div class="relative aspect-video overflow-hidden bg-slate-100">
						{#if video.thumbnail_url}
							<img src={video.thumbnail_url} alt="" class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110" />
						{:else}
							<div class="h-full w-full flex items-center justify-center text-slate-200">
								{#if video.youtube_url}<Youtube size={64} />{:else}<Video size={64} />{/if}
							</div>
						{/if}
						<div class="absolute inset-0 bg-black/20 group-hover:bg-transparent transition-colors"></div>
						<div class="absolute bottom-4 right-4 h-12 w-12 rounded-full bg-white text-slate-900 flex items-center justify-center shadow-2xl opacity-0 group-hover:opacity-100 transition-all translate-y-2 group-hover:translate-y-0">
							<PlayCircle size={28} fill="currentColor" class="text-blue-600" />
						</div>
						<div class="absolute top-4 left-4">
							<span class="px-3 py-1 bg-white/90 backdrop-blur-md rounded-lg text-[10px] font-black uppercase tracking-widest text-slate-900 shadow-sm border border-white/20">
								{video.categories?.name || 'General'}
							</span>
						</div>
					</div>

					<!-- Content -->
					<div class="p-8 space-y-4">
						<div class="flex items-center justify-between">
							<div class="flex items-center gap-1.5 text-amber-500">
								<Star size={14} fill="currentColor" />
								<span class="text-xs font-black">4.9</span>
							</div>
							<span class={cn("text-[10px] font-black uppercase tracking-widest px-2 py-0.5 rounded-lg", {
								'bg-green-50 text-green-600': video.difficulty_level === 'beginner',
								'bg-blue-50 text-blue-600': video.difficulty_level === 'intermediate',
								'bg-purple-50 text-purple-600': video.difficulty_level === 'advanced',
							})}>
								{video.difficulty_level}
							</span>
						</div>
						
						<h3 class="text-2xl font-black text-slate-900 leading-tight group-hover:text-blue-600 transition-colors line-clamp-2">
							{video.title}
						</h3>
						
						<p class="text-slate-500 font-medium line-clamp-2 text-sm leading-relaxed">
							{video.description}
						</p>

						<div class="pt-6 border-t border-slate-50 flex items-center justify-between">
							<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
								<Clock size={14} /> {video.duration || '15m'}
							</div>
							<div class="flex items-center gap-1 text-sm font-black text-slate-900">
								Start Learning <ArrowRight size={16} class="transition-transform group-hover:translate-x-1" />
							</div>
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
