import { writable } from 'svelte/store';

export const isAuthModalOpen = writable(false);
export const authModalMode = writable<'login' | 'signup'>('login');

export function openLogin() {
    authModalMode.set('login');
    isAuthModalOpen.set(true);
}

export function openSignup() {
    authModalMode.set('signup');
    isAuthModalOpen.set(true);
}
