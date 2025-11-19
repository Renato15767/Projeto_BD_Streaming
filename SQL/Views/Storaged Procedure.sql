-- Nome: sp_CadastrarUsuarioComPerfil Objetivo: Garantir a integridade do cadastro. Em plataformas de streaming, não faz sentido existir um usuário sem pelo 
-- menos um perfil (geralmente o perfil principal). Esta procedure cria o usuário e, automaticamente, cria o primeiro perfil "Admin" ou "Principal".

-- Por que criar? Encapsulamento e Regra de Negócio. Ao invés de fazer dois INSERTs soltos no código da aplicação (backend), 
-- você chama uma única rotina no banco que garante que todo usuário novo já nasça com um perfil atrelado.

DELIMITER $$

CREATE PROCEDURE sp_CadastrarUsuarioComPerfil(
    IN p_nome VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_senha VARCHAR(255),
    IN p_data_nascimento DATE
)
BEGIN
    DECLARE novo_id_usuario INT;

    -- Inicia uma transação para garantir que ambos (usuário e perfil) sejam criados ou nenhum deles
    START TRANSACTION;

    -- 1. Insere o usuário na tabela principal
    INSERT INTO usuarios (nome, email, senha_hash, data_nascimento)
    VALUES (p_nome, p_email, p_senha, p_data_nascimento);

    -- Captura o ID gerado para o usuário
    SET novo_id_usuario = LAST_INSERT_ID();

    -- 2. Cria automaticamente o primeiro perfil (Padrão Adulto)
    INSERT INTO perfis (id_usuario, nome_perfil, tipo_perfil)
    VALUES (novo_id_usuario, p_nome, 'ADULTO');

    -- Confirma a transação
    COMMIT;
END $$

DELIMITER ;



-- Teste Storaged Procdure

-- 1. Chamar a Procedure passando os dados fictícios
CALL sp_CadastrarUsuarioComPerfil('Lucas Silva', 'lucas@teste.com', 'hash123', '1995-05-20');

-- 2. Verificação:
-- O usuário foi criado?
SELECT * FROM usuarios;

-- O perfil foi criado automaticamente com o mesmo ID do usuário?
SELECT * FROM perfis;