<script lang="ts">
	import { getAIChatCompletion } from '$lib/ai_service';
	import { 
		Send, 
		Bot, 
		User, 
		Trash2, 
		Plus, 
		MessageSquare, 
		Settings,
		History,
		Paperclip,
		Menu,
		Sparkles,
		Zap,
		ChevronRight,
		Globe,
		Lightbulb,
		BrainCircuit
	} from 'lucide-svelte';
	import { onMount, tick } from 'svelte';
	import { fly, fade } from 'svelte/transition';
	import { cn } from '$lib/utils';
	import { marked } from 'marked';

	let inputMessage = $state('');
	let isLoading = $state(false);
	let messages = $state<{ role: 'user' | 'assistant'; content: string; timestamp: Date }[]>([
		{
			role: 'assistant',
			content: 'Hello! I am the **Programming Tails Bot**. How can I assist your learning journey today?',
			timestamp: new Date()
		}
	]);

	let chatHistory = $state([
		{ id: 1, title: 'Quantum Physics Basics', date: 'Oct 24' },
		{ id: 2, title: 'React Hooks Explained', date: 'Oct 23' },
		{ id: 3, title: 'Study Schedule Nov', date: 'Oct 22' },
	]);

	let scrollContainer: HTMLDivElement;
	let sidebarOpen = $state(true);

	async function scrollToBottom() {
		await tick();
		if (scrollContainer) {
			scrollContainer.scrollTop = scrollContainer.scrollHeight;
		}
	}

	async function sendMessage() {
		if (!inputMessage.trim() || isLoading) return;

		const userMsg = inputMessage.trim();
		inputMessage = '';
		messages.push({
			role: 'user',
			content: userMsg,
			timestamp: new Date()
		});

		isLoading = true;
		await scrollToBottom();

		try {
			const apiMessages = messages.map(m => ({
				role: m.role,
				content: m.content
			}));

			const response = await getAIChatCompletion(apiMessages);
			
			messages.push({
				role: 'assistant',
				content: response,
				timestamp: new Date()
			});
		} catch (error) {
			messages.push({
				role: 'assistant',
				content: 'I encountered an error. Please check your connection and try again.',
				timestamp: new Date()
			});
		} finally {
			isLoading = false;
			await scrollToBottom();
		}
	}

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'Enter' && !e.shiftKey) {
			e.preventDefault();
			sendMessage();
		}
	}

	function clearChat() {
		messages = [
			{
				role: 'assistant',
				content: 'New session started. How can I help you learn today?',
				timestamp: new Date()
			}
		];
	}

	onMount(() => {
		scrollToBottom();
	});
</script>

