-- Add duration column to videos table
alter table public.videos add column if not exists duration text default '15m';
