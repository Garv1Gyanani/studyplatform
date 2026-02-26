<script lang="ts">
	const currentYear = new Date().getFullYear();
</script>

<footer class="border-t border-slate-200 bg-white py-12">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="grid grid-cols-2 gap-8 md:grid-cols-4 lg:grid-cols-5">
			<div class="col-span-2 lg:col-span-2">
				<a href="/" class="flex items-center gap-2">
					<div class="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 text-white shadow-lg">
						<span class="text-xl font-bold">P</span>
					</div>
					<span class="text-xl font-bold tracking-tight text-slate-900">Programming<span class="text-blue-600">Tails</span></span>
				</a>
				<p class="mt-4 max-w-xs text-sm leading-relaxed text-slate-500">
					The ultimate learning companion for students and admins. Gamified, fast, and feature-rich.
				</p>
			</div>
			<div>
				<h3 class="text-xs font-bold uppercase tracking-wider text-slate-400">Platform</h3>
				<ul class="mt-4 space-y-2">
					<li><a href="/courses" class="text-sm text-slate-600 hover:text-blue-600">Courses</a></li>
					<li><a href="/quizzes" class="text-sm text-slate-600 hover:text-blue-600">Quizzes</a></li>
					<li><a href="/leaderboard" class="text-sm text-slate-600 hover:text-blue-600">Leaderboard</a></li>
					<li><a href="/games" class="text-sm text-slate-600 hover:text-blue-600">Games</a></li>
				</ul>
			</div>
			<div>
				<h3 class="text-xs font-bold uppercase tracking-wider text-slate-400">Resources</h3>
				<ul class="mt-4 space-y-2">
					<li><a href="/blogs" class="text-sm text-slate-600 hover:text-blue-600">Blogs</a></li>
					<li><a href="/news" class="text-sm text-slate-600 hover:text-blue-600">News</a></li>
					<li><a href="/books" class="text-sm text-slate-600 hover:text-blue-600">Books</a></li>
					<li><a href="/notes" class="text-sm text-slate-600 hover:text-blue-600">Study Notes</a></li>
				</ul>
			</div>
			<div>
				<h3 class="text-xs font-bold uppercase tracking-wider text-slate-400">Support</h3>
				<ul class="mt-4 space-y-2">
					<li><a href="/help" class="text-sm text-slate-600 hover:text-blue-600">Help Center</a></li>
					<li><a href="/faq" class="text-sm text-slate-600 hover:text-blue-600">FAQ</a></li>
					<li><a href="/contact" class="text-sm text-slate-600 hover:text-blue-600">Contact Us</a></li>
				</ul>
			</div>
		</div>
		<div class="mt-12 border-t border-slate-100 pt-8 flex flex-col items-center justify-between gap-4 sm:flex-row">
			<p class="text-sm text-slate-500">
				&copy; {currentYear} Programming Tails. All rights reserved. Built with SvelteKit & Supabase.
			</p>
			<div class="flex gap-6">
				<a href="/privacy" class="text-sm text-slate-400 hover:text-slate-600 transition-colors">Privacy Policy</a>
				<a href="/terms" class="text-sm text-slate-400 hover:text-slate-600 transition-colors">Terms of Service</a>
			</div>
		</div>
	</div>
</footer>
