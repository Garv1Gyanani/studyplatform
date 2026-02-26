<script lang="ts">
	import { getAIChatCompletion } from '$lib/ai_service';
	import { MessageSquare, Send, X, Bot, User, Trash2, Sparkles, Minus } from 'lucide-svelte';
	import { onMount, tick } from 'svelte';
	import { fly, fade } from 'svelte/transition';
	import { marked } from 'marked';
	import { cn } from '$lib/utils';

	let isOpen = $state(false);
	let isMinimized = $state(false);
	let inputMessage = $state('');
	let isLoading = $state(false);
	let unreadCount = $state(1);
	let messages = $state<{ role: 'user' | 'assistant'; content: string; timestamp: Date }[]>([
		{
			role: 'assistant',
			content: 'Hello! I am the **Programming Tails Bot**. How can I help you learn today?',
			timestamp: new Date()
		}
	]);

	let scrollContainer: HTMLDivElement;

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
		
		// Use reassignment for guaranteed reactivity in Svelte 5
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
				content: 'Chat cleared. How else can I assist you?',
				timestamp: new Date()
			}
		];
	}

	// External Trigger Handler
	function handleExternalPrompt(prompt: string) {
		isOpen = true;
		isMinimized = false;
		unreadCount = 0;
		inputMessage = prompt;
		sendMessage();
	}

	onMount(() => {
		const listener = (e: any) => {
			if (e.detail) {
				handleExternalPrompt(e.detail);
			}
		};

		// Attach to window for absolute fallback
		(window as any).openTailBot = (prompt: string) => {
			handleExternalPrompt(prompt);
		};

		window.addEventListener('ai-assistant-prompt', listener);
		return () => window.removeEventListener('ai-assistant-prompt', listener);
	});

	$effect(() => {
		if (isOpen && !isMinimized) {
			unreadCount = 0;
			scrollToBottom();
		}
	});
</script>

