<script lang="ts">
	import { 
		Plus, 
		Search, 
		Filter, 
		Edit2, 
		Trash2, 
		GraduationCap,
		X,
		Loader2,
		Calendar,
		Clock,
		Timer,
		AlertTriangle,
		Save,
        ChevronRight
	} from 'lucide-svelte';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let tests = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Test Form State
	let title = $state('');
	let instructions = $state('');
	let duration = $state(60);
	let availableFrom = $state('');
	let availableTo = $state('');
	let isPublished = $state(false);

	// Question State
	let questions = $state<any[]>([]);

	onMount(fetchTests);

	async function fetchTests() {
		loading = true;
		const { data, error } = await supabase
			.from('tests')
			.select('*')
			.order('created_at', { ascending: false });
		
		if (!error) tests = data;
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
			],
			marks: 1
		}];
	}

	async function handleSaveTest() {
		formLoading = true;
		
		const { data: testData, error: testError } = await supabase
			.from('tests')
			.insert({
				title,
				instructions,
				duration_minutes: duration,
				available_from: availableFrom || null,
				available_to: availableTo || null,
				is_published: isPublished
			})
			.select()
			.single();

		if (testError) {
			alert(testError.message);
			formLoading = false;
			return;
		}

		const questionsToInsert = questions.map(q => ({
			test_id: testData.id,
			question: q.question,
			type: q.type,
			options: q.options,
			marks: q.marks
		}));

		if (questionsToInsert.length > 0) {
			await supabase.from('test_questions').insert(questionsToInsert);
		}

		isFormOpen = false;
		resetForm();
		fetchTests();
		formLoading = false;
	}

	function resetForm() {
		title = '';
		instructions = '';
		duration = 60;
		questions = [];
		availableFrom = '';
		availableTo = '';
	}
</script>

