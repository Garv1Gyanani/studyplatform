<script lang="ts">
	import { 
		Plus, 
		Search, 
		Edit2, 
		Trash2, 
		NotebookIcon, 
		X,
		Loader2,
		FolderOpen,
		Tag,
		BookMarked,
		ChevronRight
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let notes = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Form State
	let title = $state('');
	let content = $state('');
	let topic = $state('');
	let isPublished = $state(true);

	onMount(fetchNotes);

	async function fetchNotes() {
		loading = true;
		const { data, error } = await supabase
			.from('notes')
			.select('*, categories(name)')
			.order('created_at', { ascending: false });
		
		if (!error) notes = data;
		loading = false;
	}

	async function handleSaveNote() {
		formLoading = true;
		const { data: { user } } = await supabase.auth.getUser();

		const { error } = await supabase.from('notes').insert({
			title,
			content,
			topic,
			is_published: isPublished,
			author_id: user?.id
		});

		if (!error) {
			isFormOpen = false;
			resetForm();
			fetchNotes();
		} else {
			alert(error.message);
		}
		formLoading = false;
	}

	function resetForm() {
		title = '';
		content = '';
		topic = '';
	}

	async function deleteNote(id: string) {
		if (confirm('Are you sure?')) {
			const { error } = await supabase.from('notes').delete().match({ id });
			if (!error) fetchNotes();
		}
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Study Notes</h1>
			<p class="mt-1 text-slate-500">Curate structured study materials and reference notes.</p>
		</div>
		<button 
			onclick={() => isFormOpen = true}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 active:scale-95"
		>
			<Plus size={18} />
			New Note
		</button>
	</div>

	<!-- Notes Grid (organized by topic/category) -->
	{#if loading}
		<div class="flex h-64 items-center justify-center">
			<Loader2 size={32} class="animate-spin text-blue-600" />
		</div>
	{:else if notes.length === 0}
		<div class="flex h-96 flex-col items-center justify-center rounded-3xl border-2 border-dashed border-slate-200 bg-slate-50 text-center p-8">
			<div class="mb-4 rounded-2xl bg-white p-4 shadow-sm text-slate-300">
				<NotebookIcon size={40} />
			</div>
			<h3 class="text-lg font-bold text-slate-900">No notes yet</h3>
			<p class="mt-1 max-w-xs text-sm text-slate-500">Create study notes to help students grasp complex topics quickly.</p>
		</div>
	{:else}
		<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each notes as note}
				<div class="group relative rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition-all hover:shadow-xl hover:shadow-slate-200/50">
					<div class="flex items-center justify-between mb-4">
						<div class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
							<BookMarked size={20} />
						</div>
						<div class="flex items-center gap-1">
							<button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-50 hover:text-slate-900" onclick={() => deleteNote(note.id)}>
								<Trash2 size={16} />
							</button>
							<button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-50 hover:text-slate-900">
								<Edit2 size={16} />
							</button>
						</div>
					</div>
					
					<h3 class="text-lg font-bold text-slate-900 line-clamp-1">{note.title}</h3>
					<div class="mt-2 flex flex-wrap gap-2">
						<span class="inline-flex items-center gap-1 rounded-lg bg-slate-100 px-2.5 py-1 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
							<FolderOpen size={12} />
							{note.categories?.name || 'General'}
						</span>
						<span class="inline-flex items-center gap-1 rounded-lg bg-blue-50 px-2.5 py-1 text-[10px] font-bold text-blue-600 uppercase tracking-widest">
							<Tag size={12} />
							{note.topic || 'No topic'}
						</span>
					</div>

					<p class="mt-4 text-sm text-slate-500 line-clamp-2 leading-relaxed">
						{note.content}
					</p>

					<div class="mt-6 flex items-center justify-between border-t border-slate-50 pt-4">
						<div class="flex items-center gap-2">
							<div class={cn("h-2 w-2 rounded-full", note.is_published ? "bg-green-500" : "bg-slate-300")}></div>
							<span class="text-xs font-bold text-slate-400">{note.is_published ? 'LIVE' : 'DRAFT'}</span>
						</div>
						<button class="flex items-center gap-1 text-xs font-bold text-blue-600 hover:underline">
							View Full
							<ChevronRight size={14} />
						</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

<!-- Form Modal -->
{#if isFormOpen}
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={() => isFormOpen = false}
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-3xl overflow-hidden rounded-3xl bg-white shadow-2xl"
			onclick={e => e.stopPropagation()}
		>
			<div class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
				<h2 class="text-xl font-bold text-slate-900">Create Study Note</h2>
				<button onclick={() => isFormOpen = false} class="rounded-full p-2 text-slate-400 hover:bg-slate-100 transition-colors">
					<X size={20} />
				</button>
			</div>

			<div class="p-8">
				<form onsubmit={e => { e.preventDefault(); handleSaveNote(); }} class="space-y-6">
					<div class="grid grid-cols-2 gap-4">
						<div class="space-y-2">
							<label for="note-title" class="text-xs font-bold uppercase tracking-widest text-slate-500">Note Title</label>
							<input 
								id="note-title"
								bind:value={title}
								required
								placeholder="e.g. Introduction to Calculus"
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white"
							/>
						</div>
						<div class="space-y-2">
							<label for="note-topic" class="text-xs font-bold uppercase tracking-widest text-slate-500">Topic / Slug</label>
							<input 
								id="note-topic"
								bind:value={topic}
								placeholder="e.g. math-101"
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white"
							/>
						</div>
					</div>

					<div class="space-y-2">
						<label for="note-content" class="text-xs font-bold uppercase tracking-widest text-slate-500">Note Content (Markdown)</label>
						<textarea 
							id="note-content"
							bind:value={content}
							rows="10"
							placeholder="Write your study notes here using markdown..."
							class="block w-full rounded-2xl border border-slate-200 bg-slate-50 p-6 text-base outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500 focus:bg-white shadow-inner"
						></textarea>
					</div>

					<div class="flex items-center justify-end gap-3 pt-6 border-t border-slate-100">
						<button type="button" onclick={() => isFormOpen = false} class="rounded-xl px-6 py-3 text-sm font-bold text-slate-500 hover:bg-slate-50">Cancel</button>
						<button 
							type="submit" 
							disabled={formLoading}
							class="flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-10 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700"
						>
							{#if formLoading}
								<Loader2 size={18} class="animate-spin" />
								Saving...
							{:else}
								Save Note
							{/if}
						</button>
					</div>
				</form>
			</div>
		</div>
	</div>
{/if}
