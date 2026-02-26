<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Bookmark, 
		Trash2, 
		Video, 
		BookOpen, 
		FileText, 
		Loader2,
		Search,
		ChevronRight,
		Filter,
		Gamepad2,
		Layout
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let bookmarks = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		const user = sessionData.session?.user;

		if (user) {
			const { data: bookmarkEntries, error } = await supabase
				.from('bookmarks')
				.select('*')
				.eq('user_id', user.id)
				.order('created_at', { ascending: false });
			
			if (!error && bookmarkEntries) {
				// Fetch details for each bookmark
				const detailedBookmarks = await Promise.all(
					bookmarkEntries.map(async (b) => {
						let detail = null;
						if (b.content_type === 'video') {
							const { data } = await supabase.from('videos').select('title, difficulty_level').eq('id', b.content_id).single();
							detail = data;
						} else if (b.content_type === 'note') {
							const { data } = await supabase.from('notes').select('title').eq('id', b.content_id).single();
							detail = data;
						} else if (b.content_type === 'book') {
							const { data } = await supabase.from('books').select('title, author').eq('id', b.content_id).single();
							detail = data;
						}

						return {
							...b,
							title: detail?.title || 'Unknown Content',
							subtitle: detail?.author || detail?.difficulty_level || '',
							typeLabel: b.content_type.charAt(0).toUpperCase() + b.content_type.slice(1),
							url: b.content_type === 'video' ? `/courses/${b.content_id}` : `/${b.content_type}s`
						};
					})
				);
				bookmarks = detailedBookmarks;
			}
		}
		loading = false;
	});

	async function removeBookmark(id: string) {
		const { error } = await supabase.from('bookmarks').delete().eq('id', id);
		if (!error) {
			bookmarks = bookmarks.filter(b => b.id !== id);
		}
	}

	let filteredBookmarks = $derived(
		bookmarks.filter(b => b.title.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="px-4 sm:px-8 py-12 max-w-6xl mx-auto space-y-10">
	<div class="flex flex-col md:flex-row md:items-center justify-between gap-6">
		<div class="space-y-2">
			<h1 class="text-4xl font-black text-slate-900 tracking-tight">Your Saved Content</h1>
			<p class="text-slate-500 font-medium text-lg">Quick access to everything you've bookmarked for later review.</p>
		</div>
		
		<div class="flex items-center gap-3">
			<div class="relative">
				<Search size={18} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
				<input 
					bind:value={searchQuery}
					placeholder="Search your library..." 
					class="pl-11 pr-4 py-3 rounded-2xl bg-white border border-slate-200 outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 font-bold text-sm min-w-[280px]"
				/>
			</div>
			<button class="p-3 bg-white border border-slate-200 rounded-2xl text-slate-400 hover:text-slate-900 shadow-sm transition-all">
				<Filter size={20} />
			</button>
		</div>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if filteredBookmarks.length === 0}
		<div class="bg-white rounded-[40px] border-2 border-dashed border-slate-200 p-20 text-center space-y-6">
			<div class="inline-flex h-24 w-24 items-center justify-center rounded-[32px] bg-slate-50 text-slate-300">
				<Bookmark size={48} fill="currentColor" />
			</div>
			<div class="space-y-2">
				<h3 class="text-2xl font-black text-slate-900">Your library is empty</h3>
				<p class="text-slate-500 max-w-xs mx-auto font-medium">Click the bookmark icon on any course, note, or blog post to save it here.</p>
			</div>
			<a href="/courses" class="inline-flex items-center gap-2 rounded-2xl bg-blue-600 px-8 py-4 font-black text-white shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all">
				Explore Content <ChevronRight size={20} />
			</a>
		</div>
	{:else}
		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
			{#each filteredBookmarks as bookmark}
				<div 
					class="group relative bg-white rounded-[32px] border border-slate-100 p-8 shadow-sm hover:shadow-2xl hover:shadow-slate-200/50 hover:translate-y-[-4px] transition-all"
					in:fade
				>
					<button 
						onclick={() => removeBookmark(bookmark.id)}
						class="absolute right-6 top-6 h-10 w-10 rounded-full bg-red-50 text-red-400 opacity-0 group-hover:opacity-100 hover:bg-red-500 hover:text-white transition-all flex items-center justify-center z-10"
					>
						<Trash2 size={18} />
					</button>

					<div class="flex items-center gap-4 mb-6">
						<div class={cn("h-12 w-12 rounded-2xl flex items-center justify-center shadow-inner", 
							bookmark.content_type === 'video' ? "bg-blue-50 text-blue-600" : 
							bookmark.content_type === 'book' ? "bg-green-50 text-green-600" :
							"bg-purple-50 text-purple-600"
						)}>
							{#if bookmark.content_type === 'video'}
								<Video size={24} />
							{:else if bookmark.content_type === 'book'}
								<BookOpen size={24} />
							{:else}
								<FileText size={24} />
							{/if}
						</div>
						<div>
							<span class="text-[10px] font-black uppercase tracking-widest text-slate-400">{bookmark.typeLabel}</span>
							{#if bookmark.subtitle}
								<p class="text-[12px] font-bold text-slate-900 flex items-center gap-1">
									<Layout size={12} class="text-blue-500" /> {bookmark.subtitle}
								</p>
							{/if}
						</div>
					</div>

					<h3 class="text-xl font-black text-slate-900 leading-tight line-clamp-2">{bookmark.title}</h3>
					
					<div class="mt-8 pt-6 border-t border-slate-50 flex items-center justify-between">
						<span class="text-xs font-bold text-slate-400">Added {new Date(bookmark.created_at).toLocaleDateString()}</span>
						<a href={bookmark.url} class="flex items-center gap-1.5 text-sm font-black text-blue-600 group-hover:underline">
							View Now <ChevronRight size={18} />
						</a>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>
