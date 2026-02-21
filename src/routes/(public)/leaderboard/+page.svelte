<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Trophy, 
		Medal, 
		TrendingUp, 
		Search, 
		Loader2, 
		User, 
		Crown,
		ArrowUp,
		ArrowDown,
		Minus
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let leaderboardData = $state<any[]>([]);
	let currentUserRank = $state<any>(null);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		const user = sessionData.session?.user;

		// Fetch Top Students
		const { data, error } = await supabase
			.from('leaderboard')
			.select('*')
			.limit(50);
		
		if (!error) leaderboardData = data;

		if (user) {
			currentUserRank = data.find(r => r.id === user.id);
		}
		
		loading = false;
	});

	let filteredLeaderboard = $derived(
		leaderboardData.filter(student => 
			student.username?.toLowerCase().includes(searchQuery.toLowerCase())
		)
	);
</script>

<div class="px-4 sm:px-8 py-12 max-w-5xl mx-auto space-y-12">
	<div class="text-center space-y-4">
		<div class="inline-flex h-16 w-16 items-center justify-center rounded-3xl bg-amber-50 text-amber-500 shadow-lg shadow-amber-200/50 mb-2">
			<Trophy size={32} />
		</div>
		<h1 class="text-5xl font-black text-slate-900 tracking-tight">Global Leaderboard</h1>
		<p class="text-lg text-slate-500 font-medium max-w-2xl mx-auto">
			Rise through the ranks by completing courses and acing quizzes. Your learning journey is now a competitive adventure!
		</p>
	</div>

	{#if loading}
		<div class="flex h-[40vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else}
		<!-- Top 3 Podium -->
		<div class="grid grid-cols-1 md:grid-cols-3 gap-8 items-end py-8" in:fade>
			<!-- Rank 2 -->
			{#if leaderboardData[1]}
				<div class="flex flex-col items-center gap-4 transition-all hover:translate-y-[-8px]">
					<div class="relative">
						<div class="h-24 w-24 rounded-full border-4 border-slate-300 bg-white p-1 overflow-hidden shadow-xl shadow-slate-200">
							{#if leaderboardData[1].avatar_url}
								<img src={leaderboardData[1].avatar_url} alt="" class="h-full w-full rounded-full object-cover" />
							{:else}
								<div class="h-full w-full rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
									<User size={32} />
								</div>
							{/if}
						</div>
						<div class="absolute -bottom-2 left-1/2 -translate-x-1/2 bg-slate-400 text-white rounded-full px-4 py-0.5 text-xs font-black shadow-lg">2nd</div>
					</div>
					<div class="text-center">
						<p class="font-black text-slate-800 text-lg">{leaderboardData[1].username || 'Anonymous'}</p>
						<p class="text-sm font-bold text-slate-400">{leaderboardData[1].points} Points</p>
					</div>
				</div>
			{/if}

			<!-- Rank 1 (The Crown) -->
			{#if leaderboardData[0]}
				<div class="flex flex-col items-center gap-6 transition-all hover:translate-y-[-10px] pb-8 md:pb-12">
					<div class="relative">
						<div class="absolute -top-12 left-1/2 -translate-x-1/2 text-amber-500 animate-bounce">
							<Crown size={48} />
						</div>
						<div class="h-32 w-32 rounded-full border-8 border-amber-400 bg-white p-1.5 overflow-hidden shadow-2xl shadow-amber-200">
							{#if leaderboardData[0].avatar_url}
								<img src={leaderboardData[0].avatar_url} alt="" class="h-full w-full rounded-full object-cover" />
							{:else}
								<div class="h-full w-full rounded-full bg-amber-50 flex items-center justify-center text-amber-400">
									<User size={48} />
								</div>
							{/if}
						</div>
						<div class="absolute -bottom-3 left-1/2 -translate-x-1/2 bg-amber-500 text-white rounded-full px-6 py-1.5 text-basis font-black shadow-xl">1st Place</div>
					</div>
					<div class="text-center">
						<h2 class="font-black text-slate-900 text-2xl">{leaderboardData[0].username || 'Anonymous'}</h2>
						<div class="flex items-center justify-center gap-2 mt-1">
							<span class="text-basis font-black text-amber-600">{leaderboardData[0].points} XP</span>
							<TrendingUp size={16} class="text-green-500" />
						</div>
					</div>
				</div>
			{/if}

			<!-- Rank 3 -->
			{#if leaderboardData[2]}
				<div class="flex flex-col items-center gap-4 transition-all hover:translate-y-[-6px]">
					<div class="relative">
						<div class="h-24 w-24 rounded-full border-4 border-amber-700/30 bg-white p-1 overflow-hidden shadow-xl shadow-slate-200">
							{#if leaderboardData[2].avatar_url}
								<img src={leaderboardData[2].avatar_url} alt="" class="h-full w-full rounded-full object-cover" />
							{:else}
								<div class="h-full w-full rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
									<User size={32} />
								</div>
							{/if}
						</div>
						<div class="absolute -bottom-2 left-1/2 -translate-x-1/2 bg-amber-700/60 text-white rounded-full px-4 py-0.5 text-xs font-black shadow-lg">3rd</div>
					</div>
					<div class="text-center">
						<p class="font-black text-slate-800 text-lg">{leaderboardData[2].username || 'Anonymous'}</p>
						<p class="text-sm font-bold text-slate-400">{leaderboardData[2].points} Points</p>
					</div>
				</div>
			{/if}
		</div>

		<!-- Main Leaderboard List -->
		<div class="space-y-6">
			<div class="flex flex-col sm:flex-row items-center justify-between gap-4">
				<h3 class="text-2xl font-black text-slate-900">Rankings Overview</h3>
				<div class="relative w-full sm:w-80">
					<Search size={20} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
					<input 
						bind:value={searchQuery}
						placeholder="Find yourself or a peer..." 
						class="w-full pl-12 pr-4 py-3 rounded-2xl border border-slate-200 bg-white shadow-sm focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all font-bold text-sm"
					/>
				</div>
			</div>

			<div class="bg-white rounded-[40px] border border-slate-100 shadow-xl shadow-slate-200/50 overflow-hidden">
				<div class="overflow-x-auto">
					<table class="w-full text-left">
						<thead class="bg-slate-50/50 border-b border-slate-100">
							<tr>
								<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400">Rank</th>
								<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400">Student</th>
								<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400 text-right">Points</th>
							</tr>
						</thead>
						<tbody class="divide-y divide-slate-50">
							{#each filteredLeaderboard as student, idx}
								<tr class={cn("group transition-all hover:bg-slate-50/50", 
									student.id === currentUserRank?.id ? "bg-blue-50/30" : ""
								)}>
									<td class="px-8 py-6">
										<div class="flex items-center gap-3">
											<span class={cn("text-lg font-black", {
												'text-amber-500': idx + 1 === 1,
												'text-slate-400': idx + 1 === 2,
												'text-amber-700/60': idx + 1 === 3,
												'text-slate-300': idx + 1 > 3
											})}>
												{idx + 1}
											</span>
											{#if idx + 1 < 5}
												<div class="flex h-1.5 w-1.5 rounded-full bg-green-500"></div>
											{/if}
										</div>
									</td>
									<td class="px-8 py-6 text-right">
										<div class="flex items-center gap-4">
											<div class="h-10 w-10 rounded-xl bg-slate-100 overflow-hidden shrink-0">
												{#if student.avatar_url}
													<img src={student.avatar_url} alt="" class="h-full w-full object-cover" />
												{:else}
													<div class="h-full w-full flex items-center justify-center text-slate-400">
														<User size={18} />
													</div>
												{/if}
											</div>
											<div>
												<p class="font-black text-slate-900 group-hover:text-blue-600 transition-colors">
													{student.username || 'Anonymous'}
													{#if student.id === currentUserRank?.id}
														<span class="ml-2 px-2 py-0.5 bg-blue-600 text-[10px] text-white rounded-lg">YOU</span>
													{/if}
												</p>
											</div>
										</div>
									</td>
									<td class="px-8 py-6 text-right">
										<div class="flex items-center justify-end gap-2">
											<span class="text-lg font-black text-slate-900 tracking-tight">{student.points}</span>
											<span class="text-xs font-bold text-slate-400 uppercase tracking-widest">XP</span>
										</div>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		</div>
	{/if}
</div>
