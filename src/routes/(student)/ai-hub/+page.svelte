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
		Shield
	} from 'lucide-svelte';
	import { onMount, tick } from 'svelte';
	import { fly, fade, slide } from 'svelte/transition';
	import { cn } from '$lib/utils';

	let inputMessage = $state('');
	let isLoading = $state(false);
	let messages = $state<{ role: 'user' | 'assistant'; content: string; timestamp: Date }[]>([
		{
			role: 'assistant',
			content: 'Welcome to the AI Study Hub. How can I assist your learning journey today? I can help you with coding, explain complex topics, or even create a personalized study schedule.',
			timestamp: new Date()
		}
	]);

	let chatHistory = $state([
		{ id: 1, title: 'Quantum Physics Basics', date: 'Oct 24' },
		{ id: 2, title: 'React Hooks Explained', date: 'Oct 23' },
		{ id: 3, title: 'Study Schedule Nov', date: 'Oct 22' },
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
				content: 'System Error: Unable to communicate with the neural network. Please check your connection and try again.',
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

	// Auto-scroll on mount
	onMount(() => {
		scrollToBottom();
	});

	let sidebarOpen = $state(true);
</script>

<div class="h-screen w-full flex bg-[#0d1117] text-slate-200 overflow-hidden font-sans selection:bg-blue-500/30">
	<!-- Sidebar (History/Nav) -->
	<aside 
		class={cn(
			"flex flex-col border-r border-slate-800/50 bg-[#0d1117] transition-all duration-300 relative z-30",
			sidebarOpen ? "w-72" : "w-0 overflow-hidden"
		)}
	>
		<div class={"p-4 h-full flex flex-col w-72"}>
			<!-- New Chat Button -->
			<button 
				onclick={clearChat}
				class="flex items-center gap-3 w-full p-3 rounded-xl border border-slate-800 hover:bg-slate-800/50 transition-all font-bold text-sm mb-6 group"
			>
				<Plus size={18} class="text-blue-500 group-hover:rotate-90 transition-transform" />
				New Chat
			</button>

			<div class="flex-1 overflow-y-auto space-y-8 scrollbar-hide">
				<!-- Recent Activity -->
				<div>
					<h3 class="text-[10px] font-black uppercase tracking-widest text-slate-500 px-2 mb-4">Recent Sessions</h3>
					<div class="space-y-1">
						{#each chatHistory as history}
							<button class="flex items-center gap-3 w-full p-3 rounded-xl hover:bg-slate-800/40 text-left text-sm font-medium transition-all group">
								<MessageSquare size={16} class="text-slate-500 group-hover:text-blue-500" />
								<span class="flex-1 truncate">{history.title}</span>
								<span class="text-[10px] text-slate-600 font-bold opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">{history.date}</span>
							</button>
						{/each}
					</div>
				</div>

				<!-- Categories/Tags -->
				<div>
					<h3 class="text-[10px] font-black uppercase tracking-widest text-slate-500 px-2 mb-4">Saved Topics</h3>
					<div class="flex flex-wrap gap-2 px-2">
						{#each ['Mathematics', 'UI Design', 'Physics', 'Python'] as tag}
							<button class="px-3 py-1.5 rounded-lg bg-slate-800/30 border border-slate-800 text-[10px] font-bold hover:border-slate-700 transition-all">
								{tag}
							</button>
						{/each}
					</div>
				</div>
			</div>

			<!-- User Profile / Settings -->
			<div class="pt-4 border-t border-slate-800 mt-auto space-y-2">
				<button class="flex items-center gap-3 w-full p-3 rounded-xl hover:bg-slate-800/40 text-sm font-bold transition-all">
					<Settings size={18} class="text-slate-500" />
					Preferences
				</button>
				<div class="flex items-center gap-3 p-3 bg-slate-800/20 rounded-2xl border border-slate-800/50">
					<div class="h-8 w-8 rounded-full bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-[10px] font-black">GP</div>
					<div class="flex-1 min-w-0">
						<p class="text-xs font-bold truncate">Premium Member</p>
						<p class="text-[10px] text-slate-500 truncate">Garv G.</p>
					</div>
					<button class="p-1 hover:bg-white/10 rounded-lg transition-colors">
						<MoreVertical size={14} class="text-slate-500" />
					</button>
				</div>
			</div>
		</div>
	</aside>

	<!-- Main Chat Area -->
	<main class="flex-1 flex flex-col relative bg-[#131922] bg-[radial-gradient(45%_45%_at_50%_50%,rgba(59,130,246,0.03)_0%,transparent_100%)]">
		<!-- Header -->
		<header class="flex items-center justify-between p-4 bg-[#0d1117]/50 backdrop-blur-xl border-b border-white/5 sticky top-0 z-20">
			<div class="flex items-center gap-4">
				<button 
					onclick={() => sidebarOpen = !sidebarOpen}
					class="p-2 hover:bg-white/5 rounded-xl text-slate-400 transition-colors"
				>
					<Search size={20} />
				</button>
				<div class="flex items-center gap-3">
					<div class="h-10 w-10 flex items-center justify-center rounded-2xl bg-blue-600/10 border border-blue-500/20 text-blue-500">
						<Cpu size={20} />
					</div>
					<div>
						<h2 class="text-sm font-black tracking-tight leading-none">Flash-Chat v1.2</h2>
						<span class="text-[10px] font-bold text-green-500 uppercase tracking-widest mt-1 block">LongCat Neural Engine</span>
					</div>
				</div>
			</div>
			
			<div class="flex items-center gap-3">
				<div class="flex h-10 px-4 items-center gap-2 rounded-xl bg-slate-800/50 border border-slate-700/50 text-[10px] font-black uppercase tracking-widest text-slate-400">
					<Zap size={14} class="text-amber-500" />
					Energy: 100%
				</div>
				<button class="h-10 w-10 flex items-center justify-center rounded-xl bg-blue-600 text-white shadow-lg shadow-blue-500/20 hover:scale-105 active:scale-95 transition-all">
					<Shield size={20} />
				</button>
			</div>
		</header>

		<!-- Message List -->
		<div 
			bind:this={scrollContainer}
			class="flex-1 overflow-y-auto px-4 md:px-8 py-10 scrollbar-hide lg:max-w-4xl lg:mx-auto w-full"
		>
			<div class="flex flex-col gap-10">
				{#each messages as message, i}
					<div 
						class="flex gap-4 md:gap-8 group"
						in:fly={{ y: 20, duration: 400, delay: 100 }}
					>
						<div class={cn(
							"h-10 w-10 md:h-12 md:w-12 rounded-2xl flex items-center justify-center shrink-0 shadow-lg border-2",
							message.role === 'assistant' 
								? "bg-blue-600 border-blue-400/20 text-white" 
								: "bg-slate-800 border-slate-700 text-slate-300"
						)}>
							{#if message.role === 'assistant'}
								<Bot size={24} />
							{:else}
								<User size={24} />
							{/if}
						</div>
						
						<div class="flex-1 flex flex-col gap-4">
							<div class="flex items-center justify-between">
								<span class="text-xs font-black uppercase tracking-widest {message.role === 'assistant' ? 'text-blue-500' : 'text-slate-400'}">
									{message.role === 'assistant' ? 'AI Assistant' : 'Garv'}
								</span>
								<span class="text-[10px] font-bold text-slate-600 opacity-0 group-hover:opacity-100 transition-opacity">
									{message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
								</span>
							</div>
							
							<div class="text-slate-300 text-base md:text-lg leading-relaxed font-medium transition-all group-hover:text-white">
								{#if message.role === 'assistant'}
									<div class="prose prose-invert max-w-none prose-p:leading-relaxed prose-pre:bg-black/50 prose-pre:rounded-2xl prose-pre:border prose-pre:border-white/5">
										{message.content}
									</div>
								{:else}
									{message.content}
								{/if}
							</div>
						</div>
					</div>
				{/each}

				{#if isLoading}
					<div class="flex gap-8 px-4" in:fade>
						<div class="h-12 w-12 rounded-2xl bg-blue-600 animate-pulse flex items-center justify-center text-white">
							<Bot size={24} />
						</div>
						<div class="flex flex-col gap-4 pt-4">
							<div class="flex gap-2">
								<div class="h-5 w-32 bg-slate-800 rounded-full animate-pulse"></div>
							</div>
							<div class="space-y-3">
								<div class="h-4 w-[400px] bg-slate-800/50 rounded-full animate-pulse"></div>
								<div class="h-4 w-[350px] bg-slate-800/50 rounded-full animate-pulse [animation-delay:0.2s]"></div>
								<div class="h-4 w-[280px] bg-slate-800/50 rounded-full animate-pulse [animation-delay:0.4s]"></div>
							</div>
						</div>
					</div>
				{/if}
			</div>
		</div>

		<!-- Bottom Input -->
		<div class="p-4 md:p-8 bg-gradient-to-t from-[#131922] via-[#131922] to-transparent sticky bottom-0 z-20">
			<div class="max-w-4xl mx-auto relative group">
				<div class="absolute -inset-1 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-[32px] blur opacity-10 group-focus-within:opacity-20 transition duration-1000"></div>
				
				<div class="relative flex flex-col bg-[#0d1117] border border-white/5 rounded-[32px] shadow-2xl overflow-hidden focus-within:border-blue-500/30 transition-all">
					<textarea 
						bind:value={inputMessage}
						onkeydown={handleKeydown}
						placeholder="What are we learning today?"
						class="w-full bg-transparent px-8 pt-8 pb-4 text-slate-200 focus:outline-none resize-none min-h-[140px] text-lg font-medium placeholder:text-slate-600"
					></textarea>
					
					<div class="flex items-center justify-between px-6 pb-6 pt-2">
						<div class="flex items-center gap-2">
							<button class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 text-[10px] font-black uppercase text-slate-400 transition-all">
								<Sparkles size={12} class="text-blue-500" />
								Complex Task
							</button>
							<button class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 text-[10px] font-black uppercase text-slate-400 transition-all">
								<Clock size={12} class="text-indigo-500" />
								Schedule
							</button>
						</div>
						
						<div class="flex items-center gap-4">
							<button 
								onclick={clearChat}
								class="text-slate-500 hover:text-red-400 transition-colors"
								title="Reset"
							>
								<Trash2 size={20} />
							</button>
							<button 
								onclick={sendMessage}
								disabled={!inputMessage.trim() || isLoading}
								class="flex items-center gap-3 px-8 py-3 bg-blue-600 text-white font-black rounded-2xl shadow-xl shadow-blue-600/20 hover:scale-105 active:scale-95 disabled:opacity-30 disabled:hover:scale-100 transition-all"
							>
								Submit
								<ChevronRight size={18} />
							</button>
						</div>
					</div>
				</div>
				
				<p class="text-center mt-4 text-[10px] font-bold text-slate-600 uppercase tracking-widest">
					LongCat AI can make mistakes. Consider checking important information.
				</p>
			</div>
		</div>
	</main>
</div>

<style>
	:global(body) {
		background-color: #0d1117;
	}

	.scrollbar-hide::-webkit-scrollbar {
		display: none;
	}
	.scrollbar-hide {
		-ms-overflow-style: none;
		scrollbar-width: none;
	}
</style>
