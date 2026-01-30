/*
=================================================================================================
DDL Script: Criação Tabelas Ouro
=================================================================================================
Finalidade do Script:
    Este script cria Views para a camada ouro no data warehouse.
    A camada ouro representa as tabelas finais de dimensões e fatos (Esquema Estrela).

    Cada view realiza transformações e combina dados da camada prata.
    Produzir um conjunto de dados limpo, enriquecido e pronto para uso comercial.

Uso:
    - Essas visualizações podem ser consultadas diretamente para análises e geração de relatórios.
===================================================================================================
*/

-- =============================================================================
-- Criação dimensão: ouro.dim_clientes
-- =============================================================================
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

-- =============================================================================
-- Criação dimensão: ouro.dim_produtos
-- =============================================================================
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

-- =============================================================================
-- Criação tabela Fato: ouro.fato_vendas
-- =============================================================================

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