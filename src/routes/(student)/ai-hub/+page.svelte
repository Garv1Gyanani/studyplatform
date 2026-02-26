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
		ChevronDown,
		Paperclip,
		Menu,
		Sparkles,
		Zap,
		Search,
		Clock,
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
			content: 'Hello! I am **Programming Tails Bot**, your AI partner. How can I assist your learning journey today?',
			timestamp: new Date()
		}
	]);

	let chatHistory = $state([
		{ id: 1, title: 'Python Data Structures', date: 'Just now' },
		{ id: 2, title: 'Understanding React State', date: '2h ago' },
		{ id: 3, title: 'SQL Joins Explained', date: 'Yesterday' },
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
		messages = [...messages, {
			role: 'user',
			content: userMsg,
			timestamp: new Date()
		}];

		isLoading = true;
		await scrollToBottom();

		try {
			const apiMessages = messages.map(m => ({
				role: m.role,
				content: m.content
			}));

			const response = await getAIChatCompletion(apiMessages);
			
			messages = [...messages, {
				role: 'assistant',
				content: response,
				timestamp: new Date()
			}];
		} catch (error) {
			messages = [...messages, {
				role: 'assistant',
				content: 'I encountered an error. Please try again.',
				timestamp: new Date()
			}];
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
				content: 'New session started. How can I help you today?',
				timestamp: new Date()
			}
		];
	}

	onMount(() => {
		scrollToBottom();
	});
</script>

