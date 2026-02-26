-- 1. Create Storage Buckets
insert into storage.buckets (id, name, public)
values ('resources', 'resources', true),
       ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- 2. Notes Table Update
alter table public.notes add column if not exists pdf_url text;

-- 3. Storage Policies for 'resources' bucket
-- Allow public access to read
create policy "Public Access to Resources"
on storage.objects for select
using ( bucket_id = 'resources' );

-- Allow admins to manage resources
create policy "Admins can manage resources"
on storage.objects for all
using (
  bucket_id = 'resources' 
  and (select role from public.profiles where id = auth.uid()) = 'admin'
)
with check (
  bucket_id = 'resources' 
  and (select role from public.profiles where id = auth.uid()) = 'admin'
);

-- 4. Storage Policies for 'avatars' bucket
create policy "Public Access to Avatars"
on storage.objects for select
using ( bucket_id = 'avatars' );

create policy "Users can manage their own avatar"
on storage.objects for all
using (
  bucket_id = 'avatars' 
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'avatars' 
  and auth.uid()::text = (storage.foldername(name))[1]
);
