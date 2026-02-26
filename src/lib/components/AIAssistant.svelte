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

	onMount(() => {
		const handlePrompt = (e: any) => {
			isOpen = true;
			isMinimized = false;
			inputMessage = e.detail;
			sendMessage();
		};

		window.addEventListener('ai-assistant-prompt', handlePrompt);
		return () => window.removeEventListener('ai-assistant-prompt', handlePrompt);
	});
</script>

<div class="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-4 font-sans antialiased text-[#1a1c1e]">
	{#if isOpen}
		<div
			transition:fly={{ y: 20, duration: 300 }}
			class="flex flex-col overflow-hidden rounded-[24px] border border-[#e3e3e3] bg-white shadow-[0_20px_60px_-15px_rgba(0,0,0,0.15)] transition-all duration-300"
			class:h-[500px]={!isMinimized}
			class:w-[380px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[300px]={isMinimized}
		>
			<!-- Header -->
			<div class="flex items-center justify-between bg-white border-b border-[#f0f0f0] p-4">
				<div class="flex items-center gap-3">
					<div class="h-8 w-8 rounded-lg bg-black flex items-center justify-center text-white">
						<Bot size={16} strokeWidth={2.5} />
					</div>
					<div>
						<h3 class="text-xs font-black tracking-tight">TailBot</h3>
						<span class="flex items-center gap-1 text-[9px] font-bold text-[#34a853] uppercase tracking-widest">
							<span class="h-1.5 w-1.5 rounded-full bg-current"></span>
							Active
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-lg p-1.5 transition-colors hover:bg-[#f0f0f0] text-[#5f6368]"
					>
						<Minus size={18} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-lg p-1.5 transition-colors hover:bg-[#f0f0f0] text-[#5f6368]"
					>
						<X size={18} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Messages Area -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-white p-4 scrollbar-hide space-y-4"
				>
					{#each messages as message}
						<div class="flex gap-3 {message.role === 'user' ? 'flex-row-reverse' : 'flex-row'}">
							<div class={cn(
								"h-7 w-7 rounded-lg flex items-center justify-center shrink-0 border text-[10px] font-black",
								message.role === 'assistant' ? "bg-black text-white border-black" : "bg-white text-[#5f6368] border-[#e3e3e3]"
							)}>
								{message.role === 'assistant' ? 'T' : 'U'}
							</div>
							<div class="flex flex-col max-w-[80%] {message.role === 'user' ? 'items-end' : 'items-start'}">
								<div
									class="rounded-[20px] px-4 py-2.5 shadow-sm text-sm font-medium leading-relaxed {message.role === 'user'
										? 'bg-blue-600 text-white rounded-tr-[4px]'
										: 'bg-[#f1f3f4] text-[#1a1c1e] rounded-tl-[4px]'}"
								>
									<div class="markdown-compact">
										{@html marked(message.content)}
									</div>
								</div>
								<span class="mt-1 px-1 text-[9px] font-bold text-[#bdc1c6] uppercase">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>
						</div>
					{/each}
					
					{#if isLoading}
						<div class="flex gap-3" in:fade>
							<div class="h-7 w-7 rounded-lg bg-black flex items-center justify-center text-white animate-pulse">
								<Bot size={14} />
							</div>
							<div class="bg-[#f1f3f4] rounded-[20px] px-4 py-2 flex items-center gap-1.5">
								<div class="h-1.5 w-1.5 rounded-full bg-[#bdc1c6] animate-bounce"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-[#bdc1c6] animate-bounce [animation-delay:0.2s]"></div>
								<div class="h-1.5 w-1.5 rounded-full bg-[#bdc1c6] animate-bounce [animation-delay:0.4s]"></div>
							</div>
						</div>
					{/if}
				</div>

				<!-- Input Area -->
				<div class="border-t border-[#f0f0f0] p-4 bg-white">
					<div class="relative flex items-end gap-2 bg-[#f8f9fa] border border-[#e3e3e3] rounded-[20px] p-1.5 focus-within:border-black transition-all">
						<textarea
							bind:value={inputMessage}
							onkeydown={handleKeydown}
							placeholder="Ask Programming Tails..."
							class="flex-1 max-h-32 min-h-[40px] bg-transparent border-none px-3 py-2 text-sm font-semibold focus:ring-0 resize-none placeholder:text-[#9aa0a6]"
							rows="1"
						></textarea>
						<button
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="h-9 w-9 flex items-center justify-center rounded-full bg-black text-white shadow-md transition-all hover:bg-zinc-800 disabled:opacity-20"
						>
							<Send size={16} strokeWidth={2.5} />
						</button>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- Compact Toggle -->
	{#if !isOpen}
		<button
			transition:fade
			onclick={() => (isOpen = true)}
			class="group h-14 w-14 flex items-center justify-center rounded-full bg-black text-white shadow-[0_10px_30px_-5px_rgba(0,0,0,0.3)] transition-all duration-300 hover:scale-105 active:scale-95"
		>
			<div class="absolute inset-0 rounded-full border-2 border-black animate-ping opacity-10"></div>
			<Bot size={24} strokeWidth={2.5} class="transition-transform group-hover:scale-110" />
			<div class="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-blue-600 text-[10px] font-black text-white border-2 border-white shadow-sm">
				1
			</div>
		</button>
	{/if}
</div>

<style>
	.scrollbar-hide::-webkit-scrollbar { display: none; }
	.scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }

	.markdown-compact :global(p) { margin: 0; }
	.markdown-compact :global(p + p) { margin-top: 8px; }
	.markdown-compact :global(pre) {
		background: #000 !important;
		color: #fff !important;
		padding: 12px !important;
		border-radius: 12px !important;
		margin: 8px 0 !important;
		font-size: 12px !important;
	}
	.markdown-compact :global(code) {
		background: rgba(0,0,0,0.05);
		padding: 1px 3px;
		border-radius: 4px;
	}
	.markdown-compact :global(ul) {
		list-style-type: disc;
		padding-left: 16px;
		margin: 8px 0;
	}
</style>
