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
		ChevronLeft,
		ChevronRight,
		Menu
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
			content: 'Hello! I am the Programming Tails Bot. How can I assist your learning journey today?',
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

<div class="h-[calc(100vh-64px)] w-full flex bg-white font-sans text-[#1a1c1e] overflow-hidden">
	<!-- Minimal Sidebar -->
	<aside 
		class={cn(
			"h-full bg-[#f9f9f9] border-r border-[#e3e3e3] transition-all duration-300 ease-in-out flex flex-col shrink-0",
			sidebarOpen ? "w-72" : "w-0 overflow-hidden border-none"
		)}
	>
		<div class="w-72 h-full flex flex-col">
			<div class="p-4">
				<button 
					onclick={clearChat}
					class="w-full flex items-center gap-3 px-4 py-3 bg-white border border-[#e3e3e3] rounded-xl hover:bg-[#f0f0f0] transition-colors text-sm font-bold shadow-sm"
				>
					<Plus size={16} />
					<span>New Session</span>
				</button>
			</div>

			<div class="flex-1 overflow-y-auto px-4 py-2 space-y-6">
				<section>
					<h3 class="text-[11px] font-black text-[#8e8e8e] uppercase tracking-wider mb-3 px-2">History</h3>
					<div class="space-y-1">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-[#ececec] transition-colors text-left group">
								<MessageSquare size={14} class="text-[#8e8e8e] group-hover:text-black" />
								<span class="text-sm font-semibold truncate flex-1">{history.title}</span>
							</button>
						{/each}
					</div>
				</section>
			</div>

			<div class="p-4 border-t border-[#e3e3e3]">
				<button class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-[#ececec] transition-colors text-sm font-bold">
					<Settings size={16} />
					<span>Preferences</span>
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Stage -->
	<main class="flex-1 flex flex-col h-full bg-white relative">
		<!-- Ultra-clean Header -->
		<header class="h-14 flex items-center justify-between px-6 border-b border-[#f0f0f0] bg-white/70 backdrop-blur-xl sticky top-0 z-10">
			<div class="flex items-center gap-4">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2 hover:bg-[#f0f0f0] rounded-lg transition-colors text-[#5f6368]"
				>
					<Menu size={20} />
				</button>
				<h1 class="text-sm font-black tracking-tight flex items-center gap-2">
					<div class="h-2 w-2 rounded-full bg-blue-500"></div>
					Programming Tails Bot
				</h1>
			</div>
			
			<div class="flex items-center gap-3">
				<span class="text-[10px] font-black text-[#5f6368] uppercase tracking-widest bg-[#f1f3f4] px-2.5 py-1 rounded-full px-2">
					v2.0 Professional
				</span>
			</div>
		</header>

		<!-- Unified Message Flow -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto pt-8 pb-48 scroll-smooth"
		>
			<div class="max-w-4xl mx-auto w-full px-4 md:px-8 space-y-12">
				{#each messages as message, i}
					<div 
						class="flex gap-6 group"
						in:fade={{ duration: 200 }}
					>
						<div class={cn(
							"h-9 w-9 rounded-xl flex items-center justify-center shrink-0 shadow-sm border select-none",
							message.role === 'assistant' 
								? "bg-black border-black text-white" 
								: "bg-white border-[#e3e3e3] text-[#5f6368]"
						)}>
							{#if message.role === 'assistant'}
								<Bot size={18} strokeWidth={2.5} />
							{:else}
								<User size={18} strokeWidth={2.5} />
							{/if}
						</div>

						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-1.5">
								<span class="text-[10px] font-black uppercase tracking-widest text-[#8e8e8e]">
									{message.role === 'assistant' ? 'TailBot' : 'Student'}
								</span>
								<span class="text-[10px] font-bold text-[#bdc1c6] opacity-0 group-hover:opacity-100 transition-opacity">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>

							<div class="text-[#1a1c1e] text-[15px] leading-[1.6] font-medium selection:bg-blue-100 antialiased">
								{#if message.role === 'assistant'}
									<div class="markdown-container">
										{@html marked(message.content)}
									</div>
								{:else}
									<p class="whitespace-pre-wrap">{message.content}</p>
								{/if}
							</div>
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="flex gap-6 animate-pulse px-4 md:px-8">
						<div class="h-9 w-9 rounded-xl bg-[#f1f3f4] shrink-0"></div>
						<div class="flex-1 space-y-4 pt-1">
							<div class="h-2.5 w-24 bg-[#f1f3f4] rounded-full"></div>
							<div class="space-y-2">
								<div class="h-2.5 w-full bg-[#f8f9fa] rounded-full"></div>
								<div class="h-2.5 w-2/3 bg-[#f8f9fa] rounded-full"></div>
							</div>
						</div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Clean Bottom Anchor -->
		<div class="absolute bottom-0 inset-x-0 p-6 md:p-8 bg-gradient-to-t from-white via-white/95 to-transparent pointer-events-none">
			<div class="max-w-3xl mx-auto w-full pointer-events-auto">
				<div class="relative bg-[#ffffff] border border-[#d2d2d2] rounded-2xl shadow-sm focus-within:border-black focus-within:ring-4 focus-within:ring-black/5 transition-all overflow-hidden group">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we focusing on today?"
						class="w-full bg-transparent px-5 py-4 text-sm font-bold text-black outline-none resize-none min-h-[56px] h-[56px] placeholder:text-[#9aa0a6]"
					></textarea>
					
					<div class="flex items-center justify-between px-3 pb-3">
						<div class="flex items-center gap-0.5">
							<button class="p-2 text-[#5f6368] hover:text-black hover:bg-[#f0f0f0] rounded-lg transition-colors">
								<Paperclip size={18} />
							</button>
							<button 
								onclick={clearChat}
								class="p-2 text-[#5f6368] hover:text-[#ea4335] hover:bg-[#feeef0] rounded-lg transition-colors"
							>
								<Trash2 size={18} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-2 px-6 py-2 bg-black text-white text-xs font-black rounded-lg hover:bg-zinc-800 disabled:opacity-20 disabled:hover:bg-black transition-all"
						>
							<span>Send Command</span>
							<Send size={14} strokeWidth={2.5} />
						</button>
					</div>
				</div>
				<p class="text-center mt-4 text-[11px] font-bold text-[#bdc1c6] uppercase tracking-tighter">
					Programming Tails • Advanced Learning Interface
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: white;
	}

	.markdown-container :global(h1),
	.markdown-container :global(h2),
	.markdown-container :global(h3) {
		font-weight: 800;
		color: #000;
		margin-top: 24px;
		margin-bottom: 12px;
	}
	.markdown-container :global(h3) { font-size: 1.1rem; }
	
	.markdown-container :global(p) { margin-bottom: 16px; }
	
	.markdown-container :global(code) {
		background: #f1f3f4;
		padding: 2px 5px;
		border-radius: 4px;
		font-size: 0.9em;
		font-weight: 600;
	}
	
	.markdown-container :global(pre) {
		background: #000 !important;
		color: #fff !important;
		padding: 24px !important;
		border-radius: 16px !important;
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

	/* Hide scrollbar but keep functionality */
	::-webkit-scrollbar {
		width: 6px;
	}
	::-webkit-scrollbar-track {
		background: transparent;
	}
	::-webkit-scrollbar-thumb {
		background: #e3e3e3;
		border-radius: 10px;
	}
	::-webkit-scrollbar-thumb:hover {
		background: #d2d2d2;
	}
</style>
