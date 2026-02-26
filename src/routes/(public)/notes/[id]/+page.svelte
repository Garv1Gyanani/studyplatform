<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import { 
		ArrowLeft, 
		BookMarked, 
		Calendar, 
		Loader2, 
		Share2, 
		Bookmark,
		FileText,
		Clock,
		User
	} from 'lucide-svelte';
	import { fade, fly } from 'svelte/transition';
	import { cn } from '$lib/utils';

	const { id } = page.params;
	let note = $state<any>(null);
	let loading = $state(true);
	let isBookmarked = $state(false);

	onMount(async () => {
		const { data, error } = await supabase
			.from('notes')
			.select('*, categories(name)')
			.eq('id', id)
			.single();
		
		if (!error) note = data;
		loading = false;
	});

	async function toggleBookmark() {
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) return alert('Please login to bookmark');

		if (isBookmarked) {
			await supabase.from('bookmarks').delete().match({ user_id: user.id, content_id: id });
			isBookmarked = false;
		} else {
			await supabase.from('bookmarks').insert({
				user_id: user.id,
				content_id: id,
				content_type: 'note'
			});
			isBookmarked = true;
		}
	}
</script>

<div class="min-h-screen bg-white">
	{#if loading}
		<div class="flex h-[80vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-purple-600" />
		</div>
	{:else if note}
		<!-- Header -->
		<header class="bg-slate-50 border-b border-slate-100 py-12 px-4 sm:px-8">
			<div class="max-w-4xl mx-auto space-y-8">
				<a href="/notes" class="inline-flex items-center gap-2 text-slate-500 hover:text-slate-900 font-bold text-sm mb-4 group transition-all">
					<ArrowLeft size={18} class="group-hover:-translate-x-1 transition-transform" /> Back to Notes
				</a>

				<div class="flex flex-col md:flex-row md:items-center justify-between gap-6">
					<div class="space-y-4">
						<div class="flex items-center gap-3">
							<span class="px-3 py-1 bg-purple-600 text-[10px] font-black uppercase tracking-widest text-white rounded-lg">
								{note.categories?.name || 'General'}
							</span>
							<span class="px-3 py-1 bg-white border border-slate-200 text-[10px] font-black uppercase tracking-widest text-slate-500 rounded-lg">
								{note.topic || 'Subject Matter'}
							</span>
						</div>
						<h1 class="text-4xl md:text-6xl font-black text-slate-900 tracking-tight leading-[1.1]">
							{note.title}
						</h1>
						<div class="flex flex-wrap items-center gap-6 pt-2">
							<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
								<Calendar size={14} />
								{new Date(note.created_at).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })}
							</div>
							<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
								<Clock size={14} />
								5 min read
							</div>
							<div class="flex items-center gap-2 text-xs font-bold text-slate-400">
								<User size={14} />
								By Expert Tutors
							</div>
						</div>
					</div>

					<div class="flex items-center gap-3">
						<button 
							onclick={toggleBookmark}
							class={cn(
								"p-4 rounded-2xl border transition-all shadow-sm",
								isBookmarked ? "bg-purple-600 border-purple-600 text-white" : "bg-white border-slate-200 text-slate-400 hover:text-slate-900"
							)}
						>
							<Bookmark size={20} fill={isBookmarked ? "currentColor" : "none"} />
						</button>
						<button class="flex items-center gap-2 px-6 py-4 bg-slate-900 text-white font-black rounded-2xl shadow-xl shadow-slate-200 hover:bg-black transition-all active:scale-95">
							<Share2 size={20} />
							Share Note
						</button>
					</div>
				</div>
			</div>
		</header>

		<!-- Content -->
		<main class="max-w-4xl mx-auto px-4 sm:px-8 py-16">
			<div class="prose prose-slate prose-lg max-w-none">
				<div class="flex items-center gap-4 mb-12 p-8 rounded-[40px] bg-slate-50 border border-slate-100">
					<div class="h-12 w-12 rounded-2xl bg-white shadow-sm flex items-center justify-center text-purple-600">
						<FileText size={24} />
					</div>
					<div class="flex-grow">
						<p class="text-xs font-black uppercase tracking-widest text-slate-400">Resource Overview</p>
						<p class="text-sm font-bold text-slate-600 mt-0.5">This note covers key concepts, definitions, and summarized examples.</p>
					</div>
					{#if note.pdf_url}
						<a 
							href={note.pdf_url} 
							target="_blank" 
							class="px-6 py-3 bg-white border border-slate-200 text-slate-900 font-black rounded-2xl flex items-center gap-2 hover:bg-slate-50 transition-all shadow-sm"
						>
							<FileText size={18} class="text-purple-600" />
							Download PDF Material
						</a>
					{/if}
				</div>

				<div class="whitespace-pre-wrap font-medium text-slate-700 leading-relaxed text-lg pb-20">
					{note.content}
				</div>

				<!-- Footer CTA -->
				<div class="mt-20 p-10 md:p-16 rounded-[60px] bg-gradient-to-br from-purple-600 to-indigo-700 text-white relative overflow-hidden group">
					<div class="absolute -right-20 -bottom-20 h-80 w-80 bg-white/10 blur-[100px] rounded-full group-hover:bg-white/20 transition-all duration-700"></div>
					<div class="relative z-10 space-y-8">
						<div class="h-16 w-16 bg-white/20 backdrop-blur-md rounded-3xl flex items-center justify-center">
							<BookMarked size={32} />
						</div>
						<div class="space-y-4 max-w-xl">
							<h3 class="text-4xl font-black tracking-tight">Master this topic?</h3>
							<p class="text-lg text-purple-100 font-medium">Take our practice quiz to test your knowledge retention on this subject.</p>
						</div>
						<a 
							href="/quizzes" 
							class="inline-flex px-12 py-5 bg-white text-purple-600 font-black rounded-2xl shadow-2xl shadow-purple-900/40 hover:scale-105 transition-all text-lg"
						>
							Start Practice Assessment
						</a>
					</div>
				</div>
			</div>
		</main>
	{:else}
		<div class="flex h-[80vh] flex-col items-center justify-center text-center">
			<h2 class="text-3xl font-black text-slate-900">Note not found</h2>
			<a href="/notes" class="mt-4 text-purple-600 font-bold hover:underline">Back to archive</a>
		</div>
	{/if}
</div>
