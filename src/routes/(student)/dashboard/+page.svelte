<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		LayoutDashboard, 
		Trophy, 
		BookOpen, 
		Clock, 
		ChevronRight, 
		Star, 
		TrendingUp, 
		CheckCircle2, 
		Loader2,
		PlayCircle,
		ArrowUpRight
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let user = $state<any>(null);
	let profile = $state<any>(null);
	let stats = $state<any>({
		completedQuizzes: 0,
		totalPoints: 0,
		watchTime: '0h',
		rank: '--'
	});
	let recentAttempts = $state<any[]>([]);
	let recommendations = $state<any[]>([]);
	let loading = $state(true);

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		user = sessionData.session?.user;

		if (user) {
			// Fetch Profile
			const { data: profileData } = await supabase
				.from('profiles')
				.select('*')
				.eq('id', user.id)
				.single();
			profile = profileData;

			// Fetch Attempts
			const { data: attemptsData } = await supabase
				.from('quiz_attempts')
				.select('*, quizzes(*, videos(thumbnail_url))')
				.eq('user_id', user.id)
				.order('completed_at', { ascending: false });
			
			recentAttempts = attemptsData?.slice(0, 5) || [];

			// Fetch Rank
			const { count: higherCount } = await supabase
				.from('profiles')
				.select('*', { count: 'exact', head: true })
				.gt('points', profileData?.points || 0);
			
			const rank = higherCount !== null ? `#${higherCount + 1}` : '--';

			// Fetch Recommendations (Latest videos)
			const { data: recData } = await supabase
				.from('videos')
				.select('*, categories(name)')
				.order('created_at', { ascending: false })
				.limit(3);
			
			recommendations = recData?.map(v => ({
				id: v.id,
				title: v.title,
				thumbnail_url: v.thumbnail_url,
				category: v.categories?.name || 'General',
				level: v.difficulty_level,
				points: 100 // Default points for completion
			})) || [];

			// Fetch Watch Time
			const { data: progressData } = await supabase
				.from('video_progress')
				.select('progress_seconds')
				.eq('user_id', user.id);
			
			const totalSeconds = progressData?.reduce((acc, curr) => acc + (curr.progress_seconds || 0), 0) || 0;
			const watchTime = totalSeconds > 0 
				? `${Math.floor(totalSeconds / 60)}m`
				: '0m';

			// Update Stats
			stats = {
				completedQuizzes: attemptsData?.length || 0,
				totalPoints: profileData?.points || 0,
				watchTime: watchTime,
				rank: rank
			};
		}
		loading = false;
	});
</script>

