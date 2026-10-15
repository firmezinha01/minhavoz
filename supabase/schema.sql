-- ====================================================================
-- BANCO DE DADOS: REDE SOCIAL "MINHA VOZ" (SUPABASE POSTGRESQL)
-- ====================================================================

-- 1. Extensão para geração de chaves primárias UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabela: USERS (Perfis de pacientes cadastrados na rede)
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

-- 3. Tabela: DOCUMENTS (Laudos médicos, exames e comprovantes SISREG)
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL, -- Ex: 'laudo', 'protocolo_sisreg', 'receita'
    arquivo_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Tabela: WAITING_TIMES (Cronômetro de Espera no Hospital ou UPA)
CREATE TABLE IF NOT EXISTS public.waiting_times (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    hospital TEXT NOT NULL,
    inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fim TIMESTAMP WITH TIME ZONE,
    tempo_total INTERVAL,
    comentario TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Tabela: REPORTS (Relatos e Depoimentos na Rede Social em Texto, Áudio e Vídeo)
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    tipo_midia TEXT NOT NULL DEFAULT 'texto', -- 'texto', 'audio', 'video'
    relato TEXT,                              -- Texto digitado ou transcrição
    video_url TEXT,                           -- Arquivo de vídeo gravado no Storage
    audio_url TEXT,                           -- Arquivo de áudio gravado no Storage
    duracao_segundos INT,                     -- Duração em segundos (vídeo ou áudio)
    anonimo BOOLEAN DEFAULT TRUE,             -- Proteção de identidade / anonimato
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. Tabela: COMMUNITY_POSTS (Fórum de Apoio Mútuo entre Pacientes)
CREATE TABLE IF NOT EXISTS public.community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    conteudo TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. Tabela: DENUNCIAS (Queixas formais contra demoras e negligência)
CREATE TABLE IF NOT EXISTS public.denuncias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    hospital TEXT NOT NULL,
    descricao TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. Tabela: NOTIFICATIONS (Alertas sobre consultas, exames e status na fila)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    mensagem TEXT NOT NULL,
    tipo TEXT NOT NULL, -- Ex: 'alerta_consulta', 'atualizacao_fila'
    status BOOLEAN DEFAULT FALSE, -- FALSE = não lido, TRUE = lido
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ====================================================================
-- ÍNDICES DE PERFORMANCE PARA CONSULTAS EM TEMPO REAL
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_users_cidade ON public.users(cidade);
CREATE INDEX IF NOT EXISTS idx_waiting_hospital ON public.waiting_times(hospital);
CREATE INDEX IF NOT EXISTS idx_waiting_inicio ON public.waiting_times(inicio DESC);
CREATE INDEX IF NOT EXISTS idx_reports_created ON public.reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_denuncias_hospital ON public.denuncias(hospital);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id) WHERE status = FALSE;

-- ====================================================================
-- POLÍTICAS DE SEGURANÇA RLS (LGPD & PROTEÇÃO DE DADOS MÉDICOS)
-- ====================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waiting_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.denuncias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Usuários só leem/alteram seu próprio prontuário e dados sensíveis
CREATE POLICY "Users read own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users manage own documents" ON public.documents FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users view own waiting times" ON public.waiting_times FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users insert waiting times" ON public.waiting_times FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Tornar user_id opcional para permitir relatos e cronômetro anônimos
ALTER TABLE public.reports ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.waiting_times ALTER COLUMN user_id DROP NOT NULL;

-- Relatos e posts comunitários podem ser lidos por todos para visibilidade pública
DROP POLICY IF EXISTS "Public read community posts" ON public.community_posts;
CREATE POLICY "Public read community posts" ON public.community_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read reports" ON public.reports;
CREATE POLICY "Public read reports" ON public.reports FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert reports" ON public.reports;
CREATE POLICY "Public insert reports" ON public.reports FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public delete reports" ON public.reports;
CREATE POLICY "Public delete reports" ON public.reports FOR DELETE USING (true);

DROP POLICY IF EXISTS "Public insert waiting_times" ON public.waiting_times;
CREATE POLICY "Public insert waiting_times" ON public.waiting_times FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read waiting_times" ON public.waiting_times;
CREATE POLICY "Public read waiting_times" ON public.waiting_times FOR SELECT USING (true);

-- ====================================================================
-- CAMPOS DINÂMICOS PARA MAPA EM TEMPO REAL POR HOSPITAL E REGIÃO
-- ====================================================================
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

-- ====================================================================
-- USUÁRIOS PADRÃO (SENHA: 123456)
-- ====================================================================

-- 1. Usuário Admin (Login: admin / Senha: 123456)
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

-- 2. Usuário José (Login: jose / Senha: 123456)
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


