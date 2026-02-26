<script lang="ts">
	import { page } from '$app/state';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Timer, 
		ChevronRight, 
		ChevronLeft, 
		Trophy, 
		Loader2, 
		X, 
		RefreshCw, 
		CheckCircle2, 
		AlertCircle,
		PlayCircle,
		ArrowRight,
		Lightbulb,
		Sparkles
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';
	import { openLogin } from '$lib/stores/auth';

	let quizId = page.params.id;
	let quiz = $state<any>(null);
	let questions = $state<any[]>([]);
	let loading = $state(true);
	let user = $state<any>(null);

	// Quiz State
	let currentQuestionIndex = $state(0);
	let answers = $state<Record<string, string>>({});
	let isCompleted = $state(false);
	let score = $state(0);
	let timeLeft = $state(0);
	let timerInterval: any;

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		user = sessionData.session?.user;

		if (!user) {
			loading = false;
			return;
		}

		// Fetch Quiz
		const { data: quizData } = await supabase
			.from('quizzes')
			.select('*')
			.eq('id', quizId)
			.single();
		
		quiz = quizData;
		timeLeft = (quiz?.time_limit || 15) * 60;

		// Fetch Questions
		const { data: questionsData } = await supabase
			.from('quiz_questions')
			.select('*')
			.eq('quiz_id', quizId);
		
		questions = questionsData || [];
		loading = false;

		startTimer();
	});

	function startTimer() {
		timerInterval = setInterval(() => {
			if (timeLeft > 0) {
				timeLeft -= 1;
			} else {
				submitQuiz();
			}
		}, 1000);
	}

	function formatTime(seconds: number) {
		const m = Math.floor(seconds / 60);
		const s = seconds % 60;
		return `${m}:${s.toString().padStart(2, '0')}`;
	}

	function nextQuestion() {
		if (currentQuestionIndex < questions.length - 1) {
			currentQuestionIndex += 1;
		} else {
			submitQuiz();
		}
	}

	async function submitQuiz() {
		clearInterval(timerInterval);
		let correctCount = 0;
		
		questions.forEach(q => {
			const userAnswer = answers[q.id];
			const correctOption = q.options.find((o: any) => o.is_correct);
			if (userAnswer === correctOption?.text) {
				correctCount += 1;
			}
		});

		score = Math.round((correctCount / questions.length) * 100);
		isCompleted = true;

		// Save Attempt
		await supabase.from('quiz_attempts').insert({
			quiz_id: quizId,
			user_id: user.id,
			score: score,
			answers: answers
		});

		// Add Points (Logic simplified)
		if (score >= quiz.passing_score) {
			await supabase.rpc('increment_points', { user_id: user.id, points_to_add: 50 });
		}
	}

	function selectOption(questionId: string, text: string) {
		answers[questionId] = text;
	}

	function getAIHint() {
		const q = questions[currentQuestionIndex];
		const prompt = `I'm taking a quiz on "${quiz.title}". The question is: "${q.question}". The options are: ${q.options.map((o: any) => o.text).join(', ')}. Without giving me the direct answer, can you give me a subtle hint or explain the concept?`;
		window.dispatchEvent(new CustomEvent('ai-assistant-prompt', { detail: prompt }));
	}
</script>

