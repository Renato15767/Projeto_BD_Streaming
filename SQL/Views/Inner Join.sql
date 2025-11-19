

SELECT 
    c.titulo AS Nome_Serie,
    t.numero_temporada AS Temporada,
    e.numero_episodio AS Episodio,
    e.titulo_episodio AS Nome_Episodio,
    e.duracao_minutos
FROM 
    conteudos c
INNER JOIN 
    temporadas t ON c.id_conteudo = t.id_serie
INNER JOIN 
    episodios e ON t.id_temporada = e.id_temporada
WHERE 
    c.tipo_conteudo = 'SERIE'
ORDER BY 
    c.titulo, t.numero_temporada, e.numero_episodio;