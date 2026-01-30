/*
 Etapas de analise a ser feita na camada Ouro 
 =============================================================================
-- Verificação de qualidade e tratamento

-- Verificação de qualidade e tratamento
 =============================================================================
*/

-- Tabela:prata.crm_informacoes_cliente para View ouro.dim_clientes

--Sempre comece a consulta com a tabela mestre para junções de tabelas, exemplo a tabela cliente de acordo com o Modelo_Integração

-- 1. Consulta que realiza verificação de qualidade e tratamento:
--Depois de juntar a tabela, verifique se alguma duplicata foi introduzida pela lógica de JOIN de tabelas
-- Expectativa de Resultado: Sem retorno de dados
SELECT clt_id, COUNT (*) FROM
	(SELECT 
		   clt_id
		  ,clt_chave
		  ,clt_primeiro_nome
		  ,clt_ultimo_nome
		  ,clt_status_civil
		  ,clt_sexo
		  ,clt_data_criacao
		  ,ca.aniversario
		  ,ca.genero
		  ,la.pais
	  FROM prata.crm_informacoes_cliente cli
	  LEFT JOIN prata.erp_custo_az12 ca ON cli.clt_chave = ca.cid
	  LEFT JOIN prata.erp_loc_a101 la ON cli.clt_chave = la.cid
	  ) t GROUP BY clt_id
	  HAVING COUNT(*) > 1

-- 2. Verificar as integrações:
--Nesse caso teria duas fontes de genero e com isso deverá ser tratado

	SELECT 
		cli.clt_sexo
		,ca.genero
	,CASE WHEN cli.clt_sexo <> 'n/a' THEN cli.clt_sexo -- CRM é a tabela principal para informação
	    ELSE COALESCE(ca.genero, 'n/a') -- Substitui valores NULL por um valor padrão, garantindo que resultados de cálculos não sejam nulos.
	END AS new_genero
	FROM prata.crm_informacoes_cliente cli
	LEFT JOIN prata.erp_custo_az12 ca ON cli.clt_chave = ca.cid
    LEFT JOIN prata.erp_loc_a101 la ON cli.clt_chave = la.cid

-- 3. Analisar se serão tabelas de fatos ou dimensão: 
--As tabelas dim contem informações descritivas do objeto, nesse caso descreve informações de clientes
--As tabelas fatos descrevem transações, eventos, medidas e etc
/*
 - Precisa-se sempre de uma chave primária para interligação de dimensões, mas nem sempre as tabelas de origem tem uma chave PK para ligação entre as tabelas
 - e com isso preicisa criar uma "CHAVE SUBSTITUTA", essas chaves são apenas para conecta os modelos de dados mas que apenas o Engenheiro de dados sabe da criação
 - para não depender apenas do sistema de origem
 - Formas de criação: Através do DDL ou uma consulta usando janela de função (ROW_NUMBER).
*/

CREATE VIEW ouro.dim_clientes AS
SELECT
	ROW_NUMBER() OVER (ORDER BY clt_id) AS chave_cliente, -- CHAVE SUBSTITUTA
	clt_id as id_cliente,
	clt_chave as numero_cliente,
	clt_primeiro_nome as primeiro_nome,
	clt_ultimo_nome as ultimo_nome,
	la.pais,
	clt_status_civil as status_civil,
	CASE WHEN cli.clt_sexo <> 'n/a' THEN cli.clt_sexo -- CRM é a tabela principal para informação
		 ELSE COALESCE(ca.genero, 'n/a') -- Substitui valores NULL por um valor padrão, garantindo que resultados de cálculos não sejam nulos.
	END AS genero,
	ca.aniversario as data_aniversario,
	clt_data_criacao as data_criacao
FROM prata.crm_informacoes_cliente cli
LEFT JOIN prata.erp_custo_az12 ca ON cli.clt_chave = ca.cid
LEFT JOIN prata.erp_loc_a101 la ON cli.clt_chave = la.cid


-- 4. Criação do objeto que se tornará uma view:
CREATE VIEW ouro.dim_clientes AS
SELECT
	ROW_NUMBER() OVER (ORDER BY clt_id) AS chave_cliente,
	clt_id as id_cliente,
	clt_chave as numero_cliente,
	clt_primeiro_nome as primeiro_nome,
	clt_ultimo_nome as ultimo_nome,
	la.pais,
	clt_status_civil as status_civil,
	CASE WHEN cli.clt_sexo <> 'n/a' THEN cli.clt_sexo -- CRM é a tabela principal para informação
		 ELSE COALESCE(ca.genero, 'n/a') -- Substitui valores NULL por um valor padrão, garantindo que resultados de cálculos não sejam nulos.
	END AS genero,
	ca.aniversario as data_aniversario,
	clt_data_criacao as data_criacao
FROM prata.crm_informacoes_cliente cli
LEFT JOIN prata.erp_custo_az12 ca ON cli.clt_chave = ca.cid
LEFT JOIN prata.erp_loc_a101 la ON cli.clt_chave = la.cid


