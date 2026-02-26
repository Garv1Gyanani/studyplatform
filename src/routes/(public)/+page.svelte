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
		Star,
		Clock,
		PlayCircle
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { openSignup } from '$lib/stores/auth';
	import { fade, fly } from 'svelte/transition';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';

	let popularCourses = $state<any[]>([]);

	onMount(async () => {
		const { data } = await supabase
			.from('videos')
			.select('*, categories(name)')
			.eq('is_published', true)
			.order('created_at', { ascending: false })
			.limit(3);
		
		popularCourses = data || [];
	});
</script>

<!-- Refined Hero Section -->
<div class="relative overflow-hidden bg-white pb-16 pt-10 sm:pb-24 sm:pt-12 lg:pb-32 lg:pt-16">
	<!-- Dynamic Background -->
	<div class="absolute inset-0 -z-10 bg-[radial-gradient(45%_45%_at_50%_50%,rgba(59,130,246,0.03)_0%,transparent_100%)]"></div>
	<div class="absolute left-1/2 top-0 -z-10 h-[600px] w-[1200px] -translate-x-1/2 bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.02)_0%,transparent_70%)] blur-3xl"></div>
	
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="lg:grid lg:grid-cols-12 lg:gap-12 items-center">
			<!-- Text Content -->
			<div class="col-span-12 lg:col-span-7 space-y-8" in:fly={{ y: 20 }}>
				<div class="inline-flex items-center gap-2 rounded-xl bg-slate-50 px-4 py-1.5 text-[10px] font-black text-slate-900 shadow-sm ring-1 ring-slate-100 uppercase tracking-widest">
					<div class="flex h-5 w-5 items-center justify-center rounded bg-blue-600 text-white">
						<Zap size={10} fill="currentColor" />
					</div>
					<span>Gamified Education</span>
				</div>

				<h1 class="text-5xl font-black text-slate-900 sm:text-6xl lg:text-7xl tracking-tighter leading-[0.95]">
					Master anything <br />
					<span class="bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 bg-clip-text text-transparent">effortlessly.</span>
				</h1>

				<p class="text-lg leading-relaxed text-slate-500 sm:max-w-xl font-medium">
					Programming Tails combines high-quality video courses with interactive gamification. Earn XP, compete in global leaderboards, and turn your learning journey into an adventure.
				</p>

				<div class="flex flex-wrap gap-4">
					<a
						href="/courses"
						class="inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-8 py-4 text-sm font-black text-white shadow-xl shadow-slate-200 transition-all hover:bg-black hover:scale-105 active:scale-95"
					>
						Explore Classes
						<ArrowRight size={18} />
					</a>
					<button
						onclick={() => {
							if (window.openTailBot) {
								window.openTailBot('Can you help me create a personalized study plan for learning modern programming?');
							} else {
								window.dispatchEvent(new CustomEvent('ai-assistant-prompt', { detail: 'Can you help me create a personalized study plan for learning modern programming?' }));
							}
						}}
						class="inline-flex items-center gap-2 rounded-2xl border-2 border-slate-100 bg-white px-8 py-4 text-sm font-black text-slate-700 transition-all hover:bg-slate-50 hover:border-slate-200 hover:scale-105 active:scale-95 shadow-sm"
					>
						AI Study Plan
						<Sparkles size={18} class="text-blue-600" />
					</button>
				</div>

				<!-- Social Proof -->
				<div class="flex items-center gap-6 pt-6 border-t border-slate-50">
					<div class="flex -space-x-2">
						{#each Array(4) as _}
							<div class="h-10 w-10 rounded-full border-2 border-white bg-slate-100 ring-1 ring-slate-100"></div>
						{/each}
						<div class="h-10 w-10 rounded-full border-2 border-white bg-blue-600 flex items-center justify-center text-[9px] font-black text-white ring-1 ring-blue-600">+2k</div>
					</div>
					<p class="text-xs font-bold text-slate-400">Trusted by <span class="text-slate-900">2,400+</span> students</p>
				</div>
			</div>

			<!-- Refined Visual Showcase -->
			<div class="hidden lg:block col-span-12 lg:col-span-5 relative" in:fly={{ x: 20 }}>
				<div class="relative w-full aspect-[4/5] rounded-[48px] bg-slate-50 border-4 border-white shadow-2xl overflow-hidden">
					<div class="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-blue-600/5 to-transparent"></div>
					
					<div class="absolute top-10 left-1/2 -translate-x-1/2 w-3/4 bg-white rounded-2xl p-4 shadow-xl border border-blue-50 transform rotate-[-1deg]">
						<div class="flex items-center justify-between mb-3">
							<div class="flex items-center gap-2">
								<div class="h-8 w-8 rounded-lg bg-blue-100 flex items-center justify-center text-blue-600">
									<Zap size={16} fill="currentColor" />
								</div>
								<div>
									<p class="text-[8px] font-black uppercase text-slate-400">XP</p>
									<p class="text-xs font-black text-slate-900">12,450</p>
								</div>
							</div>
						</div>
						<div class="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden">
							<div class="h-full w-3/4 bg-blue-600 rounded-full"></div>
						</div>
					</div>

					<div class="absolute bottom-16 -right-6 w-56 bg-white rounded-3xl p-4 shadow-xl border border-indigo-50 transform rotate-[2deg]">
						<div class="space-y-3">
							<p class="text-[8px] font-black uppercase text-slate-400">Ranking</p>
							<div class="flex items-center gap-3 p-2 bg-indigo-50 rounded-xl">
								<div class="h-8 w-8 rounded-lg bg-white flex items-center justify-center font-black text-xs text-indigo-600 shadow-sm">#4</div>
								<div class="flex-grow">
									<p class="text-xs font-black text-slate-900">Alex J.</p>
								</div>
							</div>
						</div>
					</div>

					<div class="absolute inset-0 flex items-center justify-center">
						<div class="h-24 w-24 rounded-3xl bg-white shadow-2xl flex items-center justify-center text-blue-600 group">
							<GraduationCap size={48} strokeWidth={1.5} class="group-hover:scale-110 transition-transform" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Refined Features Section -->
<section class="py-16 bg-slate-50 overflow-hidden">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
			<div class="space-y-6">
				<h2 class="text-3xl sm:text-4xl font-black text-slate-900 tracking-tight leading-tight">
					Designed for the <br />
					<span class="text-blue-600">next Gen.</span>
				</h2>
				<p class="text-basis text-slate-500 font-medium leading-relaxed max-w-lg">
					Online education reimagined. cinematic content meets competitive mechanics.
				</p>
				
				<div class="space-y-4 pt-4">
					{#each [
						{ icon: Target, title: 'Adaptive Learning', desc: 'Difficulty adjusts based on your progress.' },
						{ icon: ShieldCheck, title: 'Verified Certification', desc: 'Earn trust with formal assessments.' }
					] as point}
						<div class="flex gap-4">
							<div class="h-10 w-10 rounded-xl bg-white shadow-sm flex items-center justify-center shrink-0 border border-slate-100">
								<point.icon size={20} class="text-blue-600" />
							</div>
							<div>
								<h4 class="font-black text-slate-900 text-sm">{point.title}</h4>
								<p class="text-xs text-slate-500 font-medium mt-0.5">{point.desc}</p>
							</div>
						</div>
					{/each}
				</div>
			</div>

			<div class="grid grid-cols-2 gap-4">
				{#each [
					{ icon: Play, title: 'Classes', color: 'bg-blue-600' },
					{ icon: BookOpen, title: 'Notes', color: 'bg-indigo-600' },
					{ icon: Trophy, title: 'Rankings', color: 'bg-blue-600' },
					{ icon: Gamepad2, title: 'Games', color: 'bg-indigo-600' }
				] as card}
					<div class="p-8 rounded-[32px] bg-white border border-slate-100 shadow-sm hover:shadow-xl hover:translate-y-[-4px] transition-all flex flex-col items-center text-center group">
						<div class={cn("h-12 w-12 rounded-2xl flex items-center justify-center text-white mb-4 shadow-lg", card.color)}>
							<card.icon size={24} />
						</div>
						<h3 class="text-basis font-black text-slate-900">{card.title}</h3>
					</div>
				{/each}
			</div>
		</div>
	</div>
