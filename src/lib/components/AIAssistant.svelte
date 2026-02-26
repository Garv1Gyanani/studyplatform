<script lang="ts">
	import { getAIChatCompletion } from '$lib/ai_service';
	import { MessageSquare, Send, X, Bot, User, Trash2, Sparkles, Minus } from 'lucide-svelte';
	import { onMount, tick } from 'svelte';
	import { fly, fade } from 'svelte/transition';
	import { marked } from 'marked';

	let isOpen = $state(false);
	let isMinimized = $state(false);
	let inputMessage = $state('');
	let isLoading = $state(false);
	let messages = $state<{ role: 'user' | 'assistant'; content: string; timestamp: Date }[]>([
		{
			role: 'assistant',
			content: 'Hello! I am the Programming Tails Bot. How can I help you learn today?',
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
				content: 'Sorry, I encountered an error. Please try again.',
				timestamp: new Date()
			});
		} finally {
			isLoading = false;
			await scrollToBottom();
		}
	}

	function clearChat() {
		messages = [
			{
				role: 'assistant',
				content: 'Chat cleared. How else can I help you?',
				timestamp: new Date()
			}
		];
	}

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'Enter' && !e.shiftKey) {
			e.preventDefault();
			sendMessage();
		}
	}

	$effect(() => {
		if (isOpen && !isMinimized) {
			scrollToBottom();
		}
	});

	// Function to be called from external dispatch
	export function openWithPrompt(prompt: string) {
		isOpen = true;
		isMinimized = false;
		inputMessage = prompt;
		sendMessage();
	}

	onMount(() => {
		const handlePrompt = (e: any) => {
			isOpen = true;
			isMinimized = false;
			inputMessage = e.detail;
			sendMessage();
		};

		// Also attach to window for global access
		(window as any).openTailBot = (prompt: string) => {
			handlePrompt({ detail: prompt });
		};

		window.addEventListener('ai-assistant-prompt', handlePrompt);
		return () => window.removeEventListener('ai-assistant-prompt', handlePrompt);
	});
</script>