-- Tabela:prata.crm_informacoes_produto para View ouro.dim_produtos

-- 1. Consulta que realiza verificação de qualidade e tratamento:
-- Expectativa de Resultado: Sem retorno de dados
SELECT prd_chave, COUNT(*) FROM (
SELECT	
cip.prd_id,
cip.categoria_id,
cip.prd_chave,
cip.prd_nm,
cip.prd_custo,
cip.prd_linha,
cip.prd_dt_inicio,
pc.categoria,
pc.subcategoria,
pc.manutencao
FROM prata.crm_informacoes_produto cip
LEFT JOIN prata.erp_px_categoria_g1v2 pc ON cip.categoria_id = pc.id
WHERE cip.prd_dt_fim IS NULL -- Filtra todos os dados históricos
) t GROUP BY prd_chave
HAVING COUNT(*) > 1

-- 2. Analisar se serão tabelas de fatos ou dimensão: 
-- Será uma tabela dim
SELECT
ROW_NUMBER() OVER (ORDER BY cip.prd_dt_inicio, cip.prd_chave) AS chave_produto,
cip.prd_id AS produto_id,
cip.prd_chave AS numero_produto,
cip.prd_nm AS nome_produto,
cip.categoria_id,
pc.categoria,
pc.subcategoria,
pc.manutencao,
cip.prd_custo as custo,
cip.prd_linha as linha_produto,
cip.prd_dt_inicio as data_inicio
FROM prata.crm_informacoes_produto cip
LEFT JOIN prata.erp_px_categoria_g1v2 pc ON cip.categoria_id = pc.id
WHERE cip.prd_dt_fim IS NULL -- Filtra todos os dados históricos

-- 4. Criação do objeto que se tornará uma view:
CREATE VIEW ouro.dim_produtos AS 
SELECT
ROW_NUMBER() OVER (ORDER BY cip.prd_dt_inicio, cip.prd_chave) AS chave_produto,
cip.prd_id AS produto_id,
cip.prd_chave AS numero_produto,
cip.prd_nm AS nome_produto,
cip.categoria_id,
pc.categoria,
pc.subcategoria,
pc.manutencao,
cip.prd_custo as custo,
cip.prd_linha as linha_produto,
cip.prd_dt_inicio as data_inicio
FROM prata.crm_informacoes_produto cip
LEFT JOIN prata.erp_px_categoria_g1v2 pc ON cip.categoria_id = pc.id
WHERE cip.prd_dt_fim IS NULL -- Filtra todos os dados históricos



-- Tabela:prata.crm_detalhes_venda para View ouro.dim_vendas

-- 1. Analisar se serão tabelas de fatos ou dimensão: 
-- Será uma tabela FATO pois há transações, eventos, datas, medidas, métricas e informações.
-- Conecta várias dimensões.
-- Obs: Um fato está conectando a várias dimensões.
-- Contrução de um FATO: Use as chaves substitutivas da dimensão em vez de IDs para conectar facilmente fatos com dimensões.
SELECT 
	dv.venda_num_ordem as numero_pedido,
	pr.chave_produto, -- Chave da dimensão dim_produtos
	cli.chave_cliente, -- Chave da dimensão dim_clientes
	dv.venda_dt_ordem as data_pedido,
	dv.venda_dt_envio as data_envio,
	dv.venda_dt_vencimento as data_vencimento,
	dv.venda_vendas as valor_vendas,
	dv.venda_qtde as quantidade,
	dv.venda_preco as preco
FROM prata.crm_detalhes_venda dv
LEFT JOIN ouro.dim_produtos pr ON dv.venda_chave_produto = pr.numero_produto
LEFT JOIN ouro.dim_clientes cli ON dv.venda_id_custo = cli.id_cliente

-- 2. Criação do objeto que se tornará uma view:
CREATE VIEW ouro.fato_vendas AS
SELECT 
	dv.venda_num_ordem as numero_pedido,
	pr.chave_produto, -- Chave da dimensão dim_produtos
	cli.chave_cliente, -- Chave da dimensão dim_clientes
	dv.venda_dt_ordem as data_pedido,
	dv.venda_dt_envio as data_envio,
	dv.venda_dt_vencimento as data_vencimento,
	dv.venda_vendas as valor_vendas,
	dv.venda_qtde as quantidade,
	dv.venda_preco as preco
FROM prata.crm_detalhes_venda dv
LEFT JOIN ouro.dim_produtos pr ON dv.venda_chave_produto = pr.numero_produto
LEFT JOIN ouro.dim_clientes cli ON dv.venda_id_custo = cli.id_cliente

-- 3. Testar integridade:
--Verificar se todas as tabelas de dimensões podem se juntar com sucesso à tabela de fatos 
SELECT *
FROM ouro.fato_vendas v
LEFT JOIN ouro.dim_clientes c ON c.chave_cliente = v.chave_cliente
LEFT JOIN ouro.dim_produtos p ON p.chave_produto = v.chave_produto
WHERE p.chave_produto IS NULL