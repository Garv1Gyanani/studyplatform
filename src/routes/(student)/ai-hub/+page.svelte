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
		Zap
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
	let sidebarOpen = $state(false);

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

<div class="h-[calc(100vh-64px)] w-full flex bg-slate-50 font-sans text-slate-900 overflow-hidden selection:bg-blue-100">
	<!-- Enhanced Sidebar -->
	<aside 
		class={cn(
			"h-full bg-white border-r border-slate-200 transition-all duration-300 ease-in-out flex flex-col shrink-0 shadow-sm",
			sidebarOpen ? "w-80" : "w-0 overflow-hidden border-none"
		)}
	>
		<div class="w-80 h-full flex flex-col">
			<div class="p-6">
				<button 
					onclick={clearChat}
					class="w-full flex items-center justify-center gap-3 px-6 py-4 bg-slate-900 text-white rounded-2xl hover:bg-black transition-all font-black text-sm shadow-xl shadow-slate-200"
				>
					<Plus size={18} />
					<span>New Session</span>
				</button>
			</div>

			<div class="flex-1 overflow-y-auto px-6 py-2 space-y-8">
				<section>
					<h3 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4 px-2">History</h3>
					<div class="space-y-2">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl hover:bg-slate-50 transition-all text-left group border border-transparent hover:border-slate-100">
								<MessageSquare size={16} class="text-slate-400 group-hover:text-blue-600" />
								<span class="text-sm font-bold truncate flex-1 text-slate-600 group-hover:text-slate-900">{history.title}</span>
							</button>
						{/each}
					</div>
				</section>

				<section>
					<h3 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4 px-2">Focus Areas</h3>
					<div class="flex flex-wrap gap-2 px-2">
						{#each ['Mathematics', 'UI Design', 'Physics', 'Python'] as tag}
							<button class="px-3 py-1.5 rounded-xl bg-slate-50 border border-slate-100 text-[10px] font-black uppercase text-slate-500 hover:border-blue-600 hover:text-blue-600 transition-all">
								{tag}
							</button>
						{/each}
					</div>
				</section>
			</div>

			<div class="p-6 border-t border-slate-100">
				<button class="w-full flex items-center gap-3 px-4 py-3 rounded-2xl hover:bg-slate-50 transition-all text-sm font-black text-slate-500">
					<Settings size={18} />
					<span>Settings</span>
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Stage -->
	<main class="flex-1 flex flex-col h-full bg-slate-50 relative">
		<!-- Signature Header -->
		<header class="h-16 flex items-center justify-between px-6 border-b border-slate-200 bg-white sticky top-0 z-10">
			<div class="flex items-center gap-5">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2.5 hover:bg-slate-50 rounded-xl transition-all text-slate-500 shadow-sm border border-slate-100"
				>
					<Menu size={20} />
				</button>
				<div class="flex items-center gap-4">
					<div class="h-10 w-10 flex items-center justify-center rounded-xl bg-blue-600 text-white shadow-lg shadow-blue-500/20">
						<Bot size={20} strokeWidth={2.5} />
					</div>
					<div>
						<h1 class="text-sm font-black tracking-tight leading-none mb-1">Programming Tails Bot</h1>
						<div class="flex items-center gap-2">
							<span class="h-1.5 w-1.5 rounded-full bg-blue-500"></span>
							<span class="text-[10px] font-black text-blue-600 uppercase tracking-widest">Active Hub v2.0</span>
						</div>
					</div>
				</div>
			</div>
			
			<div class="hidden sm:flex items-center gap-4">
				<div class="flex h-10 px-4 items-center gap-3 rounded-xl border border-slate-200 bg-slate-50 text-[10px] font-black uppercase tracking-widest text-slate-500 shadow-sm">
					<Zap size={14} class="text-amber-500" fill="currentColor" />
					LongCat Thinking
				</div>
				<div class="h-10 px-4 flex items-center gap-2 rounded-xl bg-slate-900 text-white text-[10px] font-black uppercase tracking-widest shadow-xl shadow-slate-200">
					<Sparkles size={14} />
					Premium
				</div>
			</div>
		</header>

		<!-- Message Flow with Theme Background -->
		<div class="absolute inset-0 -z-10 bg-[radial-gradient(45%_45%_at_50%_50%,rgba(59,130,246,0.03)_0%,transparent_100%)] pointer-events-none"></div>
		
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto pt-10 pb-48 scroll-smooth"
		>
			<div class="max-w-4xl mx-auto w-full px-6 md:px-12 space-y-12">
				{#each messages as message}
					<div 
						class="flex gap-8 group"
						in:fade={{ duration: 250 }}
					>
						<div class={cn(
							"h-12 w-12 rounded-[20px] flex items-center justify-center shrink-0 shadow-xl border-2 select-none transition-transform group-hover:scale-105",
							message.role === 'assistant' 
								? "bg-slate-900 border-slate-800 text-white" 
								: "bg-white border-white text-slate-400"
						)}>
							{#if message.role === 'assistant'}
								<Bot size={24} strokeWidth={2.5} />
							{:else}
								<User size={24} strokeWidth={2.5} />
							{/if}
						</div>

						<div class="flex-1 min-w-0">
							<div class="flex items-center justify-between mb-2">
								<span class="text-[11px] font-black uppercase tracking-widest {message.role === 'assistant' ? 'text-blue-600' : 'text-slate-400'}">
									{message.role === 'assistant' ? 'TailBot — AI' : 'Student'}
								</span>
								<span class="text-[10px] font-bold text-slate-300 opacity-0 group-hover:opacity-100 transition-opacity">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>

							<div class={cn(
								"p-8 rounded-[32px] border transition-all leading-relaxed",
								message.role === 'assistant' 
									? "bg-white border-slate-100 shadow-sm text-slate-800" 
									: "bg-blue-600/5 border-blue-100 shadow-sm text-slate-900"
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
					</div>
				{/each}

				{#if isLoading}
					<div class="flex gap-8 animate-pulse px-6 md:px-12">
						<div class="h-12 w-12 rounded-[20px] bg-slate-200 shrink-0"></div>
						<div class="flex-1 space-y-6 pt-2">
							<div class="h-3 w-32 bg-slate-200 rounded-full"></div>
							<div class="p-8 rounded-[32px] bg-white border border-slate-100 space-y-3">
								<div class="h-3 w-full bg-slate-50 rounded-full"></div>
								<div class="h-3 w-4/5 bg-slate-50 rounded-full"></div>
								<div class="h-3 w-2/3 bg-slate-50 rounded-full"></div>
							</div>
						</div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Clean Integration Input -->
		<div class="absolute bottom-0 inset-x-0 p-8 md:p-12 bg-gradient-to-t from-slate-50 via-slate-50/95 to-transparent pointer-events-none">
			<div class="max-w-4xl mx-auto w-full pointer-events-auto">
				<div class="relative bg-white border-2 border-slate-200 rounded-[24px] shadow-2xl shadow-slate-200 transition-all overflow-hidden focus-within:border-blue-600 focus-within:ring-8 focus-within:ring-blue-600/5 group">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we learning today?"
						class="w-full bg-transparent px-8 py-6 text-basis font-bold text-slate-900 outline-none resize-none min-h-[72px] h-[72px] placeholder:text-slate-300"
					></textarea>
					
					<div class="flex items-center justify-between px-6 pb-6 pt-2">
						<div class="flex items-center gap-2">
							<button class="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 text-[10px] font-black uppercase text-slate-500 transition-all border border-slate-100 shadow-sm">
								<Paperclip size={14} class="text-blue-600" />
								Attach Resource
							</button>
							<button 
								onclick={clearChat}
								class="p-3 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all"
								title="Reset Session"
							>
								<Trash2 size={20} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-3 px-10 py-4 bg-slate-900 text-white text-sm font-black rounded-2xl hover:bg-black disabled:opacity-30 disabled:hover:scale-100 transition-all shadow-xl shadow-slate-200 transform hover:scale-105 active:scale-95"
						>
							<span>Send Command</span>
							<Send size={18} strokeWidth={3} />
						</button>
					</div>
				</div>
				<p class="text-center mt-6 text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">
					Programming Tails • Neural Intelligence Interface • 2026
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
		font-weight: 900;
		color: #0f172a;
		margin-top: 32px;
		margin-bottom: 16px;
		letter-spacing: -0.025em;
	}
	.markdown-container :global(h1) { font-size: 1.8rem; }
	.markdown-container :global(h2) { font-size: 1.4rem; }
	.markdown-container :global(h3) { font-size: 1.2rem; }
	
	.markdown-container :global(p) { margin-bottom: 20px; }
	
	.markdown-container :global(code) {
		background: #f1f5f9;
		padding: 3px 6px;
		border-radius: 6px;
		font-size: 0.9em;
		font-weight: 800;
		color: #2563eb;
	}
	
	.markdown-container :global(pre) {
		background: #0f172a !important;
		color: #f8fafc !important;
		padding: 28px !important;
		border-radius: 20px !important;
		margin: 24px 0 !important;
		border: 1px solid #1e293b !important;
		overflow-x: auto;
		box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
	}

	.markdown-container :global(pre code) {
		background: transparent !important;
		padding: 0 !important;
		color: inherit !important;
		font-weight: 500;
	}

	.markdown-container :global(ul) {
		list-style-type: disc;
		padding-left: 28px;
		margin-bottom: 20px;
	}

	.markdown-container :global(li) {
		margin-bottom: 10px;
		font-weight: 600;
	}

	.markdown-container :global(strong) {
		font-weight: 900;
		color: #1e293b;
	}

	/* Beautiful Scrollbar */
	::-webkit-scrollbar {
		width: 10px;
	}
	::-webkit-scrollbar-track {
		background: #f1f5f9;
	}
	::-webkit-scrollbar-thumb {
		background: #cbd5e1;
		border-radius: 20px;
		border: 3px solid #f1f5f9;
	}
	::-webkit-scrollbar-thumb:hover {
		background: #94a3b8;
	}
</style>
