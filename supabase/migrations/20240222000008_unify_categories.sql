-- Add category_id to quizzes and news for unified categorization
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES public.categories(id);
ALTER TABLE public.news ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES public.categories(id);
ALTER TABLE public.books ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES public.categories(id);
ALTER TABLE public.tests ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES public.categories(id);

-- Migration of existing text category in news to unified categories table could be done here,
-- but since we are in dev/initial phase, we'll just add the column.
