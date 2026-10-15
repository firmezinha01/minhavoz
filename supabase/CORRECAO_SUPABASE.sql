-- ====================================================================
-- SCRIPT DE LIBERAÇÃO IMEDIATA (SUPABASE - REDE SOCIAL MINHA VOZ)
-- ====================================================================
-- Execute no SQL Editor do Supabase: https://supabase.com/dashboard
-- Este script é limpo, direto e não utiliza comandos restritos.
-- ====================================================================

-- 1. Desativar RLS em todas as tabelas principais
ALTER TABLE public.reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.waiting_times DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts DISABLE ROW LEVEL SECURITY;

-- 2. Derrubar políticas restritivas antigas
DROP POLICY IF EXISTS "Users insert reports" ON public.reports;
DROP POLICY IF EXISTS "Users insert waiting times" ON public.waiting_times;
DROP POLICY IF EXISTS "Users view own waiting times" ON public.waiting_times;
DROP POLICY IF EXISTS "Users read own profile" ON public.users;
DROP POLICY IF EXISTS "allow_all_reports" ON public.reports;
DROP POLICY IF EXISTS "allow_all_waiting_times" ON public.waiting_times;
DROP POLICY IF EXISTS "allow_all_users" ON public.users;

-- 3. Criar políticas públicas totais (caso o Supabase force o RLS ativado)
CREATE POLICY "allow_all_reports" ON public.reports FOR ALL TO anon, authenticated, service_role USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_waiting_times" ON public.waiting_times FOR ALL TO anon, authenticated, service_role USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_users" ON public.users FOR ALL TO anon, authenticated, service_role USING (true) WITH CHECK (true);

-- 4. Conceder permissões totais para o perfil público 'anon' e 'authenticated'
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.reports TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.waiting_times TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.users TO anon, authenticated, service_role;

-- 5. Remover travas de chave estrangeira e permitir publicações sem login obrigatório
ALTER TABLE public.reports DROP CONSTRAINT IF EXISTS reports_user_id_fkey;
ALTER TABLE public.waiting_times DROP CONSTRAINT IF EXISTS waiting_times_user_id_fkey;
ALTER TABLE public.reports ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.waiting_times ALTER COLUMN user_id DROP NOT NULL;

-- 6. Garantir criação das colunas do Mapa em Tempo Real (caso ainda não criadas)
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS hospital TEXT;
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS especialidade TEXT;
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS categoria TEXT;
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS tempo_espera_dias INT;
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS tempo_espera_horas NUMERIC;
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS cidade TEXT;
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS estado TEXT;

ALTER TABLE public.waiting_times ADD COLUMN IF NOT EXISTS setor TEXT;
ALTER TABLE public.waiting_times ADD COLUMN IF NOT EXISTS categoria TEXT;
ALTER TABLE public.waiting_times ADD COLUMN IF NOT EXISTS tempo_horas NUMERIC;
ALTER TABLE public.waiting_times ADD COLUMN IF NOT EXISTS cidade TEXT;
ALTER TABLE public.waiting_times ADD COLUMN IF NOT EXISTS estado TEXT;

-- 7. Inserir ou atualizar os 3 usuários padrão (sem restrição de cpf)
INSERT INTO public.users (id, nome, idade, cidade, email, cpf, senha_hash, condicao_saude)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', 'Administrador Minha Voz', 35, 'Brasília, DF', 'admin@minhavoz.org.br', 'admin', '123456', 'Gestão e Moderação SUS'),
    ('a0000000-0000-0000-0000-000000000002', 'José Silva', 48, 'São Paulo, SP', 'jose@minhavoz.org.br', 'jose', '123456', 'Ortopedia / Fila Cirurgia'),
    ('a0000000-0000-0000-0000-000000000003', 'Maria Silva', 42, 'São Paulo, SP', 'maria@minhavoz.org.br', 'maria', '123456', 'Paciente SUS / Consultas e Exames')
ON CONFLICT (id) DO UPDATE SET nome = EXCLUDED.nome;
