<script lang="ts">
	import { 
		Plus, 
		Search, 
		Edit2, 
		Trash2, 
		Newspaper, 
		X,
		Loader2,
		ExternalLink,
		Calendar,
		Tag,
		Save,
        ArrowRight
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let news = $state<any[]>([]);
	let categories = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Form State
	let title = $state('');
	let summary = $state('');
	let content = $state('');
	let categoryId = $state('');
	let isPublished = $state(true);
	let editingId = $state<string | null>(null);

	onMount(async () => {
		fetchNews();
		const { data } = await supabase.from('categories').select('*').order('name');
		categories = data || [];
	});

	async function fetchNews() {
		loading = true;
		const { data, error } = await supabase
			.from('news')
			.select('*, categories(name)')
			.order('published_at', { ascending: false });
		
		if (!error) news = data;
		loading = false;
	}

	async function handleSaveNews() {
		formLoading = true;
		
		const newsData = {
			title,
			summary,
			content,
			category_id: categoryId || null,
			is_published: isPublished,
			published_at: isPublished ? (isPublished && !editingId ? new Date().toISOString() : null) : null
		};

		const { error } = editingId 
			? await supabase.from('news').update(newsData).eq('id', editingId)
			: await supabase.from('news').insert(newsData);

		if (!error) {
			isFormOpen = false;
			resetForm();
			fetchNews();
		} else {
			alert(error.message);
		}
		formLoading = false;
	}

	function startEdit(article: any) {
		editingId = article.id;
		title = article.title;
		summary = article.summary || '';
		content = article.content || '';
		categoryId = article.category_id || '';
		isPublished = article.is_published;
		isFormOpen = true;
	}

	function resetForm() {
		editingId = null;
		title = '';
		summary = '';
		content = '';
		categoryId = '';
	}
	async function deleteNews(id: string) {
		if (confirm('Are you sure you want to delete this news article?')) {
			const { error } = await supabase.from('news').delete().match({ id });
			if (!error) fetchNews();
		}
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Education News</h1>
			<p class="mt-1 text-slate-500">Post updates about exams, scholarships, and EdTech news.</p>
		</div>
		<button 
			onclick={() => isFormOpen = true}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 active:scale-95"
		>
			<Plus size={18} />
			Post News Article
		</button>
	</div>

	<!-- List -->
	<div class="rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">
		{#if loading}
			<div class="flex h-64 items-center justify-center">
				<Loader2 size={32} class="animate-spin text-blue-600" />
			</div>
		{:else if news.length === 0}
			<div class="p-20 text-center">
				<div class="inline-flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-50 text-slate-300 mb-6">
					<Newspaper size={40} />
				</div>
				<h3 class="text-xl font-bold text-slate-900">No news posted yet</h3>
				<p class="text-slate-500 max-w-xs mx-auto mt-2">Keep your students updated with the latest in education.</p>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Headline</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Category</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Date</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each news as article}
							<tr class="group hover:bg-slate-50/30 transition-colors">
								<td class="px-6 py-4">
									<p class="font-bold text-slate-900 line-clamp-1">{article.title}</p>
									<p class="text-xs text-slate-400 mt-0.5 line-clamp-1">{article.summary}</p>
								</td>
								<td class="px-6 py-4">
									<span class="inline-flex items-center gap-1.5 rounded-lg bg-indigo-50 px-2.5 py-1 text-[10px] font-black uppercase text-indigo-600 tracking-widest">
										<Tag size={12} /> {article.categories?.name || article.category || 'General'}
									</span>
								</td>
								<td class="px-6 py-4 text-slate-500 text-sm">
									{new Date(article.published_at).toLocaleDateString()}
								</td>
								<td class="px-6 py-4 text-right">
									<div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
										<button 
											onclick={() => startEdit(article)}
											class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg"
										>
											<Edit2 size={16} />
										</button>
										<button 
											onclick={() => deleteNews(article.id)}
											class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg"
										>
											<Trash2 size={16} />
										</button>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>

<!-- Modal -->
{#if isFormOpen}
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={() => isFormOpen = false}
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-3xl overflow-hidden rounded-[40px] bg-white shadow-2xl"
			onclick={e => e.stopPropagation()}
		>
			<div class="px-10 py-8 border-b border-slate-100 flex items-center justify-between">
				<h2 class="text-2xl font-black text-slate-900 tracking-tight">
					{editingId ? 'Edit News Article' : 'Post Education News'}
				</h2>
				<button onclick={() => isFormOpen = false} class="p-2 text-slate-400 hover:text-slate-900">
					<X size={24} />
				</button>
			</div>

			<div class="p-10 space-y-6">
				<form onsubmit={e => { e.preventDefault(); handleSaveNews(); }} class="space-y-6">
					<div class="grid grid-cols-1 md:grid-cols-12 gap-6">
						<div class="md:col-span-8 space-y-2">
							<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Headline</label>
							<input bind:value={title} required class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-basis font-bold outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 focus:bg-white transition-all" placeholder="e.g. CBSE Announces 2025 Exam Schedule" />
						</div>
						<div class="md:col-span-4 space-y-2">
							<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Category</label>
							<select bind:value={categoryId} class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-basis font-bold outline-none focus:bg-white transition-all cursor-pointer">
								<option value="">Select Category</option>
								{#each categories as cat}
									<option value={cat.id}>{cat.name}</option>
								{/each}
							</select>
						</div>
					</div>

					<div class="space-y-2">
						<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Summary (Brief Preview)</label>
						<textarea bind:value={summary} rows="2" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-medium outline-none focus:bg-white transition-all resize-none" placeholder="A short catch-all summary..."></textarea>
					</div>

					<div class="space-y-2">
						<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Full Article Content</label>
						<textarea bind:value={content} rows="8" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-5 text-basis font-medium outline-none focus:bg-white transition-all" placeholder="Write the full story here..."></textarea>
					</div>

					<div class="flex items-center justify-between pt-6 border-t border-slate-100">
						<label class="flex items-center gap-3 cursor-pointer">
							<div class="relative h-6 w-11 rounded-full bg-slate-200" class:bg-blue-600={isPublished}>
								<input type="checkbox" bind:checked={isPublished} class="sr-only" />
								<div class={cn("absolute top-1 left-1 h-4 w-4 bg-white rounded-full transition-all", isPublished ? "translate-x-5" : "translate-x-0")}></div>
							</div>
							<span class="text-xs font-black uppercase tracking-widest text-slate-500">Publish to News Feed</span>
						</label>
						<div class="flex items-center gap-3">
							<button type="button" onclick={() => isFormOpen = false} class="px-6 py-3 text-sm font-bold text-slate-400 hover:text-slate-900 transition-all">Cancel</button>
							<button 
								type="submit" 
								disabled={formLoading}
								class="px-10 py-4 rounded-2xl bg-slate-900 text-white font-black text-sm shadow-xl shadow-slate-200 hover:bg-black transition-all active:scale-95 flex items-center gap-2"
							>
								{#if formLoading}
									<Loader2 size={18} class="animate-spin" /> Posting...
								{:else}
									<Save size={18} /> {editingId ? 'Update News' : 'Post News'}
								{/if}
							</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
{/if}
