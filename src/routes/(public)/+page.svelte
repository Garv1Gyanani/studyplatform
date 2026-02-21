<script lang="ts">
	import { ArrowRight, Play, BookOpen, Trophy, Sparkles, GraduationCap, ChevronRight } from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { openSignup } from '$lib/stores/auth';
</script>

<div class="relative overflow-hidden bg-white pb-16 pt-24 sm:pb-24 sm:pt-32 lg:pb-32 lg:pt-40">
	<!-- Background Decorations -->
	<div class="absolute -top-24 left-1/2 -z-10 h-[500px] w-[1000px] -translate-x-1/2 bg-[radial-gradient(circle_at_center,rgba(59,130,246,0.1)_0%,transparent_70%)] blur-3xl"></div>
	<div class="absolute right-0 top-0 -z-10 h-96 w-96 translate-x-1/2 rounded-full bg-indigo-50/50 blur-3xl"></div>

	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="lg:grid lg:grid-cols-12 lg:gap-16">
			<!-- Text Content -->
			<div class="col-span-12 lg:col-span-7">
				<div class="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50/50 px-4 py-1.5 text-sm font-semibold text-blue-600 shadow-sm ring-1 ring-inset ring-blue-600/10">
					<Sparkles size={16} />
					<span>New Gamified Learning Experience</span>
				</div>

				<h1 class="mt-8 text-5xl font-extrabold tracking-tight text-slate-900 sm:text-6xl md:text-7xl lg:text-7xl">
					Learn <span class="bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Faster</span>, <br />
					Play <span class="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent underline decoration-purple-200 decoration-8 underline-offset-4">Harder</span>.
				</h1>

				<p class="mt-8 text-xl leading-relaxed text-slate-500 sm:max-w-2xl">
					Master subjects with interactive video courses, challenging quizzes, and formal tests. Earn points, climb the leaderboard, and unlock your potential.
				</p>

				<div class="mt-10 flex flex-wrap gap-4">
					<a
						href="/courses"
						class="inline-flex items-center gap-2 rounded-2xl bg-blue-600 px-8 py-4 text-basis font-bold text-white shadow-xl shadow-blue-200 transition-all hover:bg-blue-700 hover:shadow-blue-300 hover:translate-y-[-2px] active:scale-95"
					>
						Browse Courses
						<ArrowRight size={20} />
					</a>
					<button
						onclick={openSignup}
						class="inline-flex items-center gap-2 rounded-2xl border border-slate-200 bg-white px-8 py-4 text-basis font-bold text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-300 hover:translate-y-[-2px] active:scale-95"
					>
						Join for Free
					</button>
				</div>

				<div class="mt-12 flex items-center gap-8 text-slate-400">
					<div class="flex items-center gap-2">
						<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-50">
							<Play size={20} class="text-blue-500" />
						</div>
						<div class="text-xs uppercase tracking-widest font-bold">100+ Courses</div>
					</div>
					<div class="flex items-center gap-2">
						<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-50">
							<Trophy size={20} class="text-amber-500" />
						</div>
						<div class="text-xs uppercase tracking-widest font-bold">Global Leaderboard</div>
					</div>
					<div class="flex items-center gap-2">
						<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-50">
							<BookOpen size={20} class="text-green-500" />
						</div>
						<div class="text-xs uppercase tracking-widest font-bold">Free Resources</div>
					</div>
				</div>
			</div>

			<!-- Image / Visual Side -->
			<div class="relative col-span-12 mt-16 lg:col-span-5 lg:mt-0 lg:flex lg:items-center">
				<div class="relative w-full overflow-hidden rounded-3xl border border-slate-200 bg-white p-2 shadow-2xl shadow-slate-200/50 lg:aspect-[4/3]">
					<div class="h-full w-full rounded-2xl bg-slate-50 relative group">
						<!-- Placeholder for a real image, using a gradient for now -->
						<div class="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-indigo-500/10 flex items-center justify-center">
							<div class="relative">
								<div class="absolute -inset-4 bg-white/20 blur-xl rounded-full"></div>
								<div class="relative flex h-24 w-24 items-center justify-center rounded-3xl bg-white shadow-xl group-hover:scale-110 transition-transform duration-500">
									<GraduationCap size={48} class="text-blue-600" />
								</div>
							</div>
						</div>

						<!-- Floating Cards -->
						<div class="absolute bottom-6 left-6 right-6">
							<div class="flex items-center justify-between rounded-2xl bg-white/80 backdrop-blur-md p-4 shadow-lg border border-white/50">
								<div class="flex items-center gap-3">
									<div class="h-10 w-10 rounded-full bg-amber-100 flex items-center justify-center">
										<Trophy size={20} class="text-amber-600" />
									</div>
									<div>
										<p class="text-xs font-bold text-slate-400">Current Rank</p>
										<p class="text-sm font-bold text-slate-900">Top 5% Student</p>
									</div>
								</div>
								<div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-50 text-blue-600 transition-transform group-hover:rotate-12">
									<ChevronRight size={20} />
								</div>
							</div>
						</div>

						<!-- More Floaties -->
						<div class="absolute -right-4 top-12 animate-bounce transition-all hover:scale-110" style="animation-duration: 3s;">
							<div class="rounded-2xl bg-white p-4 shadow-xl shadow-blue-100/50 border border-blue-50">
								<div class="flex items-center gap-2">
									<div class="h-8 w-8 rounded-lg bg-blue-100 flex items-center justify-center">
										<Play size={16} class="text-blue-600" />
									</div>
									<span class="text-sm font-bold text-slate-700">New Quiz: Physics</span>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Features Selection -->
