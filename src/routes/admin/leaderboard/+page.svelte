<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Trophy, 
		Search, 
		User, 
		Edit2, 
		RefreshCw, 
		Loader2, 
		ShieldAlert,
		ArrowUp,
		ArrowDown,
		MoreVertical,
		Save,
		X
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let students = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');
	
	let editingStudent = $state<any>(null);
	let newPoints = $state(0);
	let saving = $state(false);

	onMount(fetchLeaderboard);

	async function fetchLeaderboard() {
		loading = true;
		const { data, error } = await supabase
			.from('leaderboard')
			.select('*');
		
		if (!error) students = data;
		loading = false;
	}

	async function updatePoints() {
		if (!editingStudent) return;
		saving = true;
		
		const { error } = await supabase
			.from('profiles')
			.update({ points: newPoints })
			.eq('id', editingStudent.id);
		
		if (!error) {
			await fetchLeaderboard();
			editingStudent = null;
		} else {
			alert(error.message);
		}
		saving = false;
	}

	function startEdit(student: any) {
		editingStudent = student;
		newPoints = student.points;
	}

	let filteredStudents = $derived(
		students.filter(s => s.username?.toLowerCase().includes(searchQuery.toLowerCase()))
	);
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Leaderboard Management</h1>
			<p class="mt-1 text-slate-500">Monitor student performance and adjust points if necessary.</p>
		</div>
		<button 
			onclick={fetchLeaderboard}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-white border border-slate-200 px-5 py-2.5 text-sm font-bold text-slate-600 shadow-sm hover:bg-slate-50 transition-all"
		>
			<RefreshCw size={18} class={cn(loading && "animate-spin")} />
			Refresh Standings
		</button>
	</div>

	<!-- Stats Overview -->
	<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
		<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
			<p class="text-xs font-black text-slate-400 uppercase tracking-widest mb-1">Total Competitors</p>
			<p class="text-3xl font-black text-slate-900">{students.length}</p>
		</div>
		<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
			<p class="text-xs font-black text-slate-400 uppercase tracking-widest mb-1">Avg. Points</p>
			<p class="text-3xl font-black text-slate-900">
				{students.length > 0 ? Math.round(students.reduce((acc, s) => acc + s.points, 0) / students.length) : 0}
			</p>
		</div>
		<div class="rounded-2xl border border-slate-200 bg-blue-600 p-6 shadow-lg shadow-blue-200 text-white">
			<p class="text-xs font-black text-blue-200 uppercase tracking-widest mb-1">Top Score</p>
			<p class="text-3xl font-black">{students[0]?.points || 0}</p>
		</div>
	</div>

	<!-- Search -->
	<div class="relative max-w-md">
		<Search size={18} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
		<input 
			bind:value={searchQuery}
			placeholder="Search for a student..." 
			class="w-full pl-12 pr-4 py-3 rounded-2xl border border-slate-200 bg-white text-sm font-medium outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 transition-all"
		/>
	</div>

	<!-- Leaderboard Table -->
	<div class="rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">
		{#if loading && students.length === 0}
			<div class="flex h-64 items-center justify-center">
				<Loader2 size={32} class="animate-spin text-blue-600" />
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Rank</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Student</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Points</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each filteredStudents as student}
							<tr class="group hover:bg-slate-50/30 transition-colors">
								<td class="px-6 py-4">
									<div class={cn("flex h-8 w-8 items-center justify-center rounded-lg font-black text-xs", 
										student.rank === 1 ? "bg-amber-100 text-amber-600" :
										student.rank === 2 ? "bg-slate-200 text-slate-600" :
										student.rank === 3 ? "bg-orange-100 text-orange-600" :
										"bg-slate-50 text-slate-400"
									)}>
										{student.rank}
									</div>
								</td>
								<td class="px-6 py-4">
									<div class="flex items-center gap-3">
										<div class="h-10 w-10 rounded-xl bg-slate-100 overflow-hidden ring-2 ring-white shadow-sm">
											{#if student.avatar_url}
												<img src={student.avatar_url} alt="" class="h-full w-full object-cover" />
											{:else}
												<div class="h-full w-full flex items-center justify-center bg-blue-100 text-blue-600 font-bold text-xs uppercase">
													{student.username?.charAt(0)}
												</div>
											{/if}
										</div>
										<span class="font-bold text-slate-900">{student.username}</span>
									</div>
								</td>
								<td class="px-6 py-4">
									<span class="font-black text-slate-900">{student.points.toLocaleString()}</span>
								</td>
								<td class="px-6 py-4 text-right">
									<button 
										onclick={() => startEdit(student)}
										class="rounded-lg p-2 text-slate-400 hover:bg-blue-50 hover:text-blue-600 transition-all"
									>
										<Edit2 size={18} />
									</button>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>

<!-- Edit Modal -->
{#if editingStudent}
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={() => editingStudent = null}
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-md overflow-hidden rounded-[40px] bg-white shadow-2xl"
			onclick={e => e.stopPropagation()}
		>
			<div class="px-10 py-8 border-b border-slate-100 flex items-center justify-between">
				<h2 class="text-xl font-black text-slate-900 tracking-tight">Adjust Points</h2>
				<button onclick={() => editingStudent = null} class="text-slate-400 hover:text-slate-900">
					<X size={24} />
				</button>
			</div>

			<div class="p-10 space-y-6">
				<div class="flex items-center gap-4 p-4 rounded-2xl bg-slate-50">
					<div class="h-12 w-12 rounded-xl bg-white shadow-sm flex items-center justify-center font-bold text-blue-600">
						{editingStudent.username?.charAt(0).toUpperCase()}
					</div>
					<div>
						<p class="font-black text-slate-900">{editingStudent.username}</p>
						<p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Current: {editingStudent.points} XP</p>
					</div>
				</div>

				<div class="space-y-2">
					<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">New XP Total</label>
					<input 
						type="number" 
						bind:value={newPoints} 
						class="w-full rounded-2xl border-2 border-slate-100 bg-white px-6 py-4 text-basis font-black outline-none focus:border-blue-600 transition-all" 
					/>
				</div>

				<div class="pt-4 flex items-center gap-3">
					<button 
						onclick={() => editingStudent = null}
						class="flex-1 py-4 text-sm font-bold text-slate-400 hover:text-slate-900 transition-all"
					>
						Cancel
					</button>
					<button 
						onclick={updatePoints}
						disabled={saving}
						class="flex-[2] py-4 rounded-2xl bg-slate-900 text-white font-black text-sm shadow-xl shadow-slate-200 hover:bg-black transition-all active:scale-95 flex items-center justify-center gap-2"
					>
						{#if saving}
							<Loader2 size={18} class="animate-spin" /> Updating...
						{:else}
							<Save size={18} /> Update User XP
						{/if}
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
