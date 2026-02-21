-- Create a trigger function to automatically set the admin role for specific emails
CREATE OR REPLACE FUNCTION public.handle_admin_promotion()
RETURNS TRIGGER AS $$
BEGIN
  -- If the email is reema@gmail.com, set role to admin
  IF (SELECT email FROM auth.users WHERE id = NEW.id) = 'reema@gmail.com' THEN
    UPDATE public.profiles
    SET role = 'admin'
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger on the profiles table
-- We want it to run after an insert into profiles (which is triggered when a user signs up)
CREATE OR REPLACE TRIGGER on_profile_created_admin_check
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_promotion();

-- Also handle existing user if they already signed up
UPDATE public.profiles
SET role = 'admin'
WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'reema@gmail.com'
);
