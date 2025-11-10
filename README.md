# Plataforma de Streaming

Este é o banco de dados do projeto STREAMIX, uma plataforma de streaming desenvolvida em MySQL/MariaDB. Basicamente, o sistema cuida de tudo relacionado a usuários, assinaturas, catálogo de conteúdo e histórico de reprodução.

## O que tem aqui

O banco foi pensado para suportar uma plataforma de streaming completa. Tem 9 tabelas principais que cobrem:

- Usuários e perfis (cada usuário pode ter vários perfis, tipo Netflix)
- Planos de assinatura e controle de pagamentos
- Catálogo de filmes e séries (com temporadas e episódios)
- Histórico do que cada perfil assistiu
- Controle de assinaturas e status

## Tecnologias usadas

- MySQL 8.0+ ou MariaDB 10.4+
- Engine InnoDB
- Charset UTF8MB4 (para suportar caracteres especiais)

## Estrutura do banco

São 9 tabelas no total:

1. `planos` - Os planos de assinatura disponíveis
2. `usuarios` - Conta principal do usuário
3. `perfis` - Perfis individuais (um usuário pode ter vários)
4. `assinaturas` - Histórico de assinaturas
5. `pagamentos` - Registro dos pagamentos
6. `conteudos` - Filmes e séries
7. `temporadas` - Temporadas das séries
8. `episodios` - Episódios
9. `historico_reproducao` - O que cada perfil assistiu

## Detalhes das tabelas

### planos

Guarda os planos de assinatura (Básico, Premium, etc).

| Campo | Tipo | O que é |
|-------|------|---------|
| id_plano | INT | Chave primária |
| nome | VARCHAR(100) | Nome do plano |
| descricao | TEXT | Descrição do plano |
| preco | DECIMAL(10,2) | Preço |
| qualidade_video | VARCHAR(50) | Qualidade (HD, 4K, etc) |
| telas_simultaneas | INT | Quantas telas podem assistir ao mesmo tempo |

### usuarios

A tabela principal de usuários.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_usuario | INT | Chave primária |
| nome | VARCHAR(255) | Nome do usuário |
| email | VARCHAR(255) | Email (único) |
| senha_hash | VARCHAR(255) | Hash da senha (nunca texto plano!) |
| data_cadastro | DATETIME | Quando se cadastrou |
| data_nascimento | DATE | Data de nascimento |
| id_plano_ativo | INT | Plano atual (FK para planos) |

### perfis

Perfis dentro de uma conta. Um usuário pode ter vários perfis (tipo família).

| Campo | Tipo | O que é |
|-------|------|---------|
| id_perfil | INT | Chave primária |
| id_usuario | INT | Dono do perfil (FK) |
| nome_perfil | VARCHAR(100) | Nome do perfil |
| avatar_url | VARCHAR(255) | URL da foto do perfil |
| tipo_perfil | ENUM | 'ADULTO' ou 'INFANTIL' |

### assinaturas

Histórico de assinaturas. Um usuário pode ter várias assinaturas ao longo do tempo.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_assinatura | INT | Chave primária |
| id_usuario | INT | Usuário (FK) |
| id_plano | INT | Plano contratado (FK) |
| data_inicio | DATE | Quando começou |
| data_fim | DATE | Quando terminou (NULL se ainda está ativa) |
| status_assinatura | ENUM | 'ATIVA', 'CANCELADA' ou 'EXPIRADA' |

### pagamentos

Registro de todos os pagamentos feitos.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_pagamento | INT | Chave primária |
| id_assinatura | INT | Assinatura relacionada (FK) |
| valor | DECIMAL(10,2) | Valor pago |
| data_pagamento | DATETIME | Quando foi pago |
| metodo_pagamento | VARCHAR(100) | Como pagou (cartão, boleto, etc) |
| status_pagamento | ENUM | 'APROVADO', 'RECUSADO' ou 'PENDENTE' |

### conteudos

