-- Initial schema for EduPlatform

-- 1. Profiles (Extends Supabase Auth)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  role text check (role in ('student', 'admin')) default 'student',
  username text unique,
  avatar_url text,
  points integer default 0,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- 2. Categories
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  icon text,
  color text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 3. Videos
create table videos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  video_url text,
  youtube_url text,
  thumbnail_url text,
  category_id uuid references categories(id),
  difficulty_level text check (difficulty_level in ('beginner', 'intermediate', 'advanced')),
  is_published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 4. Quizzes
create table quizzes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  time_limit integer, -- in minutes
  passing_score integer,
  is_published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 5. Quiz Questions
create table quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid references quizzes(id) on delete cascade,
  question text not null,
  type text check (type in ('mcq', 'multi-select', 'boolean', 'fill-in-the-blank')),
  options jsonb, -- e.g. [{"text": "A", "is_correct": true}, ...]
  correct_answer text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 6. Quiz Attempts
create table quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  quiz_id uuid references quizzes(id) on delete cascade,
  score integer not null,
  answers jsonb,
  completed_at timestamp with time zone default timezone('utc'::text, now())
);

-- 7. Tests
create table tests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  instructions text,
  duration_minutes integer,
  available_from timestamp with time zone,
  available_to timestamp with time zone,
  is_published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 8. Test Questions
create table test_questions (
  id uuid primary key default gen_random_uuid(),
  test_id uuid references tests(id) on delete cascade,
  question text not null,
  type text,
  options jsonb,
  correct_answer text,
  marks integer default 1,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 9. Test Attempts
create table test_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  test_id uuid references tests(id) on delete cascade,
  score integer,
  answers jsonb,
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

-- 10. Blogs
create table blogs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique not null,
  content text not null,
  excerpt text,
  cover_image text,
  author_id uuid references profiles(id),
  category_id uuid references categories(id),
  published_at timestamp with time zone,
  is_published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 11. Books
create table books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text,
  pdf_url text,
  external_url text,
  cover_image text,
  subject text,
  description text,
  is_published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 12. Notes
create table notes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  category_id uuid references categories(id),
  topic text,
  author_id uuid references profiles(id),
  is_published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 13. News
create table news (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text,
  content text,
  source_url text,
  category text,
  is_published boolean default false,
  published_at timestamp with time zone default timezone('utc'::text, now()),
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 14. Bookmarks
create table bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  content_type text not null, -- 'video', 'blog', 'note', 'book'
  content_id uuid not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 15. Video Progress
create table video_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  video_id uuid references videos(id) on delete cascade,
  progress_seconds integer default 0,
  completed boolean default false,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- 16. TRIGGERS
-- Create profile on signup
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, role)
  values (new.id, new.email, 'student');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Enable RLS
alter table profiles enable row level security;
alter table categories enable row level security;
alter table videos enable row level security;
alter table quizzes enable row level security;
alter table quiz_questions enable row level security;
alter table quiz_attempts enable row level security;
alter table tests enable row level security;
alter table test_questions enable row level security;
alter table test_attempts enable row level security;
alter table blogs enable row level security;
alter table books enable row level security;
alter table notes enable row level security;
alter table news enable row level security;
alter table bookmarks enable row level security;
alter table video_progress enable row level security;

-- Policies (Simplified for now - can be refined later)
create policy "Public can read published content" on videos for select using (is_published = true);
create policy "Public can read published content" on blogs for select using (is_published = true);
create policy "Public can read published content" on books for select using (is_published = true);
create policy "Public can read published content" on notes for select using (is_published = true);
create policy "Public can read published content" on news for select using (is_published = true);
create policy "Public can read categories" on categories for select using (true);

create policy "Users can manage their own profile" on profiles for all using (auth.uid() = id);
create policy "Users can manage their own attempts" on quiz_attempts for all using (auth.uid() = user_id);
create policy "Users can manage their own attempts" on test_attempts for all using (auth.uid() = user_id);
create policy "Users can manage their own progress" on video_progress for all using (auth.uid() = user_id);
create policy "Users can manage their own bookmarks" on bookmarks for all using (auth.uid() = user_id);
