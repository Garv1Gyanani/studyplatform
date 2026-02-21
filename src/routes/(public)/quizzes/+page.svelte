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
		Star
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let quizzes = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('quizzes')
			.select('*')
			.eq('is_published', true)
			.order('created_at', { ascending: false });
		
		if (!error) quizzes = data;
		loading = false;
	});

	let filteredQuizzes = $derived(
		quizzes.filter(q => q.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="px-4 sm:px-8 py-10 max-w-6xl mx-auto space-y-10">
	<div class="flex flex-col md:flex-row md:items-center justify-between gap-10">
		<div class="space-y-4">
			<div class="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-600 shadow-xl shadow-blue-200">
				<FileQuestion size={24} class="text-white" />
			</div>
			<h1 class="text-5xl font-black text-slate-900 tracking-tight">Challenge Yourself</h1>
			<p class="text-lg text-slate-500 font-medium max-w-xl">
				Test your comprehension with our interactive quizzes. Earn points, view rankings, and master your subjects.
			</p>
		</div>

		<div class="bg-white rounded-3xl p-8 border border-slate-100 shadow-xl shadow-slate-200/50 flex flex-col items-center text-center space-y-3 min-w-[300px]">
			<div class="flex items-center gap-1.5 text-amber-500">
				<Trophy size={28} fill="currentColor" />
			</div>
			<h4 class="font-black text-slate-900 text-xl">Top Ranking</h4>
			<p class="text-slate-400 font-bold text-xs uppercase tracking-widest">Beat the average score of 82%</p>
			<a href="/leaderboard" class="text-blue-600 font-black text-sm hover:underline">View Standing &rarr;</a>
		</div>
	</div>

	<!-- Search bar -->
	<div class="relative">
		<Search size={24} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-300" />
		<input 
			bind:value={searchQuery}
			placeholder="Find a quiz by topic or difficulty..." 
			class="w-full pl-16 pr-8 py-5 rounded-[32px] bg-slate-100/50 border-2 border-transparent focus:bg-white focus:border-blue-600 outline-none transition-all font-bold text-lg"
		/>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredQuizzes.length === 0}
		<div class="py-20 text-center text-slate-400 font-black text-xl italic">
			No quizzes found matching your criteria
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
			{#each filteredQuizzes as quiz, i}
				<a 
					href={`/quizzes/${quiz.id}`}
					class="group relative bg-white rounded-[48px] border border-slate-100 p-10 shadow-sm hover:shadow-2xl hover:translate-y-[-4px] transition-all flex flex-col"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<div class="flex items-start justify-between mb-8">
						<div class="h-16 w-16 rounded-[28px] bg-blue-50 text-blue-600 flex items-center justify-center group-hover:scale-110 transition-transform duration-500">
							<FileQuestion size={32} />
						</div>
						<div class="flex items-center gap-1 px-3 py-1 bg-amber-50 rounded-lg text-amber-500 font-black text-[10px] tracking-widest border border-amber-100">
							<Star size={12} fill="currentColor" /> +50 XP
						</div>
					</div>

					<div class="flex-grow space-y-4">
						<h3 class="text-2xl font-black text-slate-900 line-clamp-2 leading-tight group-hover:text-blue-600 transition-colors">
							{quiz.title}
						</h3>
						<p class="text-slate-500 font-medium line-clamp-2 leading-relaxed text-sm">
							{quiz.description || 'Test your knowledge on this subject with randomized questions and instant feedback.'}
						</p>
					</div>

					<div class="mt-10 pt-8 border-t border-slate-50 grid grid-cols-2 gap-4">
						<div class="flex items-center gap-2">
							<div class="h-8 w-8 rounded-lg bg-slate-50 flex items-center justify-center text-blue-600">
								<Timer size={16} />
							</div>
							<span class="text-xs font-black text-slate-900">{quiz.time_limit} MINS</span>
						</div>
						<div class="flex items-center gap-2">
							<div class="h-8 w-8 rounded-lg bg-slate-50 flex items-center justify-center text-green-600">
								<CheckCircle2 size={16} />
							</div>
							<span class="text-xs font-black text-slate-900">{quiz.passing_score}% PASS</span>
						</div>
					</div>

					<div class="mt-8 flex items-center justify-between">
						<span class="text-[10px] font-black uppercase text-slate-400 tracking-widest">12 Questions</span>
						<div class="h-12 w-12 rounded-full bg-slate-900 text-white flex items-center justify-center group-hover:bg-blue-600 group-hover:translate-x-2 transition-all shadow-lg">
							<ArrowRight size={20} />
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
