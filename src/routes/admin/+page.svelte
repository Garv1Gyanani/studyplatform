<script lang="ts">
	import { Video, Users, FileQuestion, BookOpen, TrendingUp, Clock, CheckCircle2, Loader2 } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';

	let loading = $state(true);

	let stats = $state([
		{ name: 'Total Students', value: '—', icon: Users, color: 'blue' },
		{ name: 'Video Courses', value: '—', icon: Video, color: 'purple' },
		{ name: 'Quizzes Taken', value: '—', icon: FileQuestion, color: 'amber' },
		{ name: 'Blog Posts', value: '—', icon: BookOpen, color: 'green' },
	]);

	let recentActivity = $state<any[]>([]);

	onMount(async () => {
		// Fetch all stats in parallel
		const [studentsRes, videosRes, attemptsRes, blogsRes, activityRes] = await Promise.all([
			supabase.from('profiles').select('id', { count: 'exact', head: true }).eq('role', 'student'),
			supabase.from('videos').select('id', { count: 'exact', head: true }),
			supabase.from('quiz_attempts').select('id', { count: 'exact', head: true }),
			supabase.from('blogs').select('id', { count: 'exact', head: true }),
			supabase.from('quiz_attempts')
				.select('*, profiles(username), quizzes(title)')
				.order('completed_at', { ascending: false })
				.limit(5)
		]);

		stats = [
			{ name: 'Total Students', value: (studentsRes.count ?? 0).toLocaleString(), icon: Users, color: 'blue' },
			{ name: 'Video Courses', value: (videosRes.count ?? 0).toLocaleString(), icon: Video, color: 'purple' },
			{ name: 'Quizzes Taken', value: (attemptsRes.count ?? 0).toLocaleString(), icon: FileQuestion, color: 'amber' },
			{ name: 'Blog Posts', value: (blogsRes.count ?? 0).toLocaleString(), icon: BookOpen, color: 'green' },
		];

		recentActivity = (activityRes.data || []).map(a => ({
			user: a.profiles?.username || 'Anonymous',
			action: `scored ${a.score}% on "${a.quizzes?.title || 'Quiz'}"`,
			time: timeAgo(a.completed_at),
			icon: a.score >= 70 ? CheckCircle2 : Clock,
			color: a.score >= 70 ? 'green' : 'slate',
		}));

		if (recentActivity.length === 0) {
			recentActivity = [
				{ user: 'System', action: 'No student activity yet. Content awaits!', time: 'Just now', icon: TrendingUp, color: 'blue' }
			];
		}

		loading = false;
	});

	function timeAgo(dateStr: string): string {
		const seconds = Math.floor((Date.now() - new Date(dateStr).getTime()) / 1000);
		if (seconds < 60) return 'Just now';
		if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
		if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
		return `${Math.floor(seconds / 86400)}d ago`;
	}
</script>

<div class="space-y-8">
	<div>
		<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Dashboard Overview</h1>
		<p class="mt-2 text-slate-500">Welcome back, Admin. Here's what's happening today.</p>
	</div>

	{#if loading}
		<div class="flex h-64 items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else}
		<!-- Stats Grid -->
		<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
			{#each stats as stat}
				<div class="group relative rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition-all hover:shadow-md">
					<div class={cn("inline-flex h-12 w-12 items-center justify-center rounded-xl mb-4", {
						'bg-blue-50 text-blue-600': stat.color === 'blue',
						'bg-purple-50 text-purple-600': stat.color === 'purple',
						'bg-amber-50 text-amber-600': stat.color === 'amber',
						'bg-green-50 text-green-600': stat.color === 'green',
					})}>
						<stat.icon size={24} />
					</div>
					<div class="flex flex-col">
						<span class="text-3xl font-bold text-slate-900 tracking-tight">{stat.value}</span>
						<span class="text-sm font-medium text-slate-500 uppercase tracking-wider mt-1">{stat.name}</span>
					</div>
				</div>
			{/each}
		</div>

		<div class="grid grid-cols-1 gap-8 lg:grid-cols-12">
			<!-- Main Content Area (e.g. Activity) -->
			<div class="lg:col-span-8">
				<div class="rounded-2xl border border-slate-200 bg-white overflow-hidden shadow-sm">
					<div class="border-b border-slate-100 bg-slate-50/50 px-6 py-4 flex items-center justify-between">
						<h3 class="font-bold text-slate-900">Recent Student Activity</h3>
						<a href="/admin/users" class="text-xs font-bold text-blue-600 hover:text-blue-700">View All</a>
					</div>
					<div class="divide-y divide-slate-100">
						{#each recentActivity as activity}
							<div class="flex items-center gap-4 px-6 py-4 transition-colors hover:bg-slate-50/50">
								<div class={cn("h-10 w-10 rounded-full flex items-center justify-center", {
									'bg-green-100 text-green-600': activity.color === 'green',
									'bg-blue-100 text-blue-600': activity.color === 'blue',
									'bg-slate-100 text-slate-600': activity.color === 'slate',
								})}>
									<activity.icon size={18} />
								</div>
								<div class="flex-grow">
									<p class="text-sm font-semibold text-slate-900">
										{activity.user} <span class="font-normal text-slate-500">{activity.action}</span>
									</p>
									<p class="text-xs text-slate-400 mt-0.5">{activity.time}</p>
								</div>
							</div>
						{/each}
					</div>
				</div>
			</div>

			<!-- Sidebar Area (Quick Actions) -->
			<div class="lg:col-span-4 space-y-6">
				<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
					<h3 class="font-bold text-slate-900 mb-4">Quick Actions</h3>
					<div class="grid gap-3">
						<a href="/admin/videos" class="flex items-center gap-3 rounded-xl border border-blue-50 bg-blue-50/20 px-4 py-3 text-sm font-bold text-blue-600 transition-all hover:bg-blue-50">
							<Video size={18} />
							Add New Video
						</a>
						<a href="/admin/quizzes" class="flex items-center gap-3 rounded-xl border border-amber-50 bg-amber-50/20 px-4 py-3 text-sm font-bold text-amber-600 transition-all hover:bg-amber-50">
							<FileQuestion size={18} />
							Create Quiz
						</a>
						<a href="/admin/blogs" class="flex items-center gap-3 rounded-xl border border-green-50 bg-green-50/20 px-4 py-3 text-sm font-bold text-green-600 transition-all hover:bg-green-50">
							<BookOpen size={18} />
							Write Blog Post
						</a>
					</div>
				</div>

				<div class="rounded-2xl border border-slate-200 bg-blue-600 p-6 shadow-lg shadow-blue-200 text-white relative overflow-hidden">
					<div class="absolute -right-8 -top-8 h-32 w-32 rounded-full bg-white/10 blur-2xl"></div>
					<h3 class="font-bold relative z-10">Pro Tip</h3>
					<p class="mt-2 text-sm text-blue-100 leading-relaxed relative z-10">
						Direct MP4 uploads are capped at 50MB. For larger videos, use the YouTube embed option for better performance.
					</p>
				</div>
			</div>
		</div>
	{/if}
</div>