</section>

<!-- Compact Popular Courses -->
{#if popularCourses.length > 0}
	<section class="py-16 bg-white">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="flex items-end justify-between gap-8 mb-10">
				<div class="space-y-2">
					<h2 class="text-3xl font-black text-slate-900 tracking-tight leading-none">
						Popular <span class="text-blue-600">Classes</span>
					</h2>
					<p class="text-sm text-slate-500 font-medium max-w-lg">
						Level up with our top video courses.
					</p>
				</div>
				<a href="/courses" class="inline-flex items-center gap-2 px-6 py-3 bg-slate-50 rounded-xl text-[10px] font-black uppercase text-slate-900 hover:bg-slate-100 transition-all group">
					View All <ArrowRight size={14} class="transition-transform group-hover:translate-x-1" />
				</a>
			</div>

			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
				{#each popularCourses as video}
					<a 
						href={`/courses/${video.id}`}
						class="group relative bg-white rounded-[32px] border border-slate-100 overflow-hidden shadow-sm hover:shadow-xl hover:translate-y-[-4px] transition-all"
					>
						<div class="relative aspect-video overflow-hidden bg-slate-100">
							{#if video.thumbnail_url}
								<img src={video.thumbnail_url} alt="" class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-105" />
							{/if}
							<div class="absolute inset-0 bg-black/5 group-hover:bg-transparent transition-colors"></div>
						</div>

						<div class="p-6 space-y-3">
							<div class="flex items-center justify-between">
								<span class="px-2.5 py-1 bg-blue-50 text-[8px] font-black uppercase tracking-widest text-blue-600 rounded">
									{video.categories?.name || 'General'}
								</span>
								<div class="flex items-center gap-1 text-amber-500 font-bold text-[10px]">
									<Star size={12} fill="currentColor" /> 4.9
								</div>
							</div>
							<h3 class="text-basis font-black text-slate-900 leading-tight group-hover:text-blue-600 transition-colors line-clamp-1">
								{video.title}
							</h3>
						</div>
					</a>
				{/each}
			</div>
		</div>
	</section>
{/if}

<!-- Compact Final CTA -->
<section class="py-16 relative">
	<div class="absolute inset-0 -z-10">
		<div class="absolute inset-0 bg-slate-900"></div>
	</div>
	
	<div class="mx-auto max-w-4xl px-4 text-center space-y-8">
		<h2 class="text-4xl sm:text-5xl font-black text-white tracking-tight leading-none">
			Ready to unlock <br />
			<span class="text-blue-500">potential?</span>
		</h2>
		<p class="text-basis text-slate-400 font-medium max-w-lg mx-auto leading-relaxed">
			Join thousands of students learning faster.
		</p>
		<div class="pt-4">
			<button 
				onclick={openSignup}
				class="px-12 py-4 bg-blue-600 text-white font-black text-basis rounded-2xl shadow-xl hover:scale-105 active:scale-95 transition-all"
			>
				Start Learning Free
			</button>
		</div>
	</div>
</section>
