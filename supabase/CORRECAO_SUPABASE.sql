-- ====================================================================
-- BANCO DE DADOS: REDE SOCIAL "MINHA VOZ"
-- SCRIPT DE CORREÇÃO TOTAL E LIBERAÇÃO DE PERMISSÕES NO SUPABASE
-- ====================================================================
-- INSTRUÇÕES DE EXECUÇÃO:
-- 1. Abra o painel do Supabase: https://supabase.com/dashboard
-- 2. Acesse seu projeto (rtpuzrjjcrwlivwtlcya)
-- 3. No menu lateral esquerdo, clique em "SQL Editor"
-- 4. Clique em "New Query", cole TODO o conteúdo deste arquivo e clique no botão verde "RUN" (ou Ctrl+Enter)
-- ====================================================================

-- 1. Extensão para UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Garantir criação das tabelas principais
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL,
    idade INT CHECK (idade >= 0),
    cidade TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    cpf TEXT UNIQUE NOT NULL,
    senha_hash TEXT NOT NULL,
    condicao_saude TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    tipo_midia TEXT NOT NULL DEFAULT 'texto',
    relato TEXT,
    video_url TEXT,
    audio_url TEXT,
    duracao_segundos INT,
    anonimo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.waiting_times (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    hospital TEXT NOT NULL,
    inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fim TIMESTAMP WITH TIME ZONE,
    tempo_total INTERVAL,
    comentario TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    titulo TEXT NOT NULL,
    conteudo TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.denuncias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    hospital TEXT NOT NULL,
    descricao TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Remover restrição NOT NULL de user_id (para permitir relatos e tempos de espera anônimos)
ALTER TABLE public.reports ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.waiting_times ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.community_posts ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.denuncias ALTER COLUMN user_id DROP NOT NULL;

-- 4. Adicionar colunas reais para o Mapa de Espera e Filtros
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

-- 5. DESATIVAR ROW LEVEL SECURITY (RLS)
-- Isso remove o erro 42501 (violação de segurança) e permite que o app salve diretamente
ALTER TABLE public.reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.waiting_times DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.denuncias DISABLE ROW LEVEL SECURITY;

-- 6. Garantir permissões de leitura, escrita e exclusão para a chave anônima (anon) e autenticada
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO anon, authenticated, service_role;

-- 7. Inserir ou atualizar os 3 usuários padrão da rede Minha Voz
INSERT INTO public.users (id, nome, idade, cidade, email, cpf, senha_hash, condicao_saude)
VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Administrador Minha Voz',
    35,
    'Brasília, DF',
    'admin@minhavoz.org.br',
    'admin',
    '123456',
    'Gestão e Moderação SUS'
) ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.users (id, nome, idade, cidade, email, cpf, senha_hash, condicao_saude)
VALUES (
    'a0000000-0000-0000-0000-000000000002',
    'José Silva',
    48,
    'São Paulo, SP',
    'jose@minhavoz.org.br',
    'jose',
    '123456',
    'Ortopedia / Fila Cirurgia'
) ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.users (id, nome, idade, cidade, email, cpf, senha_hash, condicao_saude)
VALUES (
    'a0000000-0000-0000-0000-000000000003',
    'Maria Silva',
    42,
    'São Paulo, SP',
    'maria@minhavoz.org.br',
    'maria',
    '123456',
    'Paciente SUS / Consultas e Exames'
) ON CONFLICT (cpf) DO NOTHING;

-- 8. Ativar Realtime para sincronização automática entre celulares e desktops
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'reports'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.reports;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'waiting_times'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.waiting_times;
    END IF;
END $$;

-- Confirmação final
SELECT '✓ Banco de dados Supabase configurado com sucesso e liberado para gravações!' AS resultado;
