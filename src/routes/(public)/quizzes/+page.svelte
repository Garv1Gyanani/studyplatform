<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Search, 
		FileQuestion, 
		Timer, 
		CheckCircle2, 
		Loader2,
		Trophy,
		ChevronRight,
		ArrowRight,
		Star,
		Zap,
		Sparkles
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let quizzes = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('quizzes')
			.select('*, categories(name)')
			.eq('is_published', true)
			.order('created_at', { ascending: false });
		
		if (!error) quizzes = data;
		loading = false;
	});

	let filteredQuizzes = $derived(
		quizzes.filter(q => q.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<!-- Refined White Hero Section -->
<div class="relative overflow-hidden bg-white pt-12 pb-16 border-b border-slate-50">
	<div class="absolute inset-0 -z-10 bg-[radial-gradient(45%_45%_at_50%_50%,rgba(59,130,246,0.02)_0%,transparent_100%)]"></div>
	
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="flex flex-col lg:flex-row lg:items-center justify-between gap-12">
			<div class="space-y-6 max-w-xl" in:fly={{ y: 20 }}>
				<div class="inline-flex items-center gap-2 rounded-xl bg-blue-50 px-4 py-1.5 text-[10px] font-black text-blue-600 shadow-sm ring-1 ring-blue-100/50">
					<Sparkles size={12} fill="currentColor" />
					<span class="uppercase tracking-widest">Challenge Your Mind</span>
				</div>
				
				<h1 class="text-4xl font-black text-slate-900 tracking-tight leading-[1.1] sm:text-5xl lg:text-6xl">
					Master subjects <br />
					<span class="text-blue-600">via Quizzes.</span>
				</h1>
				
				<p class="text-basis text-slate-500 font-medium leading-relaxed max-w-lg">
					Test your knowledge and earn XP rewards. Our interactive quizzes are designed to help you study smarter.
				</p>

				<div class="flex items-center gap-8 pt-2">
					<div class="flex items-center gap-3">
						<div class="h-10 w-10 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-lg">
							<Trophy size={18} />
						</div>
						<div>
							<p class="text-[9px] font-black uppercase text-slate-400">Streak</p>
							<p class="text-sm font-black text-slate-900">12 Days</p>
						</div>
					</div>
					<div class="flex items-center gap-3">
						<div class="h-10 w-10 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/10">
							<Zap size={18} fill="currentColor" />
						</div>
						<div>
							<p class="text-[9px] font-black uppercase text-slate-400">Total XP</p>
							<p class="text-sm font-black text-slate-900">4.2M</p>
						</div>
					</div>
				</div>
			</div>

			<!-- Compact Card -->
			<div class="lg:w-80 bg-white rounded-[32px] p-8 border border-slate-100 shadow-xl shadow-slate-200/50 space-y-6 relative" in:fly={{ x: 20 }}>
				<div class="space-y-1">
					<h3 class="text-xl font-black text-slate-900 tracking-tight">Leaderboard</h3>
					<p class="text-xs font-medium text-slate-400">See how you rank globally.</p>
				</div>
				
				<div class="space-y-3">
					<div class="flex items-center justify-between p-3 bg-slate-50 rounded-xl border border-slate-100">
						<div class="flex items-center gap-3">
							<div class="h-8 w-8 rounded-lg bg-white flex items-center justify-center font-black text-xs text-slate-900 border border-slate-100 shadow-sm">1</div>
							<p class="text-xs font-black text-slate-700">Alex J.</p>
						</div>
						<div class="text-[10px] font-black text-blue-600">2.4k XP</div>
					</div>
				</div>
				
				<a href="/leaderboard" class="flex items-center justify-center gap-2 w-full py-4 bg-slate-900 text-white rounded-xl font-black text-xs hover:bg-black transition-all shadow-lg group">
					Rankings
					<ArrowRight size={16} class="transition-transform group-hover:translate-x-1" />
				</a>
			</div>
		</div>
	</div>
</div>

<div class="px-4 sm:px-8 py-16 max-w-7xl mx-auto space-y-12">
	<!-- Refined Search -->
	<div class="relative max-w-2xl mx-auto w-full group">
		<Search size={22} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-blue-600 transition-colors" />
		<input 
			bind:value={searchQuery}
			placeholder="Search for a quiz topic..." 
			class="w-full pl-16 pr-8 py-5 rounded-2xl bg-slate-100/50 border-2 border-transparent focus:bg-white focus:border-blue-600 outline-none transition-all font-bold text-lg placeholder:text-slate-300 shadow-sm"
		/>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={40} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredQuizzes.length === 0}
		<div class="py-20 text-center text-slate-300 font-black text-xl italic tracking-tight">
			No matching challenges found
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
			{#each filteredQuizzes as quiz, i}
				<a 
					href={`/quizzes/${quiz.id}`}
					class="group relative bg-white rounded-[32px] border border-slate-100 p-8 shadow-sm hover:shadow-xl hover:translate-y-[-4px] transition-all flex flex-col"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<div class="flex items-start justify-between mb-8">
						<div class="h-14 w-14 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center group-hover:scale-110 transition-transform duration-500">
							<FileQuestion size={28} />
						</div>
						<div class="flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 rounded-lg text-amber-600 font-black text-[10px] tracking-widest border border-amber-100">
							<Star size={12} fill="currentColor" /> +50 XP
						</div>
					</div>

					<div class="flex-grow space-y-3">
						{#if quiz.categories?.name}
							<span class="inline-flex px-3 py-1 bg-indigo-50 text-[9px] font-black uppercase tracking-widest text-indigo-600 rounded-lg">
								{quiz.categories.name}
							</span>
						{/if}
						<h3 class="text-xl font-black text-slate-900 tracking-tight line-clamp-2 leading-tight group-hover:text-blue-600 transition-colors">
							{quiz.title}
						</h3>
						<p class="text-slate-500 font-medium line-clamp-2 leading-relaxed text-sm">
							{quiz.description || 'Test your knowledge on this subject with randomized questions.'}
						</p>
					</div>

					<div class="mt-8 pt-6 border-t border-slate-50 flex items-center justify-between">
						<div class="flex items-center gap-4">
							<div class="flex flex-col">
								<span class="text-[9px] font-black text-slate-300 uppercase tracking-widest">Time</span>
								<span class="text-xs font-black text-slate-900">{quiz.time_limit}M</span>
							</div>
							<div class="h-4 w-[1px] bg-slate-100"></div>
							<div class="flex flex-col">
								<span class="text-[9px] font-black text-slate-300 uppercase tracking-widest">Passing</span>
								<span class="text-xs font-black text-slate-900">{quiz.passing_score}%</span>
							</div>
						</div>
						
						<div class="h-10 w-10 rounded-full bg-slate-900 text-white flex items-center justify-center group-hover:bg-blue-600 group-hover:translate-x-2 transition-all shadow-md">
							<ArrowRight size={18} strokeWidth={3} />
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
