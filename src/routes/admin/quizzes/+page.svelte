<script lang="ts">
	import { 
		Plus, 
		Search, 
		Filter, 
		MoreVertical, 
		Edit2, 
		Trash2, 
		FileQuestion,
		X,
		Loader2,
		CheckCircle2,
		Timer,
		ChevronRight,
		Save
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let quizzes = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Quiz Form State
	let title = $state('');
	let description = $state('');
	let timeLimit = $state(15);
	let passingScore = $state(70);
	let isPublished = $state(false);

	// Question State
	let questions = $state<any[]>([]);

	onMount(fetchQuizzes);

	async function fetchQuizzes() {
		loading = true;
		const { data, error } = await supabase
			.from('quizzes')
			.select('*')
			.order('created_at', { ascending: false });
		
		if (!error) quizzes = data;
		loading = false;
	}

	function addQuestion() {
		questions = [...questions, {
			question: '',
			type: 'mcq',
			options: [
				{ text: '', is_correct: true },
				{ text: '', is_correct: false },
				{ text: '', is_correct: false },
				{ text: '', is_correct: false }
			]
		}];
	}

	function removeQuestion(index: number) {
		questions = questions.filter((_, i) => i !== index);
	}

	async function handleSaveQuiz() {
		formLoading = true;
		
		// 1. Insert Quiz
		const { data: quizData, error: quizError } = await supabase
			.from('quizzes')
			.insert({
				title,
				description,
				time_limit: timeLimit,
				passing_score: passingScore,
				is_published: isPublished
			})
			.select()
			.single();

		if (quizError) {
			alert(quizError.message);
			formLoading = false;
			return;
		}

		// 2. Insert Questions
		const questionsToInsert = questions.map(q => ({
			quiz_id: quizData.id,
			question: q.question,
			type: q.type,
			options: q.options
		}));

		if (questionsToInsert.length > 0) {
			const { error: qError } = await supabase
				.from('quiz_questions')
				.insert(questionsToInsert);
			
			if (qError) alert(qError.message);
		}

		isFormOpen = false;
		resetForm();
		fetchQuizzes();
		formLoading = false;
	}

	function resetForm() {
		title = '';
		description = '';
		timeLimit = 15;
		passingScore = 70;
		questions = [];
		isPublished = false;
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Quizzes</h1>
			<p class="mt-1 text-slate-500">Create and manage interactive quizzes for your students.</p>
		</div>
		<button 
			onclick={() => isFormOpen = true}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700 active:scale-95"
		>
			<Plus size={18} />
			Create New Quiz
		</button>
	</div>

	<!-- Stats / Overview -->
	<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
		<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
			<div class="flex items-center gap-4">
				<div class="h-10 w-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
					<FileQuestion size={20} />
				</div>
				<div>
					<p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Total Quizzes</p>
					<p class="text-xl font-bold text-slate-900">{quizzes.length}</p>
				</div>
			</div>
		</div>
		<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
			<div class="flex items-center gap-4">
				<div class="h-10 w-10 rounded-xl bg-green-50 text-green-600 flex items-center justify-center">
					<CheckCircle2 size={20} />
				</div>
				<div>
					<p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Published</p>
					<p class="text-xl font-bold text-slate-900">{quizzes.filter(q => q.is_published).length}</p>
				</div>
			</div>
		</div>
		<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
			<div class="flex items-center gap-4">
				<div class="h-10 w-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
					<Timer size={20} />
				</div>
				<div>
					<p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Avg. Time</p>
					<p class="text-xl font-bold text-slate-900">~12m</p>
				</div>
			</div>
		</div>
	</div>

	<!-- List / Table -->
	<div class="rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">
		{#if loading}
			<div class="flex h-64 items-center justify-center">
				<Loader2 size={32} class="animate-spin text-blue-600" />
			</div>
		{:else if quizzes.length === 0}
			<div class="p-12 text-center">
				<div class="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-50 text-slate-300 mb-4">
					<FileQuestion size={32} />
				</div>
				<h3 class="text-lg font-bold text-slate-900">No quizzes yet</h3>
				<p class="text-sm text-slate-500 mt-1">Start by creating your first interactive assessment.</p>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Quiz Title</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-center">Time Limit</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-center">Passing</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-center">Status</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each quizzes as quiz}
							<tr class="group hover:bg-slate-50/50 transition-colors">
								<td class="px-6 py-4">
									<p class="font-bold text-slate-900">{quiz.title}</p>
									<p class="text-xs text-slate-400 mt-0.5 line-clamp-1">{quiz.description}</p>
								</td>
								<td class="px-6 py-4 text-center">
									<span class="text-sm font-medium text-slate-600">{quiz.time_limit} mins</span>
								</td>
								<td class="px-6 py-4 text-center">
									<span class="text-sm font-bold text-blue-600">{quiz.passing_score}%</span>
								</td>
								<td class="px-6 py-4 text-center">
									<span class={cn("inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-bold", quiz.is_published ? "bg-green-50 text-green-700" : "bg-slate-100 text-slate-500")}>
										{quiz.is_published ? 'Published' : 'Draft'}
									</span>
								</td>
								<td class="px-6 py-4 text-right">
									<div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
										<button class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all">
											<Edit2 size={18} />
										</button>
										<button class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all">
											<Trash2 size={18} />
										</button>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>

<!-- Builder Modal -->
{#if isFormOpen}
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
		onclick={() => isFormOpen = false}
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-5xl overflow-hidden rounded-3xl bg-white shadow-2xl flex flex-col h-[90vh]"
			onclick={e => e.stopPropagation()}
		>
			<!-- Header -->
			<div class="flex items-center justify-between border-b border-slate-100 px-8 py-6 bg-slate-50/50">
				<div>
					<h2 class="text-xl font-bold text-slate-900">Quiz Builder</h2>
					<p class="text-xs font-medium text-slate-500">Design an engaging assessment for your students</p>
				</div>
				<button onclick={() => isFormOpen = false} class="rounded-full p-2 text-slate-400 hover:bg-white hover:text-slate-900 shadow-sm border border-transparent hover:border-slate-100 transition-all">
					<X size={20} />
				</button>
			</div>

			<div class="flex-grow overflow-y-auto p-8 grid grid-cols-1 lg:grid-cols-12 gap-8">
				<!-- Quiz Settings -->
				<div class="lg:col-span-4 space-y-6">
					<div class="rounded-2xl border border-slate-200 p-6 space-y-4">
						<h3 class="text-sm font-bold uppercase tracking-widest text-slate-400 mb-2">General Settings</h3>
						<div class="space-y-1">
							<label class="text-xs font-bold text-slate-500">Quiz Title</label>
							<input bind:value={title} class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:bg-white focus:ring-4 focus:ring-blue-500/10 transition-all outline-none border-transparent focus:border-blue-500" placeholder="e.g. Biology Basics" />
						</div>
						<div class="space-y-1">
							<label class="text-xs font-bold text-slate-500">Description</label>
							<textarea bind:value={description} class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:bg-white transition-all outline-none resize-none h-24" placeholder="Brief overview of the quiz..."></textarea>
						</div>
						<div class="grid grid-cols-2 gap-4">
							<div class="space-y-1">
								<label class="text-xs font-bold text-slate-500">Time Limit (m)</label>
								<input type="number" bind:value={timeLimit} class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:bg-white transition-all outline-none" />
							</div>
							<div class="space-y-1">
								<label class="text-xs font-bold text-slate-500">Passing (%)</label>
								<input type="number" bind:value={passingScore} class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:bg-white transition-all outline-none" />
							</div>
						</div>
						<label class="flex items-center justify-between cursor-pointer pt-2">
							<span class="text-sm font-bold text-slate-700">Publish immediately</span>
							<div class="relative inline-flex h-6 w-11 items-center rounded-full bg-slate-200 transition-colors" class:bg-blue-600={isPublished}>
								<input type="checkbox" bind:checked={isPublished} class="sr-only" />
								<span class={cn("h-4 w-4 bg-white rounded-full transition-transform", isPublished ? "translate-x-6" : "translate-x-1")}></span>
							</div>
						</label>
					</div>
					
					<div class="rounded-2xl bg-blue-600 p-6 text-white shadow-lg shadow-blue-200">
						<h4 class="font-bold flex items-center gap-2"><CheckCircle2 size={18} /> Pro Builder</h4>
						<p class="mt-2 text-xs text-blue-100 leading-relaxed">Ensure questions are random and diverse to keep students engaged. You can add images to questions too!</p>
					</div>
				</div>

				<!-- Questions Area -->
				<div class="lg:col-span-8 space-y-6">
					<div class="flex items-center justify-between">
						<h3 class="font-bold text-slate-900 flex items-center gap-2">
							Questions
							{#if questions.length > 0}
								<span class="rounded-full bg-blue-100 text-blue-600 px-2.5 py-0.5 text-xs">{questions.length}</span>
							{/if}
						</h3>
						<button 
							onclick={addQuestion}
							class="text-sm font-bold text-blue-600 hover:text-blue-700 flex items-center gap-1.5"
						>
							<Plus size={16} /> Add Question
						</button>
					</div>

					{#if questions.length === 0}
						<div class="rounded-3xl border-2 border-dashed border-slate-200 p-12 text-center">
							<p class="text-slate-400 font-medium">Click "Add Question" to start building your quiz.</p>
						</div>
					{:else}
						<div class="space-y-4">
							{#each questions as question, qIndex}
								<div class="rounded-3xl border border-slate-100 bg-white p-6 shadow-sm relative group/q" in:fly={{ y: 10, duration: 200 }}>
									<button 
										onclick={() => removeQuestion(qIndex)}
										class="absolute -right-2 -top-2 h-8 w-8 rounded-full bg-white shadow-md border border-slate-100 text-slate-400 hover:text-red-600 flex items-center justify-center opacity-0 group-hover/q:opacity-100 transition-opacity"
									>
										<Trash2 size={16} />
									</button>
									
									<div class="flex gap-4">
										<div class="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-900 text-white font-bold text-xs shrink-0">{qIndex + 1}</div>
										<div class="flex-grow space-y-4">
											<input 
												bind:value={question.question} 
												class="w-full text-lg font-bold text-slate-900 placeholder-slate-300 outline-none border-b border-transparent focus:border-blue-500 pb-1"
												placeholder="Type your question here..."
											/>
											
											<div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-4">
												{#each question.options as option, oIndex}
													<div class="flex items-center gap-2 rounded-xl border border-slate-100 bg-slate-50/50 p-2 focus-within:ring-2 focus-within:ring-blue-500/10 transition-all">
														<input 
															type="checkbox" 
															checked={option.is_correct} 
															onchange={() => {
																question.options = question.options.map((opt, i) => ({
																	...opt,
																	is_correct: i === oIndex
																}));
															}}
															class="h-4 w-4 rounded-full border-slate-300 text-blue-600 focus:ring-offset-0"
														/>
														<input 
															bind:value={option.text} 
															class="flex-grow bg-transparent text-sm font-medium outline-none"
															placeholder={`Option ${oIndex + 1}`}
														/>
													</div>
												{/each}
											</div>
										</div>
									</div>
								</div>
							{/each}
						</div>
					{/if}
				</div>
			</div>

			<!-- Footer -->
			<div class="border-t border-slate-100 px-8 py-6 flex items-center justify-between bg-slate-50/50">
				<p class="text-xs font-medium text-slate-400">All changes are saved to the cloud automatically</p>
				<div class="flex items-center gap-3">
					<button onclick={() => isFormOpen = false} class="px-6 py-2.5 text-sm font-bold text-slate-500 hover:bg-slate-100 rounded-xl transition-all">Discard</button>
					<button 
						onclick={handleSaveQuiz}
						disabled={loading || formLoading || questions.length === 0}
						class="inline-flex items-center gap-2 rounded-xl bg-slate-900 px-8 py-2.5 text-sm font-bold text-white shadow-xl shadow-slate-200 hover:bg-black disabled:opacity-50 transition-all"
					>
						{#if formLoading}
							<Loader2 size={18} class="animate-spin" /> Sealing...
						{:else}
							<Save size={18} /> Save & Close
						{/if}
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
