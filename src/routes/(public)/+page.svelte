<script lang="ts">
	import { 
		ArrowRight, 
		Play, 
		BookOpen, 
		Trophy, 
		Sparkles, 
		GraduationCap, 
		ChevronRight, 
		Zap, 
		Target, 
		Users, 
		ShieldCheck,
		Gamepad2,
		Star
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { openSignup } from '$lib/stores/auth';
	import { fade, fly } from 'svelte/transition';
</script>

<!-- Hero Section -->
<div class="relative overflow-hidden bg-white pb-20 pt-24 sm:pb-32 sm:pt-40 lg:pb-40 lg:pt-48">
	<!-- Dynamic Background -->
	<div class="absolute inset-0 -z-10 bg-[radial-gradient(45%_45%_at_50%_50%,rgba(59,130,246,0.05)_0%,transparent_100%)]"></div>
	<div class="absolute left-1/2 top-0 -z-10 h-[800px] w-[1600px] -translate-x-1/2 bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.03)_0%,transparent_70%)] blur-3xl"></div>
	
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="lg:grid lg:grid-cols-12 lg:gap-16 items-center">
			<!-- Text Content -->
			<div class="col-span-12 lg:col-span-7 space-y-10" in:fly={{ y: 20 }}>
				<div class="inline-flex items-center gap-3 rounded-2xl bg-slate-50 px-5 py-2 text-sm font-black text-slate-900 shadow-sm ring-1 ring-slate-100">
					<div class="flex h-6 w-6 items-center justify-center rounded-lg bg-blue-600 text-white shadow-lg">
						<Zap size={14} fill="currentColor" />
					</div>
					<span class="uppercase tracking-widest text-[10px]">The Future of Gamified Education</span>
				</div>

				<h1 class="text-6xl font-black text-slate-900 sm:text-7xl md:text-8xl lg:text-8xl tracking-tighter leading-[0.9]">
					Master anything <br />
					<span class="bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 bg-clip-text text-transparent">effortlessly.</span>
				</h1>

				<p class="text-xl leading-relaxed text-slate-500 sm:max-w-2xl font-medium">
					EduPlatform combines high-quality video courses with interactive gamification. Earn XP, compete in global leaderboards, and turn your learning journey into an adventure.
				</p>

				<div class="flex flex-wrap gap-6">
					<a
						href="/courses"
						class="inline-flex items-center gap-3 rounded-[24px] bg-slate-900 px-10 py-5 text-basis font-black text-white shadow-2xl shadow-slate-200 transition-all hover:bg-black hover:scale-105 active:scale-95"
					>
						Explore Classes
						<ArrowRight size={20} />
					</a>
					<button
						onclick={openSignup}
						class="inline-flex items-center gap-3 rounded-[24px] border-2 border-slate-100 bg-white px-10 py-5 text-basis font-black text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-200 hover:scale-105 active:scale-95"
					>
						Join Now — It's Free
					</button>
				</div>

				<!-- Social Proof -->
				<div class="flex items-center gap-8 pt-8 border-t border-slate-50">
					<div class="flex -space-x-3">
						{#each Array(4) as _}
							<div class="h-12 w-12 rounded-full border-4 border-white bg-slate-100 ring-1 ring-slate-100"></div>
						{/each}
						<div class="h-12 w-12 rounded-full border-4 border-white bg-blue-600 flex items-center justify-center text-[10px] font-black text-white ring-1 ring-blue-600 shadow-lg">+2k</div>
					</div>
					<p class="text-sm font-bold text-slate-400">Trusted by <span class="text-slate-900">2,400+</span> students worldwide</p>
				</div>
			</div>

			<!-- Visual Showcase -->
			<div class="hidden lg:block col-span-12 lg:col-span-5 relative mt-12 lg:mt-0" in:fly={{ x: 20 }}>
				<div class="relative w-full aspect-[4/5] rounded-[60px] bg-slate-50 border-8 border-white shadow-[0_40px_100px_-20px_rgba(0,0,0,0.1)] overflow-hidden">
					<!-- Simulated Interface Background -->
					<div class="absolute inset-x-0 top-0 h-40 bg-gradient-to-b from-blue-600/5 to-transparent"></div>
					
					<!-- Floating Game UI Element -->
					<div class="absolute top-12 left-1/2 -translate-x-1/2 w-4/5 bg-white rounded-[32px] p-6 shadow-2xl shadow-blue-200/40 border border-blue-50 transform rotate-[-2deg]">
						<div class="flex items-center justify-between mb-4">
							<div class="flex items-center gap-3">
								<div class="h-10 w-10 rounded-xl bg-blue-100 flex items-center justify-center text-blue-600">
									<Zap size={20} fill="currentColor" />
								</div>
								<div>
									<p class="text-[10px] font-black uppercase text-slate-400">Current XP</p>
									<p class="text-basis font-black text-slate-900">12,450 XP</p>
								</div>
							</div>
							<div class="h-8 w-8 rounded-full bg-green-50 flex items-center justify-center text-green-500">
								<Star size={16} fill="currentColor" />
							</div>
						</div>
						<div class="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
							<div class="h-full w-3/4 bg-blue-600 rounded-full"></div>
						</div>
					</div>

					<!-- Floating Leaderboard Item -->
					<div class="absolute bottom-20 -right-8 w-64 bg-white rounded-[32px] p-6 shadow-2xl shadow-indigo-200/40 border border-indigo-50 transform rotate-[4deg]">
						<div class="space-y-4">
							<p class="text-[10px] font-black uppercase text-slate-400">Global Ranking</p>
							<div class="flex items-center gap-4 p-3 bg-indigo-50 rounded-2xl">
								<div class="h-10 w-10 rounded-xl bg-white flex items-center justify-center font-black text-indigo-600">#4</div>
								<div class="flex-grow">
									<p class="text-sm font-black text-slate-900">Alex J.</p>
									<p class="text-[10px] font-bold text-indigo-400">Physics Master</p>
								</div>
							</div>
						</div>
					</div>

					<!-- Main Illustration Center -->
					<div class="absolute inset-0 flex items-center justify-center">
						<div class="h-32 w-32 rounded-[40px] bg-white shadow-2xl flex items-center justify-center text-blue-600 group">
							<GraduationCap size={64} strokeWidth={1.5} class="group-hover:scale-110 transition-transform" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Features Section -->
<section class="py-32 bg-slate-50 overflow-hidden">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="grid grid-cols-1 lg:grid-cols-2 gap-20 items-center">
			<div class="space-y-8">
				<h2 class="text-4xl sm:text-5xl font-black text-slate-900 tracking-tight leading-tight">
					Designed for the next <br />
					generation of <span class="text-blue-600">minds.</span>
				</h2>
				<p class="text-lg text-slate-500 font-medium leading-relaxed max-w-xl">
					We've reimagined online education by blending cinematic content with competitive mechanics. It's not just learning; it's a quest for mastery.
				</p>
				
				<div class="space-y-6 pt-6">
					{#each [
						{ icon: Target, title: 'Adaptive Learning', desc: 'Our platform adjusts difficulty based on your progress.' },
						{ icon: ShieldCheck, title: 'Verified Certification', desc: 'Earn trust with formal assessments and digital certificates.' },
						{ icon: Users, title: 'Collaborative Study', desc: 'Connect with thousands of peers in a global learning network.' }
					] as point}
						<div class="flex gap-4">
							<div class="h-12 w-12 rounded-2xl bg-white shadow-sm flex items-center justify-center shrink-0 border border-slate-100">
								<point.icon size={24} class="text-blue-600" />
							</div>
							<div>
								<h4 class="font-black text-slate-900">{point.title}</h4>
								<p class="text-sm text-slate-500 font-medium mt-1">{point.desc}</p>
							</div>
						</div>
					{/each}
				</div>
			</div>

			<!-- Cards Grid -->
			<div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
				{#each [
					{ icon: Play, title: 'Video Classes', color: 'bg-blue-600' },
					{ icon: BookOpen, title: 'Study Notes', color: 'bg-purple-600' },
					{ icon: Trophy, title: 'Leaderboard', color: 'bg-amber-500' },
					{ icon: Gamepad2, title: 'Skill Games', color: 'bg-green-500' }
				] as card}
					<div class="p-10 rounded-[48px] bg-white border border-slate-100 shadow-sm hover:shadow-2xl hover:translate-y-[-8px] transition-all flex flex-col items-center text-center group">
						<div class={cn("h-16 w-16 rounded-[24px] flex items-center justify-center text-white mb-6 shadow-xl", card.color)}>
							<card.icon size={32} />
						</div>
						<h3 class="text-xl font-black text-slate-900">{card.title}</h3>
						<p class="text-slate-400 font-bold text-[10px] uppercase tracking-widest mt-2">{card.title.split(' ')[0]} Master</p>
					</div>
				{/each}
			</div>
		</div>
	</div>
