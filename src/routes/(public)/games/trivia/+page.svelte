<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { Brain, Timer, Trophy, RefreshCw, CheckCircle2, XCircle, ArrowRight, X } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';

	let gameState = $state<'idle' | 'playing' | 'result'>('idle');
	let score = $state(0);
	let currentQuestion = $state<any>(null);
	let questionIndex = $state(0);
	let selectedAnswer = $state<number | null>(null);
	let answered = $state(false);
	let totalQuestions = 10;
	let correct = $state(0);

	const triviaQuestions = [
		{
			question: "What is the chemical symbol for Gold?",
			options: ["Go", "Gd", "Au", "Ag"],
			correct: 2, category: "Chemistry"
		},
		{
			question: "What is the derivative of sin(x)?",
			options: ["cos(x)", "-cos(x)", "tan(x)", "-sin(x)"],
			correct: 0, category: "Mathematics"
		},
		{
			question: "Which data structure uses LIFO order?",
			options: ["Queue", "Stack", "LinkedList", "Tree"],
			correct: 1, category: "Computer Science"
		},
		{
			question: "What is the powerhouse of the cell?",
			options: ["Nucleus", "Ribosome", "Mitochondria", "Golgi Body"],
			correct: 2, category: "Biology"
		},
		{
			question: "Who wrote 'The Origin of Species'?",
			options: ["Newton", "Darwin", "Einstein", "Galileo"],
			correct: 1, category: "History"
		},
		{
			question: "What is the speed of light (approx)?",
			options: ["3×10⁶ m/s", "3×10⁸ m/s", "3×10¹⁰ m/s", "3×10⁴ m/s"],
			correct: 1, category: "Physics"
		},
		{
			question: "React.js was created by?",
			options: ["Google", "Microsoft", "Facebook", "Twitter"],
			correct: 2, category: "Tech"
		},
		{
			question: "What is the largest planet in our solar system?",
			options: ["Saturn", "Neptune", "Jupiter", "Uranus"],
			correct: 2, category: "Astronomy"
		},
		{
			question: "What does SQL stand for?",
			options: ["Structured Query Language", "Simple Query Logic", "Standard Question Language", "System Query Layout"],
			correct: 0, category: "Computer Science"
		},
		{
			question: "In binary, what is the decimal number 10?",
			options: ["1010", "1100", "1001", "0110"],
			correct: 0, category: "Computer Science"
		},
		{
			question: "What does DNA stand for?",
			options: ["Deoxyribonucleic Acid", "Dinitrogen Acid", "Dynamic Nuclear Array", "Direct Nucleic Acid"],
			correct: 0, category: "Biology"
		},
		{
			question: "Which element has atomic number 1?",
			options: ["Helium", "Lithium", "Hydrogen", "Carbon"],
			correct: 2, category: "Chemistry"
		},
	];

	function startGame() {
		gameState = 'playing';
		score = 0;
		questionIndex = 0;
		correct = 0;
		loadQuestion();
	}

	function loadQuestion() {
		selectedAnswer = null;
		answered = false;
		currentQuestion = triviaQuestions[questionIndex % triviaQuestions.length];
	}

	function selectAnswer(idx: number) {
		if (answered) return;
		selectedAnswer = idx;
		answered = true;
		if (idx === currentQuestion.correct) {
			score += 50;
			correct += 1;
		}
		setTimeout(() => {
			questionIndex += 1;
			if (questionIndex >= totalQuestions) {
				endGame();
			} else {
				loadQuestion();
			}
		}, 1200);
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
	<div class="absolute -left-20 -top-20 h-64 w-64 bg-purple-600 blur-[100px] opacity-20"></div>
	<div class="absolute -right-20 -bottom-20 h-64 w-64 bg-indigo-600 blur-[100px] opacity-20"></div>

	<div class="w-full max-w-2xl relative z-10">
		{#if gameState === 'idle'}
			<div class="bg-white rounded-[40px] p-12 text-center shadow-2xl space-y-8" in:scale>
				<div class="inline-flex h-24 w-24 items-center justify-center rounded-[32px] bg-purple-100 text-purple-600 mb-4 animate-bounce">
					<Brain size={48} />
				</div>
				<div class="space-y-2">
					<h1 class="text-4xl font-black text-slate-900 tracking-tight">SUBJECT TRIVIA</h1>
					<p class="text-lg text-slate-500 font-medium">Test your knowledge across all subjects!</p>
				</div>
				<div class="flex items-center justify-center gap-6">
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Rewards</p>
						<p class="font-black text-slate-900 text-xl">+50 XP/Round</p>
					</div>
					<div class="h-10 w-px bg-slate-100"></div>
					<div class="text-center">
						<p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Questions</p>
						<p class="font-black text-slate-900 text-xl">{totalQuestions} Total</p>
					</div>
				</div>
				<button onclick={startGame} class="w-full py-5 rounded-3xl bg-purple-600 text-white font-black text-xl shadow-xl shadow-purple-200 hover:bg-purple-700 hover:scale-[1.02] active:scale-95 transition-all">
					START TRIVIA
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
					</div>
					<div class="px-6 py-3 rounded-2xl bg-white/10 backdrop-blur-xl border border-white/20 text-white font-black">
						{questionIndex + 1} / {totalQuestions}
					</div>
					<a href="/games" class="p-3 bg-white/10 rounded-2xl text-white hover:bg-white/20">
						<X size={24} />
					</a>
				</div>

				<!-- Progress Bar -->
				<div class="px-4">
					<div class="h-2 bg-white/10 rounded-full overflow-hidden">
						<div class="h-full bg-purple-500 rounded-full transition-all duration-500" style="width: {((questionIndex) / totalQuestions) * 100}%"></div>
					</div>
				</div>

				{#key questionIndex}
					<div class="bg-white rounded-[40px] p-10 shadow-2xl space-y-8" in:fly={{ x: 50, duration: 300 }}>
						<div class="flex items-center gap-2">
							<span class="px-3 py-1 bg-purple-50 text-purple-600 text-[10px] font-black uppercase tracking-widest rounded-lg border border-purple-100">
								{currentQuestion.category}
							</span>
						</div>
						<h2 class="text-2xl font-black text-slate-900 leading-tight">{currentQuestion.question}</h2>

						<div class="grid grid-cols-1 gap-3">
							{#each currentQuestion.options as option, idx}
								<button 
									onclick={() => selectAnswer(idx)}
									disabled={answered}
									class={cn(
										"w-full text-left px-6 py-5 rounded-2xl border-2 font-bold text-lg transition-all",
										answered && idx === currentQuestion.correct
											? "bg-green-50 border-green-500 text-green-700"
											: answered && idx === selectedAnswer && idx !== currentQuestion.correct
												? "bg-red-50 border-red-500 text-red-700"
												: selectedAnswer === idx
													? "border-purple-600 bg-purple-50 text-purple-700"
													: "border-slate-100 bg-white text-slate-900 hover:border-purple-200 hover:bg-purple-50/30"
									)}
								>
									<div class="flex items-center justify-between">
										<div class="flex items-center gap-4">
											<span class={cn("h-8 w-8 rounded-lg flex items-center justify-center text-sm font-black",
												answered && idx === currentQuestion.correct ? "bg-green-500 text-white" :
												answered && idx === selectedAnswer && idx !== currentQuestion.correct ? "bg-red-500 text-white" :
												"bg-slate-100 text-slate-500"
											)}>
												{String.fromCharCode(65 + idx)}
											</span>
											{option}
										</div>
										{#if answered && idx === currentQuestion.correct}
											<CheckCircle2 size={24} class="text-green-500" />
										{:else if answered && idx === selectedAnswer && idx !== currentQuestion.correct}
											<XCircle size={24} class="text-red-500" />
										{/if}
									</div>
								</button>
							{/each}
						</div>
					</div>
				{/key}
			</div>
		{:else if gameState === 'result'}
			<div class="bg-white rounded-[40px] p-16 text-center shadow-2xl space-y-10" in:scale>
				<div class="relative inline-block">
					<div class="absolute inset-0 bg-purple-400 blur-3xl opacity-20 rounded-full"></div>
					<div class="relative h-40 w-40 rounded-full bg-purple-50 border-8 border-purple-600 flex flex-col items-center justify-center shadow-xl">
						<Trophy size={48} class="text-purple-600 mb-1" />
						<span class="text-4xl font-black text-slate-900">{correct}/{totalQuestions}</span>
						<span class="text-[10px] font-black text-slate-400 uppercase">Correct</span>
					</div>
				</div>
				<div class="space-y-2">
					<h2 class="text-4xl font-black text-slate-900 tracking-tight">
						{correct >= 8 ? "BRILLIANT!" : correct >= 5 ? "WELL DONE!" : "KEEP TRYING!"}
					</h2>
					<p class="text-lg text-slate-500 font-medium">You earned <span class="text-purple-600 font-black">{score} XP</span> from this round.</p>
				</div>
				<div class="grid grid-cols-2 gap-4">
					<button onclick={startGame} class="py-5 rounded-3xl bg-purple-600 text-white font-black shadow-xl shadow-purple-200 hover:bg-purple-700 transition-all flex items-center justify-center gap-2">
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
