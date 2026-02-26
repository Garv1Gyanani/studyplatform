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
		Clock,
		BrainCircuit
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
			content: 'Hello! I am **Programming Tails Bot**, your advanced AI learning partner. How can I assist your learning journey today?',
			timestamp: new Date()
		}
	]);

	let chatHistory = $state([
		{ id: 1, title: 'Python Data Structures', date: 'Just now' },
		{ id: 2, title: 'Understanding React State', date: '2h ago' },
		{ id: 3, title: 'SQL Joins Explained', date: 'Yesterday' },
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
				content: 'New session started. How can I help you today?',
				timestamp: new Date()
			}
		];
	}

	onMount(() => {
		scrollToBottom();
	});
</script>

<div class="h-[calc(100vh-64px)] w-full flex bg-white font-sans text-slate-900 overflow-hidden selection:bg-blue-100">
	<!-- White & Blue Professional Sidebar -->
	<aside 
		class={cn(
			"h-full bg-slate-50 border-r border-slate-200 transition-all duration-300 ease-in-out flex flex-col shrink-0 z-20",
			sidebarOpen ? "w-[300px]" : "w-0 overflow-hidden"
		)}
	>
		<div class="w-[300px] h-full flex flex-col p-6">
			<div class="flex items-center gap-3 mb-10 px-2">
				<div class="h-10 w-10 rounded-xl bg-blue-600 text-white flex items-center justify-center shadow-lg shadow-blue-500/20">
					<BrainCircuit size={20} strokeWidth={2.5} />
				</div>
				<div>
					<h3 class="text-xs font-black text-slate-900 uppercase tracking-widest leading-none mb-1">TailBot AI</h3>
					<span class="text-[9px] font-black text-blue-600 uppercase tracking-tighter">Premium Intelligence</span>
				</div>
			</div>

			<button 
				onclick={clearChat}
				class="w-full flex items-center justify-center gap-3 px-6 py-4 bg-white border-2 border-blue-600 text-blue-600 rounded-2xl hover:bg-blue-50 transition-all font-black text-sm shadow-sm mb-8"
			>
				<Plus size={18} />
				<span>New Session</span>
			</button>

			<div class="flex-1 overflow-y-auto space-y-8">
				<div>
					<h3 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4 px-2">Recent chats</h3>
					<div class="space-y-2">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl hover:bg-white transition-all text-left group border border-transparent hover:border-blue-100 hover:shadow-sm">
								<MessageSquare size={16} class="text-slate-400 group-hover:text-blue-600" />
								<span class="text-sm font-bold truncate flex-1 text-slate-600 group-hover:text-slate-900">{history.title}</span>
							</button>
						{/each}
					</div>
				</div>
			</div>

			<div class="pt-6 mt-auto border-t border-slate-200">
				<button class="w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl hover:bg-white transition-all text-sm font-black text-slate-500 hover:text-blue-600">
					<Settings size={20} />
					<span>User Preferences</span>
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Chat Area: Centered & Minimal but Light -->
	<main class="flex-1 flex flex-col h-full bg-white relative">
		<!-- Ultra-clean Header -->
		<header class="h-16 flex items-center justify-between px-6 border-b border-slate-100 bg-white/80 backdrop-blur-xl sticky top-0 z-10">
			<div class="flex items-center gap-4">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2.5 hover:bg-slate-50 rounded-xl transition-all text-slate-500 border border-slate-100 bg-white shadow-sm"
				>
					<Menu size={20} />
				</button>
				<div class="flex items-center gap-3">
					<h1 class="text-sm font-black tracking-tight text-slate-900">Programming Tails Bot</h1>
					<div class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-pulse"></div>
				</div>
			</div>
			
			<div class="flex items-center gap-4">
				<div class="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-full bg-blue-50 text-[10px] font-black text-blue-600 uppercase tracking-widest border border-blue-100">
					<Zap size={14} fill="currentColor" />
					Neural Engine v2
				</div>
			</div>
		</header>

		<!-- Messages Container -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto pt-10 pb-48 scroll-smooth"
		>
			<div class="max-w-[800px] mx-auto w-full px-6 space-y-12">
				{#each messages as message}
					<div class="group flex flex-col gap-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
						<div class="flex items-center gap-4">
							<div class={cn(
								"h-9 w-9 rounded-xl flex items-center justify-center shrink-0 border-2 shadow-sm font-black text-[10px]",
								message.role === 'assistant' 
									? "bg-blue-600 border-blue-500 text-white" 
									: "bg-white border-slate-200 text-slate-500"
							)}>
								{#if message.role === 'assistant'}
									<Bot size={20} strokeWidth={2.5} />
								{:else}
									<User size={20} strokeWidth={2.5} />
								{/if}
							</div>
							<div class="flex flex-col">
								<span class="text-[10px] font-black uppercase tracking-widest {message.role === 'assistant' ? 'text-blue-600' : 'text-slate-400'}">
									{message.role === 'assistant' ? 'TailBot AI' : 'Student'}
								</span>
								<span class="text-[9px] font-bold text-slate-300">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>
						</div>

						<div class="pl-13">
							<div class="markdown-pro text-[17px] leading-[1.7] text-slate-700 font-medium selection:bg-blue-200 antialiased">
								{#if message.role === 'assistant'}
									{@html marked(message.content)}
								{:else}
									<p class="whitespace-pre-wrap">{message.content}</p>
								{/if}
							</div>
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="flex flex-col gap-4 animate-pulse">
						<div class="flex items-center gap-4">
							<div class="h-9 w-9 rounded-xl bg-blue-100 border-2 border-blue-50"></div>
							<div class="h-2 w-24 bg-slate-100 rounded-full"></div>
						</div>
						<div class="pl-13 space-y-3">
							<div class="h-3 w-full bg-slate-50 rounded-full"></div>
							<div class="h-3 w-4/5 bg-slate-50 rounded-full"></div>
						</div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Footer Action Area -->
		<div class="absolute bottom-0 inset-x-0 p-6 md:p-10 bg-gradient-to-t from-white via-white/95 to-transparent pointer-events-none">
			<div class="max-w-[800px] mx-auto w-full pointer-events-auto">
				<div class="relative bg-white border-2 border-slate-200 rounded-[28px] shadow-2xl shadow-slate-200/50 transition-all focus-within:border-blue-600 focus-within:ring-8 focus-within:ring-blue-600/5 overflow-hidden">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we mastering today?"
						class="w-full bg-transparent px-8 py-6 text-basis font-bold text-slate-900 outline-none resize-none min-h-[76px] h-auto max-h-[300px] placeholder:text-slate-300"
						rows="1"
					></textarea>
					
					<div class="flex items-center justify-between px-6 pb-6">
						<div class="flex items-center gap-2">
							<button class="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-50 text-[10px] font-black uppercase text-slate-500 hover:bg-slate-100 transition-all border border-slate-100">
								<Paperclip size={14} class="text-blue-600" />
								<span>Attach</span>
							</button>
							<button 
								onclick={clearChat}
								class="p-2.5 text-slate-300 hover:text-red-500 transition-colors"
								title="Reset"
							>
								<Trash2 size={20} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-3 px-10 py-4 bg-blue-600 text-white text-xs font-black rounded-2xl hover:bg-blue-700 disabled:opacity-20 transition-all transform hover:scale-[1.02] active:scale-95 shadow-xl shadow-blue-500/20"
						>
							<span>Send command</span>
							<Send size={16} strokeWidth={3} />
						</button>
					</div>
				</div>
				<p class="text-center mt-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-4">
					Programming Tails • Neural Intelligence Core
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: white;
	}

	.pl-13 { padding-left: 52px; }

	.markdown-pro :global(h1),
	.markdown-pro :global(h2),
	.markdown-pro :global(h3) {
		font-weight: 900;
		color: #0f172a;
		margin-top: 32px;
		margin-bottom: 16px;
		letter-spacing: -0.02em;
	}
	.markdown-pro :global(h1) { font-size: 1.6rem; }
	.markdown-pro :global(h2) { font-size: 1.3rem; }
	.markdown-pro :global(h3) { font-size: 1.1rem; }
	
	.markdown-pro :global(p) { margin-bottom: 20px; }
	
	.markdown-pro :global(code) {
		background: #f1f5f9;
		padding: 3px 6px;
		border-radius: 6px;
		font-size: 0.9em;
		font-weight: 800;
		color: #2563eb;
	}
	
	.markdown-pro :global(pre) {
		background: #0f172a !important;
		color: #f8fafc !important;
		padding: 28px !important;
		border-radius: 20px !important;
		margin: 24px 0 !important;
		border: 1px solid #1e293b !important;
		overflow-x: auto;
		box-shadow: 0 15px 30px -10px rgba(0,0,0,0.1);
	}

	.markdown-pro :global(pre code) {
		background: transparent !important;
		padding: 0 !important;
		color: inherit !important;
		font-weight: 500;
	}

	.markdown-pro :global(ul) {
		list-style-type: disc;
		padding-left: 28px;
		margin-bottom: 20px;
	}

	.markdown-pro :global(li) {
		margin-bottom: 10px;
		font-weight: 600;
	}

	.markdown-pro :global(strong) {
		font-weight: 900;
		color: #2563eb;
	}

	/* Hidden but functional Scrollbar */
	::-webkit-scrollbar {
		width: 6px;
	}
	::-webkit-scrollbar-track {
		background: transparent;
	}
	::-webkit-scrollbar-thumb {
		background: #e2e8f0;
		border-radius: 10px;
	}
	::-webkit-scrollbar-thumb:hover {
		background: #cbd5e1;
	}

	@media (max-width: 640px) {
		.pl-13 { padding-left: 0; }
	}
</style>
