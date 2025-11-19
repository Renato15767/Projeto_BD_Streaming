-- Nome: vw_RelatorioFaturamento Objetivo: Simplificar a visualização financeira (RF08). Esta View junta as tabelas de pagamentos, 
-- assinaturas e planos para mostrar exatamente quanto dinheiro entrou, quem pagou e qual plano foi comprado.

-- Por que criar? Segurança e Facilidade. Um analista financeiro não precisa saber fazer JOIN entre 4 tabelas. Ele apenas faz 
-- um SELECT * FROM vw_RelatorioFaturamento. Além disso, você pode dar permissão de leitura apenas na View, protegendo 
-- as tabelas originais que contêm dados sensíveis (como senhas).

CREATE VIEW vw_RelatorioFaturamento AS
SELECT 
    pag.id_pagamento,
    u.nome AS nome_cliente,
    pl.nome AS nome_plano,
    pag.valor,
    pag.data_pagamento,
    pag.status_pagamento
FROM 
    pagamentos pag
JOIN 
    assinaturas ass ON pag.id_assinatura = ass.id_assinatura
JOIN 
    usuarios u ON ass.id_usuario = u.id_usuario
JOIN 
    planos pl ON ass.id_plano = pl.id_plano
WHERE 
    pag.status_pagamento = 'APROVADO';
    
    
Select * from vw_RelatorioFaturamento;