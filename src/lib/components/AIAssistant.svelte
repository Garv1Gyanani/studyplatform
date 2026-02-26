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

<div class="fixed bottom-6 right-6 z-[9999] flex flex-col items-end gap-5 font-sans antialiased text-slate-900">
	{#if isOpen}
		<div
			transition:fly={{ y: 30, duration: 400, opacity: 0 }}
			class="flex flex-col overflow-hidden rounded-[28px] border-2 border-slate-100 bg-white shadow-[0_30px_100px_-20px_rgba(37,99,235,0.2)] transition-all duration-300"
			class:h-[620px]={!isMinimized}
			class:w-[420px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[320px]={isMinimized}
		>
			<!-- White/Blue Premium Header -->
			<div class="flex items-center justify-between border-b border-slate-100 bg-white p-5">
				<div class="flex items-center gap-4">
					<div class="h-10 w-10 rounded-2xl bg-blue-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
						<Bot size={20} strokeWidth={2.5} />
					</div>
					<div>
						<h3 class="text-xs font-black tracking-tight leading-none mb-1.5 flex items-center gap-2 uppercase text-slate-900">
							TailBot AI
						</h3>
						<span class="flex items-center gap-1.5 text-[9px] font-black uppercase tracking-widest text-blue-600">
							<span class="h-1.5 w-1.5 rounded-full bg-current animate-pulse"></span>
							Active Hub
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-xl p-2 transition-all hover:bg-slate-50 text-slate-400 hover:text-blue-600"
					>
						<Minus size={20} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-xl p-2 transition-all hover:bg-slate-50 text-slate-400 hover:text-red-500"
					>
						<X size={20} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Clean Message Area -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-slate-50/30 p-6 scrollbar-hide space-y-8"
				>
					{#each messages as message}
						<div class="flex flex-col gap-3 {message.role === 'user' ? 'items-end' : 'items-start'}">
							<div class="flex items-center gap-3 px-1">
								{#if message.role === 'assistant'}
									<div class="h-6 w-6 rounded-lg bg-blue-600 text-white flex items-center justify-center shadow-sm">
										<Bot size={14} />
									</div>
								{/if}
								<span class="text-[9px] font-black uppercase tracking-widest text-slate-400">
									{message.role === 'assistant' ? 'Assistant' : 'Student'}
								</span>
							</div>
							<div
								class={cn(
									"rounded-[24px] px-6 py-4 shadow-sm text-[15px] font-medium leading-relaxed max-w-[90%]",
									message.role === 'user'
										? 'bg-blue-600 text-white rounded-tr-none shadow-blue-500/20'
										: 'bg-white text-slate-800 border-2 border-slate-50 rounded-tl-none'
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
							<div class="bg-white border-2 border-slate-50 rounded-[20px] px-5 py-3.5 flex items-center gap-1.5 shadow-sm">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce [animation-delay:0.2s]"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce [animation-delay:0.4s]"></div>
							</div>
						</div>
					{/if}
				</div>

				<!-- Premium Input Area (White/Blue) -->
				<div class="border-t border-slate-100 p-6 bg-white">
					<div class="relative flex items-end gap-3 bg-slate-50 border-2 border-slate-100 rounded-[24px] p-2 focus-within:border-blue-600 focus-within:bg-white transition-all shadow-inner">
						<textarea
							bind:value={inputMessage}
							onkeydown={handleKeydown}
							placeholder="Type your message..."
							class="flex-1 max-h-32 min-h-[48px] bg-transparent border-none px-4 py-3 text-sm font-bold focus:ring-0 resize-none placeholder:text-slate-300 text-slate-900"
							rows="1"
						></textarea>
						<button
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="h-12 w-12 flex items-center justify-center rounded-[18px] bg-blue-600 text-white shadow-xl shadow-blue-500/20 transition-all hover:bg-blue-700 hover:scale-105 active:scale-95 disabled:opacity-20"
						>
							<Send size={20} strokeWidth={2.5} />
						</button>
					</div>
					<div class="mt-4 flex items-center justify-between px-2">
						<button 
							onclick={clearChat}
							class="text-[9px] font-black uppercase tracking-[0.2em] text-slate-300 hover:text-blue-600 transition-colors"
						>
							Reset HUB
						</button>
						<span class="text-[9px] font-black uppercase tracking-[0.2em] text-blue-600/30">Programming Tails</span>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- Launcher Button (White/Blue) -->
	{#if !isOpen}
		<button
			transition:fade={{ duration: 200 }}
			onclick={() => (isOpen = true)}
			class="group h-16 w-16 flex items-center justify-center rounded-[24px] bg-white text-blue-600 shadow-[0_20px_60px_-15px_rgba(37,99,235,0.3)] transition-all duration-300 hover:scale-105 active:scale-95 relative border-4 border-white"
		>
			<div class="absolute inset-0 rounded-[20px] bg-blue-600 animate-pulse opacity-5"></div>
			<div class="relative">
				<BrainCircuit size={28} strokeWidth={2.5} class="transition-transform group-hover:scale-110" />
				{#if unreadCount > 0}
					<div 
						transition:fade
						class="absolute -right-4 -top-4 flex h-6 w-6 items-center justify-center rounded-full bg-blue-600 text-[10px] font-black text-white border-4 border-white shadow-lg"
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
		padding: 24px !important;
		border-radius: 20px !important;
		margin: 16px 0 !important;
		font-size: 13px !important;
		font-weight: 500 !important;
		overflow-x: auto;
	}
	.markdown-rich :global(code) {
		background: #f1f5f9;
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
	.markdown-rich :global(strong) {
		font-weight: 900;
		color: #2563eb;
	}
</style>
