BEGIN;

ALTER TABLE public.tournament_invites
  ADD COLUMN IF NOT EXISTS invite_token TEXT,
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

CREATE UNIQUE INDEX IF NOT EXISTS tournament_invites_invite_token_unique
  ON public.tournament_invites (invite_token)
  WHERE invite_token IS NOT NULL;
UPDATE public.tournament_invites
SET status = 'expired', updated_at = NOW()
WHERE status = 'pending' AND invite_token IS NULL;

DROP FUNCTION IF EXISTS public.create_tournament_invite(UUID, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.accept_tournament_invite(UUID);

CREATE OR REPLACE FUNCTION public.create_tournament_invite(
  p_tournament_id UUID,
  p_invited_email TEXT,
  p_invite_token TEXT,
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
  IF p_invite_token IS NULL OR p_invite_token !~ '^[A-Za-z0-9_-]{43}$' THEN
    RAISE EXCEPTION 'invalid invite token';
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

  INSERT INTO public.tournament_invites (
    tournament_id, inviter_id, invited_email, role, status, invite_token, expires_at
  )
  VALUES (
    p_tournament_id, auth.uid(), v_email, p_role, 'pending',
    p_invite_token, NOW() + INTERVAL '30 days'
  )
  ON CONFLICT (tournament_id, invited_email)
  DO UPDATE SET inviter_id = EXCLUDED.inviter_id,
                role = EXCLUDED.role,
                status = 'pending',
                invite_token = EXCLUDED.invite_token,
                expires_at = EXCLUDED.expires_at,
                updated_at = NOW()
  RETURNING id INTO v_invite_id;
  RETURN v_invite_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.accept_tournament_invite(p_invite_token TEXT)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_email TEXT := lower(COALESCE(auth.jwt()->>'email', ''));
  v_role TEXT;
  v_tournament_id UUID;
  v_invite_id UUID;
BEGIN
  IF auth.uid() IS NULL OR v_email = '' OR p_invite_token IS NULL THEN
    RAISE EXCEPTION 'sign in with the invited account';
  END IF;

  SELECT ti.id, ti.tournament_id, ti.role
  INTO v_invite_id, v_tournament_id, v_role
  FROM public.tournament_invites ti
  WHERE ti.invite_token = p_invite_token
    AND lower(ti.invited_email) = v_email
    AND ti.status = 'pending'
    AND ti.expires_at > NOW()
  FOR UPDATE;

  IF v_role IS NULL THEN
    RAISE EXCEPTION 'no valid invitation for this account';
  END IF;

  INSERT INTO public.tournament_members (tournament_id, user_id, email, role)
  VALUES (v_tournament_id, auth.uid(), v_email, v_role)
  ON CONFLICT (tournament_id, user_id)
  DO UPDATE SET email = EXCLUDED.email, role = EXCLUDED.role;

  UPDATE public.tournament_invites
  SET status = 'accepted', invite_token = NULL, updated_at = NOW()
  WHERE id = v_invite_id;

  RETURN v_tournament_id;
END;
$$;

REVOKE ALL ON FUNCTION public.create_tournament_invite(UUID, TEXT, TEXT, TEXT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.accept_tournament_invite(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_tournament_invite(UUID, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_tournament_invite(TEXT) TO authenticated;

COMMIT;
