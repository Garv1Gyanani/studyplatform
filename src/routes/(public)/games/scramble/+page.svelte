<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { Type, Timer, Trophy, RefreshCw, CheckCircle2, XCircle, ArrowRight, X, Sparkles } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';

	let gameState = $state<'idle' | 'playing' | 'result'>('idle');
	let score = $state(0);
	let timeLeft = $state(60);
	let currentWord = $state({ original: '', scrambled: '', hint: '' });
	let userAnswer = $state('');
	let timerInterval: any;
	let feedback = $state<'correct' | 'wrong' | null>(null);
	let streak = $state(0);

	const words = [
		{ word: 'PHOTOSYNTHESIS', hint: 'How plants make food using sunlight' },
		{ word: 'ALGORITHM', hint: 'Step-by-step procedure for solving a problem' },
		{ word: 'DERIVATIVE', hint: 'Rate of change in calculus' },
		{ word: 'CHROMOSOME', hint: 'Thread-like structure containing DNA' },
		{ word: 'METAMORPHOSIS', hint: 'Transformation in an organism\'s life cycle' },
		{ word: 'ELECTRON', hint: 'Negatively charged subatomic particle' },
		{ word: 'HYPOTHESIS', hint: 'An educated guess in scientific method' },
		{ word: 'QUADRATIC', hint: 'Type of equation with a squared term' },
		{ word: 'ECOSYSTEM', hint: 'Community of living organisms and environment' },
		{ word: 'MITOCHONDRIA', hint: 'Powerhouse of the cell' },
		{ word: 'VELOCITY', hint: 'Speed in a given direction' },
		{ word: 'DEMOCRACY', hint: 'Government by the people' },
		{ word: 'CATALYST', hint: 'Substance that speeds up a reaction' },
		{ word: 'FIBONACCI', hint: 'Sequence where each number is the sum of the two preceding' },
		{ word: 'NEUTRON', hint: 'Neutral subatomic particle' },
	];

	function scrambleWord(word: string): string {
		const arr = word.split('');
		for (let i = arr.length - 1; i > 0; i--) {
			const j = Math.floor(Math.random() * (i + 1));
			[arr[i], arr[j]] = [arr[j], arr[i]];
		}
		const scrambled = arr.join('');
		return scrambled === word ? scrambleWord(word) : scrambled;
	}

	function generateWord() {
		const wordObj = words[Math.floor(Math.random() * words.length)];
		currentWord = { original: wordObj.word, scrambled: scrambleWord(wordObj.word), hint: wordObj.hint };
		userAnswer = '';
		feedback = null;
	}

	function startGame() {
		gameState = 'playing';
		score = 0;
		streak = 0;
		timeLeft = 60;
		generateWord();
		timerInterval = setInterval(() => {
			if (timeLeft > 0) timeLeft -= 1;
			else endGame();
		}, 1000);
	}

	function checkAnswer() {
		if (userAnswer.toUpperCase().trim() === currentWord.original) {
			streak += 1;
			const bonus = streak >= 3 ? 25 : 15;
			score += bonus;
			feedback = 'correct';
			setTimeout(() => generateWord(), 300);
		}
	}

	function skipWord() {
		streak = 0;
		generateWord();
	}

	async function endGame() {
		clearInterval(timerInterval);
		gameState = 'result';
		const { data: sessionData } = await supabase.auth.getSession();
		const user = sessionData.session?.user;
		if (user && score > 0) {
			await supabase.rpc('increment_points', { user_id: user.id, points_to_add: score });
		}
	}
</script>

