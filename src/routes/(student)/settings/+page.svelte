<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		User, 
		Mail, 
		Lock, 
		Save, 
		Loader2, 
		Bell, 
		Moon, 
		Sun, 
		Globe, 
		Shield,
		Camera,
		Trash2,
		CheckCircle2
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let user = $state<any>(null);
	let profile = $state<any>(null);
	let loading = $state(true);
	let saving = $state(false);
	let saved = $state(false);
	let activeTab = $state('profile');

	// Form state
	let username = $state('');
	let bio = $state('');

	onMount(async () => {
		const { data: sessionData } = await supabase.auth.getSession();
		user = sessionData.session?.user;

		if (user) {
			const { data } = await supabase.from('profiles').select('*').eq('id', user.id).single();
			profile = data;
			username = data?.username || '';
			bio = data?.bio || '';
		}
		loading = false;
	});

	async function handleSave() {
		if (!user) return;
		saving = true;
		const { error } = await supabase
			.from('profiles')
			.update({ username, bio, updated_at: new Date().toISOString() })
			.eq('id', user.id);
		
		if (!error) {
			saved = true;
			setTimeout(() => saved = false, 3000);
		} else {
			alert(error.message);
		}
		saving = false;
	}

	async function handleAvatarUpload(event: Event) {
		const target = event.target as HTMLInputElement;
		if (!target.files || target.files.length === 0 || !user) return;

		const file = target.files[0];
		const fileExt = file.name.split('.').pop();
		const filePath = `${user.id}-${Math.random()}.${fileExt}`;

		saving = true;
		try {
			// 1. Upload to Supabase Storage
			const { error: uploadError } = await supabase.storage
				.from('avatars')
				.upload(filePath, file);

			if (uploadError) throw uploadError;

			// 2. Get Public URL
			const { data: { publicUrl } } = supabase.storage
				.from('avatars')
				.getPublicUrl(filePath);

			// 3. Update Profile
			const { error: updateError } = await supabase
				.from('profiles')
				.update({ avatar_url: publicUrl })
				.eq('id', user.id);

			if (updateError) throw updateError;

			// 4. Update Local State
			profile.avatar_url = publicUrl;
			saved = true;
			setTimeout(() => saved = false, 3000);
		} catch (error: any) {
			alert(error.message);
		} finally {
			saving = false;
		}
	}

	async function handlePasswordReset() {
		if (!user?.email) return;
		const { error } = await supabase.auth.resetPasswordForEmail(user.email);
		if (!error) {
			alert('Password reset email sent! Check your inbox.');
		} else {
			alert(error.message);
		}
	}

	const tabs = [
		{ id: 'profile', name: 'Profile', icon: User },
		{ id: 'notifications', name: 'Notifications', icon: Bell },
		{ id: 'security', name: 'Security', icon: Shield },
		{ id: 'preferences', name: 'Preferences', icon: Globe },
	];
</script>

