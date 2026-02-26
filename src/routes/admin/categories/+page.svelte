<script lang="ts">
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { 
		Plus, 
		Search, 
		Filter, 
		MoreVertical, 
		Edit2, 
		Trash2, 
		Loader2,
		LayoutGrid,
		CheckCircle2,
		X
	} from 'lucide-svelte';
	import { cn } from '$lib/utils';
	import { fade, fly } from 'svelte/transition';

	let categories = $state<any[]>([]);
	let loading = $state(true);
	let isFormOpen = $state(false);
	let formLoading = $state(false);

	// Form State
	let name = $state('');
	let slug = $state('');
	let icon = $state('');
	let color = $state('#3b82f6');
	let editingId = $state<string | null>(null);

	onMount(async () => {
		fetchCategories();
	});

	async function fetchCategories() {
		loading = true;
		const { data, error } = await supabase
			.from('categories')
			.select('*')
			.order('name');
		
		if (!error) categories = data || [];
		loading = false;
	}

	function generateSlug(text: string) {
		return text.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
	}

	$effect(() => {
		if (name && !editingId) {
			slug = generateSlug(name);
		}
	});

	async function handleSaveCategory() {
		formLoading = true;
		
		const categoryData = {
			name,
			slug,
			icon: icon || null,
			color: color || null
		};

		const { error } = editingId 
			? await supabase.from('categories').update(categoryData).eq('id', editingId)
			: await supabase.from('categories').insert(categoryData);

		if (!error) {
			isFormOpen = false;
			resetForm();
			fetchCategories();
		} else {
			alert(error.message);
		}
		formLoading = false;
	}

	function startEdit(cat: any) {
		editingId = cat.id;
		name = cat.name;
		slug = cat.slug;
		icon = cat.icon || '';
		color = cat.color || '';
		isFormOpen = true;
	}

	function resetForm() {
		editingId = null;
		name = '';
		slug = '';
		icon = '';
		color = '#3b82f6';
	}

	async function deleteCategory(id: string) {
		if (confirm('Are you sure? This may affect videos associated with this category.')) {
			const { error } = await supabase.from('categories').delete().eq('id', id);
			if (!error) {
				fetchCategories();
			} else if (error.code === '23503') {
				alert('Cannot delete category: it is currently used by one or more videos.');
			} else {
				alert(error.message);
			}
		}
	}
</script>

<div class="space-y-8">
	<!-- Header -->
	<div class="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
		<div class="space-y-1">
			<h1 class="text-3xl font-black text-slate-900 tracking-tight">Category Management</h1>
			<p class="text-sm font-bold text-slate-500">Organize your content into meaningful sections</p>
		</div>
		<button 
			onclick={() => { resetForm(); isFormOpen = true; }}
			class="inline-flex h-12 items-center gap-2 rounded-2xl bg-blue-600 px-6 text-sm font-black text-white shadow-xl shadow-blue-200 transition-all hover:bg-blue-700 active:scale-95"
		>
			<Plus size={20} />
			New Category
		</button>
	</div>

	<!-- Stats Strip -->
	<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
		<div class="bg-white p-6 rounded-[32px] border border-slate-100 shadow-sm">
			<p class="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-1">Total Categories</p>
			<p class="text-3xl font-black text-slate-900">{categories.length}</p>
		</div>
	</div>

	<!-- Main List -->
	<div class="relative overflow-hidden rounded-[32px] border border-slate-200 bg-white shadow-sm">
		{#if loading}
			<div class="flex h-64 flex-col items-center justify-center gap-3">
				<Loader2 size={32} class="animate-spin text-blue-600" />
				<p class="text-sm font-medium text-slate-500">Loading categories...</p>
			</div>
		{:else if categories.length === 0}
			<div class="flex h-96 flex-col items-center justify-center gap-4 text-center p-8">
				<div class="flex h-20 w-20 items-center justify-center rounded-3xl bg-slate-50 text-slate-300">
					<LayoutGrid size={40} />
				</div>
				<div>
					<h3 class="text-lg font-bold text-slate-900">No categories found</h3>
					<p class="mt-1 max-w-xs text-sm text-slate-500">Start by creating your first content category.</p>
				</div>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-left">
					<thead class="bg-slate-50 border-b border-slate-100">
						<tr>
							<th class="px-6 py-4 text-xs font-black uppercase tracking-widest text-slate-400">Category Name</th>
							<th class="px-6 py-4 text-xs font-black uppercase tracking-widest text-slate-400">Slug</th>
							<th class="px-6 py-4 text-xs font-black uppercase tracking-widest text-slate-400">Icon / Color</th>
							<th class="px-6 py-4 text-xs font-black uppercase tracking-widest text-slate-400 text-right">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each categories as cat}
							<tr class="group transition-colors hover:bg-slate-50/50">
								<td class="px-6 py-5">
									<p class="text-sm font-black text-slate-900">{cat.name}</p>
								</td>
								<td class="px-6 py-5">
									<code class="text-xs font-bold text-slate-500 bg-slate-100 px-2 py-1 rounded-lg">{cat.slug}</code>
								</td>
								<td class="px-6 py-5">
									<div class="flex items-center gap-3">
										<div class="h-8 w-8 rounded-lg flex items-center justify-center text-white font-bold text-xs" style={`background-color: ${cat.color || '#cbd5e1'}`}>
											{cat.icon || cat.name.charAt(0)}
										</div>
										<span class="text-xs font-bold text-slate-500">{cat.color || 'No color'}</span>
									</div>
								</td>
								<td class="px-6 py-5 text-right">
									<div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
										<button 
											onclick={() => startEdit(cat)}
											class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all"
										>
											<Edit2 size={16} />
										</button>
										<button 
											onclick={() => deleteCategory(cat.id)}
											class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all"
										>
											<Trash2 size={16} />
										</button>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>