<div class="space-y-8">
	<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-extrabold tracking-tight text-slate-900">Formal Tests</h1>
			<p class="mt-1 text-slate-500">Create scheduled exams and formal assessments.</p>
		</div>
		<button 
			onclick={() => isFormOpen = true}
			class="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-blue-200 transition-all hover:bg-blue-700"
		>
			<Plus size={18} />
			Create Formal Test
		</button>
	</div>

	<!-- List Area -->
	<div class="rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">
		{#if loading}
			<div class="flex h-64 items-center justify-center">
				<Loader2 size={32} class="animate-spin text-blue-600" />
			</div>
		{:else if tests.length === 0}
			<div class="p-20 text-center">
				<div class="inline-flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-50 text-slate-300 mb-6">
					<GraduationCap size={40} />
				</div>
                <h3 class="text-xl font-bold text-slate-900">No tests created yet</h3>
                <p class="text-slate-500 max-w-xs mx-auto mt-2">Formal tests help you evaluate student performance in a controlled environment.</p>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left font-medium">
					<thead class="bg-slate-50/50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Test Details</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Duration</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Time Window</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400">Status</th>
							<th class="px-6 py-4 text-xs font-bold uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each tests as test}
							<tr class="group hover:bg-slate-50/30 transition-colors">
								<td class="px-6 py-4">
									<div class="flex items-center gap-3">
										<div class="h-10 w-10 flex-shrink-0 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
											<GraduationCap size={20} />
										</div>
										<p class="font-bold text-slate-900">{test.title}</p>
									</div>
								</td>
								<td class="px-6 py-4">
									<div class="flex items-center gap-2 text-sm text-slate-600">
										<Timer size={16} class="text-slate-400" />
										{test.duration_minutes}m
									</div>
								</td>
								<td class="px-6 py-4">
									{#if test.available_from}
										<div class="flex flex-col gap-1">
											<div class="flex items-center gap-2 text-[10px] text-slate-400 uppercase font-black">
												<Calendar size={12} /> Starts
											</div>
											<span class="text-xs text-slate-900">{new Date(test.available_from).toLocaleDateString()}</span>
										</div>
									{:else}
										<span class="text-xs text-slate-400 italic">Always Available</span>
									{/if}
								</td>
								<td class="px-6 py-4">
									<span class={cn("inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-black uppercase tracking-widest border", 
										test.is_published ? "bg-green-50 text-green-700 border-green-200" : "bg-slate-50 text-slate-400 border-slate-200"
									)}>
										{test.is_published ? 'Published' : 'Draft'}
									</span>
								</td>
								<td class="px-6 py-4 text-right">
									<div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
										<button class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg"><Edit2 size={16} /></button>
										<button class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg"><Trash2 size={16} /></button>
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
			class="w-full max-w-6xl h-[90vh] flex flex-col overflow-hidden rounded-[40px] bg-white shadow-2xl"
			onclick={e => e.stopPropagation()}
		>
			<div class="px-10 py-8 border-b border-slate-100 flex items-center justify-between">
				<div class="flex items-center gap-4">
					<div class="h-12 w-12 rounded-2xl bg-blue-600 text-white flex items-center justify-center shadow-lg shadow-blue-200">
						<GraduationCap size={24} />
					</div>
					<div>
						<h2 class="text-2xl font-black text-slate-900 tracking-tight">Formal Test Builder</h2>
						<p class="text-sm font-bold text-slate-400 uppercase tracking-widest">Designing: {title || 'Untitled Assessment'}</p>
					</div>
				</div>
				<button onclick={() => isFormOpen = false} class="h-10 w-10 rounded-full border border-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-900 hover:bg-slate-50 transition-all">
					<X size={20} />
				</button>
			</div>

			<div class="flex-grow overflow-y-auto px-10 py-10 grid grid-cols-12 gap-10">
				<!-- Settings -->
				<div class="col-span-4 space-y-6">
					<div class="space-y-4 rounded-3xl bg-slate-50 p-6">
						<h3 class="text-xs font-black uppercase tracking-widest text-slate-400 mb-2 flex items-center gap-2">
							<AlertTriangle size={14} /> Core Configuration
						</h3>
						<div class="space-y-1">
							<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Test Title</label>
							<input bind:value={title} class="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold focus:ring-4 focus:ring-blue-500/10 outline-none focus:border-blue-600 transition-all" placeholder="Final Geography Exam" />
						</div>
						<div class="grid grid-cols-2 gap-4">
							<div class="space-y-1">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Duration (min)</label>
								<input type="number" bind:value={duration} class="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold outline-none" />
							</div>
							<div class="space-y-1">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Scheduled</label>
								<div class="h-11 flex items-center justify-center bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-400">
									<Clock size={16} class="mr-2" /> Optional
								</div>
							</div>
						</div>
						<div class="space-y-1">
							<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Instructions (Proctoring)</label>
							<textarea bind:value={instructions} class="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold outline-none h-32 resize-none" placeholder="Do not switch tabs during the test..."></textarea>
						</div>
					</div>
					
					<div class="p-6 rounded-3xl border border-blue-100 bg-blue-50/30">
						<p class="text-xs font-bold text-blue-600 leading-relaxed">
							"Formal tests" are designed for timed, high-stakes assessment. Unlike quizzes, students won't see results until the window closes.
						</p>
					</div>
				</div>

				<!-- Question Builder -->
				<div class="col-span-8 space-y-8">
					<div class="flex items-center justify-between">
						<h3 class="text-lg font-black text-slate-900">Assessment Items</h3>
						<button 
							onclick={addQuestion}
							class="inline-flex items-center gap-2 rounded-xl bg-slate-900 px-6 py-2.5 text-xs font-black text-white uppercase tracking-widest hover:scale-105 transition-all"
						>
							<Plus size={14} /> Add Question
						</button>
					</div>

					{#each questions as q, qIdx}
						<div class="p-8 rounded-[32px] border border-slate-100 bg-white shadow-xl shadow-slate-200/20 space-y-6 relative" in:fly={{ y: 20 }}>
							<button class="absolute -right-3 -top-3 h-10 w-10 rounded-full bg-white border border-slate-100 shadow-lg text-slate-300 hover:text-red-500 flex items-center justify-center transition-all">
								<Trash2 size={18} />
							</button>
							<div class="flex items-center gap-4">
								<div class="h-10 w-10 rounded-full bg-slate-50 text-slate-900 font-black flex items-center justify-center text-sm">{qIdx + 1}</div>
								<input bind:value={q.question} class="flex-grow text-xl font-bold text-slate-900 outline-none border-b-2 border-transparent focus:border-blue-600 pb-2" placeholder="State your formal question..." />
								<div class="flex items-center gap-2 px-3 py-1.5 bg-slate-50 rounded-lg">
									<span class="text-[10px] font-black text-slate-400">MARKS</span>
									<input type="number" bind:value={q.marks} class="w-8 bg-transparent text-xs font-bold text-blue-600 outline-none text-center" />
								</div>
							</div>
							
							<div class="grid grid-cols-2 gap-4">
								{#each q.options as opt, oIdx}
									<div class="flex items-center gap-3 p-4 bg-slate-50 rounded-2xl border border-transparent focus-within:border-blue-600 transition-all">
										<input 
											type="radio" 
											checked={opt.is_correct} 
											onchange={() => q.options = q.options.map((o, i) => ({ ...o, is_correct: i === oIdx }))}
											class="h-5 w-5 border-slate-300 text-blue-600" 
										/>
										<input bind:value={opt.text} class="flex-grow bg-transparent text-sm font-bold text-slate-700 outline-none" placeholder={`Option ${oIdx + 1}`} />
									</div>
								{/each}
							</div>
						</div>
					{/each}
				</div>
			</div>

			<div class="px-10 py-8 border-t border-slate-100 flex items-center justify-between bg-slate-50/30">
				<label class="flex items-center gap-3 cursor-pointer">
					<div class="relative h-6 w-11 rounded-full bg-slate-200" class:bg-blue-600={isPublished}>
						<input type="checkbox" bind:checked={isPublished} class="sr-only" />
						<div class={cn("absolute top-1 left-1 h-4 w-4 bg-white rounded-full transition-all", isPublished ? "translate-x-5" : "translate-x-0")}></div>
					</div>
					<span class="text-xs font-black uppercase tracking-widest text-slate-500">Make test live now</span>
				</label>
				<div class="flex items-center gap-4">
					<button onclick={() => isFormOpen = false} class="text-sm font-bold text-slate-400 hover:text-slate-900 px-6 py-3">Discard</button>
					<button 
						onclick={handleSaveTest}
						disabled={loading || formLoading || questions.length === 0}
						class="rounded-2xl bg-blue-600 px-12 py-4 text-sm font-black text-white shadow-2xl shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all flex items-center gap-3"
					>
                        {#if formLoading}
                            <Loader2 size={18} class="animate-spin" /> Finalizing...
                        {:else}
                            <Save size={18} /> Seal Assessment
                        {/if}
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
</div>
