<script lang="ts">
	import { getAIChatCompletion } from '$lib/ai_service';
	import { 
		Send, 
		Bot, 
		User, 
		Trash2, 
		Sparkles, 
		ChevronRight, 
		Plus, 
		MessageSquare, 
		Settings,
		Search,
		History,
		Paperclip
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

<div class="h-[calc(100vh-64px)] w-full flex bg-white font-sans text-slate-900 border-t border-slate-100">
	<!-- Sidebar - History -->
	<aside 
		class={cn(
			"flex flex-col border-r border-slate-200 bg-slate-50 transition-all duration-300",
			sidebarOpen ? "w-64" : "w-0 overflow-hidden border-none"
		)}
	>
		<div class="flex flex-col h-full w-64">
			<div class="p-4">
				<button 
					onclick={clearChat}
					class="flex items-center gap-2 w-full p-2 rounded-lg border border-slate-200 hover:bg-slate-100 transition-all text-sm font-semibold"
				>
					<Plus size={16} />
					New Chat
				</button>
			</div>
			
			<div class="flex-1 overflow-y-auto p-4 space-y-4">
				<h3 class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Recent</h3>
				<div class="space-y-1">
					{#each chatHistory as history}
						<button class="flex items-center gap-2 w-full p-2 rounded-lg hover:bg-slate-200 transition-all text-left text-sm truncate">
							<MessageSquare size={14} class="shrink-0 text-slate-400" />
							<span class="truncate">{history.title}</span>
						</button>
					{/each}
				</div>
			</div>
		</div>
	</aside>

	<!-- Main Chat -->
	<main class="flex-1 flex flex-col relative overflow-hidden h-full">
		<!-- Minimal Header -->
		<header class="flex items-center justify-between px-6 py-3 border-b border-slate-100 bg-white/80 backdrop-blur-md sticky top-0 z-20">
			<div class="flex items-center gap-3">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2 transition-colors hover:bg-slate-100 rounded-lg text-slate-500"
				>
					<History size={18} />
				</button>
				<div class="h-4 w-px bg-slate-200"></div>
				<h2 class="text-sm font-bold tracking-tight">Programming Tails Bot</h2>
			</div>
			<div class="flex items-center gap-2">
				<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold bg-green-50 text-green-600 border border-green-100">
					<span class="h-1.5 w-1.5 rounded-full bg-green-500"></span>
					Ready
				</span>
			</div>
		</header>

		<!-- Messages Container -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto scrollbar-hide"
		>
			<div class="w-full">
				{#each messages as message}
					<div class={cn(
						"py-8 flex justify-center border-b border-slate-50 transition-colors",
						message.role === 'assistant' ? "bg-slate-50/50" : "bg-white"
					)}>
						<div class="w-full max-w-3xl px-6 flex gap-6">
							<div class={cn(
								"h-8 w-8 rounded-lg flex items-center justify-center shrink-0 border",
								message.role === 'assistant' ? "bg-blue-600 border-blue-500 text-white" : "bg-white border-slate-200 text-slate-600 shadow-sm"
							)}>
								{#if message.role === 'assistant'}
									<Bot size={18} />
								{:else}
									<User size={18} />
								{/if}
							</div>
							<div class="flex-1 space-y-2">
								<p class="text-[10px] font-bold uppercase tracking-widest text-slate-400">
									{message.role === 'assistant' ? 'TailBot' : 'You'}
								</p>
								<div class="prose prose-slate max-w-none text-slate-700 leading-relaxed font-medium">
									{#if message.role === 'assistant'}
										{@html marked(message.content)}
									{:else}
										<p class="whitespace-pre-wrap">{message.content}</p>
									{/if}
								</div>
							</div>
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="py-12 flex justify-center bg-slate-50/50 border-b border-slate-50">
						<div class="w-full max-w-3xl px-6 flex gap-6">
							<div class="h-8 w-8 rounded-lg bg-blue-600 flex items-center justify-center text-white animate-pulse">
								<Bot size={18} />
							</div>
							<div class="flex-1 space-y-4 pt-2">
								<div class="h-2 w-24 bg-slate-200 rounded-full animate-pulse"></div>
								<div class="space-y-2">
									<div class="h-2 w-full bg-slate-100 rounded-full animate-pulse"></div>
									<div class="h-2 w-3/4 bg-slate-100 rounded-full animate-pulse"></div>
								</div>
							</div>
						</div>
					</div>
				{/if}
			</div>
			<!-- Bottom padding for input -->
			<div class="h-32"></div>
		</div>

		<!-- Bottom Input Area -->
		<div class="absolute bottom-0 inset-x-0 bg-gradient-to-t from-white via-white/95 to-transparent pb-8 pt-4 px-6 flex justify-center">
			<div class="w-full max-w-3xl relative group">
				<div class="relative flex flex-col bg-white border border-slate-200 rounded-2xl shadow-[0_10px_40px_-15px_rgba(0,0,0,0.1)] focus-within:border-blue-500/50 focus-within:ring-4 focus-within:ring-blue-500/5 transition-all">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="Send a message..."
						class="w-full bg-transparent px-5 py-4 text-slate-800 outline-none resize-none min-h-[56px] h-[56px] text-sm font-medium placeholder:text-slate-400"
					></textarea>
					
					<div class="flex items-center justify-between px-3 pb-3">
						<div class="flex items-center gap-1">
							<button class="p-2 text-slate-400 hover:text-slate-600 transition-colors rounded-lg">
								<Paperclip size={16} />
							</button>
							<button class="p-2 text-slate-400 hover:text-slate-600 transition-colors rounded-lg" onclick={clearChat}>
								<Trash2 size={16} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-2 px-4 py-2 bg-slate-900 text-white text-xs font-bold rounded-xl hover:bg-black disabled:opacity-30 disabled:hover:bg-slate-900 transition-all shadow-lg shadow-slate-200"
						>
							Send
							<Send size={14} />
						</button>
					</div>
				</div>
				<p class="text-center mt-3 text-[10px] font-medium text-slate-400 tracking-tight">
					TailBot can make mistakes. Always check crucial information.
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	/* Standard typography improvements */
	:global(.prose) {
		font-size: 0.9375rem;
	}
	:global(.prose p) {
		margin-bottom: 1.25em;
	}
	:global(.prose p:last-child) {
		margin-bottom: 0;
	}
	:global(.prose pre) {
		background: #0f172a !important;
		padding: 1.5rem !important;
		border-radius: 12px !important;
		border: 1px solid rgba(255,255,255,0.1) !important;
	}

	.scrollbar-hide::-webkit-scrollbar {
		display: none;
	}
	.scrollbar-hide {
		-ms-overflow-style: none;
		scrollbar-width: none;
	}
</style>
