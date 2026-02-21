-- Create new tables for News, Books, and Bookmarks

-- 1. News table
create table if not exists public.news (
    id uuid default gen_random_uuid() primary key,
    title text not null,
    summary text,
    content text,
    category text default 'Exams',
    is_published boolean default true,
    published_at timestamp with time zone default now(),
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

-- 2. Books / Digital Library table
create table if not exists public.books (
    id uuid default gen_random_uuid() primary key,
    title text not null,
    author text,
    subject text,
    description text,
    cover_image text,
    file_url text,
    is_published boolean default true,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

-- 3. Bookmarks table
create table if not exists public.bookmarks (
    id uuid default gen_random_uuid() primary key,
    user_id uuid references auth.users(id) on delete cascade not null,
    content_id uuid not null, -- Can be video_id, blog_id, note_id, etc.
    content_type text not null, -- 'video', 'blog', 'note', 'book'
    created_at timestamp with time zone default now(),
    unique(user_id, content_id, content_type)
);

-- Enable RLS
alter table public.news enable row level security;
alter table public.books enable row level security;
alter table public.bookmarks enable row level security;

-- Policies for News
drop policy if exists "Published news are viewable by everyone" on public.news;
create policy "Published news are viewable by everyone" on public.news
    for select using (is_published = true);
drop policy if exists "Admins can manage news" on public.news;
create policy "Admins can manage news" on public.news
    using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') );

-- Policies for Books
drop policy if exists "Published books are viewable by everyone" on public.books;
create policy "Published books are viewable by everyone" on public.books
    for select using (is_published = true);
drop policy if exists "Admins can manage books" on public.books;
create policy "Admins can manage books" on public.books
    using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') );

-- Policies for Bookmarks
drop policy if exists "Users can manage their own bookmarks" on public.bookmarks;
create policy "Users can manage their own bookmarks" on public.bookmarks
    using ( auth.uid() = user_id );

-- Refresh Leaderboard View (re-run to ensure it includes new profiles)
create or replace view public.leaderboard as
select 
  id,
  username,
  avatar_url,
  points,
  rank() over (order by points desc) as rank
from public.profiles
where role = 'student'
order by points desc;