<div class="fixed bottom-6 right-6 z-[9999] flex flex-col items-end gap-5 font-sans antialiased text-slate-900">
	{#if isOpen}
		<div
			transition:fly={{ y: 30, duration: 400, opacity: 0 }}
			class="flex flex-col overflow-hidden rounded-[32px] border border-blue-100 bg-white shadow-[0_30px_100px_-20px_rgba(37,99,235,0.25)] transition-all duration-300"
			class:h-[600px]={!isMinimized}
			class:w-[420px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[320px]={isMinimized}
		>
			<!-- Premium Header -->
			<div class="flex items-center justify-between bg-gradient-to-br from-slate-900 to-slate-800 p-5 text-white">
				<div class="flex items-center gap-4">
					<div class="h-10 w-10 rounded-2xl bg-blue-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/20 ring-2 ring-white/10">
						<Bot size={20} strokeWidth={2.5} />
					</div>
					<div>
						<h3 class="text-sm font-black tracking-tight leading-none mb-1.5 flex items-center gap-2">
							TailBot AI
							<span class="inline-block px-1.5 py-0.5 rounded-md bg-blue-500/10 border border-blue-500/20 text-[8px] font-black uppercase tracking-tighter text-blue-400">Pro</span>
						</h3>
						<span class="flex items-center gap-1.5 text-[9px] font-black uppercase tracking-widest text-emerald-400">
							<span class="h-1.5 w-1.5 rounded-full bg-current animate-pulse"></span>
							Online Hub
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-xl p-2 transition-all hover:bg-white/10 text-slate-400 hover:text-white"
					>
						<Minus size={20} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-xl p-2 transition-all hover:bg-white/10 text-slate-400 hover:text-white"
					>
						<X size={20} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Bubble-based Message Flow -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-slate-50/50 p-6 scrollbar-hide space-y-6"
				>
					{#each messages as message}
						<div class="flex flex-col gap-2 {message.role === 'user' ? 'items-end' : 'items-start'}">
							<div class="flex items-center gap-2 px-1">
								<span class="text-[9px] font-black uppercase tracking-widest text-slate-400">
									{message.role === 'assistant' ? 'Assistant' : 'Student'}
								</span>
							</div>
							<div
								class={cn(
									"rounded-[24px] px-5 py-3.5 shadow-sm text-[15px] font-medium leading-relaxed max-w-[90%]",
									message.role === 'user'
										? 'bg-blue-600 text-white rounded-tr-none shadow-blue-500/10'
										: 'bg-white text-slate-900 border border-slate-100 rounded-tl-none'
								)}
							>
								<div class="markdown-rich">
									{@html marked(message.content)}
								</div>
							</div>
							<span class="px-2 text-[9px] font-bold text-slate-300">
								{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
							</span>
						</div>
					{/each}
					
					{#if isLoading}
						<div class="flex flex-col gap-2 items-start" in:fade>
							<div class="h-8 w-16 bg-white border border-slate-100 rounded-2xl flex items-center justify-center gap-1.5 shadow-sm">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce [animation-delay:0.2s]"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce [animation-delay:0.4s]"></div>
							</div>
						</div>
					{/if}
				</div>

				<!-- Command Input Area -->
				<div class="border-t border-slate-100 p-6 bg-white">
					<div class="relative flex items-end gap-3 bg-slate-50 border-2 border-slate-100 rounded-[24px] p-2 focus-within:border-blue-600 focus-within:bg-white transition-all shadow-inner">
						<textarea
							bind:value={inputMessage}
							onkeydown={handleKeydown}
							placeholder="Ask Programming Tails..."
							class="flex-1 max-h-32 min-h-[48px] bg-transparent border-none px-4 py-3 text-sm font-bold focus:ring-0 resize-none placeholder:text-slate-300 text-slate-900"
							rows="1"
						></textarea>
						<button
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="h-12 w-12 flex items-center justify-center rounded-[18px] bg-slate-900 text-white shadow-xl transition-all hover:bg-black hover:scale-105 active:scale-95 disabled:opacity-20"
						>
							<Send size={20} strokeWidth={2.5} />
						</button>
					</div>
					<div class="mt-4 flex items-center justify-between px-2">
						<button 
							onclick={clearChat}
							class="text-[10px] font-black uppercase tracking-widest text-slate-400 hover:text-red-500 transition-colors flex items-center gap-2"
						>
							<Trash2 size={12} />
							Clear Session
						</button>
						<span class="text-[10px] font-black uppercase tracking-tighter text-slate-300">v2.1 Build</span>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- Signature Action Button -->
	{#if !isOpen}
		<button
			transition:fade={{ duration: 200 }}
			onclick={() => (isOpen = true)}
			class="group h-16 w-16 flex items-center justify-center rounded-[24px] bg-slate-950 text-white shadow-[0_20px_50px_-10px_rgba(0,0,0,0.4)] transition-all duration-300 hover:scale-110 hover:-translate-y-1 active:scale-95 relative"
		>
			<div class="absolute inset-0 rounded-[24px] border-2 border-blue-500 animate-ping opacity-20 group-hover:opacity-40"></div>
			<div class="relative">
				<Bot size={28} strokeWidth={2.5} class="transition-transform group-hover:rotate-12" />
				{#if unreadCount > 0}
					<div 
						transition:fade
						class="absolute -right-3 -top-3 flex h-6 w-6 items-center justify-center rounded-full bg-blue-600 text-[10px] font-black text-white border-4 border-slate-950 shadow-lg"
					>
						{unreadCount}
					</div>
				{/if}
			</div>
		</button>
	{/if}
</div>

<style>
	.scrollbar-hide::-webkit-scrollbar { display: none; }
	.scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }

	.markdown-rich :global(p) { margin: 0; }
	.markdown-rich :global(p + p) { margin-top: 10px; }
	.markdown-rich :global(pre) {
		background: #0f172a !important;
		color: #f8fafc !important;
		padding: 20px !important;
		border-radius: 16px !important;
		margin: 12px 0 !important;
		font-size: 13px !important;
		font-weight: 500 !important;
		overflow-x: auto;
	}
	.markdown-rich :global(code) {
		background: rgba(37,99,235,0.05);
		padding: 2px 5px;
		border-radius: 6px;
		font-weight: 800;
		color: #2563eb;
	}
	.markdown-rich :global(ul) {
		list-style-type: disc;
		padding-left: 20px;
		margin: 10px 0;
	}
	.markdown-rich :global(li) {
		margin-bottom: 6px;
	}
	.markdown-rich :global(strong) {
		font-weight: 900;
	}
</style>
