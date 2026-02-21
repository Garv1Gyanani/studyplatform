<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { Mail, ArrowLeft, Loader2, CheckCircle2, ArrowRight } from 'lucide-svelte';
	import { fade, fly, scale } from 'svelte/transition';

	let email = $state('');
	let loading = $state(false);
	let success = $state(false);
	let error = $state<string | null>(null);

	async function handleResetRequest(e: SubmitEvent) {
		e.preventDefault();
		loading = true;
		error = null;

		try {
			const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
				redirectTo: `${window.location.origin}/auth/update-password`,
			});
			if (resetError) throw resetError;
			success = true;
		} catch (e: any) {
			error = e.message;
		} finally {
			loading = false;
		}
	}
</script>

<div class="min-h-[calc(100vh-64px)] bg-slate-50 flex items-center justify-center p-4">
	<div class="w-full max-w-md bg-white rounded-[40px] shadow-2xl border border-slate-100 overflow-hidden" in:fly={{ y: 20 }}>
		<div class="bg-gradient-to-br from-slate-900 to-slate-800 p-10 text-white relative overflow-hidden">
			<!-- Decoration -->
			<div class="absolute -right-10 -bottom-10 h-40 w-40 bg-blue-600 blur-[80px] opacity-20"></div>
			
			<a href="/" class="inline-flex items-center gap-2 text-slate-400 hover:text-white transition-colors mb-8 text-sm font-bold">
				<ArrowLeft size={16} /> Back to EduPlatform
			</a>
			
			<h1 class="text-3xl font-black tracking-tight">Forgot Password?</h1>
			<p class="text-slate-400 mt-2 font-medium">No worries, we'll help you get back into your account.</p>
		</div>

		<div class="p-10">
			{#if success}
				<div class="text-center space-y-6" in:scale>
					<div class="inline-flex h-20 w-20 items-center justify-center rounded-[32px] bg-green-50 text-green-600 shadow-inner">
						<CheckCircle2 size={40} />
					</div>
					<div class="space-y-2">
						<h2 class="text-2xl font-black text-slate-900">Check Your Email</h2>
						<p class="text-slate-500 font-medium">
							We've sent a password reset link to <br><strong>{email}</strong>
						</p>
					</div>
					<a 
						href="/?auth=login" 
						class="flex items-center justify-center gap-2 w-full py-4 rounded-2xl bg-slate-900 text-white font-black hover:bg-black transition-all shadow-xl shadow-slate-200"
					>
						Return to Login <ArrowRight size={20} />
					</a>
				</div>
			{:else}
				{#if error}
					<div class="mb-6 p-4 rounded-2xl bg-red-50 text-red-600 text-sm font-bold flex items-center gap-3 border border-red-100" in:fade>
						<div class="h-2 w-2 rounded-full bg-red-600 animate-pulse"></div>
						{error}
					</div>
				{/if}

				<form onsubmit={handleResetRequest} class="space-y-6">
					<div class="space-y-2">
						<label for="email" class="text-xs font-black uppercase tracking-widest text-slate-400 ml-1">Account Email</label>
						<div class="relative group">
							<div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-300 group-focus-within:text-blue-600 transition-colors">
								<Mail size={18} />
							</div>
							<input 
								id="email" 
								type="email" 
								bind:value={email}
								required
								placeholder="e.g. name@example.com"
								class="block w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 pl-12 text-basis font-bold placeholder:text-slate-300 placeholder:font-medium focus:bg-white focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 outline-none transition-all shadow-sm"
							/>
						</div>
					</div>

					<button 
						type="submit" 
						disabled={loading}
						class="w-full py-5 rounded-2xl bg-blue-600 text-white font-black shadow-2xl shadow-blue-200 hover:bg-blue-700 transition-all hover:translate-y-[-2px] active:translate-y-0 disabled:opacity-50 disabled:translate-y-0 flex items-center justify-center gap-2"
					>
						{#if loading}
							<Loader2 size={20} class="animate-spin" />
							Sending Link...
						{:else}
							Send Reset Instructions
						{/if}
					</button>
				</form>
			{/if}
		</div>
	</div>
</div>
