<script lang="ts">
	import { 
		Gamepad2, 
		Zap, 
		Brain, 
		Type, 
		Dices, 
		Play,
		Star,
		ChevronRight,
		Loader2
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	const games = [
		{
			id: 'math',
			title: 'Math Speed Challenge',
			description: 'Solve arithmetic problems as fast as you can. Boost your calculation speed!',
			icon: Zap,
			color: 'bg-amber-100 text-amber-600',
			points: '10 XP per win',
			difficulty: 'All Levels',
			path: '/games/math'
		},
		{
			id: 'scramble',
			title: 'Word Scramble',
			description: 'Unscramble subject-specific vocabulary. Great for testing your terminology!',
			icon: Type,
			color: 'bg-blue-100 text-blue-600',
			points: '15 XP per word',
			difficulty: 'Easy',
			path: '/games/scramble'
		},
		{
			id: 'trivia',
			title: 'Subject Trivia',
			description: 'Random trivia from across all educational subjects. Are you an all-rounder?',
			icon: Brain,
			color: 'bg-purple-100 text-purple-600',
			points: '50 XP per round',
			difficulty: 'Hard',
			path: '/games/trivia'
		},
		{
			id: 'memory',
			title: 'Memory Match',
			description: 'Match terms to their definitions in this classic card flipping game.',
			icon: Dices,
			color: 'bg-green-100 text-green-600',
			points: '20 XP per match',
			difficulty: 'Medium',
			path: '/games/memory'
		}
	];
</script>

<div class="px-4 sm:px-8 py-12 max-w-6xl mx-auto space-y-12">
	<div class="flex flex-col md:flex-row md:items-end justify-between gap-6">
		<div class="space-y-4">
			<div class="inline-flex items-center gap-2 px-4 py-1.5 bg-indigo-50 text-indigo-600 rounded-full text-xs font-black uppercase tracking-widest border border-indigo-100">
				<Gamepad2 size={14} /> Learning is Fun
			</div>
			<h1 class="text-5xl font-black text-slate-900 tracking-tight">Game Center</h1>
			<p class="text-lg text-slate-500 font-medium max-w-xl">
				Take a break from textbooks and sharpen your skills with our educational mini-games.
			</p>
		</div>
		
		<div class="hidden lg:flex items-center gap-8 text-right">
			<div>
				<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Monthly Players</p>
				<p class="text-2xl font-black text-slate-900">2,450+</p>
			</div>
			<div class="h-10 w-px bg-slate-200"></div>
			<div>
				<p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Total Rewards</p>
				<p class="text-2xl font-black text-slate-900">85k XP</p>
			</div>
		</div>
	</div>

	<!-- Games Grid -->
	<div class="grid grid-cols-1 md:grid-cols-2 gap-8">
		{#each games as game}
			<a 
				href={game.path}
				class="group relative flex flex-col bg-white rounded-[40px] border border-slate-100 p-10 shadow-sm transition-all hover:shadow-2xl hover:shadow-slate-200/50 hover:translate-y-[-4px]"
				in:fade
			>
				<div class="flex items-start justify-between mb-8">
					<div class={cn("h-16 w-16 rounded-3xl flex items-center justify-center shadow-lg transition-transform group-hover:scale-110", game.color)}>
						<game.icon size={32} strokeWidth={2.5} />
					</div>
					<div class="flex items-center gap-1.5 px-3 py-1 bg-slate-50 border border-slate-100 rounded-xl text-[10px] font-black text-slate-400 uppercase tracking-widest">
						<Star size={12} fill="currentColor" class="text-amber-400" /> {game.points}
					</div>
				</div>

				<div class="space-y-3">
					<h3 class="text-2xl font-black text-slate-900 group-hover:text-blue-600 transition-colors uppercase tracking-tight">{game.title}</h3>
					<p class="text-slate-500 font-medium leading-relaxed">{game.description}</p>
				</div>

				<div class="mt-10 pt-8 border-t border-slate-50 flex items-center justify-between">
					<div class="flex items-center gap-2">
						{#each Array(3) as _, i}
							<div class={cn("h-1.5 w-6 rounded-full", 
								i === 0 ? "bg-blue-600" : (i === 1 && (game.difficulty === 'Medium' || game.difficulty === 'Hard')) ? "bg-blue-600" : (i === 2 && game.difficulty === 'Hard') ? "bg-blue-600" : "bg-slate-100"
							)}></div>
						{/each}
						<span class="ml-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">{game.difficulty}</span>
					</div>
					
					<div class="h-12 w-12 rounded-full bg-slate-900 text-white flex items-center justify-center transition-all group-hover:bg-blue-600 group-hover:translate-x-2">
						<Play size={20} fill="currentColor" />
					</div>
				</div>
			</a>
		{/each}
	</div>

	<!-- Coming Soon -->
	<div class="relative overflow-hidden rounded-[40px] bg-slate-900 p-12 text-white">
		<div class="absolute right-0 top-0 h-64 w-64 bg-blue-600 blur-[100px] opacity-20"></div>
		<div class="relative z-10 flex flex-col md:flex-row items-center justify-between gap-8">
			<div class="space-y-2">
				<h2 class="text-3xl font-black">Want more games?</h2>
				<p class="text-slate-400 font-medium">New educational mini-games are added every week. Stay tuned!</p>
			</div>
			<button class="px-8 py-4 bg-white text-slate-900 rounded-2xl font-black flex items-center gap-2 hover:bg-slate-100 transition-all active:scale-95 shadow-xl">
				Request a Game <ChevronRight size={20} />
			</button>
		</div>
	</div>
</div>