<div class="min-h-[calc(100vh-64px)] bg-slate-900 flex flex-col items-center justify-center p-4 relative overflow-hidden">
	<div class="absolute -left-20 -top-20 h-64 w-64 bg-blue-600 blur-[100px] opacity-20"></div>
	<div class="absolute -right-20 -bottom-20 h-64 w-64 bg-cyan-600 blur-[100px] opacity-20"></div>

	<div class="w-full max-w-2xl relative z-10">
		{#if gameState === 'idle'}
			<div class="bg-white rounded-[40px] p-12 text-center shadow-2xl space-y-8" in:scale>
				<div class="inline-flex h-24 w-24 items-center justify-center rounded-[32px] bg-blue-100 text-blue-600 mb-4 animate-bounce">
					<Type size={48} />
				</div>
				<div class="space-y-2">
					<h1 class="text-4xl font-black text-slate-900 tracking-tight">WORD SCRAMBLE</h1>
					<p class="text-lg text-slate-500 font-medium">Unscramble subject-specific vocabulary!</p>
				</div>
				<div class="flex items-center justify-center gap-6">
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Rewards</p>
						<p class="font-black text-slate-900 text-xl">+15 XP/Word</p>
					</div>
					<div class="h-10 w-px bg-slate-100"></div>
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Time</p>
						<p class="font-black text-slate-900 text-xl">60 Seconds</p>
					</div>
					<div class="h-10 w-px bg-slate-100"></div>
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Streak Bonus</p>
						<p class="font-black text-slate-900 text-xl">+25 XP</p>
					</div>
				</div>
				<button onclick={startGame} class="w-full py-5 rounded-3xl bg-blue-600 text-white font-black text-xl shadow-xl shadow-blue-200 hover:bg-blue-700 hover:scale-[1.02] active:scale-95 transition-all">
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
						{#if streak >= 3}
							<div class="flex items-center gap-1 px-3 py-1.5 rounded-full bg-amber-500 text-white text-xs font-black animate-pulse">
								<Sparkles size={14} /> {streak}x Streak!
							</div>
						{/if}
					</div>
					<div class={cn("h-16 w-32 rounded-3xl bg-white/10 backdrop-blur-xl border-2 flex items-center justify-center gap-2 text-2xl font-black transition-all",
						timeLeft < 15 ? "border-red-500 text-red-500 animate-pulse" : "border-white/20 text-white"
					)}>
						<Timer size={24} />
						{timeLeft}s
					</div>
					<a href="/games" class="p-3 bg-white/10 rounded-2xl text-white hover:bg-white/20">
						<X size={24} />
					</a>
				</div>

				<div class="bg-white rounded-[50px] p-12 text-center shadow-2xl space-y-8 relative" in:fly={{ y: 20 }}>
					{#if feedback === 'correct'}
						<div class="absolute inset-0 flex items-center justify-center bg-green-500/10 rounded-[50px] z-20 pointer-events-none" in:fade>
							<CheckCircle2 size={120} class="text-green-500 opacity-50" />
						</div>
					{/if}

					<p class="text-xs font-black text-blue-600 uppercase tracking-widest bg-blue-50 inline-block px-4 py-1.5 rounded-full border border-blue-100">
						💡 {currentWord.hint}
					</p>

					<div class="flex items-center justify-center gap-3 flex-wrap py-4">
						{#each currentWord.scrambled.split('') as letter, i}
							<span 
								class="h-14 w-14 rounded-2xl bg-slate-100 border-2 border-slate-200 flex items-center justify-center text-2xl font-black text-slate-900 shadow-sm"
								in:fly={{ y: -10, delay: i * 30 }}
							>
								{letter}
							</span>
						{/each}
					</div>

					<div class="space-y-4">
						<input
							type="text"
							bind:value={userAnswer}
							oninput={checkAnswer}
							autofocus
							class="w-full text-center bg-slate-50 border-4 border-slate-100 rounded-[32px] py-6 text-3xl font-black text-slate-900 outline-none focus:border-blue-500 transition-all placeholder-slate-200 uppercase tracking-wider"
							placeholder="Type your answer..."
						/>
						<button onclick={skipWord} class="text-sm font-bold text-slate-400 hover:text-slate-600 transition-colors">
							Skip this word →
						</button>
					</div>
				</div>
			</div>
		{:else if gameState === 'result'}
			<div class="bg-white rounded-[40px] p-16 text-center shadow-2xl space-y-10" in:scale>
				<div class="relative inline-block">
					<div class="absolute inset-0 bg-blue-400 blur-3xl opacity-20 rounded-full"></div>
					<div class="relative h-40 w-40 rounded-full bg-blue-50 border-8 border-blue-600 flex flex-col items-center justify-center shadow-xl">
						<Trophy size={48} class="text-blue-600 mb-1" />
						<span class="text-4xl font-black text-slate-900">{score}</span>
						<span class="text-[10px] font-black text-slate-400 uppercase">XP Earned</span>
					</div>
				</div>
				<div class="space-y-2">
					<h2 class="text-4xl font-black text-slate-900 tracking-tight">TIME'S UP!</h2>
					<p class="text-lg text-slate-500 font-medium italic">"Words are the model, words are the tools, words are the board."</p>
				</div>
				<div class="grid grid-cols-2 gap-4">
					<button onclick={startGame} class="py-5 rounded-3xl bg-blue-600 text-white font-black shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all flex items-center justify-center gap-2">
						<RefreshCw size={20} /> TRY AGAIN
					</button>
					<a href="/games" class="py-5 rounded-3xl bg-slate-100 text-slate-900 font-black hover:bg-slate-200 transition-all flex items-center justify-center gap-2">
						BROWSE GAMES <ArrowRight size={20} />
					</a>
				</div>
			</div>
		{/if}
	</div>
</div>
