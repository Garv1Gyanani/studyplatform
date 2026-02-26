<script lang="ts">
	import { page } from '$app/state';
	import { supabase } from '$lib/supabase';
	import { onMount, onDestroy } from 'svelte';
	import { 
		Timer, 
		ChevronRight, 
		ChevronLeft, 
		Trophy, 
		Loader2, 
		AlertTriangle,
		Lock,
		CheckCircle2,
		XCircle,
		ArrowRight,
		GraduationCap
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly, scale } from 'svelte/transition';
	import { openLogin } from '$lib/stores/auth';

	let testId = page.params.id;
	let test = $state<any>(null);
	let questions = $state<any[]>([]);
	let loading = $state(true);
	let user = $state<any>(null);

	// Test State
	let currentQuestionIndex = $state(0);
	let answers = $state<Record<string, string>>({});
	let isCompleted = $state(false);
	let score = $state(0);
	let timeLeft = $state(0);
	let timerInterval: any;
	let isStarted = $state(false);

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		user = sessionData.session?.user;

		if (!user) {
			loading = false;
			return;
		}

		// Fetch Test
		const { data: testData } = await supabase
			.from('tests')
			.select('*')
			.eq('id', testId)
			.single();
		
		test = testData;
		timeLeft = (test?.duration_minutes || 60) * 60;

		// Check availability
		const now = new Date();
		if (now < new Date(test.available_from) || now > new Date(test.available_to)) {
			alert('This test is not available at this time.');
			window.location.href = '/tests';
			return;
		}

		// Fetch Questions
		const { data: questionsData } = await supabase
			.from('test_questions')
			.select('*')
			.eq('test_id', testId);
		
		questions = questionsData || [];
		loading = false;
	});

	function startTest() {
		isStarted = true;
		startTimer();
		// Request fullscreen for formal vibe? Skip for now to avoid UX annoyance, but can add later.
	}

	function startTimer() {
		timerInterval = setInterval(() => {
			if (timeLeft > 0) {
				timeLeft -= 1;
			} else {
				submitTest();
			}
		}, 1000);
	}

	function formatTime(seconds: number) {
		const h = Math.floor(seconds / 3600);
		const m = Math.floor((seconds % 3600) / 60);
		const s = seconds % 60;
		return `${h > 0 ? h + ':' : ''}${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
	}

	async function submitTest() {
		clearInterval(timerInterval);
		let earnedMarks = 0;
		let totalMarks = 0;
		
		questions.forEach(q => {
			totalMarks += (q.marks || 1);
			if (answers[q.id] === q.correct_answer) {
				earnedMarks += (q.marks || 1);
			}
		});

		score = Math.round((earnedMarks / totalMarks) * 100);
		isCompleted = true;

		// Save Attempt
		await supabase.from('test_attempts').insert({
			test_id: testId,
			user_id: user.id,
			score: score,
			answers: answers
		});

		// Add Points
		if (score >= 40) { // Standard 40% passing for formal tests
			await supabase.rpc('increment_points', { user_id: user.id, points_to_add: 200 });
		}
	}

	function selectOption(questionId: string, value: string) {
		answers[questionId] = value;
	}

	onDestroy(() => {
		if (timerInterval) clearInterval(timerInterval);
	});
</script>

<div class="min-h-screen bg-white flex flex-col">
	{#if loading}
		<div class="flex flex-1 items-center justify-center">
			<Loader2 size={48} class="animate-spin text-indigo-600" />
		</div>
	{:else if !user}
		<div class="flex flex-1 flex-col items-center justify-center p-8 text-center" in:fade>
			<div class="h-24 w-24 rounded-3xl bg-amber-50 text-amber-500 flex items-center justify-center mb-6">
				<Lock size={48} />
			</div>
			<h1 class="text-3xl font-black text-slate-900 tracking-tight">Examination Secure Area</h1>
			<p class="mt-4 text-slate-500 max-w-sm leading-relaxed text-lg font-medium">
				You must be signed in to take formal assessments. Your session will be monitored.
			</p>
			<button 
				onclick={openLogin}
				class="mt-10 rounded-2xl bg-indigo-600 px-12 py-5 text-basis font-black text-white shadow-2xl shadow-indigo-200 transition-all hover:bg-indigo-700 hover:scale-[1.02] active:scale-95 flex items-center gap-3"
			>
				Sign In to Proceed
				<ArrowRight size={20} />
			</button>
		</div>
	{:else if !isStarted && !isCompleted}
		<!-- Pre-test Briefing -->
		<div class="flex-grow flex items-center justify-center p-6">
			<div class="w-full max-w-2xl bg-slate-50 rounded-[48px] p-12 border border-slate-100 shadow-sm space-y-10" in:scale>
				<div class="space-y-4 text-center">
					<div class="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-indigo-600 text-white shadow-xl shadow-indigo-200 mb-2">
						<AlertTriangle size={32} />
					</div>
					<h2 class="text-3xl font-black text-slate-900">Pre-Examination Briefing</h2>
					<p class="text-slate-500 font-medium">{test.title}</p>
				</div>

				<div class="grid grid-cols-2 gap-6">
					<div class="bg-white rounded-3xl p-6 border border-slate-100">
						<p class="text-[10px] font-black uppercase text-slate-400 mb-1">Duration</p>
						<p class="text-xl font-black text-slate-900">{test.duration_minutes} Minutes</p>
					</div>
					<div class="bg-white rounded-3xl p-6 border border-slate-100">
						<p class="text-[10px] font-black uppercase text-slate-400 mb-1">Questions</p>
						<p class="text-xl font-black text-slate-900">{questions.length} Items</p>
					</div>
				</div>

				<div class="space-y-4">
					<h4 class="font-black text-slate-900 uppercase tracking-widest text-xs border-b border-slate-200 pb-2">Rules & Regulations</h4>
					<ul class="space-y-3">
						<li class="flex items-start gap-3 text-sm text-slate-600 font-medium">
							<div class="h-5 w-5 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center shrink-0 mt-0.5 text-[10px] font-black">1</div>
							Once the test starts, the timer cannot be paused.
						</li>
						<li class="flex items-start gap-3 text-sm text-slate-600 font-medium">
							<div class="h-5 w-5 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center shrink-0 mt-0.5 text-[10px] font-black">2</div>
							Closing the browser or refreshing will not stop the timer.
						</li>
						<li class="flex items-start gap-3 text-sm text-slate-600 font-medium">
							<div class="h-5 w-5 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center shrink-0 mt-0.5 text-[10px] font-black">3</div>
							Ensure you have a stable internet connection.
						</li>
					</ul>
				</div>

				<button 
					onclick={startTest}
					class="w-full py-5 rounded-3xl bg-slate-900 text-white font-black text-lg hover:bg-black transition-all active:scale-95 shadow-2xl"
				>
					Start Examination Now
				</button>
			</div>
		</div>
	{:else if isCompleted}
		<!-- Result Screen -->
		<div class="flex-grow flex items-center justify-center p-6">
			<div class="w-full max-w-2xl text-center space-y-12" in:fly={{ y: 20 }}>
				<div class="relative inline-block">
					<div class="absolute inset-0 bg-indigo-400 blur-3xl opacity-20 rounded-full animate-pulse"></div>
					<div class={cn("relative h-56 w-56 rounded-[60px] flex flex-col items-center justify-center border-8 shadow-2xl", 
						score >= 40 ? "border-green-500 bg-green-50" : "border-red-400 bg-red-50"
					)}>
						<span class="text-xs uppercase tracking-widest font-black text-slate-400">Final Grade</span>
						<span class="text-7xl font-black text-slate-900">{score}%</span>
					</div>
				</div>

				<div class="space-y-4">
					<h2 class="text-4xl font-black text-slate-900 tracking-tight">
						{score >= 40 ? 'Assessment Passed' : 'Assessment Unsuccessful'}
					</h2>
					<p class="text-xl text-slate-500 font-medium max-w-lg mx-auto">
						{score >= 40 
							? `You have successfully completed the formal assessment for "${test.title}". Your score has been recorded.` 
							: `Unfortunately your score of ${score}% falls below the graduation requirement. Please review the curriculum and try again in the next window.`}
					</p>
				</div>

				<div class="flex gap-4 justify-center">
					<a href="/tests" class="px-10 py-5 rounded-3xl bg-slate-100 text-slate-900 font-black hover:bg-slate-200 transition-all border border-slate-200">
						Exit Examination Area
					</a>
					<a href="/dashboard" class="px-10 py-5 rounded-3xl bg-indigo-600 text-white font-black shadow-xl shadow-indigo-200 hover:bg-indigo-700 transition-all">
						Return to Dashboard
					</a>
				</div>
			</div>
		</div>
	{:else}
		<!-- Active Test UI (Focus Mode) -->
		<div class="bg-indigo-900 text-white px-8 py-4 flex items-center justify-between border-b border-indigo-800">
			<div class="flex items-center gap-4">
				<div class="h-10 w-10 rounded-xl bg-white/10 flex items-center justify-center border border-white/20">
					<GraduationCap size={24} />
				</div>
				<div>
					<p class="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-300">Live Examination</p>
					<h2 class="font-black text-basis tracking-tight">{test.title}</h2>
				</div>
			</div>

			<div class="flex items-center gap-10">
				<div class="hidden md:flex flex-col items-end">
					<p class="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-300">Progress</p>
					<p class="font-black text-basis">{currentQuestionIndex + 1} / {questions.length} Questions</p>
				</div>
				<div class="h-14 w-px bg-indigo-800"></div>
				<div class="flex flex-col items-end">
					<p class="text-[10px] font-black uppercase tracking-[0.2em] text-indigo-300">Remaining</p>
					<div class={cn("font-mono text-2xl font-black", timeLeft < 300 ? "text-red-400 animate-pulse" : "text-white")}>
						{formatTime(timeLeft)}
					</div>
				</div>
			</div>
		</div>

		<div class="flex-grow overflow-y-auto bg-slate-50/50">
			<!-- Progress Bar -->
			<div class="h-1 bg-slate-200 w-full mb-12">
				<div class="h-full bg-indigo-600 transition-all duration-500" style="width: {((currentQuestionIndex + 1) / questions.length) * 100}%"></div>
			</div>

			<div class="max-w-4xl mx-auto px-6 pb-20 pt-4">
				{#key currentQuestionIndex}
					<div in:fly={{ x: 20, duration: 400 }} class="space-y-12">
						<div class="space-y-4">
							<span class="px-3 py-1 bg-indigo-50 text-indigo-600 text-[10px] font-black uppercase tracking-widest rounded-lg border border-indigo-100">
								{questions[currentQuestionIndex].marks || 1} Marks
							</span>
							<h3 class="text-4xl font-black text-slate-900 leading-tight">
								{questions[currentQuestionIndex].question}
							</h3>
						</div>

						<div class="grid grid-cols-1 gap-4">
							{#each (questions[currentQuestionIndex].options || []) as option}
								<button 
									onclick={() => selectOption(questions[currentQuestionIndex].id, option.text || option)}
									class={cn(
										"group flex items-center justify-between rounded-3xl border-2 p-8 transition-all text-left",
										answers[questions[currentQuestionIndex].id] === (option.text || option)
											? "border-indigo-600 bg-white ring-4 ring-indigo-600/10 shadow-xl"
											: "border-slate-100 bg-white/50 hover:bg-white hover:border-indigo-200"
									)}
								>
									<span class="text-xl font-bold text-slate-700 leading-tight">{option.text || option}</span>
									<div class={cn(
										"h-8 w-8 rounded-full border-2 flex items-center justify-center shrink-0",
										answers[questions[currentQuestionIndex].id] === (option.text || option)
											? "border-indigo-600 bg-indigo-600"
											: "border-slate-200"
									)}>
										{#if answers[questions[currentQuestionIndex].id] === (option.text || option)}
											<div class="h-2.5 w-2.5 rounded-full bg-white"></div>
										{/if}
									</div>
								</button>
							{/each}
						</div>
					</div>
				{/key}
			</div>
		</div>

		<!-- Footer Controls -->
		<div class="bg-white border-t border-slate-200 px-8 py-6 flex items-center justify-between shadow-2xl">
			<button 
				disabled={currentQuestionIndex === 0}
				onclick={() => currentQuestionIndex -= 1}
				class="flex items-center gap-2 px-8 py-3 rounded-2xl font-black text-slate-400 hover:text-indigo-600 hover:bg-slate-50 disabled:opacity-0 transition-all"
			>
				<ChevronLeft size={24} /> Prev
			</button>

			<div class="flex items-center gap-4">
				<p class="text-xs font-black text-slate-300 uppercase tracking-widest hidden sm:block">Automated Grading Active</p>
				{#if currentQuestionIndex === questions.length - 1}
					<button 
						onclick={() => { if(confirm('Are you sure you want to finalise your submission?')) submitTest(); }}
						class="px-12 py-4 rounded-2xl bg-indigo-600 text-white font-black shadow-xl shadow-indigo-200 hover:bg-indigo-700 active:scale-95 transition-all"
					>
						Finalise & Submit
					</button>
				{:else}
					<button 
						onclick={() => currentQuestionIndex += 1}
						class="px-12 py-4 rounded-2xl bg-slate-900 text-white font-black shadow-xl shadow-slate-200 hover:bg-black active:scale-95 transition-all flex items-center gap-2"
					>
						Next Item <ChevronRight size={24} />
					</button>
				{/if}
			</div>
		</div>
	{/if}
</div>
