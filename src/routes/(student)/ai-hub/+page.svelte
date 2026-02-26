<script lang="ts">
	import { getAIChatCompletion } from '$lib/ai_service';
	import { 
		Send, 
		Bot, 
		User, 
		Trash2, 
		Sparkles, 
		ChevronRight, 
		Clock, 
		Plus, 
		MessageSquare, 
		Settings,
		MoreVertical,
		Search,
		Cpu,
		Zap,
		Shield,
		Layout,
		History
	} from 'lucide-svelte';
	import { onMount, tick } from 'svelte';
	import { fly, fade, slide } from 'svelte/transition';
	import { cn } from '$lib/utils';

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

<div class="h-[calc(100vh-64px)] w-full flex bg-slate-50 font-sans selection:bg-blue-100 selection:text-blue-900">
	<!-- Sidebar (History/Nav) - Closed by default -->
	<aside 
		class={cn(
			"flex flex-col border-r border-slate-200 bg-white transition-all duration-300 relative z-30 shadow-sm",
			sidebarOpen ? "w-80" : "w-0 overflow-hidden border-none"
		)}
	>
		<div class="p-6 h-full flex flex-col w-80">
			<!-- New Chat Button -->
			<button 
				onclick={clearChat}
				class="flex items-center gap-3 w-full p-4 rounded-2xl bg-blue-600 text-white hover:bg-blue-700 transition-all font-black text-sm mb-8 shadow-lg shadow-blue-100 group"
			>
				<Plus size={18} class="group-hover:rotate-90 transition-transform" />
				New Study Session
			</button>

			<div class="flex-1 overflow-y-auto space-y-8 scrollbar-hide">
				<div>
					<h3 class="text-[10px] font-black uppercase tracking-widest text-slate-400 px-2 mb-4">Recent Activity</h3>
					<div class="space-y-1">
						{#each chatHistory as history}
							<button class="flex items-center gap-3 w-full p-4 rounded-2xl hover:bg-slate-50 text-left text-sm font-bold border border-transparent hover:border-slate-100 transition-all group">
								<MessageSquare size={16} class="text-slate-400 group-hover:text-blue-600" />
								<span class="flex-1 truncate text-slate-700">{history.title}</span>
								<span class="text-[10px] text-slate-400 font-bold opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">{history.date}</span>
							</button>
						{/each}
					</div>
				</div>

				<div>
					<h3 class="text-[10px] font-black uppercase tracking-widest text-slate-400 px-2 mb-4">Focus Areas</h3>
					<div class="flex flex-wrap gap-2 px-2">
						{#each ['Mathematics', 'UI Design', 'Physics', 'Python'] as tag}
							<button class="px-4 py-2 rounded-xl bg-slate-100 border border-slate-200 text-[10px] font-black uppercase text-slate-600 hover:bg-white hover:border-blue-600 hover:text-blue-600 transition-all">
								{tag}
							</button>
						{/each}
					</div>
				</div>
			</div>

			<!-- User Profile / Settings -->
			<div class="pt-6 border-t border-slate-100 mt-auto">
				<button class="flex items-center gap-3 w-full p-4 rounded-2xl hover:bg-slate-50 text-sm font-black text-slate-600 transition-all border border-transparent hover:border-slate-100">
					<Settings size={18} />
					Settings
				</button>
			</div>
		</div>
	</aside>

	<!-- Main Chat Area -->
	<main class="flex-1 flex flex-col relative bg-slate-50 overflow-hidden">
		<!-- Header / Panel Toolbar -->
		<header class="h-16 flex items-center justify-between px-6 bg-white border-b border-slate-200 sticky top-0 z-20">
			<div class="flex items-center gap-4">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class={cn(
						"p-2 rounded-xl transition-all",
						sidebarOpen ? "bg-blue-50 text-blue-600" : "hover:bg-slate-100 text-slate-400"
					)}
					title="History"
				>
					<History size={20} />
				</button>
				<div class="h-6 w-px bg-slate-200"></div>
				<div class="flex items-center gap-3">
					<div class="h-10 w-10 flex items-center justify-center rounded-xl bg-blue-50 text-blue-600 font-black border border-blue-100 shadow-sm">
						<Sparkles size={18} />
					</div>
					<div>
						<h2 class="text-sm font-black tracking-tight leading-none text-slate-900">Programming Tails Bot</h2>
						<span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1 block">Powered by LongCat-Flash</span>
					</div>
				</div>
			</div>
			
			<div class="flex items-center gap-3">
				<div class="flex h-10 px-4 items-center gap-2 rounded-xl border border-slate-200 bg-white text-[10px] font-black whitespace-nowrap uppercase tracking-widest text-slate-500 shadow-sm">
					<div class="h-2 w-2 rounded-full bg-green-500 animate-pulse"></div>
					Neural Engine v1.2
				</div>
			</div>
		</header>

		<!-- Message List - Panel Structure -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto px-6 py-8 md:px-12 scrollbar-thin lg:max-w-5xl lg:mx-auto w-full"
		>
			<div class="flex flex-col gap-6">
				{#each messages as message, i}
					<div 
						class={cn(
							"flex flex-col p-8 rounded-[32px] border transition-all duration-300",
							message.role === 'assistant' 
								? "bg-white border-slate-200 shadow-sm" 
								: "bg-blue-50/50 border-blue-100 shadow-sm"
						)}
						in:fly={{ y: 20, duration: 400 }}
					>
						<div class="flex items-center justify-between mb-6">
							<div class="flex items-center gap-3">
								<div class={cn(
									"h-10 w-10 rounded-xl flex items-center justify-center font-black shadow-sm border",
									message.role === 'assistant' 
										? "bg-blue-600 border-blue-400 text-white" 
										: "bg-white border-slate-200 text-slate-600"
								)}>
									{#if message.role === 'assistant'}
										<Bot size={20} />
									{:else}
										<User size={20} />
									{/if}
								</div>
								<div class="flex flex-col">
									<span class="text-[10px] font-black uppercase tracking-widest {message.role === 'assistant' ? 'text-blue-600' : 'text-slate-500'}">
										{message.role === 'assistant' ? 'TailBot' : 'Student'}
									</span>
									<span class="text-xs font-bold text-slate-400">
										{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
									</span>
								</div>
							</div>
						</div>
						
						<div class="text-slate-700 text-basis md:text-lg leading-relaxed font-medium">
							{#if message.role === 'assistant'}
								<div class="prose prose-slate max-w-none prose-p:leading-relaxed prose-strong:font-black prose-pre:bg-slate-900 prose-pre:rounded-2xl prose-pre:p-6 prose-pre:border prose-pre:border-white/10">
									{message.content}
								</div>
							{:else}
								{message.content}
							{/if}
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="p-8 rounded-[32px] bg-white border border-slate-200 shadow-sm animate-pulse flex items-center gap-4">
						<div class="h-10 w-10 rounded-xl bg-slate-100"></div>
						<div class="flex-1 space-y-3">
							<div class="h-3 w-1/4 bg-slate-100 rounded-full"></div>
							<div class="h-3 w-full bg-slate-50 rounded-full"></div>
						</div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Bottom Input - Modern Panel Structure -->
		<div class="p-6 md:p-10 bg-gradient-to-t from-slate-50 via-slate-50/95 to-transparent sticky bottom-0 z-20">
			<div class="max-w-4xl mx-auto">
				<div class="relative flex flex-col bg-white border border-slate-200 rounded-[32px] shadow-2xl overflow-hidden focus-within:border-blue-600 focus-within:ring-4 focus-within:ring-blue-500/5 transition-all">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we focusing on today?"
						class="w-full bg-transparent px-8 pt-8 pb-4 text-slate-900 outline-none resize-none min-h-[120px] text-lg font-bold placeholder:text-slate-300"
					></textarea>
					
					<div class="flex flex-col sm:flex-row items-center justify-between px-6 pb-6 pt-2 gap-4">
						<div class="flex items-center gap-2">
							<button class="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 text-[10px] font-black uppercase text-slate-500 transition-all border border-slate-100">
								<Layout size={12} class="text-blue-600" />
								Summarize Page
							</button>
							<button class="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-50 hover:bg-slate-100 text-[10px] font-black uppercase text-slate-500 transition-all border border-slate-100">
								<Zap size={12} class="text-amber-500" />
								Quick Lesson
							</button>
						</div>
						
						<div class="flex items-center gap-3 w-full sm:w-auto">
							<button 
								onclick={clearChat}
								class="p-4 text-slate-300 hover:text-red-500 transition-colors"
								title="Reset Session"
							>
								<Trash2 size={20} />
							</button>
							<button 
								onclick={sendMessage}
								disabled={!inputMessage.trim() || isLoading}
								class="flex-1 sm:flex-none flex items-center justify-center gap-3 px-10 py-4 bg-slate-900 text-white font-black rounded-2xl shadow-xl shadow-slate-200 hover:bg-black hover:scale-105 active:scale-95 disabled:opacity-30 disabled:hover:scale-100 transition-all"
							>
								Send Command
								<ChevronRight size={18} />
							</button>
						</div>
					</div>
				</div>
				<p class="text-center mt-6 text-[10px] font-black text-slate-400 uppercase tracking-widest">
					Neural Hub • Secure Learning Environment
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: #f8fafc;
	}

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
</style>
