/*
  Respostas das questões
  Autor: Thiago Vilarinho Lemes
  Data: 11/02/2024
*/

1) Quantos chamados foram abertos no dia 01/04/2023?
Resp.: 73 chamados
Query SQL: 
SELECT 
  COUNT(id_chamado) AS total_chamados
FROM `datario.administracao_servicos_publicos.chamado_1746`
WHERE 
  DATE(data_inicio) = '2023-04-01';


2) Qual o tipo de chamado que teve mais reclamações no dia 01/04/2023?
Resp.: Poluição sonora
Query SQL: 
SELECT 
  tipo, COUNT(tipo) AS total_reclamacoes
FROM `datario.administracao_servicos_publicos.chamado_1746` 
WHERE 
  DATE(data_inicio) = '2023-04-01'
GROUP BY 
  tipo
ORDER BY total_reclamacoes DESC;


3) Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?
Resp.: Engenho de Dentro, Campo Grande e Leblon
Query SQL: 
WITH
  cte_chamado_1746 AS (
    SELECT *
    FROM 
      `datario.administracao_servicos_publicos.chamado_1746` 
    WHERE 
      DATE(data_inicio) = '2023-04-01'
  ),
  cte_bairro_chamado_1746 as(
    SELECT  
      b.nome, 
      COUNT(b.nome) AS total_chamados_bairro, 
    FROM cte_chamado_1746 AS c
    INNER JOIN `datario.dados_mestres.bairro` AS b
    ON 
      c.id_bairro = b.id_bairro
    GROUP BY
      b.nome
    ORDER BY
      total_chamados_bairro DESC
  )
SELECT 
  b.nome, 
  SUM(b.total_chamados_bairro) AS total_chamados_bairro
FROM cte_bairro_chamado_1746 AS b
GROUP BY 
  b.nome
ORDER BY 
  total_chamados_bairro DESC;


4) Qual o nome da subprefeitura com mais chamados abertos nesse dia?
Resp.: 	Zona Norte
Query SQL: 
WITH
  cte_chamado_1746 AS (
    SELECT *
    FROM `datario.administracao_servicos_publicos.chamado_1746` 
    WHERE DATE(data_inicio) = '2023-04-01'
  ),
  cte_bairro_chamado_1746 as(
    SELECT  
      b.subprefeitura, 
      COUNT(b.subprefeitura) AS total_chamados_subprefeitura, 
    FROM cte_chamado_1746 AS c
    INNER JOIN `datario.dados_mestres.bairro` AS b
    ON 
      c.id_bairro = b.id_bairro
    GROUP BY
      b.subprefeitura
    ORDER BY
      total_chamados_subprefeitura DESC
  )
SELECT b.subprefeitura, SUM(b.total_chamados_subprefeitura) AS total_chamados_subprefeitura
FROM cte_bairro_chamado_1746 AS b
GROUP BY 
  b.subprefeitura
ORDER BY 
  total_chamados_subprefeitura DESC;


5) Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? 
Se sim, por que isso acontece?
Resp.: Sim. Isso acontece no momento do cadastro do chamado em que o usuário não insere os dados corretamente, 
assim como, pode não está cadastrado o bairro ou subprefeitura no sitema impossibilitando sua inserção no cadastro, 
ou até mesmo, erro durante a migração dos dados para a cloud, causando ruído nos dados.


6)Quantos chamados com o subtipo "Perturbação do sossego" foram abertos 
desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?
Resp.: 38203 chamados
Query SQL: 
SELECT
  COUNT(id_chamado) AS total_chamados
FROM `datario.administracao_servicos_publicos.chamado_1746`
WHERE
  DATE(data_inicio) >= '2022-01-01'  
  AND DATE(data_fim)<='2023-12-31'
  AND subtipo="Perturbação do sossego"


7) Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos 
(Reveillon, Carnaval e Rock in Rio).
Resp.:
WITH cte_chamado_1746 AS (
        SELECT * 
        FROM `datario.administracao_servicos_publicos.chamado_1746` 
        WHERE subtipo = "Perturbação do sossego"                 
)
SELECT c.id_chamado, DATE(c.data_inicio) AS data_inicio,  b.evento, c.subtipo,
FROM cte_chamado_1746 AS c
INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS b
ON DATE(c.data_inicio) BETWEEN DATE(b.data_inicial) AND DATE(b.data_final)  
GROUP BY 
    id_chamado, 
    b.evento, 
    c.subtipo, 
    data_inicio
ORDER BY 
    data_inicio


8) Quantos chamados desse subtipo foram abertos em cada evento?
Resp.: Rock in Rio 834 chamados, Carnaval 241 chamados, Reveillon 137 chamados
Query SQL:
WITH cte_chamado_1746 AS (
        SELECT * 
        FROM `datario.administracao_servicos_publicos.chamado_1746` 
        WHERE subtipo = "Perturbação do sossego"                 
)
SELECT b.evento, c.subtipo, COUNT(b.evento) AS total_evento_subtipo
FROM cte_chamado_1746 AS c
INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS b
ON DATE(c.data_inicio) BETWEEN DATE(b.data_inicial) AND DATE(b.data_final)  
GROUP BY 
    b.evento, 
    c.subtipo
ORDER BY
  total_evento_subtipo DESC
  

9) Qual evento teve a maior média diária de chamados abertos desse subtipo?
Resp.: Rock in Rio
Query SQL:
WITH
  cte_chamado_1746 AS (
    SELECT * 
    FROM `datario.administracao_servicos_publicos.chamado_1746` 
    WHERE subtipo="Perturbação do sossego"
  ),
  cte_media_diaria AS (
    SELECT 
      b.evento, 
      DATE(c.data_inicio) AS data_inicio,
      COUNT(b.evento) AS total_evento_subtipo
    FROM cte_chamado_1746 AS c
    INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS b
    ON DATE(c.data_inicio) BETWEEN DATE(b.data_inicial) AND DATE(b.data_final)
    GROUP BY
      b.evento, 
      DATE(c.data_inicio)
  )
SELECT 
  e.evento, 
  AVG(e.total_evento_subtipo) AS media_diaria
FROM cte_media_diaria AS e
GROUP BY 
  e.evento
ORDER BY 
  media_diaria DESC;



10) Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos 
(Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o 
período de 01/01/2022 até 31/12/2023.
Resp.:
WITH
  cte_chamado_1746 AS (
    SELECT * 
    FROM `datario.administracao_servicos_publicos.chamado_1746` 
    WHERE subtipo = "Perturbação do sossego"
  ),
  cte_chamado_evento AS (
    SELECT 
      DATE(c.data_inicio) AS data_inicio,
      b.evento, 
      COUNT(b.evento) AS total_evento_subtipo
    FROM cte_chamado_1746 AS c
    INNER JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` AS b
    ON DATE(c.data_inicio) BETWEEN DATE('2022-01-01') AND DATE('2023-12-31')
    GROUP BY
      b.evento,
      data_inicio
  )
  SELECT 
    evento,
    AVG(d.total_evento_subtipo) AS total
  FROM cte_chamado_evento AS d
  GROUP BY 
    d.evento

