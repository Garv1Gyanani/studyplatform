<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		NotebookIcon, 
		Search, 
		Tag, 
		Calendar, 
		Loader2,
		ArrowUpRight,
		FolderOpen,
		BookMarked,
		ChevronRight,
        FileText
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let notes = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('notes')
			.select('*, categories(name)')
			.eq('is_published', true)
			.order('created_at', { ascending: false });
		
		if (!error) notes = data;
		loading = false;
	});

	let filteredNotes = $derived(
		notes.filter(n => n.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="px-4 sm:px-8 py-10 max-w-6xl mx-auto space-y-10">
	<div class="space-y-6">
		<div class="flex items-center gap-4">
			<div class="h-14 w-14 rounded-2xl bg-gradient-to-br from-purple-600 to-indigo-600 text-white flex items-center justify-center shadow-lg shadow-purple-200">
				<NotebookIcon size={28} />
			</div>
			<div>
				<h1 class="text-5xl font-black text-slate-900 tracking-tight">Study Notes</h1>
				<p class="text-xl text-slate-500 font-medium">Concise, structured knowledge blocks for efficient revision.</p>
			</div>
		</div>

		<div class="bg-white rounded-[32px] p-6 border border-slate-100 shadow-sm flex flex-col sm:flex-row items-center gap-6">
			<div class="relative flex-grow w-full">
				<Search size={20} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400" />
				<input 
					bind:value={searchQuery}
					placeholder="Search for a concept or subject..." 
					class="w-full pl-16 pr-6 py-4 rounded-2xl bg-slate-50 border-transparent focus:bg-white focus:border-purple-600 outline-none transition-all font-bold"
				/>
			</div>
			<div class="flex items-center gap-4 text-xs font-black uppercase tracking-widest text-slate-400 whitespace-nowrap">
				<span>Sort By</span>
				<select class="bg-transparent border-none font-black text-slate-900 outline-none cursor-pointer">
					<option>Latest</option>
					<option>Topic</option>
					<option>Popular</option>
				</select>
			</div>
		</div>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredNotes.length === 0}
		<div class="py-20 text-center text-slate-400 font-black text-xl italic bg-white rounded-[40px] border border-slate-100">
			No study notes found in this archive
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
			{#each filteredNotes as note, i}
				<div 
					class="group relative bg-white rounded-[40px] border border-slate-100 p-8 shadow-sm hover:shadow-2xl hover:translate-y-[-4px] transition-all flex flex-col"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<div class="flex items-center justify-between mb-8">
						<div class="h-12 w-12 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center">
							<BookMarked size={24} />
						</div>
						<div class="flex items-center gap-2">
							<span class="px-3 py-1 bg-slate-50 rounded-lg text-[10px] font-black uppercase tracking-widest text-slate-500 border border-slate-100">
								{note.topic || 'General'}
							</span>
						</div>
					</div>

					<div class="flex-grow space-y-3">
						<h3 class="text-2xl font-black text-slate-900 group-hover:text-purple-600 transition-colors line-clamp-2 leading-tight">
							{note.title}
						</h3>
						<p class="text-slate-500 font-medium text-sm line-clamp-3 leading-relaxed">
							{note.content}
						</p>
					</div>

					<div class="mt-10 pt-8 border-t border-slate-50 flex items-center justify-between">
						<div class="flex items-center gap-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">
                            <Calendar size={12} /> {new Date(note.created_at).toLocaleDateString()}
                        </div>
						<button class="flex items-center gap-1.5 text-sm font-black text-purple-600 group-hover:translate-x-1 transition-transform">
							Open Note <ChevronRight size={18} />
						</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}

	<!-- Pro Tips Widget -->
	<div class="p-12 rounded-[48px] bg-white border border-slate-100 shadow-xl shadow-slate-200/50 grid grid-cols-1 md:grid-cols-12 gap-10 overflow-hidden relative group">
		<div class="absolute -right-20 -bottom-20 h-64 w-64 bg-purple-600 blur-[100px] opacity-10 group-hover:opacity-20 transition-opacity"></div>
		<div class="md:col-span-8 space-y-6 relative z-10">
			<h2 class="text-3xl font-black text-slate-900 tracking-tight">Effective Note-taking</h2>
			<p class="text-lg text-slate-500 font-medium leading-relaxed">
				Research shows that structured revision notes can improve retention by up to 40%. Our digital notes are designed to be scanned and understood in under 5 minutes.
			</p>
			<div class="flex items-center gap-4">
				<button class="px-8 py-4 bg-slate-900 text-white font-black rounded-2xl shadow-xl shadow-slate-200 hover:bg-black transition-all active:scale-95">Download PDF Guide</button>
				<button class="px-8 py-4 bg-white border border-slate-200 text-slate-900 font-black rounded-2xl hover:bg-slate-50 transition-all">Learn Strategies</button>
			</div>
		</div>
		<div class="hidden md:flex md:col-span-4 items-center justify-center relative z-10">
			<div class="h-40 w-40 rounded-[40px] bg-purple-50 text-purple-600 flex items-center justify-center shadow-inner">
				<FileText size={64} strokeWidth={1} />
			</div>
		</div>
	</div>
</div>
