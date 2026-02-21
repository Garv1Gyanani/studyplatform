<script lang="ts">
	import { 
		LayoutDashboard, 
		Video, 
		FileQuestion, 
		BookOpen, 
		NotebookIcon, 
		Newspaper, 
		Gamepad2, 
		Users, 
		Trophy,
		ExternalLink,
		Settings,
		Search,
		Bell
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { page } from '$app/state';

	let { children } = $props();

	const menuItems = [
		{ name: 'Dashboard', icon: LayoutDashboard, href: '/admin' },
		{ name: 'Videos', icon: Video, href: '/admin/videos' },
		{ name: 'Quizzes', icon: FileQuestion, href: '/admin/quizzes' },
		{ name: 'Tests', icon: GraduationCap, href: '/admin/tests' }, // Added GraduationCap manually if needed, or stick to imported
		{ name: 'Blogs', icon: BookOpen, href: '/admin/blogs' },
		{ name: 'Books', icon: NotebookIcon, href: '/admin/books' },
		{ name: 'Notes', icon: notebookText, href: '/admin/notes' }, // Fixing icon names below
		{ name: 'News', icon: Newspaper, href: '/admin/news' },
		{ name: 'Games', icon: Gamepad2, href: '/admin/games' },
		{ name: 'Users', icon: Users, href: '/admin/users' },
		{ name: 'Leaderboard', icon: Trophy, href: '/admin/leaderboard' },
	];

    // Correcting imports for icons I missed or renamed
</script>

<script lang="ts" context="module">
    import { GraduationCap, NotebookPen as notebookText } from 'lucide-svelte';
</script>

<div class="flex min-h-screen bg-slate-50">
	<!-- Sidebar -->
	<aside class="fixed inset-y-0 left-0 w-64 border-r border-slate-200 bg-white">
		<div class="flex h-16 items-center border-b border-slate-200 px-6">
			<a href="/" class="flex items-center gap-2">
				<div class="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600 text-white">
					<span class="font-bold">E</span>
				</div>
				<span class="font-bold text-slate-900">EduAdmin</span>
			</a>
		</div>

		<nav class="flex flex-col gap-1 p-4">
			{#each menuItems as item}
				{@const isActive = page.url.pathname === item.href}
				<a
					href={item.href}
					class={cn(
						"flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
						isActive 
							? "bg-blue-50 text-blue-600 shadow-sm ring-1 ring-blue-100" 
							: "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
					)}
				>
					<item.icon size={18} class={cn(isActive ? "text-blue-600" : "text-slate-400")} />
					{item.name}
				</a>
			{/each}
		</nav>

		<div class="absolute bottom-0 w-full border-t border-slate-200 p-4">
			<a href="/" target="_blank" class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50">
				<ExternalLink size={18} class="text-slate-400" />
				View Website
			</a>
		</div>
	</aside>

	<!-- Main Content -->
	<div class="ml-64 flex-1">
		<!-- Header -->
		<header class="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-slate-200 bg-white px-8">
			<div class="flex w-96 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
				<Search size={18} class="text-slate-400" />
				<input type="text" placeholder="Search content..." class="bg-transparent text-sm outline-none w-full" />
			</div>

			<div class="flex items-center gap-4">
				<button class="rounded-full p-2 text-slate-500 hover:bg-slate-100">
					<Bell size={20} />
				</button>
				<button class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-900 text-white shadow-lg">
					<Settings size={20} />
				</button>
			</div>
		</header>

		<main class="p-8">
			{@render children()}
		</main>
	</div>
</div>
