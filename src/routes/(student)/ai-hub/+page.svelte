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
		Clock
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
			content: 'Hello! I am **Programming Tails Bot**, your advanced AI learning partner. I can help you debug code, explain complex concepts, or plan your study schedule. \n\nWhat are we building today?',
			timestamp: new Date()
		}
	]);

	let chatHistory = $state([
		{ id: 1, title: 'Python Data Structures', date: 'Just now' },
		{ id: 2, title: 'Understanding React State', date: '2h ago' },
		{ id: 3, title: 'SQL Joins Explained', date: 'Yesterday' },
		{ id: 4, title: 'Machine Learning Basics', date: 'Feb 24' },
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
				content: 'New session started. How can I assist your learning today?',
				timestamp: new Date()
			}
		];
	}

	onMount(() => {
		scrollToBottom();
	});
</script>

<div class="h-[calc(100vh-64px)] w-full flex bg-[#0d1117] font-sans text-slate-100 overflow-hidden">
	<!-- ChatGPT/Grok Style Sidebar -->
	<aside 
		class={cn(
			"h-full bg-[#0d1117] border-r border-slate-800 transition-all duration-300 ease-in-out flex flex-col shrink-0 z-20",
			sidebarOpen ? "w-[260px]" : "w-0 overflow-hidden"
		)}
	>
		<div class="w-[260px] h-full flex flex-col p-3">
			<!-- New Chat Button -->
			<button 
				onclick={clearChat}
				class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg border border-slate-800 hover:bg-slate-800 transition-all text-sm font-medium mb-4 group"
			>
				<Plus size={16} class="text-slate-400 group-hover:text-white" />
				<span class="text-slate-200">New Chat</span>
				<div class="ml-auto opacity-0 group-hover:opacity-100 transition-opacity">
					<div class="px-1.5 py-0.5 rounded-md border border-slate-700 text-[10px]">Ctrl+N</div>
				</div>
			</button>

			<div class="flex-1 overflow-y-auto space-y-6">
				<!-- History Groups -->
				<div>
					<h3 class="text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2 px-2">Recent chats</h3>
					<div class="space-y-0.5">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg hover:bg-slate-800/50 transition-all text-left group">
								<MessageSquare size={14} class="text-slate-500 shrink-0" />
								<span class="text-[13px] font-medium truncate flex-1 text-slate-300 group-hover:text-white">{history.title}</span>
							</button>
						{/each}
					</div>
				</div>
			</div>

			<!-- Sidebar Footer -->
			<div class="pt-4 mt-auto border-t border-slate-800">
				<button class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-slate-800 transition-all text-[13px] font-medium text-slate-300">
					<div class="h-6 w-6 rounded-full bg-blue-600 flex items-center justify-center text-xs text-white">R</div>
					<span>Premium Student</span>
					<ChevronDown size={14} class="ml-auto text-slate-500" />
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Chat Area -->
	<main class="flex-1 flex flex-col h-full bg-[#0d1117] relative">
		<!-- Top Bar -->
		<header class="h-14 flex items-center justify-between px-4 border-b border-slate-800/50 sticky top-0 z-10 bg-[#0d1117]/80 backdrop-blur-sm">
			<div class="flex items-center gap-2">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2 hover:bg-slate-800 rounded-lg transition-all text-slate-400"
					aria-label="Toggle Sidebar"
				>
					<Menu size={18} />
				</button>
				<div class="px-3 py-1 rounded-lg hover:bg-slate-800 transition-all cursor-pointer">
					<span class="text-sm font-bold text-slate-200">TailBot 4o</span>
					<ChevronDown size={14} class="inline ml-1 text-slate-500" />
				</div>
			</div>
			
			<div class="flex items-center gap-3">
				<button class="p-2 hover:bg-slate-800 rounded-lg text-slate-400">
					<Search size={18} />
				</button>
				<div class="h-4 w-[1px] bg-slate-800"></div>
				<button class="p-2 hover:bg-slate-800 rounded-lg text-slate-400">
					<Settings size={18} />
				</button>
			</div>
		</header>

		<!-- Messages: Centered & Minimal -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto pt-8 pb-32 scroll-smooth"
		>
			<div class="max-w-[760px] mx-auto w-full px-4 space-y-10">
				{#each messages as message}
					<div class="group flex flex-col gap-3">
						<div class="flex items-center gap-3">
							<div class={cn(
								"h-7 w-7 rounded-md flex items-center justify-center shrink-0 border",
								message.role === 'assistant' 
									? "bg-blue-600 border-blue-500 text-white" 
									: "bg-teal-600 border-teal-500 text-white"
							)}>
								{#if message.role === 'assistant'}
									<Bot size={16} strokeWidth={2.5} />
								{:else}
									<User size={16} strokeWidth={2.5} />
								{/if}
							</div>
							<span class="text-sm font-black text-slate-100 uppercase tracking-tight">
								{message.role === 'assistant' ? 'TailBot' : 'You'}
							</span>
						</div>

						<div class="pl-0 md:pl-10">
							<div class="markdown-pro text-[16px] leading-[1.7] text-slate-300 font-normal antialiased">
								{#if message.role === 'assistant'}
									{@html marked(message.content)}
								{:else}
									<p class="whitespace-pre-wrap">{message.content}</p>
								{/if}
							</div>
							
							{#if message.role === 'assistant'}
								<div class="mt-4 flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
									<button class="p-1.5 hover:bg-slate-800 rounded text-slate-500 hover:text-slate-300 transition-all">
										<Zap size={14} />
									</button>
									<button class="p-1.5 hover:bg-slate-800 rounded text-slate-500 hover:text-slate-300 transition-all">
										<Trash2 size={14} />
									</button>
								</div>
							{/if}
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="flex flex-col gap-3 animate-pulse">
						<div class="flex items-center gap-3">
							<div class="h-7 w-7 rounded-md bg-slate-800"></div>
							<div class="h-2 w-20 bg-slate-800 rounded-full"></div>
						</div>
						<div class="pl-10 space-y-2">
							<div class="h-2.5 w-full bg-slate-800/50 rounded-full"></div>
							<div class="h-2.5 w-4/5 bg-slate-800/50 rounded-full"></div>
						</div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Footer Input Area: Fixed at bottom, Centered -->
		<div class="absolute bottom-0 inset-x-0 p-4 md:p-6 bg-gradient-to-t from-[#0d1117] via-[#0d1117]/95 to-transparent">
			<div class="max-w-[760px] mx-auto w-full relative">
				<div class="relative bg-[#161b22] border border-slate-800 rounded-2xl shadow-xl transition-all focus-within:border-slate-700">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="Message TailBot..."
						class="w-full bg-transparent px-4 py-4 text-sm font-medium text-slate-100 outline-none resize-none min-h-[56px] h-auto max-h-[200px] placeholder:text-slate-500 pr-12"
						rows="1"
					></textarea>
					
					<div class="flex items-center justify-between px-3 pb-3">
						<div class="flex items-center gap-1">
							<button class="p-2 text-slate-500 hover:text-white hover:bg-slate-800 rounded-lg transition-all" title="Attach">
								<Paperclip size={18} />
							</button>
							<button class="p-2 text-slate-500 hover:text-white hover:bg-slate-800 rounded-lg transition-all" title="Features">
								<Sparkles size={18} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center justify-center p-2 bg-white text-black rounded-lg hover:bg-slate-200 disabled:opacity-20 disabled:hover:scale-100 transition-all"
						>
							<Send size={18} fill="currentColor" />
						</button>
					</div>
				</div>
				<p class="text-center mt-3 text-[11px] font-medium text-slate-500">
					TailBot can make mistakes. Check important info.
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: #0d1117;
	}

	.markdown-pro :global(h1),
	.markdown-pro :global(h2),
	.markdown-pro :global(h3) {
		font-weight: 700;
		color: #fff;
		margin-top: 24px;
		margin-bottom: 12px;
	}
	.markdown-pro :global(h1) { font-size: 1.4rem; }
	.markdown-pro :global(h2) { font-size: 1.25rem; }
	.markdown-pro :global(h3) { font-size: 1.1rem; }
	
	.markdown-pro :global(p) { margin-bottom: 16px; }
	
	.markdown-pro :global(code) {
		background: #1f2937;
		padding: 2px 4px;
		border-radius: 4px;
		font-size: 0.9em;
		font-weight: 600;
		color: #93c5fd;
	}
	
	.markdown-pro :global(pre) {
		background: #161b22 !important;
		color: #e6edf3 !important;
		padding: 16px !important;
		border-radius: 12px !important;
		margin: 20px 0 !important;
		border: 1px solid #30363d !important;
		overflow-x: auto;
	}

	.markdown-pro :global(pre code) {
		background: transparent !important;
		padding: 0 !important;
		color: inherit !important;
		font-weight: 400;
	}

	.markdown-pro :global(ul) {
		list-style-type: disc;
		padding-left: 24px;
		margin-bottom: 16px;
	}

	.markdown-pro :global(li) {
		margin-bottom: 8px;
	}

	.markdown-pro :global(strong) {
		font-weight: 700;
		color: #fff;
	}

	/* Hidden Scrollbar */
	::-webkit-scrollbar {
		width: 8px;
	}
	::-webkit-scrollbar-track {
		background: transparent;
	}
	::-webkit-scrollbar-thumb {
		background: #30363d;
		border-radius: 10px;
	}
	::-webkit-scrollbar-thumb:hover {
		background: #484f58;
	}
</style>