<div class="h-[calc(100vh-64px)] w-full flex bg-white font-sans text-slate-900 overflow-hidden selection:bg-blue-100">
	<!-- Compact Professional Sidebar -->
	<aside 
		class={cn(
			"h-full bg-slate-50 border-r border-slate-100 transition-all duration-300 ease-in-out flex flex-col shrink-0 z-20",
			sidebarOpen ? "w-[260px]" : "w-0 overflow-hidden"
		)}
	>
		<div class="w-[260px] h-full flex flex-col p-5">
			<div class="flex items-center gap-3 mb-8 px-1">
				<div class="h-9 w-9 rounded-xl bg-blue-600 text-white flex items-center justify-center shadow-lg">
					<BrainCircuit size={18} strokeWidth={2.5} />
				</div>
				<div>
					<h3 class="text-[13px] font-black text-slate-900 uppercase tracking-tighter leading-none mb-1">TailBot AI</h3>
					<div class="text-[9px] font-black text-blue-600 uppercase tracking-widest opacity-70">Neural Engine</div>
				</div>
			</div>

			<button 
				onclick={clearChat}
				class="w-full flex items-center justify-center gap-3 px-4 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-all font-black text-sm shadow-lg shadow-blue-500/10 mb-8 active:scale-95"
			>
				<Plus size={16} />
				<span>New Session</span>
			</button>

			<div class="flex-1 overflow-y-auto space-y-6 pr-1">
				<div>
					<h3 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3 px-3">History</h3>
					<div class="space-y-1">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all text-left group hover:bg-white border border-transparent hover:border-slate-100">
								<MessageSquare size={14} class="text-slate-400 group-hover:text-blue-600" />
								<span class="text-[13px] font-bold truncate flex-1 text-slate-600 group-hover:text-slate-900">{history.title}</span>
							</button>
						{/each}
					</div>
				</div>
			</div>

			<div class="pt-4 mt-auto border-t border-slate-100">
				<button class="w-full flex items-center justify-between px-4 py-3 rounded-xl hover:bg-white transition-all group">
					<div class="flex items-center gap-3">
						<Settings size={16} class="text-slate-400 group-hover:text-blue-600" />
						<span class="text-xs font-black text-slate-500 group-hover:text-slate-900">Settings</span>
					</div>
					<ChevronDown size={12} class="text-slate-300" />
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Stage -->
	<main class="flex-1 flex flex-col h-full bg-white relative">
		<!-- Header -->
		<header class="h-14 flex items-center justify-between px-6 border-b border-slate-50 sticky top-0 z-10 bg-white/80 backdrop-blur-md">
			<div class="flex items-center gap-4">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2 hover:bg-slate-50 rounded-lg transition-all text-slate-400"
				>
					<Menu size={18} />
				</button>
				<h1 class="text-sm font-black tracking-tight text-slate-900 flex items-center gap-2">
					Programming Tails Bot
					<span class="px-1.5 py-0.5 rounded bg-blue-50 text-[9px] font-black text-blue-600 uppercase">v4.0</span>
				</h1>
			</div>
			
			<button class="p-2 text-slate-400 hover:text-slate-900 transition-colors">
				<Search size={18} />
			</button>
		</header>

		<!-- Messages -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto scroll-smooth"
		>
			<div class="max-w-[760px] mx-auto w-full px-6 pt-10">
				<div class="space-y-12">
					{#each messages as message}
						<div class="group flex flex-col gap-3">
							<div class="flex items-center gap-3">
								<div class={cn(
									"h-7 w-7 rounded-lg flex items-center justify-center shrink-0 border shadow-sm",
									message.role === 'assistant' 
										? "bg-blue-600 border-blue-500 text-white" 
										: "bg-white border-slate-200 text-slate-400"
								)}>
									{#if message.role === 'assistant'}
										<Bot size={16} strokeWidth={2.5} />
									{:else}
										<User size={16} strokeWidth={2.5} />
									{/if}
								</div>
								<span class="text-[10px] font-black uppercase tracking-widest {message.role === 'assistant' ? 'text-blue-600' : 'text-slate-400'}">
									{message.role === 'assistant' ? 'TailBot' : 'Student'}
								</span>
							</div>

							<div class="pl-10">
								<div class="markdown-pro text-[15.5px] leading-relaxed text-slate-700 font-medium antialiased">
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
						<div class="flex flex-col gap-3 animate-pulse">
							<div class="flex items-center gap-3">
								<div class="h-7 w-7 rounded-lg bg-slate-50 border border-slate-100"></div>
								<div class="h-1.5 w-16 bg-slate-50 rounded-full"></div>
							</div>
							<div class="pl-10 space-y-2">
								<div class="h-3 w-full bg-slate-50/50 rounded-full"></div>
								<div class="h-3 w-4/5 bg-slate-50/50 rounded-full"></div>
							</div>
						</div>
					{/if}
					
					<div class="h-64"></div>
				</div>
			</div>
		</div>

		<!-- Compact Bottom Input -->
		<div class="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-white via-white/100 to-transparent pointer-events-none">
			<div class="max-w-[760px] mx-auto w-full pointer-events-auto">
				<div class="relative bg-white border border-slate-200 rounded-2xl shadow-xl transition-all focus-within:border-blue-600 focus-within:ring-4 focus-within:ring-blue-600/5 group overflow-hidden">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="Message TailBot..."
						class="w-full bg-transparent px-6 py-5 text-basis font-bold text-slate-900 outline-none resize-none min-h-[64px] h-auto max-h-[200px] placeholder:text-slate-300"
						rows="1"
					></textarea>
					
					<div class="flex items-center justify-between px-5 pb-4">
						<div class="flex items-center gap-1">
							<button class="p-2 text-slate-300 hover:text-blue-600 transition-colors">
								<Paperclip size={18} />
							</button>
							<button 
								onclick={clearChat}
								class="p-2 text-slate-200 hover:text-red-500 transition-colors"
							>
								<Trash2 size={18} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-2 px-6 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 disabled:opacity-20 transition-all transition-transform active:scale-95 shadow-lg shadow-blue-500/20"
						>
							<span>Send</span>
							<Send size={14} strokeWidth={3} />
						</button>
					</div>
				</div>
				<p class="text-center mt-3 text-[9px] font-black text-slate-300 uppercase tracking-widest">
					Programming Tails • Neural Intelligence Core
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	.markdown-pro :global(h1),
	.markdown-pro :global(h2),
	.markdown-pro :global(h3) {
		font-weight: 900;
		color: #0f172a;
		margin-top: 24px;
		margin-bottom: 12px;
	}
	.markdown-pro :global(h1) { font-size: 1.4rem; }
	.markdown-pro :global(h2) { font-size: 1.2rem; }
	.markdown-pro :global(h3) { font-size: 1.1rem; }
	.markdown-pro :global(p) { margin-bottom: 12px; }
	.markdown-pro :global(code) {
		background: #f1f5f9;
		padding: 2px 4px;
		border-radius: 4px;
		font-size: 0.9em;
		font-weight: 800;
		color: #2563eb;
	}
	.markdown-pro :global(pre) {
		background: #0f172a !important;
		color: #f8fafc !important;
		padding: 20px !important;
		border-radius: 16px !important;
		margin: 16px 0 !important;
		border: 1px solid #1e293b !important;
		overflow-x: auto;
	}
	.markdown-pro :global(ul) { list-style-type: disc; padding-left: 20px; margin-bottom: 12px; }
	.markdown-pro :global(li) { margin-bottom: 6px; font-weight: 600; }
	.markdown-pro :global(strong) { font-weight: 800; color: #2563eb; }

	::-webkit-scrollbar { width: 4px; }
	::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
</style>
