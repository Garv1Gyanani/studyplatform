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
			content: 'Hello! I am **Programming Tails Bot**, your AI partner. How can I assist your learning journey today?',
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
	<!-- High-End White & Blue Sidebar -->
	<aside 
		class={cn(
			"h-full bg-white border-r border-slate-100 transition-all duration-500 ease-in-out flex flex-col shrink-0 z-20",
			sidebarOpen ? "w-[320px]" : "w-0 overflow-hidden"
		)}
	>
		<div class="w-[320px] h-full flex flex-col p-8">
			<div class="flex items-center gap-4 mb-12 px-2">
				<div class="h-12 w-12 rounded-2xl bg-blue-600 text-white flex items-center justify-center shadow-2xl shadow-blue-500/20">
					<BrainCircuit size={24} strokeWidth={2.5} />
				</div>
				<div>
					<h3 class="text-basis font-black text-slate-900 uppercase tracking-tighter leading-none mb-1.5">TailBot AI</h3>
					<div class="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-blue-50 text-[9px] font-black text-blue-600 uppercase tracking-widest border border-blue-100">
						<span class="h-1 w-1 rounded-full bg-blue-600"></span>
						Pro Intelligence
					</div>
				</div>
			</div>

			<button 
				onclick={clearChat}
				class="w-full flex items-center justify-center gap-3 px-6 py-5 bg-blue-600 text-white rounded-[24px] hover:bg-blue-700 transition-all font-black text-[15px] shadow-2xl shadow-blue-500/20 mb-10 group active:scale-95"
			>
				<Plus size={20} />
				<span>Start New Session</span>
			</button>

			<div class="flex-1 overflow-y-auto space-y-10 pr-2">
				<div>
					<h3 class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-6 px-4">Recent Conversations</h3>
					<div class="space-y-3">
						{#each chatHistory as history}
							<button class="w-full flex items-center gap-4 px-5 py-4 rounded-[24px] bg-white transition-all text-left group hover:bg-blue-50/50 border border-transparent hover:border-blue-100/50">
								<div class="h-10 w-10 rounded-xl bg-slate-50 flex items-center justify-center text-slate-400 group-hover:bg-white group-hover:text-blue-600 transition-all">
									<MessageSquare size={18} />
								</div>
								<div class="flex-1 min-w-0">
									<p class="text-[14px] font-black truncate text-slate-600 group-hover:text-slate-900">{history.title}</p>
									<p class="text-[10px] font-bold text-slate-300 uppercase tracking-widest mt-0.5">{history.date}</p>
								</div>
							</button>
						{/each}
					</div>
				</div>
			</div>

			<div class="pt-8 mt-auto border-t border-slate-50">
				<button class="w-full flex items-center justify-between px-6 py-4 rounded-[24px] bg-slate-50 hover:bg-slate-100 transition-all group">
					<div class="flex items-center gap-4">
						<div class="h-10 w-10 rounded-xl bg-white flex items-center justify-center text-slate-400 group-hover:text-blue-600 shadow-sm transition-all">
							<Settings size={20} />
						</div>
						<span class="text-sm font-black text-slate-500 group-hover:text-slate-900">Preferences</span>
					</div>
					<ChevronDown size={14} class="text-slate-300" />
				</button>
			</div>
		</div>
	</aside>

	<!-- Centered Main Content -->
	<main class="flex-1 flex flex-col h-full bg-white relative">
		<!-- Header -->
		<header class="h-20 flex items-center justify-between px-8 bg-white/80 backdrop-blur-2xl sticky top-0 z-10">
			<div class="flex items-center gap-6">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-3 hover:bg-slate-50 rounded-2xl transition-all text-slate-400 border border-slate-100 bg-white shadow-sm hover:text-blue-600 hover:border-blue-100"
				>
					<Menu size={22} />
				</button>
				<div class="flex flex-col">
					<h1 class="text-basis font-black tracking-tight text-slate-900 leading-none mb-1 flex items-center gap-2">
						Programming Tails Bot
					</h1>
					<span class="text-[10px] font-black text-slate-300 uppercase tracking-widest leading-none">Powered by Neural Engine 4o</span>
				</div>
			</div>
			
			<div class="flex items-center gap-4">
				<button class="flex items-center gap-3 px-6 py-2.5 rounded-full bg-slate-100 text-[10px] font-black text-slate-600 uppercase tracking-widest transition-all hover:bg-blue-600 hover:text-white group">
					<Search size={14} class="text-slate-400 group-hover:text-white" />
					Find Message
				</button>
			</div>
		</header>

		<!-- Messages Container -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto scroll-smooth pb-0"
		>
			<div class="max-w-[860px] mx-auto w-full px-8 pt-12">
				<div class="space-y-16">
					{#each messages as message}
						<div class="group flex flex-col gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
							<div class="flex items-center gap-4">
								<div class={cn(
									"h-10 w-10 rounded-[14px] flex items-center justify-center shrink-0 border-2 shadow-2xl font-black text-[12px]",
									message.role === 'assistant' 
										? "bg-blue-600 border-blue-500 text-white shadow-blue-500/10" 
										: "bg-white border-slate-100 text-slate-400 shadow-slate-100"
								)}>
									{#if message.role === 'assistant'}
										<Bot size={22} strokeWidth={2.5} />
									{:else}
										<User size={22} strokeWidth={2.5} />
									{/if}
								</div>
								<div class="flex flex-col">
									<span class="text-[11px] font-black uppercase tracking-widest {message.role === 'assistant' ? 'text-blue-600' : 'text-slate-500'}">
										{message.role === 'assistant' ? 'TailBot — System' : 'Verified Student'}
									</span>
									<span class="text-[10px] font-bold text-slate-300">
										{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
									</span>
								</div>
							</div>

							<div class="pl-0 md:pl-14">
								<div class="markdown-pro text-[18px] leading-[1.8] text-slate-800 font-medium selection:bg-blue-200 antialiased">
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
						<div class="flex flex-col gap-6 animate-pulse px-2">
							<div class="flex items-center gap-4">
								<div class="h-10 w-10 rounded-[14px] bg-slate-50 border-2 border-slate-50"></div>
								<div class="h-2 w-32 bg-slate-50 rounded-full"></div>
							</div>
							<div class="pl-14 space-y-4">
								<div class="h-4 w-full bg-slate-50/50 rounded-full"></div>
								<div class="h-4 w-4/5 bg-slate-50/50 rounded-full"></div>
							</div>
						</div>
					{/if}
					
					<!-- Fixed Padding Spacer -->
					<div class="h-[400px]"></div>
				</div>
			</div>
		</div>

		<!-- Premium Fixed Input -->
		<div class="absolute bottom-0 inset-x-0 p-8 md:p-12 bg-gradient-to-t from-white via-white/100 to-transparent pointer-events-none">
			<div class="max-w-[860px] mx-auto w-full pointer-events-auto">
				<div class="relative bg-white border-[3px] border-slate-100 rounded-[40px] shadow-[0_-20px_100px_-20px_rgba(37,99,235,0.05)] shadow-[0_40px_100px_-20px_rgba(0,0,0,0.1)] transition-all focus-within:border-blue-600 focus-within:ring-[15px] focus-within:ring-blue-600/5 group overflow-hidden">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we mastering today?"
						class="w-full bg-transparent px-10 py-8 text-lg font-black text-slate-900 outline-none resize-none min-h-[96px] h-auto max-h-[300px] placeholder:text-slate-300"
						rows="1"
					></textarea>
					
					<div class="flex items-center justify-between px-10 pb-8 pt-2">
						<div class="flex items-center gap-3">
							<button class="flex items-center gap-3 px-6 py-3 rounded-2xl bg-slate-50 text-[11px] font-black uppercase text-slate-500 hover:bg-slate-100 transition-all border border-slate-100 group/btn shadow-sm">
								<Paperclip size={16} class="text-blue-600 transition-transform group-hover/btn:rotate-[-45deg]" />
								<span>Attach</span>
							</button>
							<button 
								onclick={clearChat}
								class="p-3 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-2xl transition-all"
								title="Reset Session"
							>
								<Trash2 size={22} />
							</button>
						</div>
						
						<button 
							onclick={sendMessage}
							disabled={!inputMessage.trim() || isLoading}
							class="flex items-center gap-4 px-12 py-5 bg-blue-600 text-white text-sm font-black rounded-3xl hover:bg-blue-700 disabled:opacity-20 transition-all transform hover:scale-[1.02] active:scale-95 shadow-2xl shadow-blue-500/20"
						>
							<span>Run Command</span>
							<Send size={20} strokeWidth={3} />
						</button>
					</div>
				</div>
				<p class="text-center mt-6 text-[10px] font-black text-slate-300 uppercase tracking-[0.3em]">
					Programming Tails • Neural Intelligence Core • Secure Environment
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: white !important;
	}

	.markdown-pro :global(h1),
	.markdown-pro :global(h2),
	.markdown-pro :global(h3) {
		font-weight: 900;
		color: #0f172a;
		margin-top: 48px;
		margin-bottom: 20px;
		letter-spacing: -0.04em;
	}
	.markdown-pro :global(h1) { font-size: 2rem; }
	.markdown-pro :global(h2) { font-size: 1.6rem; }
	.markdown-pro :global(h3) { font-size: 1.3rem; }
	
	.markdown-pro :global(p) { margin-bottom: 24px; }
	
	.markdown-pro :global(code) {
		background: #f8fafc;
		padding: 4px 8px;
		border-radius: 8px;
		font-size: 0.9em;
		font-weight: 900;
		color: #2563eb;
		border: 1px solid #f1f5f9;
	}
	
	.markdown-pro :global(pre) {
		background: #0f172a !important;
		color: #f8fafc !important;
		padding: 40px !important;
		border-radius: 32px !important;
		margin: 32px 0 !important;
		border: 1px solid #1e293b !important;
		overflow-x: auto;
		box-shadow: 0 40px 100px -20px rgba(0,0,0,0.2);
	}

	.markdown-pro :global(pre code) {
		background: transparent !important;
		padding: 0 !important;
		color: inherit !important;
		font-weight: 500;
		border: none;
	}

	.markdown-pro :global(ul) {
		list-style-type: disc;
		padding-left: 32px;
		margin-bottom: 24px;
	}

	.markdown-pro :global(li) {
		margin-bottom: 12px;
		font-weight: 700;
		color: #1e293b;
	}

	.markdown-pro :global(strong) {
		font-weight: 900;
		color: #000;
		background: linear-gradient(120deg, rgba(37,99,235,0.1) 0%, rgba(37,99,235,0.1) 100%);
		background-repeat: no-repeat;
		background-size: 100% 0.3em;
		background-position: 0 80%;
	}

	::-webkit-scrollbar {
		width: 8px;
	}
	::-webkit-scrollbar-track {
		background: transparent;
	}
	::-webkit-scrollbar-thumb {
		background: #f1f5f9;
		border-radius: 10px;
	}
	::-webkit-scrollbar-thumb:hover {
		background: #e2e8f0;
	}

	@media (max-width: 640px) {
		.pl-14 { padding-left: 0; }
	}
</style>
