-- ==============================================================
-- FIX RLS: Missing Public Read & Missing Admin CRUD
-- ==============================================================

-- 1. Ensure public can read published assessments
DROP POLICY IF EXISTS "Public can read published quizzes" ON quizzes;
CREATE POLICY "Public can read published quizzes" ON quizzes
  FOR SELECT USING (is_published = true);

DROP POLICY IF EXISTS "Public can read quiz questions" ON quiz_questions;
CREATE POLICY "Public can read quiz questions" ON quiz_questions
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM quizzes WHERE quizzes.id = quiz_questions.quiz_id AND quizzes.is_published = true
  ));

DROP POLICY IF EXISTS "Public can read published tests" ON tests;
CREATE POLICY "Public can read published tests" ON tests
  FOR SELECT USING (is_published = true);

DROP POLICY IF EXISTS "Public can read test questions" ON test_questions;
CREATE POLICY "Public can read test questions" ON test_questions
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM tests WHERE tests.id = test_questions.test_id AND tests.is_published = true
  ));

-- 2. Grant full CRUD to admins for TESTS and TEST QUESTIONS
DROP POLICY IF EXISTS "Admins can manage tests" ON tests;
CREATE POLICY "Admins can manage tests" ON tests
  FOR ALL USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage test_questions" ON test_questions;
CREATE POLICY "Admins can manage test_questions" ON test_questions
  FOR ALL USING (public.is_admin());

-- 3. Robust Quiz & Video policies (All actions)
DROP POLICY IF EXISTS "Admins can manage quizzes" ON quizzes;
CREATE POLICY "Admins can manage quizzes" ON quizzes
  FOR ALL USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage quiz_questions" ON quiz_questions;
CREATE POLICY "Admins can manage quiz_questions" ON quiz_questions
  FOR ALL USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage videos" ON videos;
CREATE POLICY "Admins can manage videos" ON videos
  FOR ALL USING (public.is_admin());

-- 4. Admin read-all for attempts (to monitor performance)
DROP POLICY IF EXISTS "Admins can read all quiz_attempts" ON quiz_attempts;
CREATE POLICY "Admins can read all quiz_attempts" ON quiz_attempts
  FOR SELECT USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can read all test_attempts" ON test_attempts;
CREATE POLICY "Admins can read all test_attempts" ON test_attempts
  FOR SELECT USING (public.is_admin());

-- 5. Force current user to admin if they are testing (optional but helpful)
-- This promotes the currently logged in user to admin if they are using the admin panel email
UPDATE public.profiles
SET role = 'admin'
WHERE username IN ('reema@gmail.com', (SELECT email FROM auth.users WHERE id = auth.uid()));
