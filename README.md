# Plataforma de Streaming - STREAMIX

Projeto de banco de dados para plataforma de streaming utilizando arquitetura híbrida com MySQL/MariaDB (SQL) e MongoDB (NoSQL).

## Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Banco de Dados SQL](#banco-de-dados-sql)
- [Banco de Dados NoSQL](#banco-de-dados-nosql)
- [Instalação](#instalação)
- [Estrutura de Dados](#estrutura-de-dados)

## Visão Geral

O STREAMIX é um sistema de gerenciamento de plataforma de streaming que utiliza uma arquitetura híbrida para otimizar performance e escalabilidade. O MySQL armazena dados transacionais e relacionais, enquanto o MongoDB gerencia dados não relacionais de alta performance.

### Funcionalidades

- Gestão de usuários e perfis (múltiplos perfis por usuário, incluindo perfis infantis)
- Planos de assinatura (5 planos: Mobile, Básico, Padrão, Premium, Família)
- Controle financeiro (assinaturas e pagamentos)
- Catálogo de conteúdo (filmes e séries com temporadas e episódios)
- Histórico de reprodução
- Sistema de avaliações e comentários
- Listas personalizadas (favoritos, watchlists)
- Sistema de recomendações
- Logs de atividades

## Arquitetura

### Divisão de Responsabilidades

**MySQL (SQL)** - Dados transacionais:
- Usuários, perfis, assinaturas e pagamentos
- Catálogo estruturado (conteúdos, temporadas, episódios)
- Histórico de reprodução básico
- Dados que exigem integridade referencial e transações ACID

**MongoDB (NoSQL)** - Dados não relacionais:
- Avaliações e comentários (estrutura flexível)
- Listas personalizadas dos usuários
- Logs de atividades (alta frequência de escrita)
- Dados de recomendação por perfil

### Relacionamentos

Os bancos se relacionam através de chaves de referência. O MongoDB armazena `id_usuario`, `id_perfil`, `id_conteudo` que referenciam as tabelas do MySQL. A aplicação é responsável por manter a consistência entre os dois bancos.

## Estrutura do Projeto

```
Projeto_BD_Streaming/
├── README.md
├── Documentação de Requisitos - Plataforma de Streaming Personalizada.docx
├── interface_usuario.png
│
├── SQL/
│   ├── mysql_streaming_schema.sql          # Script principal de criação
│   ├── banco.sql                           # Dump completo
│   ├── modelagem_bd.pdf
│   ├── Inserts Queries/                    # Dados de exemplo
│   │   ├── planos.sql
│   │   ├── usuarios.sql
│   │   ├── perfis.sql
│   │   ├── assinaturas.sql
│   │   ├── pagamentos.sql
│   │   ├── conteudos.sql
│   │   ├── temporadas.sql
│   │   ├── episodios.sql
│   │   └── historico_reproducao.sql
│   └── Views/                              # Views, Procedures e Triggers
│       ├── View.sql
│       ├── Inner Join.sql
│       ├── Storaged Procedure.sql
│       └── Trigger.sql
│
└── NoSQL/                                  # MongoDB
    ├── prelude.json
    ├── avaliacoes.bson
    ├── avaliacoes.metadata.json
    ├── listas_usuarios.bson
    ├── listas_usuarios.metadata.json
    ├── log_atividades.bson
    ├── log_atividades.metadata.json
    ├── perfis_recomendacao.bson
    └── perfis_recomendacao.metadata.json
```

## Banco de Dados SQL

### Tabelas Principais

**planos** - Planos de assinatura
- id_plano, nome, descricao, preco, qualidade_video, telas_simultaneas

**usuarios** - Usuários da plataforma
- id_usuario, nome, email (UNIQUE), senha_hash, data_cadastro, data_nascimento, id_plano_ativo

**perfis** - Perfis dos usuários (múltiplos por usuário)
- id_perfil, id_usuario (FK), nome_perfil, avatar_url, tipo_perfil (ADULTO/INFANTIL)

**assinaturas** - Histórico de assinaturas
- id_assinatura, id_usuario (FK), id_plano (FK), data_inicio, data_fim, status_assinatura

**pagamentos** - Registro de pagamentos
- id_pagamento, id_assinatura (FK), valor, data_pagamento, metodo_pagamento, status_pagamento

**conteudos** - Catálogo de filmes e séries
- id_conteudo, titulo, descricao, ano_lancamento, classificacao_indicativa, duracao_minutos, genero, tipo_conteudo (FILME/SERIE)

**temporadas** - Temporadas das séries
- id_temporada, id_serie (FK), numero_temporada, titulo_temporada, ano_lancamento

**episodios** - Episódios das temporadas
- id_episodio, id_temporada (FK), numero_episodio, titulo_episodio, descricao, duracao_minutos, data_lancamento

**historico_reproducao** - Histórico de visualizações
- id_historico, id_perfil (FK), id_conteudo (FK, nullable), id_episodio (FK, nullable), progresso_segundos, ultima_visualizacao, status_reproducao

### Relacionamentos

- usuarios (1) → (N) perfis
- usuarios (1) → (N) assinaturas
- planos (1) → (N) assinaturas
- planos (1) → (N) usuarios (id_plano_ativo)
- assinaturas (1) → (N) pagamentos
- conteudos (1) → (N) temporadas (se tipo_conteudo = 'SERIE')
- temporadas (1) → (N) episodios
- perfis (1) → (N) historico_reproducao
- conteudos (1) → (N) historico_reproducao
- episodios (1) → (N) historico_reproducao

### Integridade Referencial

- CASCADE: Deletar usuário remove perfis e histórico
- CASCADE: Deletar perfil remove histórico
- CASCADE: Deletar série remove temporadas e episódios
- UNIQUE: Email único por usuário
- FOREIGN KEYS: Previnem dados órfãos

### Views, Procedures e Triggers

**vw_RelatorioFaturamento** - View que une pagamentos, assinaturas, usuários e planos para relatórios financeiros.

**sp_CadastrarUsuarioComPerfil** - Procedure que cria usuário e perfil padrão em transação única.

**trg_AtualizaUltimaVisualizacao** - Trigger que atualiza automaticamente `ultima_visualizacao` quando `progresso_segundos` é alterado.

## Banco de Dados NoSQL

### Coleções

**avaliacoes** - Avaliações e comentários dos usuários
- Estrutura: id_usuario, id_perfil, id_conteudo, id_episodio (opcional), nota (1-5), comentario, data_avaliacao, curtidas, editado

**listas_usuarios** - Listas personalizadas (favoritos, watchlists)
- Estrutura: id_usuario, id_perfil, nome_lista, tipo_lista (WATCHLIST/FAVORITOS/CUSTOMIZADA), conteudos (array), publica, data_criacao, data_atualizacao

**log_atividades** - Logs de atividades dos usuários
- Estrutura: id_usuario, id_perfil, tipo_atividade, id_conteudo (opcional), id_episodio (opcional), acao, timestamp, detalhes (objeto flexível), ip_address, user_agent

**perfis_recomendacao** - Dados de recomendação por perfil
- Estrutura: id_perfil, algoritmo, recomendacoes (array com id_conteudo, score, motivo), preferencias (objeto), data_atualizacao, versao_algoritmo

### Relacionamentos com SQL

As coleções MongoDB referenciam tabelas SQL através de:
- id_usuario → usuarios.id_usuario
- id_perfil → perfis.id_perfil
- id_conteudo → conteudos.id_conteudo
- id_episodio → episodios.id_episodio

A aplicação deve validar a existência desses IDs no MySQL antes de inserir no MongoDB.

## Instalação

### Pré-requisitos

- MySQL 8.0+ ou MariaDB 10.4+
- MongoDB 4.4+

### MySQL

1. Criar banco de dados:
```sql
CREATE DATABASE streaming;
USE streaming;
```

2. Executar script principal:
```bash
mysql -u usuario -p streaming < SQL/mysql_streaming_schema.sql
```

3. (Opcional) Popular com dados de exemplo:
```bash
mysql -u usuario -p streaming < SQL/Inserts\ Queries/planos.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/usuarios.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/perfis.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/assinaturas.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/pagamentos.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/conteudos.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/temporadas.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/episodios.sql
mysql -u usuario -p streaming < SQL/Inserts\ Queries/historico_reproducao.sql
```

4. (Opcional) Criar Views, Procedures e Triggers:
```bash
mysql -u usuario -p streaming < SQL/Views/View.sql
mysql -u usuario -p streaming < SQL/Views/Storaged\ Procedure.sql
mysql -u usuario -p streaming < SQL/Views/Trigger.sql
```

### MongoDB

1. Restaurar coleções:
```bash
mongorestore --db streaming NoSQL/
```

2. Verificar:
```javascript
use streaming
show collections
```

## Estrutura de Dados

### Dados de Exemplo (SQL)

- 5 planos de assinatura
- 100 usuários
- 122 perfis
- 100 assinaturas
- 111 pagamentos
- 104 conteúdos (68 filmes, 36 séries)
- Múltiplas temporadas e episódios
- 69 registros de histórico de reprodução

### Dados de Exemplo (NoSQL)

- Avaliações de usuários
- Listas personalizadas
- Logs de atividades
- Dados de recomendação

## Requisitos Funcionais

- RF01: Cadastro e autenticação de usuários
- RF02: Validação de login e plano ativo em tempo real
- RF03: Gerenciamento de catálogo (filmes, séries, episódios)
- RF04: Registro de histórico de reprodução
- RF08: Relatórios financeiros e de assinaturas

## Segurança

### MySQL

- Senhas armazenadas como hash (nunca texto plano)
- Validação de plano ativo em tempo real
- Perfis infantis com restrições de conteúdo
- Integridade referencial via foreign keys
- Views para controle de acesso

### MongoDB

- Autenticação e autorização configuradas
- Validação de schema via validators
- Índices apropriados para performance
- TLS/SSL para conexões
- Backups regulares

## Notas Importantes

1. O campo `senha_hash` deve sempre conter um hash (bcrypt, SHA-256). Nunca armazenar senhas em texto plano.

2. Perfis do tipo 'INFANTIL' devem ter restrições baseadas na `classificacao_indicativa` dos conteúdos.

3. No `historico_reproducao`, um registro referencia OU `id_conteudo` OU `id_episodio`, nunca ambos.

4. No MySQL, `data_fim` em `assinaturas` é NULL quando ativa. Preencher ao cancelar ou expirar.

5. No MongoDB, sempre validar a existência dos IDs no MySQL antes de inserir.

6. Implementar lógica de limpeza ao deletar registros no MySQL (cascata manual no MongoDB).

7. Criar índices apropriados no MongoDB:
   - avaliacoes: { id_usuario: 1, id_conteudo: 1 }
   - log_atividades: { timestamp: -1 } (com TTL se necessário)
   - perfis_recomendacao: { id_perfil: 1 }
