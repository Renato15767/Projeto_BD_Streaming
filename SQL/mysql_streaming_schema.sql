create database streaming;
use streaming;

-- Tabela para os planos de assinatura
CREATE TABLE planos (
    id_plano INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    qualidade_video VARCHAR(50),
    telas_simultaneas INT NOT NULL
);

-- Tabela principal de usuários
-- RF01: O sistema deve permitir cadastro, autenticação e gerenciamento de usuários no MySQL.
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL, -- Armazenar o hash da senha, nunca o texto plano.
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_nascimento DATE,
    id_plano_ativo INT,
    FOREIGN KEY (id_plano_ativo) REFERENCES planos(id_plano)
);

-- Tabela de perfis por usuário
-- Um usuário pode ter vários perfis (ex: Adulto, Criança)
CREATE TABLE perfis (
    id_perfil INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    nome_perfil VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(255),
    tipo_perfil ENUM('ADULTO', 'INFANTIL') NOT NULL DEFAULT 'ADULTO',
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE -- Se o usuário for deletado, seus perfis também são.
);

-- Tabela para gerenciar as assinaturas dos usuários
-- RF02: O sistema deve validar login e plano ativo em tempo real.
CREATE TABLE assinaturas (
    id_assinatura INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_plano INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    status_assinatura ENUM('ATIVA', 'CANCELADA', 'EXPIRADA') NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_plano) REFERENCES planos(id_plano)
);

-- Tabela para registrar o histórico de pagamentos
-- RF08: O sistema deve gerar relatórios financeiros e de assinaturas no MySQL.
CREATE TABLE pagamentos (
    id_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    id_assinatura INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    data_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pagamento VARCHAR(100),
    status_pagamento ENUM('APROVADO', 'RECUSADO', 'PENDENTE') NOT NULL,
    FOREIGN KEY (id_assinatura) REFERENCES assinaturas(id_assinatura)
);

-- Tabela unificada para conteúdos (filmes e séries)
-- RF03: O sistema deve gerenciar catálogo de filmes, séries e episódios no MySQL.
CREATE TABLE conteudos (
    id_conteudo INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    ano_lancamento INT,
    classificacao_indicativa VARCHAR(10),
    duracao_minutos INT, -- Para filmes. Para séries, pode ser nulo.
    genero VARCHAR(100),
    tipo_conteudo ENUM('FILME', 'SERIE') NOT NULL
);

-- Tabela para as temporadas de uma série
CREATE TABLE temporadas (
    id_temporada INT PRIMARY KEY AUTO_INCREMENT,
    id_serie INT NOT NULL, -- Chave estrangeira para a tabela de conteúdos
    numero_temporada INT NOT NULL,
    titulo_temporada VARCHAR(255),
    ano_lancamento INT,
    FOREIGN KEY (id_serie) REFERENCES conteudos(id_conteudo) ON DELETE CASCADE
);

-- Tabela para os episódios de uma temporada
CREATE TABLE episodios (
    id_episodio INT PRIMARY KEY AUTO_INCREMENT,
    id_temporada INT NOT NULL,
    numero_episodio INT NOT NULL,
    titulo_episodio VARCHAR(255) NOT NULL,
    descricao TEXT,
    duracao_minutos INT NOT NULL,
    data_lancamento DATE,
    FOREIGN KEY (id_temporada) REFERENCES temporadas(id_temporada) ON DELETE CASCADE
);

-- Tabela para o histórico de reprodução por perfil
-- RF04: O sistema deve registrar histórico de reprodução (play, pause, stop) no MySQL.
CREATE TABLE historico_reproducao (
    id_historico INT PRIMARY KEY AUTO_INCREMENT,
    id_perfil INT NOT NULL,
    id_conteudo INT, -- Pode ser um filme (direto)
    id_episodio INT, -- Ou um episódio de uma série
    progresso_segundos INT NOT NULL DEFAULT 0,
    ultima_visualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_reproducao ENUM('ASSISTINDO', 'CONCLUIDO') NOT NULL DEFAULT 'ASSISTINDO',
    FOREIGN KEY (id_perfil) REFERENCES perfis(id_perfil) ON DELETE CASCADE,
    FOREIGN KEY (id_conteudo) REFERENCES conteudos(id_conteudo),
    FOREIGN KEY (id_episodio) REFERENCES episodios(id_episodio)
);