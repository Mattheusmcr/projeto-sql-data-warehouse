/*
 Etapas de analise a ser feita na camada PRATA
 =============================================================================
-- Verifique se há nulos ou duplicatas na chave primária
-- Expectativa de Resultado: Sem retorno de nulos ou duplicatas

-- Verifique se há espaços indesejados(Em tudo que tem STRING)
-- Expectativa de Resultado: Sem retorno de espaços em branco nesse caso ou nulo
 =============================================================================
*/


-- 1. Agrupando os dados com base na chave primaria(PK) com base em resultados que tem contagens maior que 1(A PK deve ser unica):
Select 
clt_id,
COUNT(*)
FROM bronze.crm_informacoes_cliente
GROUP BY clt_id
HAVING COUNT(*) > 1 or clt_id is null;


-- Pegando um dado especifico para comparar:
SELECT 
* 
FROM bronze.crm_informacoes_cliente
WHERE clt_id = 29466;

-- 2. Consulta que realiza transformação e limpeza dos dados:
SELECT
*
FROM(
SELECT 
*,
-- a função(ROW_NUMBER) atribui um número exclusivo a cada linha em conjunto de resultados, com base em uma ordem definida (numeração de registros [1, 2, 2, 4, 5])
ROW_NUMBER() OVER (PARTITION BY clt_id ORDER BY clt_data_criacao DESC) as ultimo_dado
FROM bronze.crm_informacoes_cliente
) t WHERE ultimo_dado = 1;


-- 3. Consulta que realiza verificação de qualidade:
-- Expectativa de Resultado: Sem retorno de espaços em branco nesse caso ou nulo

--Verificando se há espaços indesejados(Em tudo que tem STRING)

SELECT 
clt_primeiro_nome,
clt_ultimo_nome, 
clt_status_civil, 
clt_sexo
FROM bronze.crm_informacoes_cliente
--a função(TRIM) remove espaços em branco, seja no inicio ou fim do dado
WHERE clt_primeiro_nome <> TRIM(clt_primeiro_nome);


--Fazendo a transformação dos dados(Padronização e Consistencia dos Dados)
-- (Quanto a padronização o objetivo é armazenar valores claros e sinificativos, em vez de usar termos abreviados, 
-- Para valores ausentes, se utiliza n/a valor "ausente")
--Exemplo, trocando o sexo de M/F para masculino e feminino e quando null colocar N/A

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



-- 4. Inserir os dados limpos:

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
