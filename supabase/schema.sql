-- Execute no SQL Editor do Supabase. Pode ser reaplicado sem apagar torneios.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 80),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  owner_email TEXT,
  scorer_emails TEXT[] NOT NULL DEFAULT '{}',
  invite_emails TEXT[] NOT NULL DEFAULT '{}',
  is_public BOOLEAN NOT NULL DEFAULT TRUE,
  status TEXT NOT NULL DEFAULT 'draft',
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.tournaments ADD COLUMN IF NOT EXISTS is_public BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.tournaments ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'draft';
ALTER TABLE public.tournaments ADD COLUMN IF NOT EXISTS game_data JSONB NOT NULL DEFAULT '{}'::jsonb;
ALTER TABLE public.tournaments ADD COLUMN IF NOT EXISTS owner_email TEXT;
ALTER TABLE public.tournaments ADD COLUMN IF NOT EXISTS scorer_emails TEXT[] NOT NULL DEFAULT '{}';
ALTER TABLE public.tournaments ADD COLUMN IF NOT EXISTS invite_emails TEXT[] NOT NULL DEFAULT '{}';
ALTER TABLE public.tournaments ALTER COLUMN owner_email DROP NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.tournaments'::regclass AND conname = 'tournaments_status_check'
  ) THEN
    ALTER TABLE public.tournaments
      ADD CONSTRAINT tournaments_status_check CHECK (status IN ('draft', 'live', 'finished'));
  END IF;
END;
$$;

CREATE TABLE IF NOT EXISTS public.tournament_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('editor', 'viewer')) DEFAULT 'editor',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tournament_id, user_id),
  UNIQUE (tournament_id, email)
);

CREATE TABLE IF NOT EXISTS public.tournament_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invited_email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('editor', 'viewer')) DEFAULT 'editor',
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')) DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tournament_id, invited_email)
);

CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS BOOLEAN
LANGUAGE sql STABLE
AS $$
  SELECT COALESCE(auth.jwt()->'app_metadata'->>'platform_admin', 'false') = 'true';
$$;

CREATE OR REPLACE FUNCTION public.is_tournament_member(p_tournament_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT public.is_platform_admin()
    OR EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = p_tournament_id AND t.owner_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = p_tournament_id AND tm.user_id = auth.uid()
    );
$$;

CREATE OR REPLACE FUNCTION public.is_tournament_editor(p_tournament_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT public.is_platform_admin()
    OR EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = p_tournament_id AND t.owner_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = p_tournament_id
        AND tm.user_id = auth.uid()
        AND tm.role = 'editor'
    );
$$;

CREATE OR REPLACE FUNCTION public.create_tournament_invite(
  p_tournament_id UUID,
  p_invited_email TEXT,
  p_role TEXT DEFAULT 'editor'
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_email TEXT := lower(trim(p_invited_email));
  v_invite_id UUID;
BEGIN
  IF auth.uid() IS NULL OR NOT public.is_tournament_editor(p_tournament_id) THEN
    RAISE EXCEPTION 'not authorized to invite co-admins';
  END IF;
  IF v_email = '' OR v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' THEN
    RAISE EXCEPTION 'invalid email address';
  END IF;
  IF lower(COALESCE(auth.jwt()->>'email', '')) = v_email THEN
    RAISE EXCEPTION 'cannot invite your own account';
  END IF;
  IF p_role NOT IN ('editor', 'viewer') THEN
    RAISE EXCEPTION 'invalid invitation role';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.tournament_members tm
    WHERE tm.tournament_id = p_tournament_id AND lower(tm.email) = v_email
  ) THEN
    RAISE EXCEPTION 'user is already a tournament member';
  END IF;

  INSERT INTO public.tournament_invites (tournament_id, inviter_id, invited_email, role, status)
  VALUES (p_tournament_id, auth.uid(), v_email, p_role, 'pending')
  ON CONFLICT (tournament_id, invited_email)
  DO UPDATE SET inviter_id = EXCLUDED.inviter_id,
                role = EXCLUDED.role,
                status = 'pending',
                updated_at = NOW()
  RETURNING id INTO v_invite_id;
  RETURN v_invite_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.accept_tournament_invite(p_tournament_id UUID)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_email TEXT := lower(COALESCE(auth.jwt()->>'email', ''));
  v_role TEXT;
BEGIN
  IF auth.uid() IS NULL OR v_email = '' THEN
    RAISE EXCEPTION 'sign in with the invited account';
  END IF;

  SELECT ti.role INTO v_role
  FROM public.tournament_invites ti
  WHERE ti.tournament_id = p_tournament_id
    AND lower(ti.invited_email) = v_email
    AND ti.status = 'pending'
  FOR UPDATE;

  IF v_role IS NULL THEN
    IF EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = p_tournament_id AND tm.user_id = auth.uid()
    ) THEN
      RETURN p_tournament_id;
    END IF;
    RAISE EXCEPTION 'no pending invitation for this account';
  END IF;

  INSERT INTO public.tournament_members (tournament_id, user_id, email, role)
  VALUES (p_tournament_id, auth.uid(), v_email, v_role)
  ON CONFLICT (tournament_id, user_id)
  DO UPDATE SET email = EXCLUDED.email, role = EXCLUDED.role;

  UPDATE public.tournament_invites
  SET status = 'accepted', updated_at = NOW()
  WHERE tournament_id = p_tournament_id AND lower(invited_email) = v_email;

  RETURN p_tournament_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_auth_user_created()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (NEW.id, NEW.email, NULLIF(trim(NEW.raw_user_meta_data->>'display_name'), ''))
  ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_profile ON auth.users;
