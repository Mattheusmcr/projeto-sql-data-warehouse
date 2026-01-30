/*
===============================================================================
Procedimento Armazenado: Carga camada Bronze
===============================================================================
Objetivo do Script:
    Este procedimento armazenado executa o processo EL (Extrair e Carregar) 
	para popular as tabelas do schema 'bronze'. 

Ações realizadas:
	- Truncar tabelas da camada bronze.
	- Insere dados a partir de arquivos CSV externos nas tabelas da camada bronze.

Parametros: 
	Nenhum.
	Este procedimento armazenado não aceita parametros nem retorna valores.

Exemplo de uso:
	Exec bronze.carregar_bronze
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.carregar_bronze as
BEGIN
	-- As variaveis @start_time/@end_time e @batch_start_time/@batch_end_time foram criadas para as primeiras mostrar 
	-- a duração do lote ao todo e as duas ultimas para o tempo de inicio e fim de cada carga de tabelas
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
/* BULK é usado para importar de forma eficiente grandes volumes de dados de um arquivo de dados externo (como um arquivo CSV ou de texto)
para uma tabela ou visualização de banco de dados. 
*/		SET @batch_start_time = GETDATE();
		PRINT '===================================';
		PRINT 'Carregando a camada bronze';
		PRINT '===================================';

		PRINT '-----------------------------------';
		PRINT 'Carregando tabelas CRM';
		PRINT '-----------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: bronze.crm_informacoes_cliente';
		Truncate table bronze.crm_informacoes_cliente;

		PRINT '>>Inserindo dados na tabela: bronze.crm_informacoes_cliente';
		BULK INSERT bronze.crm_informacoes_cliente
		FROM 'C:\Users\USUARIO\Desktop\Engenharia de Dados\Data Warehouse\datasets\origem_crm\informacao_cliente.csv'
		with (
		--Definindo qual linha está os dados de fato
			firstrow = 2,
		--Definindo qual é a separação dos dados no csv
			fieldterminator = ',',
		--Bloquea a tabela inteira durante o carregamento
			tablock 
		);
		SET @end_time = GETDATE();
		-- DATEDIFF cauclula o intervalo entre duas datas/tempo  
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: bronze.crm_detalhes_venda';
		 Truncate table bronze.crm_detalhes_venda;

		PRINT '>>Inserindo dados na tabela: bronze.crm_detalhes_venda';
		BULK INSERT bronze.crm_detalhes_venda
		FROM 'C:\Users\USUARIO\Desktop\Engenharia de Dados\Data Warehouse\datasets\origem_crm\detalhes_vendas.csv'
		with (
		--Definindo qual linha está os dados de fato
			firstrow = 2,
		--Definindo qual é a separação dos dados no csv
			fieldterminator = ',',
		--Bloquea a tabela inteira durante o carregamento
			tablock 
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: bronze.crm_informacoes_produto';
		Truncate table bronze.crm_informacoes_produto;

		PRINT '>>Inserindo dados na tabela: bronze.crm_informacoes_produto';
		BULK INSERT bronze.crm_informacoes_produto
		FROM 'C:\Users\USUARIO\Desktop\Engenharia de Dados\Data Warehouse\datasets\origem_crm\informacao_produto.csv'
		with (
		--Definindo qual linha está os dados de fato
			firstrow = 2,
		--Definindo qual é a separação dos dados no csv
			fieldterminator = ',',
		--Bloquea a tabela inteira durante o carregamento
			tablock 
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		PRINT '-----------------------------------';
		PRINT 'Carregando tabelas ERP';
		PRINT '-----------------------------------';
	
		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: bronze.erp_custo_az12';
		Truncate table bronze.erp_custo_az12;

		PRINT '>>Inserindo dados na tabela: bronze.erp_custo_az12';
		BULK INSERT bronze.erp_custo_az12
		FROM 'C:\Users\USUARIO\Desktop\Engenharia de Dados\Data Warehouse\datasets\origem_erp\CUST_AZ12.csv'
		with (
		--Definindo qual linha está os dados de fato
			firstrow = 2,
		--Definindo qual é a separação dos dados no csv
			fieldterminator = ',',
		--Bloquea a tabela inteira durante o carregamento
			tablock 
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: bronze.erp_loc_a101';
		Truncate table bronze.erp_loc_a101;

		PRINT '>>Inserindo dados na tabela: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\USUARIO\Desktop\Engenharia de Dados\Data Warehouse\datasets\origem_erp\LOC_A101.csv'
		with (
		--Definindo qual linha está os dados de fato
			firstrow = 2,
		--Definindo qual é a separação dos dados no csv
			fieldterminator = ',',
		--Bloquea a tabela inteira durante o carregamento
			tablock 
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Limpando tabela: bronze.erp_px_categoria_g1v2';
		Truncate table bronze.erp_px_categoria_g1v2;
	
		PRINT '>>Inserindo dados na tabela: bronze.erp_px_categoria_g1v2';
		BULK INSERT bronze.erp_px_categoria_g1v2
		FROM 'C:\Users\USUARIO\Desktop\Engenharia de Dados\Data Warehouse\datasets\origem_erp\PX_CAT_G1V2.csv'
		with (
		--Definindo qual linha está os dados de fato
			firstrow = 2,
		--Definindo qual é a separação dos dados no csv
			fieldterminator = ',',
		--Bloquea a tabela inteira durante o carregamento
			tablock 
		);
		SET @end_time = GETDATE();
		PRINT '>> Duração da carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +  ' seconds';
		PRINT '-------------------';

		SET @batch_end_time = GETDATE();
		PRINT '===================================='
		PRINT 'Carga da camada bronze está completa!';
		PRINT '  - Duração total da carga: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) +  ' seconds';
		PRINT '===================================='
	END TRY
	BEGIN CATCH
		PRINT '===================================='
		PRINT 'Erro ao carregar a camada bronze'
		PRINT 'Mensagem de erro' + ERROR_MESSAGE();
		PRINT 'Mensagem de erro' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Mensagem de erro' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '===================================='
	END CATCH
END

