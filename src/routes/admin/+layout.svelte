<script lang="ts">
	import { 
		LayoutDashboard, 
		Video, 
		FileQuestion, 
		BookOpen, 
		StickyNote, 
		Newspaper, 
		Gamepad2, 
		Users, 
		Trophy,
		ExternalLink,
		Settings,
		Search,
		Bell,
		GraduationCap,
		Library,
		ChevronRight
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { page } from '$app/state';

	let { children } = $props();

	const menuSections = [
		{
			label: 'Overview',
			items: [
				{ name: 'Dashboard', icon: LayoutDashboard, href: '/admin' },
			]
		},
		{
			label: 'Content',
			items: [
				{ name: 'Videos', icon: Video, href: '/admin/videos' },
				{ name: 'Categories', icon: LayoutDashboard, href: '/admin/categories' },
				{ name: 'Blogs', icon: BookOpen, href: '/admin/blogs' },
				{ name: 'Notes', icon: StickyNote, href: '/admin/notes' },
				{ name: 'Books', icon: Library, href: '/admin/books' },
				{ name: 'News', icon: Newspaper, href: '/admin/news' },
			]
		},
		{
			label: 'Assessments',
			items: [
				{ name: 'Quizzes', icon: FileQuestion, href: '/admin/quizzes' },
				{ name: 'Tests', icon: GraduationCap, href: '/admin/tests' },
			]
		},
		{
			label: 'Community',
			items: [
				{ name: 'Users', icon: Users, href: '/admin/users' },
				{ name: 'Leaderboard', icon: Trophy, href: '/admin/leaderboard' },
			]
		}
	];
</script>

<div class="flex min-h-screen bg-slate-50">
	<!-- Sidebar -->
	<aside class="fixed inset-y-0 left-0 z-40 w-72 border-r border-slate-100 bg-white flex flex-col">
		<!-- Logo -->
		<div class="flex h-20 items-center border-b border-slate-100 px-8">
			<a href="/admin" class="flex items-center gap-3 group">
				<div class="flex h-10 w-10 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-200 group-hover:scale-110 transition-transform">
					<span class="text-lg font-black">E</span>
				</div>
				<div>
					<span class="text-lg font-black text-slate-900 tracking-tight">EduAdmin</span>
					<p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest -mt-0.5">Control Panel</p>
				</div>
			</a>
		</div>

		<!-- Navigation -->
		<nav class="flex-1 overflow-y-auto px-4 py-6 space-y-8">
			{#each menuSections as section}
				<div class="space-y-2">
					<p class="px-4 text-[10px] font-black uppercase tracking-[0.2em] text-slate-300">{section.label}</p>
					{#each section.items as item}
						{@const isActive = page.url.pathname === item.href}
						<a
							href={item.href}
							class={cn(
								"flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold transition-all",
								isActive 
									? "bg-blue-600 text-white shadow-lg shadow-blue-200" 
									: "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
							)}
						>
							<item.icon size={18} class={cn(isActive ? "text-white" : "text-slate-400")} />
							{item.name}
							{#if isActive}
								<ChevronRight size={16} class="ml-auto text-white/60" />
							{/if}
						</a>
					{/each}
				</div>
			{/each}
		</nav>

		<!-- Bottom -->
		<div class="border-t border-slate-100 p-4 space-y-2">
			<a href="/" target="_blank" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-bold text-slate-500 hover:bg-slate-50 hover:text-slate-900 transition-all">
				<ExternalLink size={18} class="text-slate-400" />
				View Public Site
			</a>
		</div>
	</aside>

	<!-- Main Content -->
	<div class="ml-72 flex-1">
		<!-- Header -->
		<header class="sticky top-0 z-30 flex h-20 items-center justify-between border-b border-slate-100 bg-white/80 backdrop-blur-md px-10">
			<div class="flex w-96 items-center gap-3 rounded-2xl bg-slate-50 px-5 py-3 border border-slate-100">
				<Search size={18} class="text-slate-300" />
				<input type="text" placeholder="Search content, users, or settings..." class="bg-transparent text-sm font-bold outline-none w-full placeholder-slate-300" />
			</div>

			<div class="flex items-center gap-4">
				<button title="Notifications" class="group relative rounded-2xl p-3 text-slate-400 hover:bg-slate-50 hover:text-slate-900 transition-all">
					<Bell size={20} />
					<span class="absolute right-2.5 top-2.5 h-2 w-2 rounded-full bg-blue-600 ring-2 ring-white"></span>
					<!-- Tooltip -->
					<div class="absolute top-14 right-0 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 p-4 opacity-0 group-hover:opacity-100 pointer-events-none transition-all translate-y-2 group-hover:translate-y-0 z-50">
						<p class="text-xs font-black text-slate-900 uppercase tracking-widest mb-2">Recent Alerts</p>
						<div class="space-y-3">
							<p class="text-[10px] font-bold text-slate-500 italic">No new notifications. Alerts for system events will appear here.</p>
						</div>
					</div>
				</button>
				<div class="h-10 w-px bg-slate-100"></div>
				<a href="/settings" class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-900 text-white shadow-xl shadow-slate-200 hover:bg-black transition-all">
					<Settings size={18} />
				</a>
			</div>
		</header>

		<main class="p-10">
			{@render children()}
		</main>
	</div>
</div>
