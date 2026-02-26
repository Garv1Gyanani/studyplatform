<script lang="ts">
	import { 
		Plus, 
		Search, 
		Filter, 
		MoreVertical, 
		Eye, 
		Edit2, 
		Trash2, 
		Video, 
		Youtube, 
		UploadCloud,
		X,
		Loader2,
		CheckCircle2,
		Clock
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let videos = $state<any[]>([]);
	let categories = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Form State
	let title = $state('');
	let description = $state('');
	let source = $state<'upload' | 'youtube'>('youtube');
	let youtubeUrl = $state('');
	let categoryId = $state('');
	let difficulty = $state('beginner');
	let duration = $state('15m');
	let isPublished = $state(true);
	let editingId = $state<string | null>(null);

	onMount(async () => {
		fetchVideos();
		fetchCategories();
	});

	async function fetchCategories() {
		const { data } = await supabase.from('categories').select('*').order('name');
		categories = data || [];
	}

	async function fetchVideos() {
		loading = true;
		const { data, error } = await supabase
			.from('videos')
			.select('*, categories(name)')
			.order('created_at', { ascending: false });
		
		if (!error) videos = data;
		loading = false;
	}

	async function handleSaveVideo() {
		formLoading = true;
		
		const videoData = {
			title,
			description,
			youtube_url: source === 'youtube' ? youtubeUrl : null,
			category_id: categoryId || null,
			difficulty_level: difficulty,
			duration,
			is_published: isPublished
		};

		const { error } = editingId 
			? await supabase.from('videos').update(videoData).eq('id', editingId)
			: await supabase.from('videos').insert(videoData);

		if (!error) {
			isFormOpen = false;
			resetForm();
			fetchVideos();
		} else {
			alert(error.message);
		}
		formLoading = false;
	}

	function startEdit(video: any) {
		editingId = video.id;
		title = video.title;
		description = video.description || '';
		categoryId = video.category_id || '';
		difficulty = video.difficulty_level;
		duration = video.duration || '15m';
		isPublished = video.is_published;
		source = video.youtube_url ? 'youtube' : 'upload';
		youtubeUrl = video.youtube_url || '';
		isFormOpen = true;
	}

	function resetForm() {
		editingId = null;
		title = '';
		description = '';
		youtubeUrl = '';
		categoryId = '';
		difficulty = 'beginner';
		duration = '15m';
		isPublished = true;
		source = 'youtube';
	}

	async function deleteVideo(id: string) {
		if (confirm('Are you sure you want to delete this video?')) {
			const { error } = await supabase.from('videos').delete().match({ id });
			if (!error) fetchVideos();
		}
	}

	async function togglePublish(video: any) {
		const { error } = await supabase
			.from('videos')
			.update({ is_published: !video.is_published })
			.match({ id: video.id });
		if (!error) fetchVideos();
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Video Courses</h1>
			<p class="mt-1 text-slate-500">Manage your educational video content and courses.</p>
		</div>
		<button 
			onclick={() => { resetForm(); fetchCategories(); isFormOpen = true; }}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 active:scale-95"
		>
			<Plus size={18} />
			New Video Course
		</button>
	</div>

	<!-- Filters & Search -->
	<div class="flex flex-col gap-4 lg:flex-row lg:items-center">
		<div class="relative flex-grow">
			<Search size={18} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
			<input 
				type="text" 
				placeholder="Search by title, description, or category..." 
				class="w-full rounded-2xl border border-slate-200 bg-white py-3 pl-12 pr-4 text-sm outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500"
			/>
		</div>
		<div class="flex items-center gap-2">
			<button class="inline-flex h-11 items-center gap-2 rounded-2xl border border-slate-200 bg-white px-4 text-sm font-bold text-slate-600 hover:bg-slate-50">
				<Filter size={18} />
				Filters
			</button>
			<button class="inline-flex h-11 items-center gap-2 rounded-2xl border border-slate-200 bg-white px-4 text-sm font-bold text-slate-600 hover:bg-slate-50">
				Category
			</button>
		</div>
	</div>

	<!-- Video Table -->
	<div class="relative overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
		{#if loading}
			<div class="flex h-64 flex-col items-center justify-center gap-3">
				<Loader2 size={32} class="animate-spin text-blue-600" />
				<p class="text-sm font-medium text-slate-500">Loading courses...</p>
			</div>
		{:else if videos.length === 0}
			<div class="flex h-96 flex-col items-center justify-center gap-4 text-center p-8">
				<div class="flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-50 text-slate-300">
					<Video size={40} />
				</div>
				<div>
					<h3 class="text-lg font-bold text-slate-900">No videos yet</h3>
					<p class="mt-1 max-w-xs text-sm text-slate-500">
						Getting started is easy! Create your first video course to start teaching your students.
					</p>
				</div>
				<button 
					onclick={() => isFormOpen = true}
					class="mt-2 text-sm font-bold text-blue-600 hover:text-blue-700"
				>
					Add your first video &rarr;
				</button>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Course / Video</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Category</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Level</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Status</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each videos as video}
							<tr class="group transition-colors hover:bg-slate-50/30">
								<td class="px-6 py-4">
									<div class="flex items-center gap-3">
										<div class="relative h-12 w-20 flex-shrink-0 overflow-hidden rounded-lg bg-slate-100 ring-1 ring-slate-200">
											{#if video.thumbnail_url}
												<img src={video.thumbnail_url} alt="" class="h-full w-full object-cover" />
											{:else}
												<div class="flex h-full w-full items-center justify-center text-slate-300">
													{#if video.youtube_url}
														<Youtube size={20} />
													{:else}
														<Video size={20} />
													{/if}
												</div>
											{/if}
										</div>
										<div>
											<p class="text-sm font-bold text-slate-900 line-clamp-1">{video.title}</p>
											<p class="text-xs text-slate-400 mt-0.5">{video.youtube_url ? 'YouTube' : 'Upload'}</p>
										</div>
									</div>
								</td>
								<td class="px-6 py-4">
									<span class="inline-flex items-center rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-bold text-slate-600 uppercase tracking-wider">
										{video.categories?.name || 'Uncategorized'}
									</span>
								</td>
								<td class="px-6 py-4">
									<span class={cn("text-xs font-bold uppercase tracking-widest", {
										'text-green-600': video.difficulty_level === 'beginner',
										'text-blue-600': video.difficulty_level === 'intermediate',
										'text-purple-600': video.difficulty_level === 'advanced',
									})}>
										{video.difficulty_level}
									</span>
								</td>
								<td class="px-6 py-4">
									<button 
										onclick={() => togglePublish(video)}
										class={cn("inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-bold ring-1 ring-inset", {
											'bg-green-50 text-green-700 ring-green-600/20': video.is_published,
											'bg-slate-50 text-slate-600 ring-slate-500/20': !video.is_published,
										})}
									>
										{#if video.is_published}
											<CheckCircle2 size={12} />
											Published
										{:else}
											<Clock size={12} />
											Draft
										{/if}
									</button>
								</td>
								<td class="px-6 py-4 text-right">
									<div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
										<button class="rounded-lg p-2 text-slate-400 hover:bg-blue-50 hover:text-blue-600">
											<Eye size={18} />
										</button>
										<button 
											onclick={() => { startEdit(video); fetchCategories(); }}
											class="rounded-lg p-2 text-slate-400 hover:bg-amber-50 hover:text-amber-600"
										>
											<Edit2 size={18} />
										</button>
										<button 
											onclick={() => deleteVideo(video.id)}
											class="rounded-lg p-2 text-slate-400 hover:bg-red-50 hover:text-red-600"
										>
											<Trash2 size={18} />
										</button>
										<button class="rounded-lg p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-900">
											<MoreVertical size={18} />
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

<!-- Modal Form -->
{#if isFormOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={() => isFormOpen = false}
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-2xl overflow-hidden rounded-3xl bg-white shadow-2xl"
			onclick={e => e.stopPropagation()}
		>
			<div class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
				<h2 class="text-xl font-bold text-slate-900">
					{editingId ? 'Edit Video Course' : 'Add New Video Course'}
				</h2>
				<button 
					onclick={() => isFormOpen = false}
					class="rounded-full p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-900 transition-colors"
				>
					<X size={20} />
				</button>
			</div>

			<div class="max-h-[70vh] overflow-y-auto p-8">
				<form onsubmit={e => { e.preventDefault(); handleSaveVideo(); }} class="space-y-6">
					<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
						<div class="space-y-2">
							<label for="title" class="text-xs font-bold uppercase tracking-widest text-slate-500">Course Title</label>
							<input 
								id="title"
								bind:value={title}
								required
								placeholder="e.g. Mastering Advanced React Patterns"
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500 focus:bg-white"
							/>
						</div>
						<div class="space-y-2">
							<label for="category" class="text-xs font-bold uppercase tracking-widest text-slate-500">Category</label>
							<select 
								id="category"
								bind:value={categoryId}
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white cursor-pointer"
							>
								<option value="">Select Category</option>
								{#each categories as cat}
									<option value={cat.id}>{cat.name}</option>
								{/each}
							</select>
						</div>
					</div>

					<div class="space-y-2">
						<label for="description" class="text-xs font-bold uppercase tracking-widest text-slate-500">Description</label>
						<textarea 
							id="description"
							bind:value={description}
							rows="3"
							placeholder="What will students learn in this course?"
							class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500 focus:bg-white resize-none"
						></textarea>
					</div>

					<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
						<div class="space-y-2">
							<label class="text-xs font-bold uppercase tracking-widest text-slate-500">Video Source</label>
							<div class="flex rounded-xl bg-slate-100 p-1">
								<button 
									type="button"
									onclick={() => source = 'youtube'}
									class={cn("flex flex-1 items-center justify-center gap-2 rounded-lg py-2 text-xs font-bold transition-all", source === 'youtube' ? "bg-white text-blue-600 shadow-sm" : "text-slate-500 hover:text-slate-900")}
								>
									<Youtube size={14} />
									YouTube
								</button>
								<button 
									type="button"
									onclick={() => source = 'upload'}
									class={cn("flex flex-1 items-center justify-center gap-2 rounded-lg py-2 text-xs font-bold transition-all", source === 'upload' ? "bg-white text-blue-600 shadow-sm" : "text-slate-500 hover:text-slate-900")}
								>
									<UploadCloud size={14} />
									Upload
								</button>
							</div>
						</div>
						<div class="space-y-2">
							<label for="difficulty" class="text-xs font-bold uppercase tracking-widest text-slate-500">Difficulty Level</label>
							<select 
								id="difficulty"
								bind:value={difficulty}
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 focus:bg-white cursor-pointer"
							>
								<option value="beginner">Beginner</option>
								<option value="intermediate">Intermediate</option>
								<option value="advanced">Advanced</option>
							</select>
						</div>
						<div class="space-y-2">
							<label for="duration" class="text-xs font-bold uppercase tracking-widest text-slate-500">Duration</label>
							<input 
								id="duration"
								bind:value={duration}
								placeholder="e.g. 15m, 1h 20m"
								class="block w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500 focus:bg-white"
							/>
						</div>
					</div>

					{#if source === 'youtube'}
						<div class="space-y-2" transition:fly={{ y: -10, duration: 200 }}>
							<label for="youtube" class="text-xs font-bold uppercase tracking-widest text-slate-500">YouTube URL</label>
							<div class="relative">
								<Youtube size={16} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
								<input 
									id="youtube"
									bind:value={youtubeUrl}
									required
									placeholder="https://youtube.com/watch?v=..."
									class="block w-full rounded-xl border border-slate-200 bg-slate-50 py-3 pl-11 pr-4 text-sm outline-none ring-blue-500/10 focus:ring-4 focus:border-blue-500 focus:bg-white"
								/>
							</div>
						</div>
					{:else}
						<div class="space-y-2" transition:fly={{ y: -10, duration: 200 }}>
							<label class="text-xs font-bold uppercase tracking-widest text-slate-500">Upload MP4 File</label>
							<div class="flex flex-col items-center justify-center rounded-2xl border-2 border-dashed border-slate-200 bg-slate-50 py-10 transition-colors hover:border-blue-400 hover:bg-blue-50/10">
								<UploadCloud size={32} class="text-slate-400" />
								<p class="mt-2 text-sm font-medium text-slate-500">Click to select or drag and drop</p>
								<p class="text-xs text-slate-400 mt-1">MP4 or WebM (Max 50MB)</p>
								<input type="file" class="hidden" accept="video/*" />
							</div>
						</div>
					{/if}

					<div class="flex items-center justify-between py-4 border-t border-slate-100">
						<label class="flex items-center gap-3 cursor-pointer">
							<div class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full bg-slate-200 transition-colors" class:bg-blue-600={isPublished}>
								<input type="checkbox" bind:checked={isPublished} class="sr-only" />
								<span class={cn("inline-block h-4 w-4 transform rounded-full bg-white transition-transform", isPublished ? "translate-x-6" : "translate-x-1")}></span>
							</div>
							<span class="text-sm font-bold text-slate-700">Publish immediately</span>
						</label>

						<div class="flex items-center gap-3">
							<button 
								type="button"
								onclick={() => isFormOpen = false}
								class="rounded-xl px-6 py-3 text-sm font-bold text-slate-500 hover:bg-slate-50"
							>
								Cancel
							</button>
							<button 
								type="submit"
								disabled={formLoading}
								class="flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-10 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 disabled:opacity-70"
							>
								{#if formLoading}
									<Loader2 size={18} class="animate-spin" />
									Saving...
								{:else}
									{editingId ? 'Save Changes' : 'Save Video'}
								{/if}
							</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
{/if}