<div class="px-4 sm:px-8 py-12 max-w-5xl mx-auto space-y-10">
	<div class="space-y-2">
		<h1 class="text-4xl font-black text-slate-900 tracking-tight">Account Settings</h1>
		<p class="text-lg font-medium text-slate-500">Personalize your profile and manage your preferences.</p>
	</div>

	{#if loading}
		<div class="flex h-[50vh] items-center justify-center">
			<Loader2 size={48} class="animate-spin text-blue-600" />
		</div>
	{:else if !user}
		<div class="text-center py-20 bg-white rounded-[40px] border border-slate-100 shadow-sm">
			<h2 class="text-2xl font-black text-slate-900">Please Sign In</h2>
			<p class="text-slate-500 mt-2">Login to access your account settings.</p>
		</div>
	{:else}
		<div class="grid grid-cols-1 lg:grid-cols-12 gap-10">
			<!-- Sidebar Tabs -->
			<div class="lg:col-span-3 space-y-2" in:fade>
				{#each tabs as tab}
					<button 
						onclick={() => activeTab = tab.id}
						class={cn(
							"w-full flex items-center gap-3 rounded-2xl px-5 py-4 text-sm font-bold transition-all text-left",
							activeTab === tab.id 
								? "bg-slate-900 text-white shadow-xl shadow-slate-200" 
								: "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
						)}
					>
						<tab.icon size={18} />
						{tab.name}
					</button>
				{/each}
			</div>

			<!-- Content -->
			<div class="lg:col-span-9" in:fly={{ y: 20 }}>
				{#if activeTab === 'profile'}
					<div class="bg-white rounded-[40px] border border-slate-100 shadow-sm overflow-hidden">
						<!-- Avatar Section -->
						<div class="p-10 border-b border-slate-100 flex items-center gap-8">
							<div class="relative group">
								<div class="h-24 w-24 rounded-[32px] bg-slate-100 overflow-hidden ring-4 ring-white shadow-xl">
									{#if profile?.avatar_url}
										<img src={profile.avatar_url} alt="Avatar" class="h-full w-full object-cover" />
									{:else}
										<div class="h-full w-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white text-3xl font-black">
											{username.charAt(0).toUpperCase() || user.email.charAt(0).toUpperCase()}
										</div>
									{/if}
								</div>
								<input 
									type="file" 
									id="avatar-input" 
									accept="image/*" 
									class="hidden" 
									onchange={handleAvatarUpload}
								/>
								<button 
									onclick={() => document.getElementById('avatar-input')?.click()}
									class="absolute -bottom-2 -right-2 h-10 w-10 rounded-full bg-slate-900 text-white flex items-center justify-center shadow-lg opacity-0 group-hover:opacity-100 transition-all hover:bg-blue-600"
								>
									{#if saving}
										<Loader2 size={16} class="animate-spin" />
									{:else}
										<Camera size={16} />
									{/if}
								</button>
							</div>
							<div>
								<h3 class="text-xl font-black text-slate-900">{username || 'Your Profile'}</h3>
								<p class="text-sm font-bold text-slate-400 flex items-center gap-2 mt-1">
									<Mail size={14} /> {user.email}
								</p>
							</div>
						</div>

						<!-- Form -->
						<form onsubmit={e => { e.preventDefault(); handleSave(); }} class="p-10 space-y-8">
							<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
								<div class="space-y-2">
									<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Display Name</label>
									<input 
										bind:value={username} 
										class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-bold outline-none focus:bg-white focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 transition-all" 
										placeholder="e.g. Alex" 
									/>
								</div>
								<div class="space-y-2">
									<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Email Address</label>
									<input 
										value={user.email} 
										disabled 
										class="w-full rounded-2xl border border-slate-100 bg-slate-50 px-5 py-4 text-sm font-bold text-slate-400 outline-none cursor-not-allowed" 
									/>
								</div>
							</div>

							<div class="space-y-2">
								<label class="text-[10px] font-black uppercase tracking-widest text-slate-500">Bio</label>
								<textarea 
									bind:value={bio} 
									rows="4" 
									class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-medium outline-none focus:bg-white focus:ring-4 focus:ring-blue-500/10 focus:border-blue-600 transition-all resize-none" 
									placeholder="Tell us a bit about yourself..."
								></textarea>
							</div>

							<div class="flex items-center justify-between pt-6 border-t border-slate-100">
								{#if saved}
									<div class="flex items-center gap-2 text-green-600 font-black text-sm" in:fly={{ y: 10 }}>
										<CheckCircle2 size={20} /> Profile saved successfully!
									</div>
								{:else}
									<div></div>
								{/if}
								<button 
									type="submit" 
									disabled={saving}
									class="px-10 py-4 rounded-2xl bg-blue-600 text-white font-black text-sm shadow-xl shadow-blue-200 hover:bg-blue-700 transition-all active:scale-95 flex items-center gap-2"
								>
									{#if saving}
										<Loader2 size={18} class="animate-spin" /> Saving...
									{:else}
										<Save size={18} /> Save Changes
									{/if}
								</button>
							</div>
						</form>
					</div>
				{:else if activeTab === 'notifications'}
					<div class="bg-white rounded-[40px] border border-slate-100 shadow-sm p-10 space-y-8">
						<h3 class="text-2xl font-black text-slate-900">Notification Preferences</h3>
						
						<div class="space-y-6">
							{#each [
								{ title: 'Quiz Results', desc: 'Get notified when your quiz score is ready.' },
								{ title: 'New Courses', desc: 'Be alerted when new video courses are published.' },
								{ title: 'Leaderboard Updates', desc: 'Know when you move up or down in ranks.' },
								{ title: 'News & Announcements', desc: 'Receive updates about exams, scholarships, and more.' },
							] as pref}
								<div class="flex items-center justify-between p-6 rounded-3xl bg-slate-50 border border-slate-100">
									<div>
										<h4 class="font-black text-slate-900">{pref.title}</h4>
										<p class="text-xs font-medium text-slate-400 mt-0.5">{pref.desc}</p>
									</div>
									<div class="relative h-6 w-11 rounded-full bg-blue-600 cursor-pointer">
										<div class="absolute top-1 right-1 h-4 w-4 bg-white rounded-full shadow-sm"></div>
									</div>
								</div>
							{/each}
						</div>
					</div>
				{:else if activeTab === 'security'}
					<div class="bg-white rounded-[40px] border border-slate-100 shadow-sm p-10 space-y-8">
						<h3 class="text-2xl font-black text-slate-900">Security Settings</h3>
						
						<div class="p-6 rounded-3xl bg-slate-50 border border-slate-100 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
							<div>
								<h4 class="font-black text-slate-900 flex items-center gap-2"><Lock size={18} /> Password</h4>
								<p class="text-xs font-medium text-slate-400 mt-0.5">Send a password reset link to your email.</p>
							</div>
							<button 
								onclick={handlePasswordReset}
								class="px-6 py-3 bg-slate-900 text-white font-black text-sm rounded-2xl shadow-lg hover:bg-black transition-all active:scale-95"
							>
								Reset Password
							</button>
						</div>

						<div class="p-6 rounded-3xl bg-red-50 border border-red-100 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
							<div>
								<h4 class="font-black text-red-600 flex items-center gap-2"><Trash2 size={18} /> Danger Zone</h4>
								<p class="text-xs font-medium text-red-400 mt-0.5">Permanently delete your account and all associated data.</p>
							</div>
							<button class="px-6 py-3 bg-red-600 text-white font-black text-sm rounded-2xl shadow-lg hover:bg-red-700 transition-all active:scale-95">
								Delete Account
							</button>
						</div>
					</div>
				{:else if activeTab === 'preferences'}
					<div class="bg-white rounded-[40px] border border-slate-100 shadow-sm p-10 space-y-8">
						<h3 class="text-2xl font-black text-slate-900">Preferences</h3>
						
						<div class="space-y-6">
							<div class="flex items-center justify-between p-6 rounded-3xl bg-slate-50 border border-slate-100">
								<div class="flex items-center gap-4">
									<div class="h-12 w-12 rounded-2xl bg-slate-900 text-amber-400 flex items-center justify-center">
										<Moon size={24} />
									</div>
									<div>
										<h4 class="font-black text-slate-900">Dark Mode</h4>
										<p class="text-xs font-medium text-slate-400 mt-0.5">Switch the interface to a dark theme.</p>
									</div>
								</div>
								<div class="relative h-6 w-11 rounded-full bg-slate-200 cursor-pointer">
									<div class="absolute top-1 left-1 h-4 w-4 bg-white rounded-full shadow-sm"></div>
								</div>
							</div>

							<div class="flex items-center justify-between p-6 rounded-3xl bg-slate-50 border border-slate-100">
								<div class="flex items-center gap-4">
									<div class="h-12 w-12 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center">
										<Globe size={24} />
									</div>
									<div>
										<h4 class="font-black text-slate-900">Language</h4>
										<p class="text-xs font-medium text-slate-400 mt-0.5">Choose your preferred interface language.</p>
									</div>
								</div>
								<select class="rounded-2xl border border-slate-200 bg-white px-4 py-2 text-sm font-bold outline-none cursor-pointer">
									<option>English</option>
									<option>Hindi</option>
									<option>Spanish</option>
								</select>
							</div>
						</div>
					</div>
				{/if}
			</div>
		</div>
	{/if}
</div>
