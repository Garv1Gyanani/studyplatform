<script lang="ts">
	import { getAIChatCompletion } from '$lib/ai_service';
	import { MessageSquare, Send, X, Bot, User, Trash2, Sparkles, Minus, BrainCircuit } from 'lucide-svelte';
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
			content: 'Hello! I am **TailBot**. How can I assist your learning journey today?',
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
				content: 'Session reset. How can I help?',
				timestamp: new Date()
			}
		];
	}

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

<div class="fixed bottom-6 right-6 z-[9999] flex flex-col items-end gap-3 font-sans antialiased text-slate-900 border-none">
	{#if isOpen}
		<div
			transition:fly={{ y: 20, duration: 400, opacity: 0 }}
			class="flex flex-col overflow-hidden rounded-[24px] border border-slate-100 bg-white shadow-[0_20px_60px_-15px_rgba(37,99,235,0.15)] transition-all duration-300"
			class:h-[540px]={!isMinimized}
			class:w-[380px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[300px]={isMinimized}
		>
			<!-- Header -->
			<div class="flex items-center justify-between border-b border-slate-50 bg-white p-4">
				<div class="flex items-center gap-3">
					<div class="h-8 w-8 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-md shadow-blue-500/10">
						<Bot size={16} strokeWidth={2.5} />
					</div>
					<div>
						<h3 class="text-[11px] font-black tracking-tight leading-none mb-1 flex items-center gap-2 uppercase text-slate-900">
							TailBot AI
						</h3>
						<span class="flex items-center gap-1 text-[8px] font-black uppercase tracking-widest text-blue-600">
							<span class="h-1 w-1 rounded-full bg-current animate-pulse"></span>
							Online
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-lg p-1.5 transition-all hover:bg-slate-50 text-slate-400 hover:text-blue-600"
					>
						<Minus size={16} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-lg p-1.5 transition-all hover:bg-slate-50 text-slate-400 hover:text-red-500"
					>
						<X size={16} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Messages -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-slate-50/20 p-5 scrollbar-hide space-y-6"
				>
					{#each messages as message}
						<div class="flex flex-col gap-2 {message.role === 'user' ? 'items-end' : 'items-start'}">
							<div class="flex items-center gap-2.5 px-1">
								{#if message.role === 'assistant'}
									<div class="h-5 w-5 rounded-md bg-blue-600 text-white flex items-center justify-center">
										<Bot size={11} />
									</div>
								{/if}
								<span class="text-[8px] font-black uppercase tracking-widest text-slate-400">
									{message.role === 'assistant' ? 'Assistant' : 'Student'}
								</span>
							</div>
							<div
								class={cn(
									"rounded-[20px] px-4 py-3 shadow-sm text-[14px] font-medium leading-relaxed max-w-[85%]",
									message.role === 'user'
										? 'bg-blue-600 text-white rounded-tr-none'
										: 'bg-white text-slate-800 border border-slate-100 rounded-tl-none'
								)}
							>
								<div class="markdown-rich">
									{@html marked(message.content)}
								</div>
							</div>
						</div>
					{/each}
					
					{#if isLoading}
						<div class="flex flex-col gap-2 items-start" in:fade>
							<div class="bg-white border border-slate-100 rounded-2xl px-4 py-2.5 flex items-center gap-1 shadow-sm">
								<div class="h-1 w-1 rounded-full bg-blue-600 animate-bounce"></div>
								<div class="h-1 w-1 rounded-full bg-blue-600 animate-bounce [animation-delay:0.2s]"></div>
								<div class="h-1 w-1 rounded-full bg-blue-600 animate-bounce [animation-delay:0.4s]"></div>
							</div>
						</div>
					{/if}
				</div>

				<!-- Input -->
				<div class="border-t border-slate-50 p-4 bg-white">
					<div class="relative flex items-end gap-2 bg-slate-50 border border-slate-100 rounded-xl p-1.5 focus-within:border-blue-600 focus-within:bg-white transition-all shadow-inner">
						<textarea
							bind:value={inputMessage}
							onkeydown={handleKeydown}
							placeholder="Type your message..."
							class="flex-1 max-h-24 min-h-[40px] bg-transparent border-none px-3 py-2 text-[13px] font-bold focus:ring-0 resize-none placeholder:text-slate-300 text-slate-900"
							rows="1"
						></textarea>
						<button
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="h-10 w-10 flex items-center justify-center rounded-lg bg-blue-600 text-white shadow-lg shadow-blue-500/10 transition-all hover:bg-blue-700 active:scale-95 disabled:opacity-20"
						>
							<Send size={16} strokeWidth={2.5} />
						</button>
					</div>
					<div class="mt-3 flex items-center justify-between px-1">
						<button 
							onclick={clearChat}
							class="text-[8px] font-black uppercase tracking-widest text-slate-300 hover:text-blue-600 transition-colors"
						>
							Clear Session
						</button>
						<span class="text-[8px] font-bold text-slate-200">Programming Tails</span>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- Launcher -->
	{#if !isOpen}
		<button
			transition:fade={{ duration: 200 }}
			onclick={() => (isOpen = true)}
			class="group h-14 w-14 flex items-center justify-center rounded-[20px] bg-white text-blue-600 shadow-[0_15px_40px_-10px_rgba(37,99,235,0.25)] transition-all duration-300 hover:scale-105 active:scale-95 border-2 border-slate-50"
		>
			<div class="absolute inset-0 rounded-[18px] bg-blue-600 animate-pulse opacity-5"></div>
			<div class="relative">
				<BrainCircuit size={24} strokeWidth={2.5} class="transition-transform group-hover:scale-110" />
				{#if unreadCount > 0}
					<div 
						transition:fade
						class="absolute -right-3 -top-3 flex h-5 w-5 items-center justify-center rounded-full bg-blue-600 text-[9px] font-black text-white border-2 border-white shadow-md"
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
	.markdown-rich :global(p) { margin: 0; }
	.markdown-rich :global(p + p) { margin-top: 8px; }
	.markdown-rich :global(pre) {
		background: #0f172a !important;
		color: #f8fafc !important;
		padding: 16px !important;
		border-radius: 12px !important;
		margin: 12px 0 !important;
		font-size: 11px !important;
		overflow-x: auto;
	}
	.markdown-rich :global(code) {
		background: #f1f5f9;
		padding: 1px 4px;
		border-radius: 4px;
		font-weight: 800;
		color: #2563eb;
	}
	.markdown-rich :global(ul) { list-style-type: disc; padding-left: 16px; margin: 8px 0; }
	.markdown-rich :global(strong) { font-weight: 800; color: #2563eb; }
</style>
