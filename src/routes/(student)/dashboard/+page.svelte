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
				.select('*, quizzes(title)')
				.eq('user_id', user.id)
				.order('completed_at', { ascending: false })
				.limit(5);
			
			recentAttempts = attemptsData || [];

			// Fetch Rank (Simplified logic)
			stats = {
				completedQuizzes: attemptsData?.length || 0,
				totalPoints: profileData?.points || 0,
				watchTime: '12h',
				rank: '#42'
			};
		}
		loading = false;
	});

	const recommendations = [
		{ title: 'Intro to Quantum Physics', category: 'Science', level: 'Intermediate', points: 100 },
		{ title: 'Modern Web Architectures', category: 'Tech', level: 'Advanced', points: 250 },
		{ title: 'Creative Writing Masterclass', category: 'Arts', level: 'Beginner', points: 80 },
	];
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
		<div class="flex flex-col md:flex-row md:items-center justify-between gap-6" in:fade>
			<div class="space-y-1">
				<div class="flex items-center gap-3">
					<div class="h-10 w-10 rounded-2xl bg-gradient-to-br from-blue-600 to-indigo-600 text-white flex items-center justify-center font-bold shadow-lg">
						{profile?.username?.charAt(0).toUpperCase() || user.email.charAt(0).toUpperCase()}
					</div>
					<h1 class="text-3xl font-black text-slate-900 tracking-tight">
						Hello, <span class="text-blue-600">{profile?.username || user.email.split('@')[0]}</span>!
					</h1>
				</div>
				<p class="text-slate-500 font-medium">Ready to continue your learning journey today?</p>
			</div>
			
			<div class="flex items-center gap-2 p-1.5 bg-slate-100 rounded-2xl">
				<button class="px-4 py-2 rounded-xl bg-white shadow-sm text-sm font-bold text-slate-900">Overview</button>
				<button class="px-4 py-2 rounded-xl text-sm font-bold text-slate-500 hover:text-slate-900 transition-all">Activities</button>
				<button class="px-4 py-2 rounded-xl text-sm font-bold text-slate-500 hover:text-slate-900 transition-all">Performance</button>
			</div>
		</div>

		<!-- Stats Grid -->
		<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6" in:fly={{ y: 20, delay: 100 }}>
			{#each [
				{ label: 'Total Points', value: stats.totalPoints, icon: Trophy, color: 'amber' },
				{ label: 'Global Rank', value: stats.rank, icon: TrendingUp, color: 'blue' },
				{ label: 'Quizzes Done', value: stats.completedQuizzes, icon: CheckCircle2, color: 'green' },
				{ label: 'Learning Time', value: stats.watchTime, icon: Clock, color: 'indigo' },
			] as stat}
				<div class="bg-white rounded-[32px] border border-slate-100 p-8 shadow-sm group hover:shadow-xl hover:shadow-slate-200/50 transition-all">
					<div class={cn("h-12 w-12 rounded-2xl flex items-center justify-center mb-6 shadow-sm", {
						'bg-amber-50 text-amber-500': stat.color === 'amber',
						'bg-blue-50 text-blue-500': stat.color === 'blue',
						'bg-green-50 text-green-500': stat.color === 'green',
						'bg-indigo-50 text-indigo-500': stat.color === 'indigo',
					})}>
						<stat.icon size={24} />
					</div>
					<p class="text-xs font-black uppercase tracking-widest text-slate-400 mb-1">{stat.label}</p>
					<p class="text-3xl font-black text-slate-900 tracking-tight">{stat.value}</p>
				</div>
			{/each}
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-12 gap-10">
			<!-- Recent Activity -->
			<div class="lg:col-span-8 space-y-6" in:fly={{ y: 20, delay: 200 }}>
				<div class="flex items-center justify-between">
					<h3 class="text-2xl font-black text-slate-900">Recent Assignments</h3>
					<a href="/quizzes" class="text-sm font-bold text-blue-600 hover:underline flex items-center gap-1">
						View All <ArrowUpRight size={16} />
					</a>
				</div>
				
				<div class="bg-white rounded-[40px] border border-slate-100 overflow-hidden shadow-sm">
					{#if recentAttempts.length === 0}
						<div class="p-20 text-center">
							<p class="text-slate-400 font-bold">No assignments completed yet. Why not try a quiz?</p>
						</div>
					{:else}
						<div class="divide-y divide-slate-50">
							{#each recentAttempts as attempt}
								<div class="p-8 flex items-center gap-6 hover:bg-slate-50/50 transition-all">
									<div class={cn("h-14 w-14 rounded-2xl flex items-center justify-center shrink-0 shadow-sm", 
										attempt.score >= 70 ? "bg-green-50 text-green-600" : "bg-red-50 text-red-600"
									)}>
										<span class="text-lg font-black">{attempt.score}%</span>
									</div>
									<div class="flex-grow">
										<p class="text-lg font-black text-slate-900">{attempt.quizzes?.title || 'Unknown Assignment'}</p>
										<p class="text-sm font-bold text-slate-400 flex items-center gap-2 mt-0.5">
											<Clock size={14} /> {new Date(attempt.completed_at).toLocaleDateString()}
										</p>
									</div>
									<button class="h-12 w-12 rounded-full border border-slate-200 flex items-center justify-center text-slate-400 hover:text-blue-600 hover:border-blue-600 transition-all">
										<ChevronRight size={24} />
									</button>
								</div>
							{/each}
						</div>
					{/if}
				</div>
			</div>

			<!-- Recommendations -->
			<div class="lg:col-span-4 space-y-8" in:fly={{ y: 20, delay: 300 }}>
				<div class="bg-slate-900 rounded-[40px] p-8 text-white relative overflow-hidden shadow-2xl">
					<div class="absolute -right-10 -top-10 h-40 w-40 bg-blue-600 blur-[80px] opacity-40"></div>
					<div class="relative z-10">
						<h3 class="text-xl font-black leading-tight">Pick up where you left off</h3>
						<p class="mt-2 text-slate-400 text-sm font-medium">Continue "Advanced React Patterns". You're 65% through!</p>
						<button class="mt-6 w-full py-4 rounded-2xl bg-blue-600 font-black text-sm flex items-center justify-center gap-2 hover:bg-blue-700 transition-all active:scale-95">
							<PlayCircle size={20} /> Resume Learning
						</button>
					</div>
				</div>

				<div class="space-y-6">
					<h3 class="text-xl font-black text-slate-900">Recommended for You</h3>
					<div class="space-y-4">
						{#each recommendations as rec}
							<div class="bg-white rounded-[32px] border border-slate-100 p-6 shadow-sm hover:translate-y-[-4px] transition-all cursor-pointer">
								<div class="flex items-center justify-between mb-3">
									<span class="px-3 py-1 bg-slate-100 text-[10px] font-black uppercase tracking-widest text-slate-500 rounded-lg">{rec.category}</span>
									<span class="text-xs font-bold text-blue-600 flex items-center gap-1">
										<Star size={12} fill="currentColor" /> {rec.points} XP
									</span>
								</div>
								<h4 class="font-bold text-slate-900 leading-snug">{rec.title}</h4>
								<div class="mt-4 flex items-center justify-between text-xs font-bold text-slate-400">
									<span>{rec.level}</span>
									<span class="text-blue-500">Free Access</span>
								</div>
							</div>
						{/each}
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