</div>

<!-- Category Form Modal -->
{#if isFormOpen}
	<div 
		transition:fade={{ duration: 150 }}
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4"
	>
		<div 
			transition:fly={{ y: 20, duration: 250 }}
			class="w-full max-w-lg overflow-hidden rounded-[32px] bg-white shadow-2xl"
		>
			<div class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
				<h2 class="text-xl font-black text-slate-900">{editingId ? 'Edit Category' : 'New Category'}</h2>
				<button onclick={() => isFormOpen = false} class="text-slate-400 hover:text-slate-900 transition-colors">
					<X size={20} />
				</button>
			</div>

			<form onsubmit={e => { e.preventDefault(); handleSaveCategory(); }} class="p-8 space-y-6">
				<div class="space-y-4">
					<div class="space-y-1">
						<label for="name" class="text-[10px] font-black uppercase tracking-widest text-slate-500 ml-1">Category Name</label>
						<input 
							id="name"
							bind:value={name}
							required
							placeholder="e.g. Computer Science"
							class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-bold outline-none focus:border-blue-500 focus:bg-white transition-all"
						/>
					</div>

					<div class="space-y-1">
						<label for="slug" class="text-[10px] font-black uppercase tracking-widest text-slate-500 ml-1">Url Slug</label>
						<input 
							id="slug"
							bind:value={slug}
							required
							placeholder="computer-science"
							class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-bold outline-none focus:border-blue-500 focus:bg-white transition-all"
						/>
					</div>

					<div class="grid grid-cols-2 gap-4">
						<div class="space-y-1">
							<label for="icon" class="text-[10px] font-black uppercase tracking-widest text-slate-500 ml-1">Icon (Emoji/Char)</label>
							<input 
								id="icon"
								bind:value={icon}
								placeholder="🚀"
								maxlength="2"
								class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-bold outline-none focus:border-blue-500 focus:bg-white transition-all"
							/>
						</div>
						<div class="space-y-1">
							<label for="color" class="text-[10px] font-black uppercase tracking-widest text-slate-500 ml-1">Color (Hex)</label>
							<input 
								id="color"
								type="color"
								bind:value={color}
								class="w-full h-11 rounded-2xl border border-slate-200 bg-slate-50 p-1 outline-none focus:border-blue-500 focus:bg-white transition-all cursor-pointer"
							/>
						</div>
					</div>
				</div>

				<div class="flex gap-3 pt-4">
					<button 
						type="button"
						onclick={() => isFormOpen = false}
						class="flex-1 rounded-2xl bg-slate-100 py-4 text-sm font-black text-slate-600 transition-all hover:bg-slate-200"
					>
						Cancel
					</button>
					<button 
						type="submit"
						disabled={formLoading}
						class="flex-2 flex-[2] rounded-2xl bg-blue-600 py-4 text-sm font-black text-white shadow-xl shadow-blue-200 transition-all hover:bg-blue-700 disabled:opacity-50"
					>
						{formLoading ? 'Saving...' : editingId ? 'Update Category' : 'Create Category'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}
