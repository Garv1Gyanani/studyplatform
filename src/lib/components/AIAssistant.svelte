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

<div class="fixed bottom-6 right-6 z-[9999] flex flex-col items-end gap-4 font-sans antialiased">
	{#if isOpen}
		<div
			transition:fly={{ y: 20, duration: 300 }}
			class="flex flex-col overflow-hidden rounded-[20px] bg-[#0d1117] border border-slate-800 shadow-[0_20px_50px_-12px_rgba(0,0,0,0.5)] transition-all duration-300"
			class:h-[580px]={!isMinimized}
			class:w-[380px]={!isMinimized}
			class:h-auto={isMinimized}
			class:w-[300px]={isMinimized}
		>
			<!-- Sleek Header -->
			<div class="flex items-center justify-between p-4 bg-[#0d1117] border-b border-slate-800">
				<div class="flex items-center gap-3">
					<div class="h-8 w-8 rounded-lg bg-blue-600 flex items-center justify-center text-white shadow-lg">
						<BrainCircuit size={18} strokeWidth={2.5} />
					</div>
					<div>
						<h3 class="text-xs font-black text-white uppercase tracking-tighter">TailBot AI</h3>
						<span class="flex items-center gap-1.5 text-[9px] font-bold text-blue-500 uppercase tracking-widest">
							Pro Intelligence
						</span>
					</div>
				</div>
				<div class="flex items-center gap-1">
					<button
						onclick={() => (isMinimized = !isMinimized)}
						class="rounded-lg p-1.5 transition-colors hover:bg-slate-800 text-slate-500 hover:text-white"
					>
						<Minus size={18} />
					</button>
					<button
						onclick={() => (isOpen = false)}
						class="rounded-lg p-1.5 transition-colors hover:bg-slate-800 text-slate-500 hover:text-white"
					>
						<X size={18} />
					</button>
				</div>
			</div>

			{#if !isMinimized}
				<!-- Centered Message Column -->
				<div
					bind:this={scrollContainer}
					class="flex-1 overflow-y-auto bg-[#0d1117] p-5 scrollbar-thin space-y-6"
				>
					{#each messages as message}
						<div class="flex flex-col gap-2">
							<div class="flex items-center gap-2">
								<div class={cn(
									"h-6 w-6 rounded flex items-center justify-center text-[10px] font-black shrink-0",
									message.role === 'assistant' ? "bg-blue-600 text-white" : "bg-slate-700 text-slate-200"
								)}>
									{message.role === 'assistant' ? 'T' : 'U'}
								</div>
								<span class="text-[10px] font-black uppercase tracking-widest text-slate-500">
									{message.role === 'assistant' ? 'TailBot' : 'Student'}
								</span>
							</div>
							<div class="pl-8">
								<div class="markdown-minimal text-[14.5px] leading-relaxed text-slate-300">
									{@html marked(message.content)}
								</div>
								<span class="mt-2 block text-[9px] font-bold text-slate-600 uppercase">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>
						</div>
					{/each}
					
					{#if isLoading}
						<div class="flex items-center gap-2 pl-8" in:fade>
							<div class="flex gap-1">
								<div class="h-1 w-1 rounded-full bg-blue-600 animate-bounce"></div>
								<div class="h-1 w-1 rounded-full bg-blue-600 animate-bounce [animation-delay:0.2s]"></div>
								<div class="h-1 w-1 rounded-full bg-blue-600 animate-bounce [animation-delay:0.4s]"></div>
							</div>
						</div>
					{/if}
				</div>

				<!-- Inline Input -->
				<div class="p-4 border-t border-slate-800 bg-[#0d1117]">
					<div class="relative bg-[#161b22] border border-slate-800 rounded-xl overflow-hidden focus-within:border-slate-700 transition-all">
						<textarea
							bind:value={inputMessage}
							onkeydown={handleKeydown}
							placeholder="Message TailBot..."
							class="w-full bg-transparent px-4 py-3 text-[14px] font-medium text-slate-100 outline-none resize-none min-h-[44px] h-auto max-h-[150px] placeholder:text-slate-600"
							rows="1"
						></textarea>
						<div class="flex items-center justify-between px-3 pb-2 pt-0.5">
							<button 
								onclick={clearChat}
								class="p-1.5 text-slate-600 hover:text-red-500 transition-colors"
								title="Reset"
							>
								<Trash2 size={16} />
							</button>
							<button
								onclick={sendMessage}
								disabled={!inputMessage.trim() || isLoading}
								class="h-8 w-8 flex items-center justify-center rounded-lg bg-white text-black transition-all hover:bg-slate-200 disabled:opacity-20"
							>
								<Send size={16} fill="currentColor" />
							</button>
						</div>
					</div>
				</div>
			{/if}
		</div>
	{/if}

	<!-- ChatGPT/Grok Style Floating Launcher -->
	{#if !isOpen}
		<button
			transition:fade
			onclick={() => (isOpen = true)}
			class="group h-14 w-14 flex items-center justify-center rounded-full bg-[#0d1117] text-white shadow-[0_10px_30px_-5px_rgba(0,0,0,0.5)] transition-all duration-300 hover:scale-110 active:scale-95 border border-slate-800"
		>
			<div class="absolute inset-0 rounded-full bg-blue-600/10 animate-pulse"></div>
			<Bot size={26} strokeWidth={2} class="transition-transform group-hover:scale-110" />
			{#if unreadCount > 0}
				<div class="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-blue-600 text-[10px] font-black text-white border-2 border-[#0d1117] shadow-lg">
					{unreadCount}
				</div>
			{/if}
		</button>
	{/if}
</div>

<style>
	.markdown-minimal :global(p) { margin-bottom: 8px; }
	.markdown-minimal :global(p:last-child) { margin-bottom: 0; }
	.markdown-minimal :global(pre) {
		background: #161b22 !important;
		padding: 12px !important;
		border-radius: 8px !important;
		margin: 10px 0 !important;
		overflow-x: auto;
		border: 1px solid #30363d !important;
	}
	.markdown-minimal :global(code) {
		background: #1f2937;
		padding: 2px 4px;
		border-radius: 4px;
		color: #93c5fd;
	}
	.markdown-minimal :global(strong) { font-weight: 700; color: #fff; }
	.markdown-minimal :global(ul) { padding-left: 1.5rem; margin-bottom: 8px; list-style-type: disc; }

	/* Custom Scrollbar */
	.scrollbar-thin::-webkit-scrollbar { width: 4px; }
	.scrollbar-thin::-webkit-scrollbar-track { background: transparent; }
	.scrollbar-thin::-webkit-scrollbar-thumb { background: #30363d; border-radius: 10px; }
</style>
