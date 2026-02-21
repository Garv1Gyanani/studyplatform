-- ==============================================================
-- ADMIN POLICIES: Grant full CRUD to admin-role users
-- ==============================================================

-- Helper: Check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ==================== VIDEOS ====================
DROP POLICY IF EXISTS "Admins can insert videos" ON videos;
CREATE POLICY "Admins can insert videos" ON videos
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update videos" ON videos;
CREATE POLICY "Admins can update videos" ON videos
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete videos" ON videos;
CREATE POLICY "Admins can delete videos" ON videos
  FOR DELETE USING (public.is_admin());

-- ==================== BLOGS ====================
DROP POLICY IF EXISTS "Admins can insert blogs" ON blogs;
CREATE POLICY "Admins can insert blogs" ON blogs
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update blogs" ON blogs;
CREATE POLICY "Admins can update blogs" ON blogs
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete blogs" ON blogs;
CREATE POLICY "Admins can delete blogs" ON blogs
  FOR DELETE USING (public.is_admin());

-- ==================== NOTES ====================
DROP POLICY IF EXISTS "Admins can insert notes" ON notes;
CREATE POLICY "Admins can insert notes" ON notes
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update notes" ON notes;
CREATE POLICY "Admins can update notes" ON notes
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete notes" ON notes;
CREATE POLICY "Admins can delete notes" ON notes
  FOR DELETE USING (public.is_admin());

-- ==================== QUIZZES ====================
DROP POLICY IF EXISTS "Admins can insert quizzes" ON quizzes;
CREATE POLICY "Admins can insert quizzes" ON quizzes
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update quizzes" ON quizzes;
CREATE POLICY "Admins can update quizzes" ON quizzes
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete quizzes" ON quizzes;
CREATE POLICY "Admins can delete quizzes" ON quizzes
  FOR DELETE USING (public.is_admin());

-- ==================== QUIZ QUESTIONS ====================
DROP POLICY IF EXISTS "Admins can insert quiz_questions" ON quiz_questions;
CREATE POLICY "Admins can insert quiz_questions" ON quiz_questions
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update quiz_questions" ON quiz_questions;
CREATE POLICY "Admins can update quiz_questions" ON quiz_questions
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete quiz_questions" ON quiz_questions;
CREATE POLICY "Admins can delete quiz_questions" ON quiz_questions
  FOR DELETE USING (public.is_admin());

-- ==================== NEWS ====================
DROP POLICY IF EXISTS "Admins can insert news" ON news;
CREATE POLICY "Admins can insert news" ON news
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update news" ON news;
CREATE POLICY "Admins can update news" ON news
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete news" ON news;
CREATE POLICY "Admins can delete news" ON news
  FOR DELETE USING (public.is_admin());

-- ==================== BOOKS ====================
DROP POLICY IF EXISTS "Admins can insert books" ON books;
CREATE POLICY "Admins can insert books" ON books
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update books" ON books;
CREATE POLICY "Admins can update books" ON books
  FOR UPDATE USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete books" ON books;
CREATE POLICY "Admins can delete books" ON books
  FOR DELETE USING (public.is_admin());

-- ==================== CATEGORIES ====================
DROP POLICY IF EXISTS "Admins can manage categories" ON categories;
CREATE POLICY "Admins can manage categories" ON categories
  FOR ALL USING (public.is_admin());

-- ==================== PROFILES (admin read-all) ====================
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
CREATE POLICY "Admins can read all profiles" ON profiles
  FOR SELECT USING (public.is_admin() OR auth.uid() = id);

DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
CREATE POLICY "Admins can update all profiles" ON profiles
  FOR UPDATE USING (public.is_admin() OR auth.uid() = id);
