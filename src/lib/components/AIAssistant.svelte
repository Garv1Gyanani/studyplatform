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
			scrollContainer.scrollTo({
				top: scrollContainer.scrollHeight,
				behavior: 'smooth'
			});
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

<div class="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-4 font-sans">
	{#if isOpen}
		<div
			transition:fly={{ y: 20, duration: 300 }}
			class="flex flex-col overflow-hidden rounded-2xl border border-blue-100 bg-white shadow-2xl transition-all duration-300"
			class:h-[500px]={!isMinimized}
			class:w-[380px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[300px]={isMinimized}
		>
			<!-- Header -->
			<div class="flex items-center justify-between bg-gradient-to-r from-blue-600 to-indigo-700 p-4 text-white">
				<div class="flex items-center gap-3">
					<div class="rounded-full bg-white/20 p-2">
						<Sparkles size={18} class="text-yellow-300" />
					</div>
					<div>
						<h3 class="text-sm font-bold">Programming Tails Bot</h3>
						<span class="flex items-center gap-1 text-[10px] opacity-80">
							<span class="h-1.5 w-1.5 rounded-full bg-green-400"></span>
							Online
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-lg p-1.5 transition-colors hover:bg-white/10"
					>
						<Minus size={18} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-lg p-1.5 transition-colors hover:bg-white/10"
					>
						<X size={18} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Messages Area -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-slate-50 p-4 scrollbar-thin scrollbar-thumb-blue-200"
				>
					<div class="flex flex-col gap-4">
						{#each messages as message}
							<div class="flex {message.role === 'user' ? 'justify-end' : 'justify-start'}">
								<div
									class="max-w-[85%] rounded-2xl p-3 shadow-sm {message.role === 'user'
										? 'bg-blue-600 text-white rounded-tr-none'
										: 'bg-white text-slate-800 border border-slate-100 rounded-tl-none'}"
								>
									<div class="flex items-start gap-2">
										{#if message.role === 'assistant'}
											<Bot size={14} class="mt-1 flex-shrink-0 text-blue-500" />
										{/if}
										<div class="prose prose-sm prose-slate max-w-none prose-p:leading-relaxed">
											{@html marked(message.content)}
										</div>
									</div>
									<div
										class="mt-1 text-right text-[10px] {message.role === 'user'
											? 'text-blue-100'
											: 'text-slate-400'}"
									>
										{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
									</div>
								</div>
							</div>
						{/each}
						
						{#if isLoading}
							<div class="flex justify-start" in:fade>
								<div class="flex gap-1 rounded-full bg-white px-4 py-2 shadow-sm border border-slate-100">
									<span class="h-1.5 w-1.5 animate-bounce rounded-full bg-blue-400"></span>
									<span class="h-1.5 w-1.5 animate-bounce rounded-full bg-blue-500 [animation-delay:0.2s]"></span>
									<span class="h-1.5 w-1.5 animate-bounce rounded-full bg-blue-600 [animation-delay:0.4s]"></span>
								</div>
							</div>
						{/if}
					</div>
				</div>

				<!-- Input Area -->
				<div class="border-t bg-white p-4">
					<div class="flex gap-2">
						<button
							onclick={clearChat}
							class="rounded-xl border border-slate-200 p-2 text-slate-400 transition-colors hover:bg-slate-50 hover:text-red-500"
							title="Clear chat"
						>
							<Trash2 size={20} />
						</button>
						<div class="relative flex-1">
							<textarea
								bind:value={inputMessage}
								onkeydown={handleKeydown}
								placeholder="Ask me anything..."
								class="max-h-32 min-h-[44px] w-full resize-none rounded-xl border border-slate-200 bg-slate-50 py-2.5 pl-4 pr-12 text-sm focus:border-blue-500 focus:bg-white focus:outline-none transition-all"
								rows="1"
							></textarea>
							<button
								onclick={sendMessage}
								disabled={!inputMessage.trim() || isLoading}
								class="absolute right-1.5 top-1.5 rounded-lg bg-blue-600 p-2 text-white shadow-md transition-all hover:bg-blue-700 disabled:bg-slate-300"
							>
								<Send size={16} />
							</button>
						</div>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- Toggle Button -->
	{#if !isOpen}
		<button
			transition:fade
			onclick={() => (isOpen = true)}
			class="group relative flex h-14 w-14 items-center justify-center rounded-full bg-gradient-to-br from-blue-600 to-indigo-700 text-white shadow-xl transition-all duration-300 hover:scale-110 hover:shadow-blue-500/25 active:scale-95"
		>
			<div class="absolute inset-0 animate-pulse rounded-full bg-blue-500/20"></div>
			<MessageSquare class="relative z-10 transition-transform group-hover:rotate-12" />
			<div class="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white shadow-md border-2 border-white">
				1
			</div>
		</button>
	{/if}
</div>

<style>
	/* Custom scrollbar for better look */
	.scrollbar-thin::-webkit-scrollbar {
		width: 6px;
	}
	.scrollbar-thin::-webkit-scrollbar-track {
		background: transparent;
	}
	.scrollbar-thin::-webkit-scrollbar-thumb {
		background: #e2e8f0;
		border-radius: 10px;
	}
	.scrollbar-thin::-webkit-scrollbar-thumb:hover {
		background: #cbd5e1;
	}
</style>
