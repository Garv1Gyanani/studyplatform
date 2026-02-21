<script lang="ts">
	import { 
		Plus, 
		Search, 
		Filter, 
		MoreVertical, 
		Eye, 
		Edit2, 
		Trash2, 
		BookOpen, 
		FileText,
		X,
		Loader2,
		CheckCircle2,
		Clock,
		Image as ImageIcon,
		Calendar
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let blogs = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Form State
	let title = $state('');
	let excerpt = $state('');
	let content = $state('');
	let slug = $state('');
	let isPublished = $state(false);

	onMount(fetchBlogs);

	async function fetchBlogs() {
		loading = true;
		const { data, error } = await supabase
			.from('blogs')
			.select('*, profiles(username)')
			.order('created_at', { ascending: false });
		
		if (!error) blogs = data;
		loading = false;
	}

	function generateSlug() {
		slug = title.toLowerCase().replace(/ /g, '-').replace(/[^\w-]+/g, '');
	}

	async function handleSaveBlog() {
		formLoading = true;
		const { data: { user } } = await supabase.auth.getUser();
		
		const { error } = await supabase.from('blogs').insert({
			title,
			slug: slug || title.toLowerCase().replace(/ /g, '-'),
			excerpt,
			content,
			is_published: isPublished,
			author_id: user?.id,
			published_at: isPublished ? new Date().toISOString() : null
		});

		if (!error) {
			isFormOpen = false;
			resetForm();
			fetchBlogs();
		} else {
			alert(error.message);
		}
		formLoading = false;
	}

	function resetForm() {
		title = '';
		excerpt = '';
		content = '';
		slug = '';
		isPublished = false;
	}

	async function deleteBlog(id: string) {
		if (confirm('Are you sure you want to delete this blog post?')) {
			const { error } = await supabase.from('blogs').delete().match({ id });
			if (!error) fetchBlogs();
		}
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Blog Posts</h1>
			<p class="mt-1 text-slate-500">Manage educational articles, news, and insights.</p>
		</div>
		<button 
			onclick={() isFormOpen = true}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 active:scale-95"
		>
			<Plus size={18} />
			Write New Post
		</button>
	</div>

	<!-- Filters & Search -->
	<div class="flex flex-col gap-4 lg:flex-row lg:items-center">
		<div class="relative flex-grow">
			<Search size={18} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
			<input 
				type="text" 
				placeholder="Search blogs..." 
				class="w-full rounded-2xl border border-slate-200 bg-white py-3 pl-12 pr-4 text-sm outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500"
			/>
		</div>
		<div class="flex items-center gap-2">
			<button class="inline-flex h-11 items-center gap-2 rounded-2xl border border-slate-200 bg-white px-4 text-sm font-bold text-slate-600 hover:bg-slate-50">
				<Filter size={18} />
				Sort by Date
			</button>
		</div>
	</div>

	<!-- Blog List -->
	<div class="relative overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
		{#if loading}
			<div class="flex h-64 flex-col items-center justify-center gap-3">
				<Loader2 size={32} class="animate-spin text-blue-600" />
				<p class="text-sm font-medium text-slate-500">Loading blogs...</p>
			</div>
		{:else if blogs.length === 0}
			<div class="flex h-96 flex-col items-center justify-center gap-4 text-center p-8">
				<div class="flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-50 text-slate-300">
					<BookOpen size={40} />
				</div>
				<div>
					<h3 class="text-lg font-bold text-slate-900">No blog posts yet</h3>
					<p class="mt-1 max-w-xs text-sm text-slate-500">
						Start sharing knowledge with your students by writing your first article.
					</p>
				</div>
				<button 
					onclick={() => isFormOpen = true}
					class="mt-2 text-sm font-bold text-blue-600 hover:text-blue-700"
				>
					Create your first post &rarr;
				</button>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Post Details</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Author</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Date</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Status</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each blogs as blog}
							<tr class="group transition-colors hover:bg-slate-50/30">
								<td class="px-6 py-4">
									<div class="flex items-center gap-3">
										<div class="h-10 w-10 flex-shrink-0 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
											<FileText size={20} />
										</div>
										<div>
											<p class="text-sm font-bold text-slate-900 line-clamp-1">{blog.title}</p>
											<p class="text-xs text-slate-400 mt-0.5">/{blog.slug}</p>
										</div>
									</div>
								</td>
								<td class="px-6 py-4">
									<p class="text-sm font-medium text-slate-600">{blog.profiles?.username || 'Admin'}</p>
								</td>
								<td class="px-6 py-4">
									<div class="flex items-center gap-2 text-xs font-medium text-slate-500">
										<Calendar size={14} />
										{new Date(blog.created_at).toLocaleDateString()}
									</div>
								</td>
								<td class="px-6 py-4">
									<span class={cn("inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-bold ring-1 ring-inset", {
										'bg-green-50 text-green-700 ring-green-600/20': blog.is_published,
										'bg-slate-50 text-slate-600 ring-slate-500/20': !blog.is_published,
									})}>
										{blog.is_published ? 'Published' : 'Draft'}
									</span>
								</td>
								<td class="px-6 py-4 text-right">
									<div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
										<button class="rounded-lg p-2 text-slate-400 hover:bg-blue-50 hover:text-blue-600">
											<Edit2 size={18} />
										</button>
										<button 
											onclick={() => deleteBlog(blog.id)}
											class="rounded-lg p-2 text-slate-400 hover:bg-red-50 hover:text-red-600"
										>
											<Trash2 size={18} />
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

<!-- Form Modal -->
{#if isFormOpen}
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={() => isFormOpen = false}
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-4xl overflow-hidden rounded-3xl bg-white shadow-2xl"
			onclick={e => e.stopPropagation()}
		>
			<div class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
				<h2 class="text-xl font-bold text-slate-900">Write New Blog Post</h2>
				<button onclick={() => isFormOpen = false} class="rounded-full p-2 text-slate-400 hover:bg-slate-100 transition-colors">
					<X size={20} />
				</button>
			</div>

			<div class="max-h-[80vh] overflow-y-auto p-8">
				<form onsubmit={e => { e.preventDefault(); handleSaveBlog(); }} class="space-y-6">
					<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
						<div class="space-y-2">
							<label for="blog-title" class="text-xs font-bold uppercase tracking-widest text-slate-500">Post Title</label>
							<input 
								id="blog-title"
								bind:value={title}
								oninput={generateSlug}
								required
								placeholder="The Future of Web Development..."
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white"
							/>
						</div>
						<div class="space-y-2">
							<label for="blog-slug" class="text-xs font-bold uppercase tracking-widest text-slate-500">URL Slug</label>
							<input 
								id="blog-slug"
								bind:value={slug}
								placeholder="the-future-of-web"
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white"
							/>
						</div>
					</div>

					<div class="space-y-2">
						<label for="blog-excerpt" class="text-xs font-bold uppercase tracking-widest text-slate-500">Excerpt (Short Preview)</label>
						<textarea 
							id="blog-excerpt"
							bind:value={excerpt}
							rows="2"
							placeholder="A brief summary shown to guests..."
							class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white resize-none"
						></textarea>
					</div>

					<div class="space-y-2">
						<label for="blog-content" class="text-xs font-bold uppercase tracking-widest text-slate-500">Full Content</label>
						<div class="rounded-2xl border border-slate-200 bg-slate-50 overflow-hidden">
							<div class="flex items-center gap-1 border-b border-slate-200 bg-white p-2">
								<button type="button" class="rounded-lg p-2 text-slate-400 hover:bg-slate-50 hover:text-slate-900"><ImageIcon size={18} /></button>
								<div class="h-4 w-px bg-slate-200 mx-1"></div>
								<span class="text-xs font-bold text-slate-400 px-2 italic">Rich text editor placeholder</span>
							</div>
							<textarea 
								id="blog-content"
								bind:value={content}
								rows="12"
								placeholder="Start writing your article here..."
								class="block w-full bg-transparent px-6 py-6 text-base outline-none ring-blue-500/10 focus:ring-inset focus:ring-4"
							></textarea>
						</div>
					</div>

					<div class="flex items-center justify-between pt-6 border-t border-slate-100">
						<label class="flex items-center gap-3 cursor-pointer">
							<div class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full bg-slate-200 transition-colors" class:bg-blue-600={isPublished}>
								<input type="checkbox" bind:checked={isPublished} class="sr-only" />
								<span class={cn("inline-block h-4 w-4 transform rounded-full bg-white transition-transform", isPublished ? "translate-x-6" : "translate-x-1")}></span>
							</div>
							<span class="text-sm font-bold text-slate-700">Publish to live site</span>
						</label>

						<div class="flex items-center gap-3">
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
									Save Blog Post
								{/if}
							</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
{/if}