<div class="h-[calc(100vh-64px)] w-full flex bg-slate-50 font-sans text-slate-900 overflow-hidden">
	<!-- Sidebar -->
	<aside 
		class={cn(
			"h-full bg-slate-950 text-slate-400 transition-all duration-300 ease-in-out flex flex-col shrink-0 z-20",
			sidebarOpen ? "w-80" : "w-0 overflow-hidden"
		)}
	>
		<div class="w-80 h-full flex flex-col">
			<div class="p-6">
				<div class="flex items-center gap-3 mb-8 px-2">
					<div class="h-8 w-8 rounded-lg bg-blue-600 flex items-center justify-center text-white">
						<BrainCircuit size={18} strokeWidth={2.5} />
					</div>
					<span class="text-xs font-black text-white uppercase tracking-widest">TailBot AI Hub</span>
				</div>

				<button 
					onclick={clearChat}
					class="w-full flex items-center gap-3 px-4 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-all font-bold text-sm shadow-lg shadow-blue-500/20"
				>
					<Plus size={16} />
					<span>New chat</span>
				</button>
			</div>

			<div class="flex-1 overflow-y-auto px-4 space-y-8">
				<section>
					<h3 class="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-4 px-4">Recent Sessions</h3>
					<div class="space-y-1">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-white/5 transition-all text-left group">
								<MessageSquare size={14} class="text-slate-600 group-hover:text-blue-500" />
								<span class="text-sm font-medium truncate flex-1 group-hover:text-white">{history.title}</span>
							</button>
						{/each}
					</div>
				</section>
				
				<section>
					<h3 class="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-4 px-4">Insights</h3>
					<div class="grid grid-cols-2 gap-2 px-4">
						<div class="p-3 rounded-xl bg-white/5 border border-white/5 flex flex-col gap-2">
							<Globe size={14} class="text-blue-500" />
							<span class="text-[10px] font-bold text-white leading-none">Global Learning</span>
						</div>
						<div class="p-3 rounded-xl bg-white/5 border border-white/5 flex flex-col gap-2">
							<Lightbulb size={14} class="text-amber-500" />
							<span class="text-[10px] font-bold text-white leading-none">Smart Hints</span>
						</div>
					</div>
				</section>
			</div>

			<div class="p-6 mt-auto">
				<button class="w-full flex items-center justify-between px-4 py-3 rounded-xl hover:bg-white/5 transition-all text-sm font-bold text-slate-400">
					<div class="flex items-center gap-3">
						<Settings size={18} />
						<span>Preferences</span>
					</div>
					<ChevronRight size={14} />
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Stage -->
	<main class="flex-1 flex flex-col h-full bg-white relative">
		<!-- Header -->
		<header class="h-16 flex items-center justify-between px-6 border-b border-slate-100 bg-white/80 backdrop-blur-md sticky top-0 z-10">
			<div class="flex items-center gap-4">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2.5 hover:bg-slate-50 rounded-lg transition-all text-slate-400"
				>
					<Menu size={20} />
				</button>
				<div class="flex items-center gap-3">
					<h1 class="text-sm font-black tracking-tight flex items-center gap-2">
						Programming Tails Bot
					</h1>
					<div class="h-4 w-[1px] bg-slate-200"></div>
					<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[9px] font-black bg-blue-50 text-blue-600 border border-blue-100 uppercase tracking-widest">
						<span class="h-1 w-1 rounded-full bg-blue-600"></span>
						Neural Engine v2
					</span>
				</div>
			</div>
			
			<div class="flex items-center gap-4">
				<div class="hidden sm:flex items-center gap-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">
					<Zap size={14} class="text-amber-500" />
					LongCat Reasoning
				</div>
			</div>
		</header>

		<!-- Message Container -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto pt-10 pb-48 scroll-smooth bg-slate-50/30"
		>
			<div class="max-w-4xl mx-auto w-full px-6 md:px-8 space-y-10">
				{#each messages as message}
					<div 
						class="flex flex-col gap-4 animate-in fade-in slide-in-from-bottom-4 duration-300"
					>
						<div class="flex items-center gap-3 px-2">
							<div class={cn(
								"h-8 w-8 rounded-lg flex items-center justify-center shrink-0 border shadow-sm",
								message.role === 'assistant' 
									? "bg-blue-600 border-blue-500 text-white" 
									: "bg-white border-slate-200 text-slate-400"
							)}>
								{#if message.role === 'assistant'}
									<Bot size={18} strokeWidth={2.5} />
								{:else}
									<User size={18} strokeWidth={2.5} />
								{/if}
							</div>
							<div class="flex flex-col">
								<span class="text-[10px] font-black uppercase tracking-widest text-slate-500 leading-none mb-1">
									{message.role === 'assistant' ? 'TailBot — AI' : 'Student'}
								</span>
								<span class="text-[9px] font-bold text-slate-300">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>
						</div>

						<div class={cn(
							"rounded-[24px] p-6 md:p-8 border leading-relaxed",
							message.role === 'assistant' 
								? "bg-white border-slate-100 shadow-sm text-slate-800" 
								: "bg-blue-600 text-white border-blue-500 shadow-xl shadow-blue-500/10"
						)}>
							<div class="markdown-container text-[16px] font-medium selection:bg-blue-200 antialiased">
								{#if message.role === 'assistant'}
									{@html marked(message.content)}
								{:else}
									<p class="whitespace-pre-wrap">{message.content}</p>
								{/if}
							</div>
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="flex flex-col gap-4 animate-pulse">
						<div class="flex items-center gap-3 px-2">
							<div class="h-8 w-8 rounded-lg bg-blue-600 text-white flex items-center justify-center opacity-50">
								<Bot size={18} />
							</div>
							<div class="h-2 w-24 bg-slate-200 rounded-full"></div>
						</div>
						<div class="h-32 rounded-[24px] bg-white border border-slate-100 shadow-sm"></div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Command Center Input -->
		<div class="absolute bottom-0 inset-x-0 p-6 md:p-10 bg-gradient-to-t from-slate-50 via-slate-50/95 to-transparent pointer-events-none">
			<div class="max-w-3xl mx-auto w-full pointer-events-auto">
				<div class="relative bg-white border border-slate-200 rounded-[28px] shadow-2xl transition-all overflow-hidden focus-within:border-blue-600 focus-within:ring-8 focus-within:ring-blue-600/5 group">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we focusing on today?"
						class="w-full bg-transparent px-8 py-6 text-basis font-bold text-slate-900 outline-none resize-none min-h-[72px] h-[72px] placeholder:text-slate-300"
					></textarea>
					
					<div class="flex items-center justify-between px-6 pb-6 mt-1">
						<div class="flex items-center gap-1.5">
							<button class="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-50 text-[10px] font-black uppercase text-slate-500 hover:bg-slate-100 transition-all border border-slate-100">
								<Paperclip size={14} class="text-blue-600" />
								<span>Summarize</span>
							</button>
							<button 
								onclick={clearChat}
								class="p-2.5 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all"
								title="Reset"
							>
								<Trash2 size={20} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-3 px-10 py-3 bg-slate-900 text-white text-xs font-black rounded-xl hover:bg-black disabled:opacity-20 disabled:hover:scale-100 transition-all shadow-xl transform active:scale-95"
						>
							<span>Send command</span>
							<Send size={16} strokeWidth={3} />
						</button>
					</div>
				</div>
				<p class="text-center mt-4 text-[10px] font-black text-slate-300 uppercase tracking-widest">
					Neural Hub • Secure Learning Environment
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: #f8fafc;
	}

	.markdown-container :global(h1),
	.markdown-container :global(h2),
	.markdown-container :global(h3) {
		font-weight: 800;
		color: #000;
		margin-top: 24px;
		margin-bottom: 12px;
	}
	.markdown-container :global(h1) { font-size: 1.6rem; }
	.markdown-container :global(h2) { font-size: 1.3rem; }
	.markdown-container :global(h3) { font-size: 1.1rem; }
	
	.markdown-container :global(p) { margin-bottom: 16px; }
	
	.markdown-container :global(code) {
		background: #f1f3f4;
		padding: 2px 4px;
		border-radius: 4px;
		font-size: 0.9em;
		font-weight: 800;
	}
	
	.markdown-container :global(pre) {
		background: #000 !important;
		color: #fff !important;
		padding: 24px !important;
		border-radius: 20px !important;
		margin: 20px 0 !important;
		border: 1px solid #333 !important;
		overflow-x: auto;
	}

	.markdown-container :global(pre code) {
		background: transparent !important;
		padding: 0 !important;
		color: inherit !important;
		font-weight: 400;
	}

	.markdown-container :global(ul) {
		list-style-type: disc;
		padding-left: 24px;
		margin-bottom: 16px;
	}

	.markdown-container :global(li) {
		margin-bottom: 8px;
	}

	::-webkit-scrollbar {
		width: 6px;
	}
	::-webkit-scrollbar-track {
		background: transparent;
	}
	::-webkit-scrollbar-thumb {
		background: #e2e8f0;
		border-radius: 10px;
	}
	::-webkit-scrollbar-thumb:hover {
		background: #cbd5e1;
	}
</style>