<div class="fixed bottom-6 right-6 z-[9999] flex flex-col items-end gap-4 font-sans antialiased text-slate-900">
	{#if isOpen}
		<div
			transition:fly={{ y: 20, duration: 300 }}
			class="flex flex-col overflow-hidden rounded-[24px] border border-slate-200 bg-white shadow-[0_20px_60px_-15px_rgba(0,0,0,0.2)] transition-all duration-300"
			class:h-[540px]={!isMinimized}
			class:w-[400px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[320px]={isMinimized}
		>
			<!-- Header -->
			<div class="flex items-center justify-between bg-slate-900 p-4 text-white">
				<div class="flex items-center gap-3">
					<div class="h-9 w-9 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
						<Bot size={18} strokeWidth={2.5} />
					</div>
					<div>
						<h3 class="text-sm font-black tracking-tight leading-none mb-1">TailBot</h3>
						<span class="flex items-center gap-1.5 text-[10px] font-black uppercase tracking-widest text-emerald-400">
							<span class="h-1.5 w-1.5 rounded-full bg-current animate-pulse"></span>
							Online
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-lg p-2 transition-colors hover:bg-white/10 text-slate-400 hover:text-white"
					>
						<Minus size={18} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-lg p-2 transition-colors hover:bg-white/10 text-slate-400 hover:text-white"
					>
						<X size={18} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Messages Area -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-slate-50/50 p-5 scrollbar-hide space-y-6"
				>
					{#each messages as message}
						<div class="flex gap-4 {message.role === 'user' ? 'flex-row-reverse' : 'flex-row'}">
							<div class={cn(
								"h-8 w-8 rounded-lg flex items-center justify-center shrink-0 border text-[10px] font-black shadow-sm",
								message.role === 'assistant' ? "bg-blue-600 text-white border-blue-500" : "bg-white text-slate-500 border-slate-200"
							)}>
								{message.role === 'assistant' ? 'T' : 'U'}
							</div>
							<div class="flex flex-col max-w-[85%] {message.role === 'user' ? 'items-end' : 'items-start'}">
								<div
									class="rounded-[20px] px-5 py-3 shadow-sm text-sm font-medium leading-relaxed {message.role === 'user'
										? 'bg-slate-900 text-white rounded-tr-[4px]'
										: 'bg-white text-slate-900 border border-slate-100 rounded-tl-[4px]'}"
								>
									<div class="markdown-compact">
										{@html marked(message.content)}
									</div>
								</div>
								<span class="mt-1.5 px-1 text-[9px] font-black text-slate-400 uppercase tracking-tighter">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>
						</div>
					{/each}
					
					{#if isLoading}
						<div class="flex gap-4" in:fade>
							<div class="h-8 w-8 rounded-lg bg-blue-600 flex items-center justify-center text-white animate-pulse">
								<Bot size={16} />
							</div>
							<div class="bg-white border border-slate-100 rounded-[20px] px-5 py-3 flex items-center gap-1.5">
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce [animation-delay:0.2s]"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-bounce [animation-delay:0.4s]"></div>
							</div>
						</div>
					{/if}
				</div>

				<!-- Input Area -->
				<div class="border-t border-slate-100 p-5 bg-white">
					<div class="relative flex items-end gap-3 bg-slate-50 border border-slate-200 rounded-[20px] p-2 focus-within:border-blue-600 focus-within:bg-white transition-all">
						<textarea
							bind:value={inputMessage}
							onkeydown={handleKeydown}
							placeholder="Type your message..."
							class="flex-1 max-h-32 min-h-[44px] bg-transparent border-none px-3 py-2 text-sm font-bold focus:ring-0 resize-none placeholder:text-slate-400"
							rows="1"
						></textarea>
						<button
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="h-10 w-10 flex items-center justify-center rounded-full bg-blue-600 text-white shadow-lg shadow-blue-500/30 transition-all hover:bg-blue-700 hover:scale-105 active:scale-95 disabled:opacity-20 disabled:hover:scale-100"
						>
							<Send size={18} strokeWidth={2.5} />
						</button>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- Signature Toggle -->
	{#if !isOpen}
		<button
			transition:fade
			onclick={() => (isOpen = true)}
			class="group h-16 w-16 flex items-center justify-center rounded-full bg-slate-900 text-white shadow-[0_20px_40px_-10px_rgba(0,0,0,0.3)] transition-all duration-300 hover:scale-110 active:scale-95"
		>
			<div class="absolute inset-0 rounded-full border-2 border-slate-900 animate-ping opacity-10"></div>
			<div class="relative">
				<Bot size={28} strokeWidth={2.5} class="transition-transform group-hover:rotate-12" />
				<div class="absolute -right-2 -top-2 flex h-6 w-6 items-center justify-center rounded-full bg-blue-600 text-[10px] font-black text-white border-4 border-slate-900 shadow-sm">
					1
				</div>
			</div>
		</button>
	{/if}
</div>

<style>
	.scrollbar-hide::-webkit-scrollbar { display: none; }
	.scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }

	.markdown-compact :global(p) { margin: 0; }
	.markdown-compact :global(p + p) { margin-top: 10px; }
	.markdown-compact :global(pre) {
		background: #000 !important;
		color: #fff !important;
		padding: 16px !important;
		border-radius: 12px !important;
		margin: 12px 0 !important;
		font-size: 13px !important;
		font-weight: 500 !important;
	}
	.markdown-compact :global(code) {
		background: rgba(0,0,0,0.05);
		padding: 2px 4px;
		border-radius: 4px;
		font-weight: 700;
	}
	.markdown-compact :global(ul) {
		list-style-type: disc;
		padding-left: 20px;
		margin: 10px 0;
	}
	.markdown-compact :global(bold), .markdown-compact :global(strong) {
		font-weight: 800;
	}
</style>