<div class="px-4 sm:px-8 py-10 max-w-7xl mx-auto space-y-10">
	{#if loading}
		<div class="flex h-[60vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if !user}
		<div class="text-center py-20 bg-white rounded-[40px] border border-slate-100 shadow-sm">
			<h2 class="text-2xl font-black text-slate-900">Please Sign In</h2>
			<p class="text-slate-500 mt-2">Access your personal dashboard by logging in.</p>
		</div>
	{:else}
		<!-- Welcome Header -->
		<div class="flex flex-col md:flex-row md:items-center justify-between gap-8 mb-12" in:fade>
			<div class="space-y-2">
				<div class="flex items-center gap-4">
					<div class="h-14 w-14 rounded-3xl bg-gradient-to-br from-blue-600 to-indigo-600 text-white flex items-center justify-center text-xl font-black shadow-2xl shadow-blue-200">
						{profile?.username?.charAt(0).toUpperCase() || user.email.charAt(0).toUpperCase()}
					</div>
					<div>
						<h1 class="text-4xl font-black text-slate-900 tracking-tight leading-none">
							Welcome back, <span class="bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">{profile?.username || user.email.split('@')[0]}</span>!
						</h1>
						<p class="text-slate-500 font-bold mt-2">You're making great progress. Here's your overview for today.</p>
					</div>
				</div>
			</div>
			
			<div class="hidden lg:flex items-center gap-6 px-8 py-4 bg-white rounded-[32px] border border-slate-100 shadow-sm">
				<div class="text-right">
					<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Current Session</p>
					<p class="text-sm font-black text-slate-900">{new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
				</div>
				<div class="h-8 w-px bg-slate-100"></div>
				<Trophy size={20} class="text-amber-500" />
			</div>
		</div>

		<!-- Stats Grid -->
		<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8" in:fly={{ y: 20, delay: 100 }}>
			{#each [
				{ label: 'Total XP', value: stats.totalPoints.toLocaleString(), icon: Trophy, color: 'amber', trend: '+120 today' },
				{ label: 'Platform Rank', value: stats.rank, icon: TrendingUp, color: 'blue', trend: 'Top 5%' },
				{ label: 'Completed', value: stats.completedQuizzes, icon: CheckCircle2, color: 'green', trend: '2 this week' },
				{ label: 'Revision Time', value: stats.watchTime, icon: Clock, color: 'indigo', trend: 'Active' },
			] as stat}
				<div class="bg-white rounded-[40px] border border-slate-100 p-8 shadow-sm group hover:shadow-2xl hover:translate-y-[-4px] transition-all relative overflow-hidden">
					<div class="absolute -right-4 -top-4 h-24 w-24 bg-slate-50 rounded-full opacity-50 group-hover:scale-150 transition-transform"></div>
					<div class={cn("h-14 w-14 rounded-2xl flex items-center justify-center mb-6 shadow-xl shadow-slate-200/50 relative z-10", {
						'bg-amber-500 text-white': stat.color === 'amber',
						'bg-blue-600 text-white': stat.color === 'blue',
						'bg-green-500 text-white': stat.color === 'green',
						'bg-indigo-600 text-white': stat.color === 'indigo',
					})}>
						<stat.icon size={28} />
					</div>
					<div class="relative z-10">
						<p class="text-xs font-black uppercase tracking-widest text-slate-400 mb-1">{stat.label}</p>
						<p class="text-4xl font-black text-slate-900 tracking-tight">{stat.value}</p>
						<p class="text-[10px] font-bold text-slate-500 mt-4 flex items-center gap-1">
							<span class="text-green-500">{stat.trend}</span>
						</p>
					</div>
				</div>
			{/each}
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-12 gap-10">
			<!-- Recent Activity -->
			<div class="lg:col-span-8 space-y-8" in:fly={{ y: 20, delay: 200 }}>
				<div class="flex items-center justify-between">
					<div class="flex items-center gap-3">
						<div class="h-8 w-1.5 bg-blue-600 rounded-full"></div>
						<h3 class="text-2xl font-black text-slate-900 tracking-tight">Learning Activity</h3>
					</div>
					<a href="/quizzes" class="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-black text-slate-600 transition-all flex items-center gap-2">
						View Transcript <ArrowUpRight size={14} />
					</a>
				</div>
				
				<div class="bg-white rounded-[48px] border border-slate-100 overflow-hidden shadow-sm lg:p-4">
					{#if recentAttempts.length === 0}
						<div class="p-20 text-center">
							<div class="h-20 w-20 bg-slate-50 rounded-[32px] flex items-center justify-center mx-auto mb-6 text-slate-300">
								<BookOpen size={40} />
							</div>
							<p class="text-slate-500 font-bold text-lg italic">No assignment history found. Your progress will appear here.</p>
						</div>
					{:else}
						<table class="w-full text-left border-collapse">
							<thead>
								<tr class="text-[10px] font-black uppercase tracking-widest text-slate-400">
									<th class="px-10 py-6">Course / Assignment</th>
									<th class="px-10 py-6 text-center">Efficiency</th>
									<th class="px-10 py-6 text-right">Completion</th>
								</tr>
							</thead>
							<tbody class="divide-y divide-slate-50">
								{#each recentAttempts as attempt}
									<tr class="group hover:bg-slate-50/80 transition-all cursor-pointer">
										<td class="px-10 py-8">
											<div class="flex items-center gap-4">
												<div class="h-10 w-16 rounded-lg bg-slate-100 flex-shrink-0 overflow-hidden ring-1 ring-slate-100">
													{#if attempt.quizzes?.videos?.thumbnail_url}
														<img src={attempt.quizzes.videos.thumbnail_url} alt="" class="h-full w-full object-cover" />
													{:else}
														<div class="h-full w-full flex items-center justify-center text-slate-400">
															<PlayCircle size={16} />
														</div>
													{/if}
												</div>
												<div>
													<p class="font-black text-slate-900 group-hover:text-blue-600 transition-all">{attempt.quizzes?.title || 'Unknown Assignment'}</p>
													<p class="text-xs font-bold text-slate-400 mt-1">{new Date(attempt.completed_at).toLocaleDateString()}</p>
												</div>
											</div>
										</td>
										<td class="px-10 py-8">
											<div class="flex flex-col items-center gap-2">
												<div class="w-24 h-2 bg-slate-100 rounded-full overflow-hidden">
													<div class={cn("h-full transition-all duration-1000", attempt.score >= 70 ? "bg-green-500" : "bg-amber-500")} style={`width: ${attempt.score}%`}></div>
												</div>
												<span class="text-xs font-black text-slate-900">{attempt.score}%</span>
											</div>
										</td>
										<td class="px-10 py-8 text-right font-black text-slate-400">
											<ChevronRight size={20} />
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					{/if}
				</div>
			</div>

			<!-- Recommendations -->
			<div class="lg:col-span-4 space-y-10" in:fly={{ y: 20, delay: 300 }}>
				<div class="bg-gradient-to-br from-slate-900 to-slate-800 rounded-[48px] p-10 text-white relative overflow-hidden shadow-2xl border border-slate-800">
					<div class="absolute -right-10 -bottom-10 h-64 w-64 bg-blue-600 blur-[100px] opacity-30"></div>
					<div class="relative z-10 space-y-6">
						<div class="flex items-center gap-4">
							<div class="h-12 w-12 rounded-2xl bg-white/10 flex items-center justify-center backdrop-blur-md">
								<PlayCircle size={24} class="text-blue-400" />
							</div>
							<div>
								<p class="text-[10px] font-black uppercase tracking-widest text-blue-400 mb-1">Up Next</p>
								<h3 class="font-black text-lg leading-tight">Video Masterclass</h3>
							</div>
						</div>
						<p class="text-slate-400 text-sm font-medium leading-relaxed italic">"Keep the momentum going. Your next scheduled lecture is ready."</p>
						<button class="w-full py-4 rounded-2xl bg-blue-600 font-black text-sm flex items-center justify-center gap-3 hover:bg-blue-700 hover:scale-[1.02] transition-all active:scale-95 shadow-xl shadow-blue-900/40">
							Resume Learning
						</button>
					</div>
				</div>

				<div class="space-y-6">
					<div class="flex items-center justify-between">
						<h3 class="text-xl font-black text-slate-900 tracking-tight">Personalized Path</h3>
						<BookOpen size={20} class="text-slate-300" />
					</div>
					<div class="space-y-6">
						{#each recommendations as rec}
							<a href={`/courses/${rec.id}`} class="group bg-white rounded-[40px] border border-slate-100 overflow-hidden shadow-sm hover:shadow-xl hover:translate-y-[-4px] transition-all cursor-pointer block">
								<!-- Thumbnail -->
								<div class="relative aspect-video overflow-hidden bg-slate-100">
									{#if rec.thumbnail_url}
										<img src={rec.thumbnail_url} alt="" class="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110" />
									{:else}
										<div class="h-full w-full flex items-center justify-center text-slate-200">
											<PlayCircle size={40} />
										</div>
									{/if}
									<div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
								</div>

								<div class="p-8 relative">
									<div class="absolute top-0 right-0 p-6 opacity-0 group-hover:opacity-100 transition-opacity">
										<ArrowUpRight size={20} class="text-blue-600" />
									</div>
									<div class="flex items-center justify-between mb-4">
										<span class="px-3 py-1 bg-blue-50 text-[10px] font-black uppercase tracking-widest text-blue-600 rounded-lg">{rec.category}</span>
										<span class="inline-flex items-center gap-1.5 text-xs font-black text-amber-500">
											<Star size={14} fill="currentColor" /> {rec.points}
										</span>
									</div>
									<h4 class="text-lg font-black text-slate-900 leading-snug mb-6 group-hover:text-blue-600 transition-colors">{rec.title}</h4>
									<div class="flex items-center justify-between mt-auto">
										<div class="flex items-center gap-2">
											<div class="h-2 w-2 rounded-full bg-green-500"></div>
											<span class="text-[10px] font-black uppercase text-slate-400">{rec.level}</span>
										</div>
										<span class="text-[10px] font-black uppercase text-blue-600 font-bold">Free Module</span>
									</div>
								</div>
							</a>
						{/each}
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
