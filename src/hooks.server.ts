import { createServerClient } from '@supabase/ssr';
import type { Handle } from '@sveltejs/kit';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';

export const handle: Handle = async ({ event, resolve }) => {
    // Create a Supabase client for the server context
    event.locals.supabase = createServerClient(
        PUBLIC_SUPABASE_URL,
        PUBLIC_SUPABASE_ANON_KEY,
        {
            cookies: {
                getAll: () => event.cookies.getAll(),
                setAll: (cookiesToSet) => {
                    cookiesToSet.forEach(({ name, value, options }) => {
                        event.cookies.set(name, value, { ...options, path: '/' });
                    });
                },
            },
        }
    );

    // Get the session for auth-guarded routes
    event.locals.getSession = async () => {
        const { data: { session } } = await event.locals.supabase.auth.getSession();
        return session;
    };

    // Protect admin routes
    if (event.url.pathname.startsWith('/admin')) {
        const session = await event.locals.getSession();

        if (!session) {
            return new Response(null, {
                status: 303,
                headers: { location: '/?auth=login' }
            });
        }

        // Check if user is admin
        const { data: profile } = await event.locals.supabase
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .single();

        if (profile?.role !== 'admin') {
            return new Response(null, {
                status: 303,
                headers: { location: '/dashboard' }
            });
        }
    }

    // Protect student routes (require login)
    if (event.url.pathname.startsWith('/dashboard')) {
        const session = await event.locals.getSession();
        if (!session) {
            return new Response(null, {
                status: 303,
                headers: { location: '/?auth=login' }
            });
        }
    }

    return resolve(event, {
        filterSerializedResponseHeaders(name) {
            return name === 'content-range' || name === 'x-supabase-api-version';
        },
    });
};
