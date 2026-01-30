/*
===============================================================================
Procedimento Armazenado: Carga camada Prata (Bronze -> Prata)
===============================================================================
Objetivo do Script:
    Este procedimento armazenado executa o processo ETL (Extrair, Transformar, Carregar) 
	para popular as tabelas do schema 'prata. 

Ações realizadas:
	- Truncar tabelas da camada prata.
	- Insere dados transformados e limpos da camada bronze em tabelas da camada prata.

Parametros: 
	Nenhum.
	Este procedimento armazenado não aceita parametros nem retorna valores.

Exemplo de uso:
	Exec prata.carregar_prata
===============================================================================
*/
CREATE OR ALTER PROCEDURE prata.carregar_prata AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '===================================';
		PRINT 'Carregando a camada prata';
		PRINT '===================================';

		PRINT '-----------------------------------';
		PRINT 'Carregando tabelas CRM';
		PRINT '-----------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: prata.crm_informacoes_cliente';
		Truncate table prata.crm_informacoes_cliente;
		PRINT '>>Inserindo dados na tabela: prata.crm_informacoes_cliente';
		INSERT INTO prata.crm_informacoes_cliente (
		clt_id,
		clt_chave,
		clt_primeiro_nome,
		clt_ultimo_nome,
		clt_status_civil,
		clt_sexo,
		clt_data_criacao)

		SELECT 
		clt_id,
		clt_chave,
		TRIM(clt_primeiro_nome) AS clt_primeiro_nome,
		TRIM(clt_ultimo_nome) AS clt_ultimo_nome,
		 CASE WHEN UPPER(TRIM(clt_status_civil)) = 'S' then 'Solteiro'
			  WHEN UPPER(TRIM(clt_status_civil)) = 'N' then 'Casado'
			  ELSE 'n/a'
		END,
		-- aplicar a função(UPPER) apenas em caso de aparecer valores mistos(maiusculo e minusculo) futuramente na coluna
		 CASE WHEN UPPER(TRIM(clt_sexo)) = 'F' then 'Feminino'
			  WHEN UPPER(TRIM(clt_sexo)) = 'M' then 'Masculino'
			  ELSE 'n/a'
		END AS clt_sexo,
		clt_data_criacao
		FROM  (
		SELECT 
		*,
		-- a função(ROW_NUMBER) atribui um número exclusivo a cada linha em conjunto de resultados, com base em uma ordem definida (numeração de registros [1, 2, 2, 4, 5])
		ROW_NUMBER() OVER (PARTITION BY clt_id ORDER BY clt_data_criacao DESC) as ultimo_dado
		FROM bronze.crm_informacoes_cliente
		) t WHERE ultimo_dado = 1;
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: prata.crm_informacoes_produto';
		Truncate table prata.crm_informacoes_produto;
		PRINT '>>Inserindo dados na tabela: prata.crm_informacoes_produto';
		INSERT INTO prata.crm_informacoes_produto (
	  prd_id,
      categoria_id,
      prd_chave,
      prd_nm,
      prd_custo,
      prd_linha,
      prd_dt_inicio,
      prd_dt_fim
	  )

		SELECT 
		prd_id,
		-- A função(Substring) extrai uma parte especifica de um valor de string, 3 argumentos(Coluna, posição de onde extrair(Nesse caso esquerda), comprimento)
		REPLACE(SUBSTRING(prd_chave, 1, 5), '-', '_') AS categoria_id,
		SUBSTRING(prd_chave, 7, LEN(prd_chave)) AS prd_chave,
		prd_nm,
		-- A função(ISNULL) renomeia onde tem valor NULL para 0
		ISNULL(prd_custo,0) AS prd_custo,
		Case upper(trim(prd_linha))
			 When 'M' then 'Montanha'
			 When 'R' then 'Estrada'
			 When 'S' then 'Outras Vendas'
			 When 'T' then 'Turismo'
			 ELSE 'n/a'
		END AS prd_linha,
		CAST (prd_dt_inicio AS DATE) AS prd_dt_inicio,
		-- A função(LEAD)é uma função de janela, que permite acessar dados de uma linha futura (subsequente)
		LEAD(prd_dt_inicio) OVER (PARTITION BY prd_chave ORDER BY prd_dt_inicio)-1 AS prd_dt_fim
		from bronze.crm_informacoes_produto;
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE()
		PRINT '>> Limpando tabela: prata.crm_detalhes_venda';
		Truncate table prata.crm_detalhes_venda;
		PRINT '>>Inserindo dados na tabela: prata.crm_detalhes_venda';
		INSERT INTO prata.crm_detalhes_venda (
	  venda_num_ordem,
      venda_chave_produto,
      venda_id_custo,
      venda_dt_ordem,
      venda_dt_envio,
      venda_dt_vencimento,
      venda_vendas,
      venda_qtde,
      venda_preco
	  )

		SELECT 
		venda_num_ordem,
		venda_chave_produto,
		venda_id_custo,
		CASE WHEN venda_dt_ordem = 0 OR LEN(venda_dt_ordem) <> 8 THEN NULL
			 ELSE CAST(CAST(venda_dt_ordem AS VARCHAR)AS DATE)
		END AS venda_dt_ordem,
		CASE WHEN venda_dt_envio = 0 OR LEN(venda_dt_envio) <> 8 THEN NULL
			 ELSE CAST(CAST(venda_dt_envio AS VARCHAR)AS DATE)
		END AS venda_dt_envio,
		CASE WHEN venda_dt_vencimento = 0 OR LEN(venda_dt_vencimento) <> 8 THEN NULL
			 ELSE CAST(CAST(venda_dt_vencimento AS VARCHAR)AS DATE)
		END AS venda_dt_vencimento,
		-- A função(ABS) retorna o valor absoluto de um número(Converte do negativo para o positivo)
		CASE WHEN venda_vendas IS NULL OR venda_vendas <= 0 OR venda_vendas <> venda_qtde * ABS(venda_preco) 
				THEN venda_qtde * ABS(venda_preco)
			 ELSE venda_vendas
		END AS venda_vendas,
		venda_qtde,
		CASE WHEN venda_preco IS NULL OR venda_preco <= 0
				THEN venda_vendas / NULLIF(venda_qtde, 0)
			ELSE venda_preco
		END AS venda_preco
		FROM bronze.crm_detalhes_venda;
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: prata.erp_custo_az12';
		Truncate table prata.erp_custo_az12;
		PRINT '>>Inserindo dados na tabela: prata.erp_custo_az12';
		INSERT INTO prata.erp_custo_az12 (cid, aniversario, genero)
		SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(cid))
			 ELSE cid
		END AS cid,
		CASE WHEN aniversario > GETDATE() THEN NULL
			 ELSE aniversario
		END AS aniversario,
		CASE WHEN UPPER(TRIM(genero)) IN ('F', 'FEMALE') then 'Femea'
			 WHEN UPPER(TRIM(genero)) IN ('M', 'MALE') then 'Macho'
			 ELSE 'n/a'
		END AS genero
		FROM bronze.erp_custo_az12;
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: prata.erp_loc_a101';
		Truncate table prata.erp_loc_a101;
		PRINT '>>Inserindo dados na tabela: prata.erp_loc_a101';
		INSERT INTO prata.erp_loc_a101
		(cid, pais) 
		SELECT 
		REPLACE(cid, '-', '') AS cid,
		CASE WHEN TRIM(pais) = 'DE' THEN 'Germany'
			 WHEN TRIM(pais) IN ('US', 'USA') THEN 'United States'
			 WHEN TRIM(pais) = ''  OR pais IS NULL THEN 'n/a'
			 ELSE TRIM(pais)
		END AS pais
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';


		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: prata.erp_px_categoria_g1v2';
		Truncate table prata.erp_px_categoria_g1v2;
		PRINT '>>Inserindo dados na tabela: prata.erp_px_categoria_g1v2';
		INSERT INTO prata.erp_px_categoria_g1v2
		(id, categoria,subcategoria,manutencao)
		select 
		id,
		categoria,
		subcategoria,
		manutencao
		FROM bronze.erp_px_categoria_g1v2;
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @batch_end_time = GETDATE();
		PRINT '===================================='
		PRINT 'Carga da camada prata está completa!';
		PRINT '  - Duração total da carga: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) +  ' seconds';
		PRINT '===================================='
	END TRY
	BEGIN CATCH
		PRINT '===================================='
		PRINT 'Erro ao carregar a camada prata'
		PRINT 'Mensagem de erro' + ERROR_MESSAGE();
		PRINT 'Mensagem de erro' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Mensagem de erro' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '===================================='
	END CATCH
END