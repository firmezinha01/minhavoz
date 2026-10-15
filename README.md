# 📢 Minha Voz | A Rede Social de Transparência da Saúde e Fila do SUS

<p align="center">
  <strong>Dando visibilidade às pessoas na fila de espera do SUS, medindo tempos reais de atendimento e pressionando autoridades com dados.</strong>
</p>

---

## 🎯 Objetivo da Rede Social

O **Minha Voz** é uma plataforma comunitária em tempo real, 100% responsiva para **Computador (Desktop)** e **Celular (Mobile)**, desenvolvida para:
1. **Dar voz às pessoas invisibilizadas** pelo sistema de saúde que aguardam meses ou anos por consultas, exames ou cirurgias.
2. **Gerar dados reais e independentes** sobre a espera em hospitais e UPAs no Brasil.
3. **Pressionar autoridades públicas** (Secretarias de Saúde, Ministério Público e Defensoria Pública) com relatos organizados e estatísticas de gargalos.
4. **Criar uma comunidade de apoio mútuo**, solidariedade e orientação jurídica gratuita.

---

## 📱 Recursos & Funcionalidades Principais

* **Feed Social em Tempo Real:** Relatos públicos e anônimos com contagem de dias na fila de espera (SISREG) e identificação da unidade de saúde.
* **Compositor Multimídia de Relatos:**
  * ✍️ **Texto:** Relatos escritos com campo para protocolo médico e anexos de laudos.
  * 🎙️ **Áudio:** Gravador de voz embutido no navegador para depoimentos falados.
  * 📹 **Vídeo:** Câmera frontal com temporizador REC e **filtro opcional de desfoque facial (anonimato garantido)**.
* **Cronômetro de Espera no Hospital / UPA:** O paciente inicia a contagem ao chegar na unidade e, ao ser atendido, clica em "Parar". O sistema apura o tempo total, coleta avaliação da triagem e gera dado público para fiscalização.
* **Difusão Social Completa:**
  * 📸 **Instagram:** Formatação em **Stories & Reels (9:16)** com sticker oficial de dias na fila e formato **Feed (1:1)**.
  * 💬 **WhatsApp:** Disparo direto de mensagens e cards para grupos de familiares e voluntários.
  * 𝕏 **Twitter (X)** e 📘 **Facebook**: Pressão direta com hashtags `#MinhaVoz` e `#SaudeNaoPodeEsperar`.
  * 🔗 **Copiar Link:** Link direto do relato para jornalistas e imprensa.
* **Mapa Nacional da Espera:** Estatísticas geográficas de gargalos por especialidade (Ortopedia, Cardiologia, Oncologia, etc.).
* **Canal com a Defensoria Pública & ONGs:** Acesso a orientações sobre pedidos de liminar judicial para procedimentos de urgência.

---

## 🚀 Como Subir na Vercel (Produção)

1. Acesse [vercel.com](https://vercel.com) e faça login com sua conta do GitHub.
2. Clique em **"Add New"** ➔ **"Project"**.
3. Selecione o repositório **`firmezinha01/minhavoz`**.
4. Em **Framework Preset**, deixe selecionado **"Other"** (ou Static).
5. Clique em **"Deploy"**.
6. Em segundos seu site estará no ar com HTTPS gratuito em uma URL como `https://minhavoz.vercel.app`!

---

## 🗄️ Como Conectar ao Supabase

1. Crie um projeto gratuito em [supabase.com](https://supabase.com).
2. No menu lateral do Supabase, clique em **SQL Editor**.
3. Copie todo o conteúdo do arquivo [`supabase/schema.sql`](supabase/schema.sql) e clique em **Run**.
4. Obtenha sua **Project URL** e sua **Anon/Public Key** em *Project Settings > API*.
5. Na rede social Minha Voz, abra o menu lateral e clique em **"⚙️ Configurar Chaves Supabase"** para ativar a sincronização em tempo real na nuvem!

---

## 📂 Estrutura do Repositório

```text
minhavoz/
├── index.html            # Aplicação Web responsiva da Rede Social
├── vercel.json           # Configurações de rotas e segurança para a Vercel
├── package.json          # Metadados e dependências
├── .env.example          # Exemplo de configuração de chaves
├── .gitignore            # Arquivos ignorados pelo Git
├── supabase/
│   └── schema.sql        # Script das 7 tabelas com RLS e índices
└── README.md             # Documentação do projeto
```

---

## ⚖️ Licença

Distribuído sob a licença MIT. Desenvolvido para apoiar a saúde pública e cidadãos brasileiros.
