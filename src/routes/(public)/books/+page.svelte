<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Search, 
		Book, 
		Download, 
		ChevronRight, 
		Loader2,
		ExternalLink,
		Library,
		Filter,
		BookOpen,
        Star
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let books = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('books')
			.select('*')
			.eq('is_published', true)
			.order('created_at', { ascending: false });
		
		if (!error) books = data;
		loading = false;
	});

	let filteredBooks = $derived(
		books.filter(b => b.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="px-4 sm:px-8 py-10 max-w-7xl mx-auto space-y-10">
	<!-- Header -->
	<div class="flex flex-col lg:flex-row lg:items-center justify-between gap-8 bg-slate-900 rounded-[48px] p-10 sm:p-20 relative overflow-hidden text-white shadow-2xl">
		<div class="absolute right-0 top-0 h-96 w-96 bg-blue-600 blur-[120px] opacity-20"></div>
		<div class="space-y-6 relative z-10 max-w-2xl">
			<div class="inline-flex items-center gap-2 px-4 py-1.5 bg-white/10 text-white rounded-full text-xs font-black uppercase tracking-widest border border-white/20">
				<Library size={14} /> Open Digital Library
			</div>
			<h1 class="text-5xl sm:text-7xl font-black tracking-tight leading-none">
				Read. Learn. <br/> <span class="text-blue-500">Transform.</span>
			</h1>
			<p class="text-xl text-slate-400 font-medium leading-relaxed">
				Access thousands of reference books, textbooks, and interactive study guides curated for your success.
			</p>
			
			<div class="pt-4 flex items-center gap-4">
				<div class="relative w-full max-w-md">
					<Search size={20} class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400" />
					<input 
						bind:value={searchQuery}
						placeholder="Search by title or author..." 
						class="w-full pl-16 pr-6 py-5 rounded-[24px] bg-white/10 border border-white/10 text-white outline-none focus:bg-white/20 transition-all font-bold"
					/>
				</div>
				<button class="hidden sm:flex h-16 w-16 items-center justify-center rounded-[24px] bg-blue-600 text-white shadow-xl shadow-blue-500/20 hover:scale-105 active:scale-95 transition-all">
					<Filter size={24} />
				</button>
			</div>
		</div>

		<div class="hidden lg:block relative z-10">
			<div class="grid grid-cols-2 gap-4">
				<div class="h-64 w-44 rounded-3xl bg-white/10 border border-white/10 transform -rotate-12 translate-y-8 flex items-center justify-center text-white/20">
                    <Book size={64} />
                </div>
				<div class="h-64 w-44 rounded-3xl bg-white/20 border border-white/10 transform rotate-6 flex items-center justify-center text-white/40 shadow-2xl">
                    <BookOpen size={64} />
                </div>
			</div>
		</div>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredBooks.length === 0}
		<div class="py-32 text-center">
			<p class="text-slate-400 font-black text-xl italic">No books found in the archives</p>
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10">
			{#each filteredBooks as book, i}
				<div 
					class="group flex flex-col items-center text-center space-y-6"
					in:fly={{ y: 20, delay: i * 50 }}
				>
					<!-- Book Spine / Cover Shadow Effect -->
					<div class="relative perspective-1000 group-hover:translate-y-[-8px] transition-transform duration-500">
						<div class="h-72 w-52 rounded-2xl bg-white shadow-[10px_10px_30px_rgba(0,0,0,0.1)] overflow-hidden relative border border-slate-100 ring-1 ring-slate-100">
							{#if book.cover_image}
								<img src={book.cover_image} alt="" class="h-full w-full object-cover" />
							{:else}
								<div class="h-full w-full bg-slate-50 flex items-center justify-center text-slate-200">
									<Book size={64} strokeWidth={1} />
								</div>
							{/if}
							<div class="absolute inset-0 bg-gradient-to-r from-black/20 via-transparent to-transparent opacity-60"></div>
							<div class="absolute top-4 left-4 h-8 w-8 rounded-full bg-white/90 backdrop-blur-md flex items-center justify-center shadow-lg">
								<Star size={14} fill="currentColor" class="text-amber-500" />
							</div>
						</div>
						<!-- 3D Ribbon / Level Badge -->
						<div class="absolute -right-2 top-8 px-4 py-1.5 bg-blue-600 text-white text-[10px] font-black uppercase tracking-widest rounded-l-lg shadow-lg">
							{book.subject}
						</div>
					</div>

					<div class="space-y-2">
						<h3 class="text-xl font-black text-slate-900 group-hover:text-blue-600 transition-colors line-clamp-1">{book.title}</h3>
						<p class="text-xs font-bold text-slate-400 uppercase tracking-widest">By {book.author}</p>
					</div>

					<div class="flex items-center gap-3 w-full justify-center">
						<button class="flex-grow py-3 rounded-2xl bg-slate-900 text-white font-black text-sm hover:bg-black active:scale-95 transition-all shadow-lg flex items-center justify-center gap-2">
							Read Now <ChevronRight size={18} />
						</button>
						<button class="h-12 w-12 rounded-2xl border-2 border-slate-100 text-slate-400 hover:text-blue-600 hover:border-blue-600 flex items-center justify-center transition-all">
							<Download size={20} />
						</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
/* Simplified perspective for CSS 3D vibes if needed, currently just using transform */
</style>
