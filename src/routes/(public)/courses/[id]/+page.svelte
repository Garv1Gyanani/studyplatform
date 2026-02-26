<script lang="ts">
	import { page } from '$app/state';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		PlayCircle, 
		Clock, 
		Star, 
		Share2, 
		Bookmark, 
		ChevronRight, 
		Loader2,
		Youtube,
		Video,
		CheckCircle2,
		ArrowLeft,
		BarChart3
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';
	import { openLogin } from '$lib/stores/auth';

	let id = page.params.id;
	let video = $state<any>(null);
	let relatedVideos = $state<any[]>([]);
	let loading = $state(true);
	let user = $state<any>(null);
	let isBookmarked = $state(false);
	let isCompleted = $state(false);
	let completing = $state(false);
	let enrolledCount = $state(0);

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		user = sessionData.session?.user;

		// Fetch Main Video
		const { data: videoData } = await supabase
			.from('videos')
			.select('*, categories(name)')
			.eq('id', id)
			.single();
		
		video = videoData;

		if (videoData) {
			// Fetch Related
			const { data: relatedData } = await supabase
				.from('videos')
				.select('id, title, thumbnail_url, difficulty_level')
				.eq('category_id', videoData.category_id)
				.neq('id', id)
				.limit(4);
			
			relatedVideos = relatedData || [];
		}

		// Check bookmark & progress
		if (user) {
			const [bookmarkRes, progressRes] = await Promise.all([
				supabase
					.from('bookmarks')
					.select('*')
					.eq('user_id', user.id)
					.eq('content_id', id)
					.single(),
				supabase
					.from('video_progress')
					.select('*')
					.eq('user_id', user.id)
					.eq('video_id', id)
					.single()
			]);
			
			isBookmarked = !!bookmarkRes.data;
			isCompleted = progressRes.data?.completed || false;
		}

		// Enrolment count
		const { count } = await supabase
			.from('video_progress')
			.select('*', { count: 'exact', head: true })
			.eq('video_id', id);
		enrolledCount = count || 0;

		loading = false;
	});

	async function toggleBookmark() {
		if (!user) return openLogin();
		
		if (isBookmarked) {
			await supabase.from('bookmarks').delete().eq('user_id', user.id).eq('content_id', id);
			isBookmarked = false;
		} else {
			await supabase.from('bookmarks').insert({ 
				user_id: user.id, 
				content_type: 'video', 
				content_id: id 
			});
			isBookmarked = true;
		}
	}

	async function completeVideo() {
		if (!user) return openLogin();
		if (isCompleted || completing) return;

		completing = true;
		try {
			// Record progress
			const { error: progressError } = await supabase
				.from('video_progress')
				.upsert({
					user_id: user.id,
					video_id: id,
					completed: true,
					progress_seconds: 0,
					updated_at: new Date().toISOString()
				});
			
			if (progressError) throw progressError;

			// Award points
			await supabase.rpc('increment_points', { 
				user_id: user.id, 
				points_to_add: 100 
			});

			isCompleted = true;
		} catch (e) {
			console.error(e);
		} finally {
			completing = false;
		}
	}
</script>

