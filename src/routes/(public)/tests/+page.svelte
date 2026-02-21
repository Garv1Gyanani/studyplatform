<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		GraduationCap, 
		Timer, 
		Calendar, 
		Search, 
		Loader2,
		ArrowRight,
		Clock,
		AlertCircle
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let tests = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('tests')
			.select('*')
			.eq('is_published', true)
			.order('available_from', { ascending: false });
		
		if (!error) tests = data;
		loading = false;
	});

	let filteredTests = $derived(
		tests.filter(t => t.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);

	function isAvailable(test: any) {
		const now = new Date();
		const from = new Date(test.available_from);
		const to = new Date(test.available_to);
		return now >= from && now <= to;
	}

	function getStatus(test: any) {
		const now = new Date();
		const from = new Date(test.available_from);
		const to = new Date(test.available_to);
		
		if (now < from) return 'upcoming';
		if (now > to) return 'expired';
		return 'active';
	}
</script>

<div class="px-4 sm:px-8 py-16 max-w-6xl mx-auto space-y-12">
	<div class="space-y-4 text-center md:text-left">
		<div class="inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-indigo-600 text-white shadow-xl shadow-indigo-200 mb-2">
			<GraduationCap size={32} />
		</div>
		<h1 class="text-5xl font-black text-slate-900 tracking-tight">Formal Assessments</h1>
		<p class="text-xl text-slate-500 font-medium max-w-2xl">
			Scheduled tests with specialized proctoring rules. Ensure you are ready before starting.
		</p>
	</div>

	<div class="relative max-w-xl">
		<Search size={24} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-300" />
		<input 
			bind:value={searchQuery}
			placeholder="Find a test by subject..." 
			class="w-full pl-16 pr-8 py-5 rounded-[24px] bg-white border-2 border-slate-100 focus:border-indigo-600 outline-none transition-all font-bold shadow-sm"
		/>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-indigo-600" />
		</div>
	{:else if filteredTests.length === 0}
		<div class="py-20 text-center bg-white rounded-[40px] border border-slate-100 font-bold text-slate-400 italic">
			No formal tests scheduled at this time.
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 gap-8">
			{#each filteredTests as test, i}
				{@const status = getStatus(test)}
				<div 
					class="group relative bg-white rounded-[40px] border border-slate-100 p-10 shadow-sm hover:shadow-2xl transition-all flex flex-col"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<div class="flex items-start justify-between mb-8">
						<div class={cn("px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest border", 
							status === 'active' ? "bg-green-50 text-green-600 border-green-100" :
							status === 'upcoming' ? "bg-blue-50 text-blue-600 border-blue-100" :
							"bg-slate-50 text-slate-400 border-slate-100"
						)}>
							{status}
						</div>
						<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
							<Clock size={14} /> {test.duration_minutes} Mins
						</div>
					</div>

					<div class="space-y-4 flex-grow">
						<h3 class="text-2xl font-black text-slate-900 group-hover:text-indigo-600 transition-colors leading-tight">
							{test.title}
						</h3>
						<p class="text-slate-500 font-medium line-clamp-2 text-sm">
							{test.instructions || 'Standard formal examination protocols apply. Late submissions will not be accepted.'}
						</p>
					</div>

					<div class="mt-8 pt-8 border-t border-slate-50 space-y-4">
						<div class="flex items-center gap-6 text-xs font-bold text-slate-400">
							<div class="flex items-center gap-1.5"><Calendar size={14} /> From: {new Date(test.available_from).toLocaleDateString()}</div>
							<div class="flex items-center gap-1.5"><Calendar size={14} /> To: {new Date(test.available_to).toLocaleDateString()}</div>
						</div>

						{#if status === 'active'}
							<a 
								href={`/tests/${test.id}`}
								class="w-full py-4 rounded-2xl bg-indigo-600 text-white font-black text-center shadow-lg shadow-indigo-200 hover:bg-indigo-700 transition-all flex items-center justify-center gap-2"
							>
								Start Examination <ArrowRight size={20} />
							</a>
						{:else if status === 'upcoming'}
							<button disabled class="w-full py-4 rounded-2xl bg-slate-100 text-slate-400 font-black cursor-not-allowed flex items-center justify-center gap-2">
								<Clock size={20} /> Starting Soon
							</button>
						{:else}
							<button disabled class="w-full py-4 rounded-2xl bg-slate-50 text-slate-300 font-black cursor-not-allowed flex items-center justify-center gap-2">
								<AlertCircle size={20} /> Test Ended
							</button>
						{/if}
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>