Catálogo de filmes e séries. A mesma tabela serve para os dois tipos.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_conteudo | INT | Chave primária |
| titulo | VARCHAR(255) | Título |
| descricao | TEXT | Sinopse |
| ano_lancamento | INT | Ano que foi lançado |
| classificacao_indicativa | VARCHAR(10) | Classificação (L, 10, 12, 14, 16, 18) |
| duracao_minutos | INT | Duração (só faz sentido para filmes) |
| genero | VARCHAR(100) | Gênero |
| tipo_conteudo | ENUM | 'FILME' ou 'SERIE' |

### temporadas

Temporadas das séries. Só faz sentido se o conteúdo for do tipo SERIE.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_temporada | INT | Chave primária |
| id_serie | INT | Série (FK para conteudos) |
| numero_temporada | INT | Número da temporada |
| titulo_temporada | VARCHAR(255) | Título da temporada |
| ano_lancamento | INT | Ano que foi lançada |

### episodios

Episódios de cada temporada.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_episodio | INT | Chave primária |
| id_temporada | INT | Temporada (FK) |
| numero_episodio | INT | Número do episódio |
| titulo_episodio | VARCHAR(255) | Título |
| descricao | TEXT | Sinopse do episódio |
| duracao_minutos | INT | Duração |
| data_lancamento | DATE | Quando foi lançado |

### historico_reproducao

O que cada perfil assistiu. Guarda tanto filmes quanto episódios.

| Campo | Tipo | O que é |
|-------|------|---------|
| id_historico | INT | Chave primária |
| id_perfil | INT | Perfil que assistiu (FK) |
| id_conteudo | INT | Filme assistido (FK, NULL se for episódio) |
| id_episodio | INT | Episódio assistido (FK, NULL se for filme) |
| progresso_segundos | INT | Em que segundo parou de assistir |
| ultima_visualizacao | DATETIME | Última vez que assistiu |
| status_reproducao | ENUM | 'ASSISTINDO' ou 'CONCLUIDO' |

## Como as tabelas se relacionam

A estrutura é bem direta:

- Um usuário tem vários perfis
- Um usuário pode ter várias assinaturas (histórico)
- Uma assinatura tem vários pagamentos
- Um conteúdo (série) tem várias temporadas
- Uma temporada tem vários episódios
- Um perfil tem vários registros de histórico (pode ser filme ou episódio)

### Integridade

Algumas coisas importantes sobre como o banco funciona:

- Se você deletar um usuário, os perfis dele são deletados também (CASCADE)
- Se deletar um perfil, o histórico dele some também
- Se deletar uma série, temporadas e episódios são deletados
- Email é único (não pode ter dois usuários com o mesmo email)
- As chaves estrangeiras garantem que não dá pra criar dados "órfãos"

## Requisitos funcionais

O sistema atende aos seguintes requisitos (conforme a documentação):

- RF01: Cadastro e autenticação de usuários
- RF02: Validação de login e plano ativo em tempo real
- RF03: Gerenciamento de catálogo (filmes, séries, episódios)
- RF04: Registro de histórico de reprodução
- RF08: Relatórios financeiros e de assinaturas

## Arquivos do projeto

- `mysql_streaming_schema.sql` - Script limpo para criar o banco (recomendado)
- `banco.sql` - Dump completo (inclui configurações do MySQL)
- `modelagem_bd.pdf` - Diagrama visual do banco
- `Documentação de Requisitos - Plataforma de Streaming Personalizada.docx` - Documentação completa
- `interface_usuario.png` - Mockup da interface

## Segurança

Algumas coisas que foram pensadas:

- Senhas são armazenadas como hash (nunca em texto plano)
- Validação de plano ativo em tempo real
- Perfis infantis podem ter restrições de conteúdo
- Integridade referencial garantida pelas foreign keys

## O que falta (ou poderia melhorar)

Algumas ideias para o futuro:

- Sistema de favoritos/minha lista
- Avaliações e comentários
- Recomendações baseadas no que a pessoa assiste
- Suporte a múltiplos idiomas
- Notificações
- Dashboard para administradores

## Sobre o projeto

Este projeto foi desenvolvido como parte de um sistema completo de plataforma de streaming. O foco aqui foi na modelagem e estruturação do banco de dados MySQL/MariaDB, pensando em escalabilidade e organização dos dados.
