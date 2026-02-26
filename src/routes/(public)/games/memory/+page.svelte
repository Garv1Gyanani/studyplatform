<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { Dices, Timer, Trophy, RefreshCw, ArrowRight, X, RotateCcw } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';

	let gameState = $state<'idle' | 'playing' | 'result'>('idle');
	let score = $state(0);
	let moves = $state(0);
	let cards = $state<any[]>([]);
	let flippedIndices = $state<number[]>([]);
	let matchedPairs = $state<number[]>([]);
	let isChecking = $state(false);

	const pairs = [
		{ term: 'H₂O', definition: 'Water' },
		{ term: 'E=mc²', definition: 'Energy' },
		{ term: 'DNA', definition: 'Genetics' },
		{ term: 'π', definition: '3.14159' },
		{ term: 'Fe', definition: 'Iron' },
		{ term: 'O₂', definition: 'Oxygen' },
		{ term: 'NaCl', definition: 'Salt' },
		{ term: 'CO₂', definition: 'Carbon Dioxide' },
	];

	function shuffleArray(arr: any[]): any[] {
		const shuffled = [...arr];
		for (let i = shuffled.length - 1; i > 0; i--) {
			const j = Math.floor(Math.random() * (i + 1));
			[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
		}
		return shuffled;
	}

	function startGame() {
		gameState = 'playing';
		score = 0;
		moves = 0;
		matchedPairs = [];
		flippedIndices = [];
		
		const cardItems: any[] = [];
		pairs.forEach((pair, i) => {
			cardItems.push({ id: i * 2, pairId: i, text: pair.term, type: 'term' });
			cardItems.push({ id: i * 2 + 1, pairId: i, text: pair.definition, type: 'definition' });
		});
		cards = shuffleArray(cardItems);
	}

	function flipCard(index: number) {
		if (isChecking) return;
		if (flippedIndices.includes(index)) return;
		if (matchedPairs.includes(cards[index].pairId)) return;
		
		flippedIndices = [...flippedIndices, index];
		
		if (flippedIndices.length === 2) {
			moves += 1;
			isChecking = true;
			const [first, second] = flippedIndices;
			
			if (cards[first].pairId === cards[second].pairId) {
				// Match!
				score += 20;
				matchedPairs = [...matchedPairs, cards[first].pairId];
				setTimeout(() => {
					flippedIndices = [];
					isChecking = false;
					if (matchedPairs.length === pairs.length) {
						endGame();
					}
				}, 600);
			} else {
				// No match
				setTimeout(() => {
					flippedIndices = [];
					isChecking = false;
				}, 800);
			}
		}
	}

	function isFlipped(index: number): boolean {
		return flippedIndices.includes(index) || matchedPairs.includes(cards[index]?.pairId);
	}

	async function endGame() {
		gameState = 'result';
		const { data: sessionData } = await supabase.auth.getSession();
		const user = sessionData.session?.user;
		if (user && score > 0) {
			await supabase.rpc('increment_points', { user_id: user.id, points_to_add: score });
		}
	}
</script>

<div class="min-h-[calc(100vh-64px)] bg-slate-900 flex flex-col items-center justify-center p-4 relative overflow-hidden">
	<div class="absolute -left-20 -top-20 h-64 w-64 bg-green-600 blur-[100px] opacity-20"></div>
	<div class="absolute -right-20 -bottom-20 h-64 w-64 bg-emerald-600 blur-[100px] opacity-20"></div>

	<div class="w-full max-w-3xl relative z-10">
		{#if gameState === 'idle'}
			<div class="bg-white rounded-[40px] p-12 text-center shadow-2xl space-y-8" in:scale>
				<div class="inline-flex h-24 w-24 items-center justify-center rounded-[32px] bg-green-100 text-green-600 mb-4 animate-bounce">
					<Dices size={48} />
				</div>
				<div class="space-y-2">
					<h1 class="text-4xl font-black text-slate-900 tracking-tight">MEMORY MATCH</h1>
					<p class="text-lg text-slate-500 font-medium">Match scientific terms with their definitions!</p>
				</div>
				<div class="flex items-center justify-center gap-6">
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Rewards</p>
						<p class="font-black text-slate-900 text-xl">+20 XP/Match</p>
					</div>
					<div class="h-10 w-px bg-slate-100"></div>
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Pairs</p>
						<p class="font-black text-slate-900 text-xl">{pairs.length} Pairs</p>
					</div>
				</div>
				<button onclick={startGame} class="w-full py-5 rounded-3xl bg-green-600 text-white font-black text-xl shadow-xl shadow-green-200 hover:bg-green-700 hover:scale-[1.02] active:scale-95 transition-all">
					START GAME
				</button>
			</div>
		{:else if gameState === 'playing'}
			<div class="space-y-8">
				<div class="flex items-center justify-between px-4">
					<div class="flex items-center gap-4">
						<div class="h-14 w-14 rounded-2xl bg-white/10 backdrop-blur-xl flex flex-col items-center justify-center text-white border border-white/20">
							<span class="text-[8px] font-black uppercase">Score</span>
							<span class="text-xl font-black">{score}</span>
						</div>
						<div class="h-14 px-4 rounded-2xl bg-white/10 backdrop-blur-xl flex flex-col items-center justify-center text-white border border-white/20">
							<span class="text-[8px] font-black uppercase">Moves</span>
							<span class="text-xl font-black">{moves}</span>
						</div>
					</div>
					<div class="px-6 py-3 rounded-2xl bg-white/10 backdrop-blur-xl border border-white/20 text-white font-black">
						{matchedPairs.length} / {pairs.length} Matched
					</div>
					<a href="/games" class="p-3 bg-white/10 rounded-2xl text-white hover:bg-white/20">
						<X size={24} />
					</a>
				</div>

				<div class="grid grid-cols-4 gap-3 sm:gap-4">
					{#each cards as card, index}
						<button
							onclick={() => flipCard(index)}
							class={cn(
								"aspect-square rounded-2xl sm:rounded-3xl text-center flex items-center justify-center p-2 sm:p-4 font-black transition-all duration-300 border-2 cursor-pointer",
								matchedPairs.includes(card.pairId)
									? "bg-green-50 border-green-300 text-green-700 scale-95 opacity-70"
									: flippedIndices.includes(index)
										? card.type === 'term'
											? "bg-blue-50 border-blue-400 text-blue-700 shadow-xl scale-105"
											: "bg-amber-50 border-amber-400 text-amber-700 shadow-xl scale-105"
										: "bg-white border-slate-200 text-slate-200 hover:border-green-300 hover:shadow-lg hover:scale-105"
							)}
						>
							{#if flippedIndices.includes(index) || matchedPairs.includes(card.pairId)}
								<span class="text-sm sm:text-base break-words leading-tight">{card.text}</span>
							{:else}
								<span class="text-2xl">?</span>
							{/if}
						</button>
					{/each}
				</div>
			</div>
		{:else if gameState === 'result'}
			<div class="bg-white rounded-[40px] p-16 text-center shadow-2xl space-y-10" in:scale>
				<div class="relative inline-block">
					<div class="absolute inset-0 bg-green-400 blur-3xl opacity-20 rounded-full"></div>
					<div class="relative h-40 w-40 rounded-full bg-green-50 border-8 border-green-600 flex flex-col items-center justify-center shadow-xl">
						<Trophy size={48} class="text-green-600 mb-1" />
						<span class="text-4xl font-black text-slate-900">{score}</span>
						<span class="text-[10px] font-black text-slate-400 uppercase">XP Earned</span>
					</div>
				</div>
				<div class="space-y-2">
					<h2 class="text-4xl font-black text-slate-900 tracking-tight">ALL MATCHED!</h2>
					<p class="text-lg text-slate-500 font-medium">Completed in <span class="text-green-600 font-black">{moves} moves</span>. {moves <= 12 ? "Incredible memory!" : "Nice work!"}</p>
				</div>
				<div class="grid grid-cols-2 gap-4">
					<button onclick={startGame} class="py-5 rounded-3xl bg-green-600 text-white font-black shadow-xl shadow-green-200 hover:bg-green-700 transition-all flex items-center justify-center gap-2">
						<RefreshCw size={20} /> PLAY AGAIN
					</button>
					<a href="/games" class="py-5 rounded-3xl bg-slate-100 text-slate-900 font-black hover:bg-slate-200 transition-all flex items-center justify-center gap-2">
						BROWSE GAMES <ArrowRight size={20} />
					</a>
				</div>
			</div>
		{/if}
	</div>
</div>
