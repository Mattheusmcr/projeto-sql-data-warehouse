/*
===============================================================================
DDL Script: Criação Tabelas Prata
===============================================================================
Finalidade do Script:
    Este script cria tabelas no esquema 'prata', excluindo tabelas existentes
    caso já existam.
    Execute este script para redefinir a estrutura DDL das tabelas 'prata'.
===============================================================================
*/

IF OBJECT_ID('silver.crm_informacoes_cliente', 'U') IS NOT NULL
    DROP TABLE silver.crm_informacoes_cliente;
GO

CREATE TABLE silver.crm_informacoes_cliente (
    clt_id INT,
    clt_chave NVARCHAR(50),
    clt_primeiro_nome NVARCHAR(50),
    clt_ultimo_nome NVARCHAR(50),
    clt_status_civil NVARCHAR(50),
    clt_sexo NVARCHAR(50),
    clt_data_criacao DATE,
	dwh_data_criacao DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.crm_informacoes_produto', 'U') IS NOT NULL
    DROP TABLE silver.crm_informacoes_produto;
GO

CREATE TABLE silver.crm_informacoes_produto (
    prd_id INT,
    prd_chave NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_custo INT,
    prd_linha NVARCHAR(50),
    prd_dt_inicio DATETIME,
    prd_dt_fim DATETIME,
	dwh_data_criacao DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.crm_detalhes_venda', 'U') IS NOT NULL
    DROP TABLE silver.crm_detalhes_venda;
GO

CREATE TABLE silver.crm_detalhes_venda (
    venda_num_ordem NVARCHAR(50),
    venda_chave_produto NVARCHAR(50),
    venda_id_custo INT,
    venda_dt_ordem INT,
    venda_dt_envio INT,
    venda_dt_vencimento INT,
    venda_vendas INT,
    venda_qtde INT,
    venda_preco INT,
	dwh_data_criacao DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    pais NVARCHAR(50),
	dwh_data_criacao DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_custo_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_custo_az12;
GO

CREATE TABLE silver.erp_custo_az12 (
    cid NVARCHAR(50),
    aniversario DATE,
    genero NVARCHAR(50),
	dwh_data_criacao DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_px_categoria_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_categoria_g1v2;
GO

CREATE TABLE silver.erp_px_categoria_g1v2 (
    id  NVARCHAR(50),
    categoria NVARCHAR(50),
    subcategoria NVARCHAR(50),
    manutencao NVARCHAR(50),
	dwh_data_criacao DATETIME DEFAULT GETDATE()
);
GO