<div class="min-h-[calc(100vh-64px)] bg-slate-50 flex flex-col">
	{#if loading}
		<div class="flex flex-1 items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if !user}
		<div class="flex flex-1 flex-col items-center justify-center p-8 text-center" in:fade>
			<div class="h-20 w-20 rounded-3xl bg-amber-50 text-amber-500 flex items-center justify-center mb-6">
				<AlertCircle size={40} />
			</div>
			<h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">Authentication Required</h1>
			<p class="mt-4 text-slate-500 max-w-sm leading-relaxed text-lg font-medium">
				You must be signed in to attempt quizzes and record your scores.
			</p>
			<button 
				onclick={openLogin}
				class="mt-8 rounded-2xl bg-blue-600 px-10 py-4 text-basis font-bold text-white shadow-xl shadow-blue-200 transition-all hover:bg-blue-700 hover:scale-105 active:scale-95 flex items-center gap-2"
			>
				Sign In Now
				<ArrowRight size={20} />
			</button>
		</div>
	{:else if isCompleted}
		<!-- Result Screen -->
		<div class="flex-grow flex items-center justify-center p-4">
			<div class="w-full max-w-2xl text-center space-y-10" in:fly={{ y: 20, duration: 500 }}>
				<div class="relative inline-block">
					<div class="absolute inset-0 bg-blue-400 blur-3xl opacity-20 rounded-full animate-pulse"></div>
					<div class={cn("relative h-48 w-48 rounded-full flex flex-col items-center justify-center border-8 shadow-2xl", 
						score >= quiz.passing_score ? "border-green-500 bg-green-50" : "border-red-400 bg-red-50"
					)}>
						<span class="text-xs uppercase tracking-widest font-bold text-slate-400">Score</span>
						<span class="text-6xl font-black text-slate-900">{score}%</span>
					</div>
				</div>

				<div class="space-y-4">
					<h2 class="text-4xl font-extrabold text-slate-900">
						{score >= quiz.passing_score ? 'Outstanding Achievement!' : 'Better luck next time'}
					</h2>
					<p class="text-lg text-slate-500 font-medium">
						{score >= quiz.passing_score 
							? `Congratulations! You've passed the "${quiz.title}" assessment with flying colors.` 
							: `You needed ${quiz.passing_score}% to pass. Don't worry, you can always try again after some review.`}
					</p>
				</div>

				<div class="flex gap-4 justify-center">
					<a href="/quizzes" class="inline-flex items-center gap-2 rounded-2xl bg-white border border-slate-200 px-8 py-4 font-bold text-slate-700 shadow-sm hover:bg-slate-50 transition-all">
						Back to Quizzes
					</a>
					<button 
						onclick={() => window.location.reload()}
						class="inline-flex items-center gap-2 rounded-2xl bg-blue-600 px-8 py-4 font-bold text-white shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all active:scale-95"
					>
						<RefreshCw size={20} />
						Retake Quiz
					</button>
				</div>
			</div>
		</div>
	{:else}
		<!-- Header / Progress Area -->
		<div class="sticky top-0 z-20 bg-white border-b border-slate-200 px-4 sm:px-8 py-4 flex items-center justify-between shadow-sm">
			<div class="flex items-center gap-4">
				<a href="/quizzes" class="p-2 text-slate-400 hover:text-slate-900 hover:bg-slate-100 rounded-xl transition-all">
					<X size={24} />
				</a>
				<div class="h-8 w-px bg-slate-200 mx-2 hidden sm:block"></div>
				<div>
					<h1 class="text-basis font-bold text-slate-900 line-clamp-1">{quiz.title}</h1>
					<p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Question {currentQuestionIndex + 1} of {questions.length}</p>
				</div>
			</div>

			<div class="flex items-center gap-6">
				<div class="hidden sm:flex flex-col items-end">
					<span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Time Remaining</span>
					<div class={cn("flex items-center gap-1.5 font-mono font-bold text-lg", timeLeft < 60 ? "text-red-500 animate-pulse" : "text-blue-600")}>
						<Timer size={18} />
						{formatTime(timeLeft)}
					</div>
				</div>
				<button 
					onclick={submitQuiz}
					class="rounded-xl border border-slate-200 bg-white px-5 py-2 text-sm font-bold text-slate-600 hover:bg-slate-50 hover:text-red-600 transition-all"
				>
					Finish
				</button>
			</div>
		</div>

		<!-- Main Engine Area -->
		<div class="flex-grow flex flex-col items-center justify-center p-4">
			<div class="w-full max-w-3xl">
				<!-- Progress Bar -->
				<div class="mb-12 h-2 w-full bg-slate-200 rounded-full overflow-hidden">
					<div 
						class="h-full bg-blue-600 transition-all duration-700 ease-out" 
						style="width: {((currentQuestionIndex + 1) / questions.length) * 100}%"
					></div>
				</div>

				{#key currentQuestionIndex}
					<div in:fly={{ x: 20, duration: 400 }} out:fly={{ x: -20, duration: 400 }} class="space-y-12">
						<h2 class="text-3xl font-extrabold text-slate-900 leading-tight">
							{questions[currentQuestionIndex].question}
						</h2>

						<!-- AI Hint Button -->
						<div class="flex">
							<button 
								onclick={getAIHint}
								class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-amber-50 border border-amber-100 text-amber-700 text-xs font-black shadow-sm hover:bg-amber-100 transition-all group"
							>
								<Lightbulb size={14} class="group-hover:scale-110 transition-transform" />
								GET AI HINT
							</button>
						</div>

						<div class="grid grid-cols-1 gap-4">
							{#each questions[currentQuestionIndex].options as option}
								<button 
									onclick={() => selectOption(questions[currentQuestionIndex].id, option.text)}
									class={cn(
										"group relative flex items-center justify-between rounded-3xl border-2 p-6 transition-all text-left",
										answers[questions[currentQuestionIndex].id] === option.text
											? "border-blue-600 bg-blue-50/50 ring-4 ring-blue-500/10"
											: "border-slate-100 bg-white hover:border-blue-200 hover:bg-vslate-50"
									)}
								>
									<div class="flex items-center gap-4">
										<div class={cn(
											"flex h-10 w-10 items-center justify-center rounded-xl text-basis font-bold transition-colors",
											answers[questions[currentQuestionIndex].id] === option.text
												? "bg-blue-600 text-white shadow-lg shadow-blue-200"
												: "bg-slate-50 text-slate-400 group-hover:bg-blue-100 group-hover:text-blue-600"
										)}>
											{option.text.charAt(0)}
										</div>
										<span class="text-lg font-bold text-slate-700">{option.text}</span>
									</div>
									<div class={cn(
										"h-6 w-6 rounded-full border-2 flex items-center justify-center transition-all",
										answers[questions[currentQuestionIndex].id] === option.text
											? "border-blue-600 bg-blue-600"
											: "border-slate-200 bg-transparent group-hover:border-blue-300"
									)}>
										{#if answers[questions[currentQuestionIndex].id] === option.text}
											<div class="h-2 w-2 rounded-full bg-white scale-110"></div>
										{/if}
									</div>
								</button>
							{/each}
						</div>
					</div>
				{/key}
			</div>
		</div>

		<!-- Footer Nav -->
		<div class="bg-white border-t border-slate-200 px-4 sm:px-8 py-6 flex items-center justify-between">
			<button 
				disabled={currentQuestionIndex === 0}
				onclick={() => currentQuestionIndex -= 1}
				class="inline-flex items-center gap-2 rounded-2xl px-6 py-3 font-bold text-slate-500 hover:bg-slate-50 disabled:opacity-30 transition-all"
			>
				<ChevronLeft size={20} />
				Previous
			</button>

			<button 
				onclick={nextQuestion}
				disabled={!answers[questions[currentQuestionIndex].id]}
				class="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-10 py-3 font-bold text-white shadow-xl shadow-slate-200 hover:bg-black active:scale-95 disabled:opacity-50 transition-all"
			>
				{currentQuestionIndex === questions.length - 1 ? 'Submit' : 'Next Question'}
				<ChevronRight size={20} />
			</button>
		</div>
	{/if}
</div>
