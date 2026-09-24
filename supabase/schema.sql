-- Schema recomendado para o modelo multi-torneio do CrieSeuVolei
-- Use em: Supabase > SQL Editor

CREATE TABLE IF NOT EXISTS tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_email TEXT NOT NULL,
  scorer_emails TEXT[] NOT NULL DEFAULT '{}',
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS app_state (
  id INTEGER PRIMARY KEY,
  game_data JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura pública dos torneios"
  ON tournaments FOR SELECT USING (true);

CREATE POLICY "Autenticado pode criar torneios"
  ON tournaments FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Autenticado pode atualizar torneios"
  ON tournaments FOR UPDATE USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Autenticado pode deletar torneios"
  ON tournaments FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Leitura pública do estado legado"
  ON app_state FOR SELECT USING (true);

CREATE POLICY "Admin autenticado pode gravar estado legado"
  ON app_state FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

ALTER PUBLICATION supabase_realtime ADD TABLE tournaments;
ALTER PUBLICATION supabase_realtime ADD TABLE app_state;
