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

<!-- Clean White Hero Section -->
<div class="relative overflow-hidden bg-white pt-16 pb-24 border-b border-slate-50">
	<div class="absolute inset-0 -z-10 bg-[radial-gradient(45%_45%_at_50%_50%,rgba(59,130,246,0.03)_0%,transparent_100%)]"></div>
	
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="flex flex-col lg:flex-row lg:items-center justify-between gap-16">
			<div class="space-y-8 max-w-2xl" in:fly={{ y: 20 }}>
				<div class="inline-flex items-center gap-3 rounded-2xl bg-blue-50 px-5 py-2 text-sm font-black text-blue-600 shadow-sm ring-1 ring-blue-100/50">
					<Sparkles size={14} fill="currentColor" />
					<span class="uppercase tracking-widest text-[10px]">Challenge Your Mind</span>
				</div>
				
				<h1 class="text-6xl font-black text-slate-900 tracking-tight leading-[0.9] sm:text-7xl">
					Master subjects <br />
					<span class="text-blue-600">via Quizzes.</span>
				</h1>
				
				<p class="text-xl text-slate-500 font-medium leading-relaxed">
					Test your knowledge, compete with friends, and earn exclusive XP rewards. Our interactive quizzes are designed to help you study smarter, not harder.
				</p>

				<div class="flex items-center gap-6 pt-4">
					<div class="flex items-center gap-3">
						<div class="h-12 w-12 rounded-2xl bg-slate-900 flex items-center justify-center text-white shadow-xl">
							<Trophy size={20} />
						</div>
						<div>
							<p class="text-[10px] font-black uppercase text-slate-400">Top Streak</p>
							<p class="text-basis font-black text-slate-900">12 Days</p>
						</div>
					</div>
					<div class="h-10 w-[1px] bg-slate-100"></div>
					<div class="flex items-center gap-3">
						<div class="h-12 w-12 rounded-2xl bg-blue-600 flex items-center justify-center text-white shadow-xl shadow-blue-500/20">
							<Zap size={20} fill="currentColor" />
						</div>
						<div>
							<p class="text-[10px] font-black uppercase text-slate-400">Global XP</p>
							<p class="text-basis font-black text-slate-900">4.2M Burned</p>
						</div>
					</div>
				</div>
			</div>

			<!-- Quick Actions Card -->
			<div class="lg:w-96 bg-white rounded-[40px] p-10 border border-slate-100 shadow-2xl shadow-slate-200/50 space-y-8 relative" in:fly={{ x: 20 }}>
				<div class="absolute -top-6 -right-6 h-20 w-20 rounded-3xl bg-blue-50 border border-blue-100 flex items-center justify-center text-blue-600 rotate-12 shadow-xl shadow-blue-500/5">
					<Star size={32} fill="currentColor" />
				</div>
				
				<div class="space-y-2">
					<h3 class="text-2xl font-black text-slate-900 tracking-tight">Leaderboard</h3>
					<p class="text-sm font-medium text-slate-400">See how you rank against the global student community.</p>
				</div>
				
				<div class="space-y-4">
					<div class="flex items-center justify-between p-4 bg-slate-50 rounded-[20px] border border-slate-100">
						<div class="flex items-center gap-3">
							<div class="h-10 w-10 rounded-xl bg-white flex items-center justify-center font-black text-slate-900 border border-slate-100 shadow-sm">1</div>
							<p class="text-sm font-black text-slate-700">Alex Johnson</p>
						</div>
						<div class="text-xs font-black text-blue-600">2,450 XP</div>
					</div>
				</div>
				
				<a href="/leaderboard" class="flex items-center justify-center gap-3 w-full py-5 bg-slate-900 text-white rounded-2xl font-black text-sm hover:bg-black transition-all shadow-xl group">
					View All Rankings
					<ArrowRight size={18} class="transition-transform group-hover:translate-x-1" />
				</a>
			</div>
		</div>
	</div>
</div>

<div class="px-4 sm:px-8 py-20 max-w-7xl mx-auto space-y-16">
	<!-- Search bar -->
	<div class="relative max-w-3xl mx-auto w-full group">
		<Search size={24} class="absolute left-8 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-blue-600 transition-colors" />
		<input 
			bind:value={searchQuery}
			placeholder="Search for a quiz topic..." 
			class="w-full pl-20 pr-10 py-7 rounded-[32px] bg-slate-50 border-2 border-slate-100 focus:bg-white focus:border-blue-600 focus:ring-8 focus:ring-blue-600/5 outline-none transition-all font-black text-xl placeholder:text-slate-300 shadow-sm"
		/>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredQuizzes.length === 0}
		<div class="py-20 text-center text-slate-300 font-black text-2xl italic tracking-tight">
			No matching challenges found
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
			{#each filteredQuizzes as quiz, i}
				<a 
					href={`/quizzes/${quiz.id}`}
					class="group relative bg-white rounded-[48px] border border-slate-100 p-12 shadow-sm hover:shadow-[0_40px_100px_-20px_rgba(0,0,0,0.1)] hover:translate-y-[-8px] transition-all flex flex-col"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<div class="flex items-start justify-between mb-10">
						<div class="h-20 w-20 rounded-[32px] bg-blue-50 text-blue-600 flex items-center justify-center shadow-inner group-hover:scale-110 transition-transform duration-500 ease-out">
							<FileQuestion size={40} strokeWidth={2.5} />
						</div>
						<div class="flex items-center gap-2 px-4 py-2 bg-amber-50 rounded-xl text-amber-600 font-black text-[12px] tracking-widest border border-amber-100 shadow-sm">
							<Star size={14} fill="currentColor" /> +50 XP
						</div>
					</div>

					<div class="flex-grow space-y-5">
						{#if quiz.categories?.name}
							<span class="inline-flex px-4 py-1.5 bg-indigo-50 text-[11px] font-black uppercase tracking-widest text-indigo-600 rounded-lg">
								{quiz.categories.name}
							</span>
						{/if}
						<h3 class="text-3xl font-black text-slate-900 tracking-tighter line-clamp-2 leading-[1.1] group-hover:text-blue-600 transition-colors">
							{quiz.title}
						</h3>
						<p class="text-slate-500 font-medium line-clamp-2 leading-relaxed text-basis">
							{quiz.description || 'Test your knowledge on this subject with randomized questions and instant feedback.'}
						</p>
					</div>

					<div class="mt-12 pt-10 border-t border-slate-50 flex items-center justify-between">
						<div class="flex items-center gap-6">
							<div class="flex flex-col">
								<span class="text-[10px] font-black uppercase text-slate-300 tracking-widest">Time</span>
								<span class="text-basis font-black text-slate-900">{quiz.time_limit}M</span>
							</div>
							<div class="h-6 w-[1px] bg-slate-100"></div>
							<div class="flex flex-col">
								<span class="text-[10px] font-black uppercase text-slate-300 tracking-widest">Passing</span>
								<span class="text-basis font-black text-slate-900">{quiz.passing_score}%</span>
							</div>
						</div>
						
						<div class="h-14 w-14 rounded-full bg-slate-900 text-white flex items-center justify-center group-hover:bg-blue-600 group-hover:translate-x-3 transition-all shadow-xl group-hover:shadow-blue-500/20">
							<ArrowRight size={24} strokeWidth={3} />
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
