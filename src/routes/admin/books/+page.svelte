<script lang="ts">
	import { 
		Plus, 
		Search, 
		Edit2, 
		Trash2, 
		Library, 
		X,
		Loader2,
		Book,
		UploadCloud,
		ExternalLink,
		Save,
        Star
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let books = $state<any[]>([]);
	let categories = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Form State
	let title = $state('');
	let author = $state('');
	let subject = $state('');
	let categoryId = $state('');
	let description = $state('');
	let resourcePdfUrl = $state('');
	let coverImage = $state('');
	let isPublished = $state(true);
	let editingId = $state<string | null>(null);
	let uploadStatus = $state('');
	let coverUploadStatus = $state('');

	onMount(async () => {
		fetchBooks();
		const { data } = await supabase.from('categories').select('*').order('name');
		categories = data || [];
	});

	async function fetchBooks() {
		loading = true;
		const { data, error } = await supabase
			.from('books')
			.select('*, categories(name)')
			.order('created_at', { ascending: false });
		
		if (!error) books = data;
		loading = false;
	}

	async function handleUpload(e: Event) {
		const target = e.target as HTMLInputElement;
		const file = target.files?.[0];
		if (!file) return;

		uploadStatus = 'Uploading...';
		const fileName = `${Date.now()}-${file.name}`;
		const { data, error } = await supabase.storage
			.from('resources')
			.upload(fileName, file);

		if (error) {
			alert(error.message);
			uploadStatus = 'Failed';
		} else {
			const { data: { publicUrl } } = supabase.storage
				.from('resources')
				.getPublicUrl(data.path);
			resourcePdfUrl = publicUrl;
			uploadStatus = 'Success!';
		}
	}

	async function handleCoverUpload(e: Event) {
		const target = e.target as HTMLInputElement;
		const file = target.files?.[0];
		if (!file) return;

		coverUploadStatus = 'Uploading...';
		const fileName = `covers/${Date.now()}-${file.name}`;
		const { data, error } = await supabase.storage
			.from('resources')
			.upload(fileName, file);

		if (error) {
			alert(error.message);
			coverUploadStatus = 'Failed';
		} else {
			const { data: { publicUrl } } = supabase.storage
				.from('resources')
				.getPublicUrl(data.path);
			coverImage = publicUrl;
			coverUploadStatus = 'Success!';
		}
	}

	async function handleSaveBook() {
		formLoading = true;
		
		const bookData = {
			title,
			author,
			subject,
			category_id: categoryId || null,
			description,
			pdf_url: resourcePdfUrl,
			cover_image: coverImage,
			is_published: isPublished
		};

		const { error } = editingId 
			? await supabase.from('books').update(bookData).eq('id', editingId)
			: await supabase.from('books').insert(bookData);

		if (!error) {
			isFormOpen = false;
			resetForm();
			fetchBooks();
		} else {
			alert(error.message);
		}
		formLoading = false;
	}

	function startEdit(book: any) {
		editingId = book.id;
		title = book.title;
		author = book.author || '';
		subject = book.subject || '';
		categoryId = book.category_id || '';
		resourcePdfUrl = book.pdf_url || '';
		coverImage = book.cover_image || '';
		isPublished = book.is_published;
		uploadStatus = '';
		coverUploadStatus = '';
		isFormOpen = true;
	}

	function resetForm() {
		editingId = null;
		title = '';
		author = '';
		subject = '';
		categoryId = '';
		description = '';
		resourcePdfUrl = '';
		coverImage = '';
		uploadStatus = '';
		coverUploadStatus = '';
	}
	async function deleteBook(id: string) {
		if (confirm('Are you sure you want to delete this resource?')) {
			const { error } = await supabase.from('books').delete().match({ id });
			if (!error) fetchBooks();
		}
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Digital Library</h1>
			<p class="mt-1 text-slate-500">Manage eBooks, PDFs, and external study resources.</p>
		</div>
		<button 
			onclick={() => { resetForm(); isFormOpen = true; }}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700"
		>
			<Plus size={18} />
			Add New Resource
		</button>
	</div>

	<!-- Library Grid -->
	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
		{#if loading}
			<div class="col-span-full flex h-64 items-center justify-center">
				<Loader2 size={32} class="animate-spin text-blue-600" />
			</div>
		{:else if books.length === 0}
			<div class="col-span-full p-20 text-center bg-white rounded-[40px] border border-slate-100 shadow-sm">
				<div class="inline-flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-50 text-slate-300 mb-6">
					<Library size={40} />
				</div>
				<h3 class="text-xl font-bold text-slate-900">Library is empty</h3>
				<p class="text-slate-500 max-w-xs mx-auto mt-2">Upload textbooks or link external PDFs to build your library.</p>
			</div>
		{:else}
			{#each books as book}
				<div class="group relative bg-white rounded-[32px] border border-slate-100 p-6 shadow-sm hover:shadow-xl hover:shadow-slate-200/50 transition-all flex flex-col">
					<div class="absolute right-4 top-4 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1">
						<button 
							onclick={() => startEdit(book)}
							class="p-2 bg-white rounded-xl shadow-sm border border-slate-100 text-slate-400 hover:text-blue-600"
						>
							<Edit2 size={16} />
						</button>
						<button class="p-2 bg-white rounded-xl shadow-sm border border-slate-100 text-slate-400 hover:text-red-500" onclick={() => deleteBook(book.id)}>
							<Trash2 size={16} />
						</button>
					</div>

					<div class="h-48 w-full rounded-2xl bg-slate-50 flex items-center justify-center mb-6 overflow-hidden">
						{#if book.cover_image}
							<img src={book.cover_image} alt="" class="h-full w-full object-cover" />
						{:else}
							<Book size={48} class="text-slate-200" />
						{/if}
					</div>

					<div class="flex-grow space-y-2">
						<div class="flex items-center gap-2">
							<span class="px-2 py-0.5 bg-blue-50 text-[10px] font-black uppercase text-blue-600 rounded">{book.subject}</span>
							{#if book.categories?.name}
								<span class="px-2 py-0.5 bg-indigo-50 text-[10px] font-black uppercase text-indigo-600 rounded">{book.categories.name}</span>
							{/if}
						</div>
						<h3 class="font-black text-slate-900 line-clamp-1">{book.title}</h3>
						<p class="text-xs font-bold text-slate-400 uppercase">By {book.author}</p>
					</div>

					<div class="mt-6 pt-6 border-t border-slate-50 flex items-center justify-between">
						<span class={cn("text-[10px] font-black uppercase tracking-widest", book.is_published ? "text-green-500" : "text-slate-300")}>
							{book.is_published ? 'Live' : 'Hidden'}
						</span>
						<a 
							href={book.pdf_url || '#'} 
							target={book.pdf_url ? "_blank" : "_self"}
							class="h-10 w-10 rounded-xl bg-slate-900 text-white flex items-center justify-center shadow-lg shadow-slate-200 hover:bg-blue-600 transition-all"
						>
							<ExternalLink size={18} />
						</a>
					</div>
				</div>
			{/each}
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
			class="w-full max-w-4xl overflow-hidden rounded-[40px] bg-white shadow-2xl h-[85vh] flex flex-col"
			onclick={e => e.stopPropagation()}
		>
			<div class="px-10 py-8 border-b border-slate-100 flex items-center justify-between">
				<h2 class="text-2xl font-black text-slate-900 tracking-tight">
					{editingId ? 'Edit Digital Resource' : 'Add Digital Resource'}
				</h2>
				<button onclick={() => isFormOpen = false} class="p-2 text-slate-400 hover:text-slate-900">
					<X size={24} />
				</button>
			</div>

			<div class="flex-grow overflow-y-auto p-10 grid grid-cols-12 gap-10">
				<div class="col-span-12 md:col-span-4 space-y-6">
					<label class="aspect-[3/4] rounded-[32px] border-2 border-dashed border-slate-200 bg-slate-50 flex flex-col items-center justify-center text-center p-8 hover:border-blue-400 hover:bg-blue-50/50 transition-all cursor-pointer relative overflow-hidden group">
						{#if coverImage}
							<img src={coverImage} alt="" class="absolute inset-0 h-full w-full object-cover" />
							<div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
								<UploadCloud size={32} class="text-white" />
							</div>
						{:else}
							<UploadCloud size={48} class={cn("mb-4", coverUploadStatus === 'Uploading...' ? 'animate-bounce text-blue-500' : 'text-slate-300')} />
							<p class="text-sm font-bold text-slate-500 leading-tight">
								{coverUploadStatus || 'Upload Cover Image'}
							</p>
							<p class="text-[10px] text-slate-400 mt-2 uppercase font-black">JPG/PNG only</p>
						{/if}
						<input type="file" accept="image/*" class="hidden" onchange={handleCoverUpload} />
					</label>
					
					<div class="p-6 rounded-3xl bg-amber-50 border border-amber-100">
						<div class="flex items-center gap-2 mb-2 text-amber-600">
							<Star size={18} fill="currentColor" />
							<span class="text-xs font-black uppercase tracking-widest">Librarian Tip</span>
						</div>
						<p class="text-xs font-medium text-amber-700 leading-relaxed">
							Ensure the PDF is compressed before upload to provide a fast reading experience for students on mobile.
						</p>
					</div>
				</div>

				<div class="col-span-12 md:col-span-8">
					<form onsubmit={e => { e.preventDefault(); handleSaveBook(); }} class="space-y-6">
						<div class="grid grid-cols-2 gap-6">
							<div class="space-y-2">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Resource Title</label>
								<input bind:value={title} required class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-bold outline-none focus:bg-white transition-all" placeholder="Physics NCERT Class 12" />
							</div>
							<div class="space-y-2">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Author / Publisher</label>
								<input bind:value={author} required class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-bold outline-none focus:bg-white transition-all" placeholder="NCERT / Pearson" />
							</div>
						</div>

						<div class="grid grid-cols-2 gap-6">
							<div class="space-y-2">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Subject Area</label>
								<input bind:value={subject} required class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-bold outline-none focus:bg-white transition-all" placeholder="Science, Math, Arts..." />
							</div>
						<div class="grid grid-cols-2 gap-6">
							<div class="space-y-2">
								<label for="book-category" class="text-[10px] font-black uppercase tracking-widest text-slate-500">Unified Category</label>
								<select id="book-category" bind:value={categoryId} class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-bold outline-none focus:bg-white transition-all cursor-pointer">
									<option value="">Select Category (Optional)</option>
									{#each categories as cat}
										<option value={cat.id}>{cat.name}</option>
									{/each}
								</select>
							</div>
							<div class="space-y-2">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Resource File (PDF)</label>
								<div class="flex items-center gap-2">
									<input 
										bind:value={resourcePdfUrl} 
										class="flex-grow rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-bold outline-none focus:bg-white transition-all" 
										placeholder="Upload file or enter URL" 
									/>
									<label class="h-14 px-4 bg-slate-900 text-white rounded-2xl flex items-center justify-center gap-2 hover:bg-black transition-all cursor-pointer min-w-[120px]">
										<UploadCloud size={18} />
										<span class="text-xs font-black uppercase">{uploadStatus || 'Upload'}</span>
										<input type="file" accept=".pdf" class="hidden" onchange={handleUpload} />
									</label>
								</div>
							</div>
						</div>

						<div class="space-y-2">
							<div class="flex items-center justify-between">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Description</label>
								<label class="flex items-center gap-2 cursor-pointer">
									<input type="checkbox" bind:checked={isPublished} class="w-4 h-4 rounded text-blue-600 focus:ring-blue-500" />
									<span class="text-[10px] font-black uppercase text-slate-500">Published</span>
								</label>
							</div>
							<textarea bind:value={description} rows="4" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-5 text-sm font-medium outline-none focus:bg-white transition-all resize-none" placeholder="What is this book about?"></textarea>
						</div>

						<div class="pt-6 flex justify-end">
							<button 
								type="submit" 
								disabled={formLoading}
								class="px-12 py-5 rounded-[40px] bg-slate-900 text-white font-black text-basis shadow-2xl shadow-slate-200 hover:bg-black transition-all active:scale-95 flex items-center gap-2"
							>
								{#if formLoading}
									<Loader2 size={24} class="animate-spin" /> Storing...
								{:else}
									<Save size={24} /> {editingId ? 'Update Resource' : 'Index Resource'}
								{/if}
							</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
{/if}