CREATE TRIGGER on_auth_user_created_profile
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_auth_user_created();

CREATE OR REPLACE FUNCTION public.protect_profile_admin_flag()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.is_admin IS DISTINCT FROM OLD.is_admin AND NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'platform admin is managed by platform operators';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_profile_admin_flag_trigger ON public.profiles;
CREATE TRIGGER protect_profile_admin_flag_trigger
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.protect_profile_admin_flag();

CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tournaments_touch_updated_at ON public.tournaments;
CREATE TRIGGER tournaments_touch_updated_at
BEFORE UPDATE ON public.tournaments
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS tournament_invites_touch_updated_at ON public.tournament_invites;
CREATE TRIGGER tournament_invites_touch_updated_at
BEFORE UPDATE ON public.tournament_invites
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

CREATE OR REPLACE FUNCTION public.protect_tournament_owner()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.owner_id IS DISTINCT FROM OLD.owner_id AND NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'only platform operators may transfer tournament ownership';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_tournament_owner_trigger ON public.tournaments;
CREATE TRIGGER protect_tournament_owner_trigger
BEFORE UPDATE ON public.tournaments
FOR EACH ROW EXECUTE FUNCTION public.protect_tournament_owner();

DO $$
DECLARE
  p RECORD;
BEGIN
  FOR p IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('profiles', 'tournaments', 'tournament_members', 'tournament_invites', 'app_state')
  LOOP
    EXECUTE format('DROP POLICY %I ON %I.%I', p.policyname, p.schemaname, p.tablename);
  END LOOP;
END;
$$;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_invites ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF to_regclass('public.app_state') IS NOT NULL THEN
    ALTER TABLE public.app_state ENABLE ROW LEVEL SECURITY;
  END IF;
END;
$$;

CREATE POLICY profiles_read_self ON public.profiles
  FOR SELECT TO authenticated USING (id = auth.uid() OR public.is_platform_admin());
CREATE POLICY profiles_update_self ON public.profiles
  FOR UPDATE TO authenticated USING (id = auth.uid() OR public.is_platform_admin())
  WITH CHECK (id = auth.uid() OR public.is_platform_admin());

CREATE POLICY tournaments_read_public_or_member ON public.tournaments
  FOR SELECT TO anon, authenticated
  USING (
    public.is_platform_admin()
    OR (is_public AND status = 'live')
    OR owner_id = auth.uid()
    OR public.is_tournament_member(id)
  );
CREATE POLICY tournaments_insert_owner ON public.tournaments
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid() OR public.is_platform_admin());
CREATE POLICY tournaments_update_editor ON public.tournaments
  FOR UPDATE TO authenticated
  USING (public.is_tournament_editor(id))
  WITH CHECK (public.is_tournament_editor(id));
CREATE POLICY tournaments_delete_owner ON public.tournaments
  FOR DELETE TO authenticated
  USING (owner_id = auth.uid() OR public.is_platform_admin());

CREATE POLICY tournament_members_read_self_or_editors ON public.tournament_members
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_tournament_editor(tournament_id));

CREATE POLICY tournament_invites_read_invitee_or_editors ON public.tournament_invites
  FOR SELECT TO authenticated
  USING (
    lower(invited_email) = lower(COALESCE(auth.jwt()->>'email', ''))
    OR public.is_tournament_editor(tournament_id)
  );

REVOKE ALL ON public.profiles, public.tournaments, public.tournament_members, public.tournament_invites FROM PUBLIC, anon, authenticated;
REVOKE SELECT (owner_email, scorer_emails, invite_emails) ON public.tournaments FROM anon, authenticated;
GRANT SELECT (id, name, owner_id, is_public, status, game_data, created_at, updated_at)
  ON public.tournaments TO anon, authenticated;
GRANT INSERT (name, owner_id, owner_email, is_public, status, game_data)
  ON public.tournaments TO authenticated;
GRANT UPDATE (name, is_public, status, game_data)
  ON public.tournaments TO authenticated;
GRANT DELETE ON public.tournaments TO authenticated;
GRANT SELECT (id, email, display_name, created_at, updated_at) ON public.profiles TO authenticated;
GRANT UPDATE (display_name) ON public.profiles TO authenticated;
GRANT SELECT (id, tournament_id, user_id, email, role, created_at)
  ON public.tournament_members TO authenticated;
GRANT SELECT (id, tournament_id, inviter_id, invited_email, role, status, created_at, updated_at)
  ON public.tournament_invites TO authenticated;

REVOKE ALL ON FUNCTION public.create_tournament_invite(UUID, TEXT, TEXT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.accept_tournament_invite(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_tournament_invite(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_tournament_invite(UUID) TO authenticated;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'tournaments') THEN
      EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.tournaments';
    END IF;
  END IF;
END;
$$;