</section>

<!-- Final CTA -->
<section class="py-40 relative">
	<div class="absolute inset-0 -z-10">
		<div class="absolute inset-0 bg-slate-900"></div>
		<div class="absolute right-0 top-0 h-full w-1/2 bg-[radial-gradient(circle_at_center,rgba(59,130,246,0.2)_0%,transparent_70%)] blur-3xl"></div>
	</div>
	
	<div class="mx-auto max-w-5xl px-4 text-center space-y-12">
		<h2 class="text-5xl sm:text-7xl font-black text-white tracking-tight leading-none">
			Ready to unlock your <br />
			<span class="text-blue-500">true potential?</span>
		</h2>
		<p class="text-xl text-slate-400 font-medium max-w-2xl mx-auto leading-relaxed">
			Join thousands of students who are already learning better, faster, and having fun while doing it.
		</p>
		<div class="pt-8">
			<button 
				onclick={openSignup}
				class="px-16 py-6 bg-blue-600 text-white font-black text-lg rounded-[32px] shadow-[0_20px_60px_-15px_rgba(37,99,235,0.5)] hover:scale-105 active:scale-95 transition-all"
			>
				Create Your Student ID
			</button>
			<p class="mt-6 text-slate-500 font-bold text-sm">No credit card required. Free forever beta.</p>
		</div>
	</div>
</section>

<!-- Footer -->
<footer class="bg-white py-20 border-t border-slate-100">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center gap-10">
		<div class="flex items-center gap-2">
			<div class="h-10 w-10 rounded-xl bg-blue-600 flex items-center justify-center text-white font-black text-xl shadow-lg">E</div>
			<span class="text-2xl font-black tracking-tight text-slate-900">EduPlatform</span>
		</div>
		
		<nav class="flex gap-10 text-sm font-black text-slate-400 uppercase tracking-widest">
			<a href="/courses" class="hover:text-slate-900 transition-colors">Courses</a>
			<a href="/blogs" class="hover:text-slate-900 transition-colors">Journal</a>
			<a href="/leaderboard" class="hover:text-slate-900 transition-colors">Ranking</a>
			<a href="/about" class="hover:text-slate-900 transition-colors">About</a>
		</nav>

		<div class="text-sm font-bold text-slate-400">
			&copy; 2026 EduPlatform. Built with ❤️ for Students.
		</div>
	</div>
</footer>