<div class="min-h-screen bg-slate-50">
	{#if loading}
		<div class="flex h-[80vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if video}
		<div class="grid grid-cols-1 lg:grid-cols-12 max-w-[1920px] mx-auto">
			<!-- Main content - Video Player & Details -->
			<div class="lg:col-span-8 p-4 sm:p-8 space-y-8">
				<!-- Navigation Back -->
				<a href="/courses" class="inline-flex items-center gap-2 text-slate-500 hover:text-slate-900 font-bold text-sm mb-2 group">
					<ArrowLeft size={18} class="transition-transform group-hover:-translate-x-1" /> Back to Courses
				</a>

				<!-- Video Wrapper -->
				<div class="relative aspect-video w-full rounded-[40px] overflow-hidden bg-black shadow-2xl ring-1 ring-white/10 group">
					{#if !user}
						<div class="absolute inset-0 z-10 bg-slate-900/40 backdrop-blur-md flex flex-col items-center justify-center text-center p-8">
							<div class="h-16 w-16 rounded-3xl bg-white/10 border border-white/20 flex items-center justify-center text-white mb-6">
								<PlayCircle size={32} />
							</div>
							<h3 class="text-3xl font-black text-white tracking-tight">Login to watch this class</h3>
							<p class="text-slate-300 mt-2 max-w-sm">Join Code Shiksha today to access our full library of educational content.</p>
							<button 
								onclick={openLogin}
								class="mt-8 px-10 py-4 bg-blue-600 text-white font-black rounded-2xl shadow-xl shadow-blue-200/20 hover:bg-blue-700 transition-all active:scale-95"
							>
								Sign In to Unlock
							</button>
						</div>
					{/if}

					{#if video.youtube_url}
						{@const getYoutubeId = (url: string) => {
							const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
							const match = url.match(regExp);
							return (match && match[2].length === 11) ? match[2] : null;
						}}
						<iframe 
							width="100%" 
							height="100%" 
							src={`https://www.youtube.com/embed/${getYoutubeId(video.youtube_url)}`}
							title={video.title}
							frameborder="0"
							allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
							allowfullscreen
						></iframe>
					{:else if video.video_url}
						<!-- svelte-ignore a11y_media_has_caption -->
						<video class="w-full h-full" controls poster={video.thumbnail_url}>
							<source src={video.video_url} type="video/mp4" />
						</video>
					{:else}
						<div class="flex items-center justify-center h-full text-slate-500">
							<Video size={120} class="opacity-10" />
						</div>
					{/if}
				</div>

				<!-- Header Info -->
				<div class="space-y-6">
					<div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
						<div class="space-y-2">
							<div class="flex items-center gap-2">
								<span class="px-3 py-1 bg-blue-600 text-[10px] font-black uppercase tracking-widest text-white rounded-lg">
									{video.categories?.name || 'General'}
								</span>
								<div class="flex items-center gap-1.5 text-amber-500 font-bold text-xs bg-amber-50 px-2 py-1 rounded-lg border border-amber-100">
									<Star size={12} fill="currentColor" /> 4.9
								</div>
							</div>
							<h1 class="text-3xl font-black text-slate-900 tracking-tight leading-tight">{video.title}</h1>
						</div>

						<div class="flex items-center gap-3">
							<button 
								onclick={toggleBookmark}
								class={cn("flex items-center gap-2 rounded-2xl px-6 py-4 font-black text-sm border-2 transition-all", 
									isBookmarked 
										? "bg-slate-900 border-slate-900 text-white" 
										: "bg-white border-slate-100 text-slate-500 hover:border-slate-200"
								)}
							>
								<Bookmark size={20} fill={isBookmarked ? "currentColor" : "none"} />
								{isBookmarked ? 'Saved' : 'Save'}
							</button>
							<button class="flex items-center justify-center h-14 w-14 rounded-2xl bg-white border-2 border-slate-100 text-slate-400 hover:text-slate-900 hover:border-slate-200 transition-all">
								<Share2 size={24} />
							</button>
						</div>
					</div>

					<div class="grid grid-cols-2 sm:grid-cols-4 gap-4 p-6 bg-white rounded-[32px] border border-slate-100 shadow-sm">
						<div class="space-y-1">
							<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Duration</p>
							<p class="font-bold text-slate-900 flex items-center gap-2"><Clock size={16} class="text-blue-500" /> {video.duration || '15m'}</p>
						</div>
						<div class="space-y-1">
							<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Level</p>
							<p class="font-bold text-slate-900 flex items-center gap-2 uppercase"><BarChart3 size={16} class="text-purple-500" /> {video.difficulty_level}</p>
						</div>
						<div class="space-y-1">
							<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Published</p>
							<p class="font-bold text-slate-900">{new Date(video.created_at).toLocaleDateString()}</p>
						</div>
						<div class="space-y-1">
							<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Students</p>
							<p class="font-bold text-slate-900">{enrolledCount.toLocaleString()} Enrolled</p>
						</div>
					</div>

					<div class="bg-white rounded-[40px] p-8 sm:p-10 border border-slate-100 shadow-sm">
						<h2 class="text-xl font-black text-slate-900 mb-6">About this Class</h2>
						<p class="text-slate-500 font-medium text-lg leading-relaxed whitespace-pre-wrap">
							{video.description}
						</p>
					</div>
				</div>
			</div>

			<!-- Sidebar - Related Content -->
			<div class="lg:col-span-4 p-4 sm:p-8 lg:border-l border-slate-200 bg-slate-50/50 space-y-8">
				<h3 class="text-xl font-black text-slate-900">Up Next</h3>
				
				<div class="space-y-6">
					{#each relatedVideos as rel}
						<a 
							href={`/courses/${rel.id}`}
							class="group flex gap-4 p-4 rounded-3xl bg-white border border-slate-100 shadow-sm hover:shadow-xl hover:translate-y-[-2px] transition-all"
						>
							<div class="h-20 w-32 rounded-2xl overflow-hidden bg-slate-100 flex-shrink-0 relative">
								{#if rel.thumbnail_url}
									<img src={rel.thumbnail_url} alt="" class="h-full w-full object-cover" />
								{:else}
									<div class="h-full w-full flex items-center justify-center text-slate-300">
										<PlayCircle size={24} />
									</div>
								{/if}
								<div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
							</div>
							<div class="flex flex-col justify-between py-1">
								<h4 class="font-bold text-slate-900 line-clamp-2 leading-tight group-hover:text-blue-600 transition-colors">
									{rel.title}
								</h4>
								<div class="flex items-center justify-between mt-2">
									<span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">{rel.difficulty_level}</span>
									<ChevronRight size={18} class="text-slate-300 group-hover:text-blue-600 transition-colors" />
								</div>
							</div>
						</a>
					{/each}
				</div>

				<!-- Mastery Widget -->
				<div class={cn("rounded-[40px] p-10 text-white relative overflow-hidden shadow-2xl transition-all duration-700", 
					isCompleted ? "bg-green-600" : "bg-indigo-600"
				)}>
					<div class="absolute -right-10 -bottom-10 h-40 w-40 bg-white blur-[80px] opacity-20"></div>
					<div class="relative z-10 flex flex-col items-center text-center">
						<div class={cn("h-16 w-16 rounded-[24px] bg-white flex items-center justify-center mb-6 shadow-xl transition-all", 
							isCompleted ? "text-green-600" : "text-indigo-600"
						)}>
							{#if isCompleted}
								<div in:scale>
									<CheckCircle2 size={32} />
								</div>
							{:else}
								<Star size={32} />
							{/if}
						</div>
						
						<h3 class="text-2xl font-black leading-tight">
							{isCompleted ? "Topic Mastered!" : "Master this topic!"}
						</h3>
						<p class="mt-2 text-indigo-50 text-sm font-medium">
							{isCompleted 
								? "Great job! You've earned 100 XP for completing this class." 
								: "Watch the full class and mark as complete to earn 100 XP."}
						</p>

						{#if !isCompleted}
							<button 
								onclick={completeVideo}
								disabled={completing}
								class="mt-8 w-full py-4 rounded-2xl bg-white text-indigo-600 font-black text-sm hover:scale-105 active:scale-95 transition-all flex items-center justify-center gap-2"
							>
								{#if completing}
									<Loader2 size={18} class="animate-spin" /> RECORDING...
								{:else}
									<CheckCircle2 size={18} /> Mark as Complete
								{/if}
							</button>
						{:else}
							<a 
								href="/quizzes" 
								class="mt-8 w-full py-4 rounded-2xl bg-white/20 text-white font-black text-sm hover:bg-white/30 transition-all flex items-center justify-center gap-2"
							>
								Try a Related Quiz <ChevronRight size={18} />
							</a>
						{/if}
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
