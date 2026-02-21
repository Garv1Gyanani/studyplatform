<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Zap, 
		Timer, 
		Trophy, 
		RefreshCw, 
		CheckCircle2, 
		XCircle,
		ArrowRight,
		Loader2,
        X
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';

	let gameState = $state<'idle' | 'playing' | 'result'>('idle');
	let score = $state(0);
	let timeLeft = $state(30);
	let currentProblem = $state({ a: 0, b: 0, op: '+', answer: 0 });
	let userAnswer = $state('');
	let timerInterval: any;
	let feedback = $state<'correct' | 'wrong' | null>(null);

	function generateProblem() {
		const ops = ['+', '-', '*'];
		const op = ops[Math.floor(Math.random() * ops.length)];
		let a, b;

		if (op === '*') {
			a = Math.floor(Math.random() * 12) + 2;
			b = Math.floor(Math.random() * 12) + 2;
		} else {
			a = Math.floor(Math.random() * 50) + 1;
			b = Math.floor(Math.random() * 50) + 1;
		}

		let answer: number;
		if (op === '+') answer = a + b;
		else if (op === '-') {
			if (a < b) [a, b] = [b, a]; // Avoid negative for simple game
			answer = a - b;
		} else answer = a * b;

		currentProblem = { a, b, op, answer };
		userAnswer = '';
		feedback = null;
	}

	function startGame() {
		gameState = 'playing';
		score = 0;
		timeLeft = 30;
		generateProblem();
		timerInterval = setInterval(() => {
			if (timeLeft > 0) {
				timeLeft -= 1;
			} else {
				endGame();
			}
		}, 1000);
	}

	function checkAnswer() {
		if (parseInt(userAnswer) === currentProblem.answer) {
			score += 10;
			feedback = 'correct';
			setTimeout(() => generateProblem(), 200);
		} else if (userAnswer.length >= currentProblem.answer.toString().length) {
			feedback = 'wrong';
			setTimeout(() => {
				feedback = null;
				userAnswer = '';
			}, 500);
		}
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
	<!-- Background Decorations -->
	<div class="absolute -left-20 -top-20 h-64 w-64 bg-blue-600 blur-[100px] opacity-20"></div>
	<div class="absolute -right-20 -bottom-20 h-64 w-64 bg-amber-600 blur-[100px] opacity-20"></div>

	<div class="w-full max-w-2xl relative z-10">
		{#if gameState === 'idle'}
			<div class="bg-white rounded-[40px] p-12 text-center shadow-2xl space-y-8" in:scale>
				<div class="inline-flex h-24 w-24 items-center justify-center rounded-[32px] bg-amber-100 text-amber-500 mb-4 animate-bounce">
					<Zap size={48} fill="currentColor" />
				</div>
				<div class="space-y-2">
					<h1 class="text-4xl font-black text-slate-900 tracking-tight">MATH SPEED CHALLENGE</h1>
					<p class="text-lg text-slate-500 font-medium">Solve as many problems as possible in 30 seconds!</p>
				</div>
				<div class="flex items-center justify-center gap-6">
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Rewards</p>
						<p class="font-black text-slate-900 text-xl">+10 XP/Correct</p>
					</div>
					<div class="h-10 w-px bg-slate-100"></div>
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Time</p>
						<p class="font-black text-slate-900 text-xl">30 Seconds</p>
					</div>
				</div>
				<button 
					onclick={startGame}
					class="w-full py-5 rounded-3xl bg-blue-600 text-white font-black text-xl shadow-xl shadow-blue-200 hover:bg-blue-700 hover:scale-[1.02] active:scale-95 transition-all"
				>
					START GAME
				</button>
			</div>
		{:else if gameState === 'playing'}
			<div class="space-y-12">
				<!-- Game Header -->
				<div class="flex items-center justify-between px-4">
					<div class="flex items-center gap-4">
						<div class="h-14 w-14 rounded-2xl bg-white/10 backdrop-blur-xl flex flex-col items-center justify-center text-white border border-white/20">
							<span class="text-[8px] font-black uppercase">Score</span>
							<span class="text-xl font-black">{score}</span>
						</div>
					</div>
					<div class={cn("h-16 w-32 rounded-3xl bg-white/10 backdrop-blur-xl border-2 flex items-center justify-center gap-2 text-2xl font-black transition-all", 
						timeLeft < 10 ? "border-red-500 text-red-500 animate-pulse" : "border-white/20 text-white"
					)}>
						<Timer size={24} />
						{timeLeft}s
					</div>
                    <a href="/games" class="p-3 bg-white/10 rounded-2xl text-white hover:bg-white/20">
                        <X size={24} />
                    </a>
				</div>

				<!-- Problem Area -->
				<div class="bg-white rounded-[50px] p-20 text-center shadow-2xl relative" in:fly={{ y: 20 }}>
					{#if feedback === 'correct'}
						<div class="absolute inset-0 flex items-center justify-center bg-green-500/10 rounded-[50px] z-20 pointer-events-none" in:fade>
							<CheckCircle2 size={120} class="text-green-500 opacity-50" />
						</div>
					{:else if feedback === 'wrong'}
						<div class="absolute inset-0 flex items-center justify-center bg-red-500/10 rounded-[50px] z-20 pointer-events-none" in:fade>
							<XCircle size={120} class="text-red-500 opacity-50" />
						</div>
					{/if}

					<div class="flex items-center justify-center gap-8 text-[120px] font-black text-slate-900 tracking-tighter leading-none mb-12">
						<span>{currentProblem.a}</span>
						<span class="text-blue-600">{currentProblem.op}</span>
						<span>{currentProblem.b}</span>
					</div>

					<input 
						type="number"
						bind:value={userAnswer}
						oninput={checkAnswer}
						autofocus
						class="w-full text-center bg-slate-50 border-4 border-slate-100 rounded-[32px] py-8 text-6xl font-black text-slate-900 outline-none focus:border-blue-500 transition-all placeholder-slate-200"
						placeholder="?"
					/>
				</div>
			</div>
		{:else if gameState === 'result'}
			<div class="bg-white rounded-[40px] p-16 text-center shadow-2xl space-y-10" in:scale>
				<div class="relative inline-block">
					<div class="absolute inset-0 bg-blue-400 blur-3xl opacity-20 rounded-full"></div>
					<div class="relative h-40 w-40 rounded-full bg-blue-50 border-8 border-blue-600 flex flex-col items-center justify-center shadow-xl">
						<Trophy size={48} class="text-blue-600 mb-1" />
						<span class="text-4xl font-black text-slate-900">{score}</span>
						<span class="text-[10px] font-black text-slate-400 uppercase">Points Earned</span>
					</div>
				</div>

				<div class="space-y-2">
					<h2 class="text-4xl font-black text-slate-900 tracking-tight">TIME'S UP!</h2>
					<p class="text-lg text-slate-500 font-medium italic">"Mathematics is the music of reason."</p>
				</div>

				<div class="grid grid-cols-2 gap-4">
					<button 
						onclick={startGame}
						class="py-5 rounded-3xl bg-blue-600 text-white font-black shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all flex items-center justify-center gap-2"
					>
						<RefreshCw size={20} /> TRY AGAIN
					</button>
					<a 
						href="/games"
						class="py-5 rounded-3xl bg-slate-100 text-slate-900 font-black hover:bg-slate-200 transition-all flex items-center justify-center gap-2"
					>
						BROWSE GAMES <ArrowRight size={20} />
					</a>
				</div>
			</div>
		{/if}
	</div>
</div>

<style>
	/* Hide number input arrows */
	input::-webkit-outer-spin-button,
	input::-webkit-inner-spin-button {
		-webkit-appearance: none;
		margin: 0;
	}
</style>
