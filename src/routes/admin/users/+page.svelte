<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Users, 
		Search, 
		Mail, 
		Calendar, 
		Filter, 
		MoreVertical, 
		ChevronRight,
		Loader2,
		UserCircle,
		ShieldCheck,
		GraduationCap,
		Trophy
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let profiles = $state<any[]>([]);
	let loading = $state(true);
	let searchQuery = $state('');

	onMount(async () => {
		const { data, error } = await supabase
			.from('profiles')
			.select('*')
			.order('points', { ascending: false });
		
		if (!error) profiles = data;
		loading = false;
	});

	let filteredProfiles = $derived(
		profiles.filter(p => 
			p.username?.toLowerCase().includes(searchQuery.toLowerCase()) ||
			p.id.toLowerCase().includes(searchQuery.toLowerCase())
		)
	);
</script>

<div class="space-y-8 px-4 sm:px-0">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">User Management</h1>
			<p class="mt-1 text-slate-500">Monitor student activity, points, and account roles.</p>
		</div>
		
		<div class="flex items-center gap-2">
			<div class="relative">
				<Search size={18} class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
				<input 
					bind:value={searchQuery}
					placeholder="Search students..." 
					class="pl-11 pr-4 py-2.5 rounded-xl border border-slate-200 bg-white outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 font-bold text-sm w-full sm:w-64"
				/>
			</div>
			<button class="p-2.5 border border-slate-200 rounded-xl text-slate-400 hover:text-slate-900 transition-all">
				<Filter size={20} />
			</button>
		</div>
	</div>

	<!-- Stats Row -->
	<div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
		<div class="bg-white rounded-[32px] border border-slate-100 p-6 shadow-sm flex items-center gap-4">
			<div class="h-12 w-12 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center">
				<Users size={24} />
			</div>
			<div>
				<p class="text-[10px] font-black uppercase text-slate-400">Total Users</p>
				<p class="text-2xl font-black text-slate-900">{profiles.length}</p>
			</div>
		</div>
		<div class="bg-white rounded-[32px] border border-slate-100 p-6 shadow-sm flex items-center gap-4">
			<div class="h-12 w-12 rounded-2xl bg-amber-50 text-amber-500 flex items-center justify-center">
				<Trophy size={24} />
			</div>
			<div>
				<p class="text-[10px] font-black uppercase text-slate-400">Active Today</p>
				<p class="text-2xl font-black text-slate-900">42</p>
			</div>
		</div>
		<div class="bg-white rounded-[32px] border border-slate-100 p-6 shadow-sm flex items-center gap-4">
			<div class="h-12 w-12 rounded-2xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
				<ShieldCheck size={24} />
			</div>
			<div>
				<p class="text-[10px] font-black uppercase text-slate-400">Moderators</p>
				<p class="text-2xl font-black text-slate-900">2</p>
			</div>
		</div>
	</div>

	<!-- Users Table -->
	<div class="rounded-[40px] border border-slate-200 bg-white shadow-sm overflow-hidden" in:fade>
		{#if loading}
			<div class="flex h-64 items-center justify-center">
				<Loader2 size={32} class="animate-spin text-blue-600" />
			</div>
		{:else if filteredProfiles.length === 0}
			<div class="p-20 text-center font-bold text-slate-400 italic">No users found</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400">Student</th>
							<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400">Role</th>
							<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400">Points</th>
							<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400">Joined</th>
							<th class="px-8 py-5 text-xs font-black uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each filteredProfiles as profile}
							<tr class="group hover:bg-slate-50/50 transition-colors">
								<td class="px-8 py-6">
									<div class="flex items-center gap-4">
										<div class="h-12 w-12 rounded-2xl bg-slate-100 overflow-hidden ring-2 ring-transparent group-hover:ring-blue-100 transition-all">
											{#if profile.avatar_url}
												<img src={profile.avatar_url} alt="" class="h-full w-full object-cover" />
											{:else}
												<div class="h-full w-full flex items-center justify-center text-slate-300"><UserCircle size={24} /></div>
											{/if}
										</div>
										<div>
											<p class="font-black text-slate-900 group-hover:text-blue-600 transition-colors">{profile.username || 'Anonymous User'}</p>
											<p class="text-xs font-medium text-slate-400 flex items-center gap-1.5 mt-0.5"><Mail size={12} /> student_{profile.id.slice(0, 4)}@edu.com</p>
										</div>
									</div>
								</td>
								<td class="px-8 py-6">
									{#if profile.role === 'admin'}
										<span class="inline-flex items-center gap-1.5 rounded-lg bg-red-50 px-2.5 py-1 text-[10px] font-black uppercase text-red-600 tracking-widest ring-1 ring-red-100">
											<ShieldCheck size={12} /> Admin
										</span>
									{:else}
										<span class="inline-flex items-center gap-1.5 rounded-lg bg-blue-50 px-2.5 py-1 text-[10px] font-black uppercase text-blue-600 tracking-widest ring-1 ring-blue-100">
											<GraduationCap size={12} /> Student
										</span>
									{/if}
								</td>
								<td class="px-8 py-6">
									<div class="flex items-center gap-2">
										<div class="h-8 w-8 rounded-lg bg-amber-50 flex items-center justify-center text-amber-500">
											<Trophy size={16} />
										</div>
										<span class="text-basis font-black text-slate-900">{profile.points}</span>
									</div>
								</td>
								<td class="px-8 py-6 text-slate-500 text-sm font-medium">
                                    <div class="flex items-center gap-2">
                                        <Calendar size={14} class="text-slate-300" />
									    {new Date(profile.created_at).toLocaleDateString()}
                                    </div>
								</td>
								<td class="px-8 py-6 text-right">
									<button class="p-2 text-slate-400 hover:text-slate-900 hover:bg-slate-100 rounded-xl transition-all">
										<MoreVertical size={20} />
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
