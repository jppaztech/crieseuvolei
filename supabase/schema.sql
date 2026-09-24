-- Schema recomendado para o modelo multi-torneio do CrieSeuVolei
-- Use em: Supabase > SQL Editor

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
  name TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  owner_email TEXT NOT NULL,
  scorer_emails TEXT[] NOT NULL DEFAULT '{}',
  invite_emails TEXT[] NOT NULL DEFAULT '{}',
  is_public BOOLEAN NOT NULL DEFAULT TRUE,
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tournament_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')) DEFAULT 'editor',
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

CREATE TABLE IF NOT EXISTS public.app_state (
  id INTEGER PRIMARY KEY,
  game_data JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Perfil pode visualizar o próprio registro"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Perfil pode criar o próprio registro"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Perfil pode atualizar o próprio registro"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Torneios públicos podem ser vistos por qualquer usuário"
  ON public.tournaments FOR SELECT
  USING (
    is_public = TRUE OR
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = tournaments.id AND tm.user_id = auth.uid()
    )
  );

CREATE POLICY "Somente o responsável pode criar torneios"
  ON public.tournaments FOR INSERT
  WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = owner_id);

CREATE POLICY "Responsável ou editor pode atualizar torneio"
  ON public.tournaments FOR UPDATE
  USING (
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = tournaments.id
        AND tm.user_id = auth.uid()
        AND tm.role IN ('owner', 'editor')
    )
  )
  WITH CHECK (
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = tournaments.id
        AND tm.user_id = auth.uid()
        AND tm.role IN ('owner', 'editor')
    )
  );

CREATE POLICY "Responsável pode excluir torneio"
  ON public.tournaments FOR DELETE
  USING (owner_id = auth.uid());

CREATE POLICY "Usuários autenticados podem ver membros do torneio"
  ON public.tournament_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = tournament_members.tournament_id
        AND (
          t.owner_id = auth.uid() OR
          EXISTS (
            SELECT 1 FROM public.tournament_members tm
            WHERE tm.tournament_id = t.id AND tm.user_id = auth.uid()
          )
        )
    )
  );

CREATE POLICY "Responsável pode gerenciar membros do torneio"
  ON public.tournament_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = tournament_members.tournament_id AND t.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = tournament_members.tournament_id AND t.owner_id = auth.uid()
    )
  );

CREATE POLICY "Visitantes podem ver convites pendentes para si"
  ON public.tournament_invites FOR SELECT
  USING (
    invited_email = auth.email() OR
    EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = tournament_invites.tournament_id AND t.owner_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.tournament_members tm
      WHERE tm.tournament_id = tournament_invites.tournament_id
        AND tm.user_id = auth.uid()
        AND tm.role IN ('owner', 'editor')
    )
  );

CREATE POLICY "Responsável pode criar e atualizar convites"
  ON public.tournament_invites FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = tournament_invites.tournament_id AND t.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.tournaments t
      WHERE t.id = tournament_invites.tournament_id AND t.owner_id = auth.uid()
    )
  );

CREATE POLICY "Leitura pública do estado legado"
  ON public.app_state FOR SELECT USING (true);

CREATE POLICY "Admin autenticado pode gravar estado legado"
  ON public.app_state FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE OR REPLACE FUNCTION public.handle_profile_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.handle_profile_update();

CREATE OR REPLACE FUNCTION public.handle_tournament_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tournaments_updated_at
BEFORE UPDATE ON public.tournaments
FOR EACH ROW
EXECUTE FUNCTION public.handle_tournament_update();

CREATE OR REPLACE FUNCTION public.handle_invite_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_invites_updated_at
BEFORE UPDATE ON public.tournament_invites
FOR EACH ROW
EXECUTE FUNCTION public.handle_invite_update();

ALTER PUBLICATION supabase_realtime ADD TABLE public.tournaments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tournament_members;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tournament_invites;
ALTER PUBLICATION supabase_realtime ADD TABLE public.app_state;
