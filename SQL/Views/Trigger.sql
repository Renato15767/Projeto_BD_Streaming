DELIMITER $$

CREATE TRIGGER trg_AtualizaUltimaVisualizacao
BEFORE UPDATE ON historico_reproducao
FOR EACH ROW
BEGIN
    -- Se o progresso mudou, atualiza a data de visualização para AGORA
    IF NEW.progresso_segundos <> OLD.progresso_segundos THEN
        SET NEW.ultima_visualizacao = CURRENT_TIMESTAMP;
    END IF;
    
    -- Lógica Extra: Se o progresso for maior que 95% do conteúdo (simulado), marca como CONCLUIDO
    -- Nota: Num cenário real, precisaríamos ler a duração da tabela conteudos/episodios, 
    -- mas para simplificar aqui, vamos supor que se o status mudar manualmente, garantimos a data.
    
END $$

DELIMITER ;



-- Teste Trigger

-- Verifique a data antiga antes de testar

SELECT * FROM historico_reproducao WHERE id_perfil = 1;

-- TESTE REAL: O usuário continuou assistindo (Update no progresso)
UPDATE historico_reproducao 
SET progresso_segundos = 500 
WHERE id_perfil = 1 AND id_conteudo = 2;

-- Verificação final
SELECT * FROM historico_reproducao WHERE id_perfil = 1;