<section class="py-24 bg-slate-50">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="text-center">
			<h2 class="text-base font-bold uppercase tracking-widest text-blue-600">Everything you need</h2>
			<p class="mt-4 text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">Built for Students, Controlled by Admins</p>
			<p class="mx-auto mt-4 max-w-2xl text-lg text-slate-500">
				A comprehensive platform that bridges the gap between content delivery and student engagement.
			</p>
		</div>

		<div class="mt-20 grid grid-cols-1 gap-8 md:grid-cols-3 lg:grid-cols-3">
			{#each [
				{ icon: Play, title: 'Video Courses', desc: 'High-quality video lessons with progress tracking and related materials.', color: 'blue' },
				{ icon: BookOpen, title: 'Interactive Quizzes', desc: 'Instant feedback and gamified scoring to make learning fun.', color: 'indigo' },
				{ icon: Trophy, title: 'Global Leaderboard', desc: 'Compete with peers and see where you stand in the global rankings.', color: 'amber' },
				{ icon: Sparkles, title: 'Study Notes', desc: 'Clean, structured markdown notes organized by subject and topic.', color: 'purple' },
				{ icon: GraduationCap, title: 'Formal Tests', desc: 'Timed assessments designed to prepare you for the real deal.', color: 'green' },
				{ icon: Play, title: 'Educational Games', desc: 'Break from study with mini-games that reinforce your knowledge.', color: 'pink' }
			] as feature}
				<div class="group relative rounded-3xl border border-slate-200 bg-white p-8 transition-all hover:shadow-2xl hover:shadow-slate-200/50 hover:translate-y-[-4px]">
					<div class={cn("inline-flex h-12 w-12 items-center justify-center rounded-2xl mb-6 shadow-sm", {
						'bg-blue-50 text-blue-600': feature.color === 'blue',
						'bg-indigo-50 text-indigo-600': feature.color === 'indigo',
						'bg-amber-50 text-amber-600': feature.color === 'amber',
						'bg-purple-50 text-purple-600': feature.color === 'purple',
						'bg-green-50 text-green-600': feature.color === 'green',
						'bg-pink-50 text-pink-600': feature.color === 'pink',
					})}>
						<feature.icon size={24} />
					</div>
					<h3 class="text-xl font-bold text-slate-900">{feature.title}</h3>
					<p class="mt-4 text-slate-500 leading-relaxed">{feature.desc}</p>
				</div>
			{/each}
		</div>
	</div>
</section>
