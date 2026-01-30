/*
 Etapas de analise a ser feita na camada PRATA como primeiro exemplo
 =============================================================================
-- Verifique se há nulos ou duplicatas na chave primária
-- Expectativa de Resultado: Sem retorno de nulos ou duplicatas

-- Verifique se há espaços indesejados(Em tudo que tem STRING)
-- Expectativa de Resultado: Sem retorno de espaços em branco nesse caso ou nulo
 =============================================================================
*/

-- Tabela:bronze.crm_informacoes_cliente para prata.crm_informacoes_cliente

-- 1. Agrupando os dados com base na chave primaria(PK) com base em resultados que tem contagens maior que 1(A PK deve ser unica):
--Script checa Qualidade, nulos ou duplicatas em chave primária
--Expectativa de Resultado: Sem retorno de dados(confirma que está correto) 
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
--Expectativa de Resultado: Sem retorno de dados(confirma que está correto) 
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

-- 5. Reexecute as consultas na camada nova(Prata) para verifcar se realmente está tudo correto e caso retorne algum dado de resultado, deverá ser revisto.



-- Tabela:bronze.crm_informacoes_produto para prata.crm_informacoes_produto


-- 1. Filtrar dados incomparáveis:
--Verificando se há nulos ou numeros negativos
--Expectativa de Resultado: Sem retorno de dados(confirma que está correto) 
SELECT prd_custo
from prata.crm_informacoes_produto
where prd_custo < 0 or prd_custo is null

--Padronização e Consistencia
SELECT DISTINCT prd_linha
from prata.crm_informacoes_produto

--Verificando se há nulos ou numeros negativos
Select *
from prata.crm_informacoes_produto
where prd_dt_fim < prd_dt_inicio


-- 2. Consulta que realiza transformação e limpeza dos dados:
SELECT 
prd_id,
-- A função(Substring) extrai uma parte especifica de um valor de string, 3 argumentos(Coluna, posição de onde extrair(Nesse caso esquerda), comprimento)
REPLACE(SUBSTRING(prd_chave, 1, 5), '-', '_') AS categoria_id, -- Extrai o ID da categoria
SUBSTRING(prd_chave, 7, LEN(prd_chave)) AS prd_chave, -- Extrai a chave do produto
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
-- A função(LEAD)é uma função de janela, que permite acessar dados de uma linha futura (subsequente). Trata-se de um enriquecimento dos dados
LEAD(prd_dt_inicio) OVER (PARTITION BY prd_chave ORDER BY prd_dt_inicio)-1 AS prd_dt_fim
from bronze.crm_informacoes_produto

-- 3. Inserir os dados limpos:

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
from bronze.crm_informacoes_produto


-- Tabela:bronze.crm_detalhes_venda para prata.crm_detalhes_venda

-- 1. Filtrar dados incomparáveis:
--Verificando se há espaços indesejados(Em tudo que tem STRING)
--Expectativa de Resultado: Sem retorno de dados(confirma que está correto) 
SELECT 
venda_num_ordem,
venda_chave_produto,
venda_id_custo,
venda_dt_ordem,
venda_dt_envio,
venda_dt_vencimento,
venda_vendas,
venda_qtde,
venda_preco
FROM bronze.crm_detalhes_venda
--a função(TRIM) remove espaços em branco, seja no inicio ou fim do dado
WHERE venda_num_ordem <> TRIM(venda_num_ordem);

--Testar a integridade de cada id de fk
SELECT 
venda_num_ordem,
venda_chave_produto,
venda_id_custo,
venda_dt_ordem,
venda_dt_envio,
venda_dt_vencimento,
venda_vendas,
venda_qtde,
venda_preco
FROM bronze.crm_detalhes_venda
--a função(TRIM) remove espaços em branco, seja no inicio ou fim do dado
WHERE venda_chave_produto NOT IN (SELECT prd_chave from prata.crm_informacoes_produto);


SELECT 
venda_num_ordem,
venda_chave_produto,
venda_id_custo,
venda_dt_ordem,
venda_dt_envio,
venda_dt_vencimento,
venda_vendas,
venda_qtde,
venda_preco
FROM bronze.crm_detalhes_venda
--a função(TRIM) remove espaços em branco, seja no inicio ou fim do dado
WHERE venda_id_custo NOT IN (SELECT clt_id from prata.crm_informacoes_cliente);

--Verificando datas invalidas: 
--Números negativos ou zeros não podem ser lançados em uma data
--Confirmar em todas as datas da tabela
SELECT
--A função(NULLIF) retorna nulo se os dois valores fornecidos forem iguais; caso contrário, retorna a primeira expressão.
NULLIF(venda_dt_ordem,0) AS venda_dt_ordem
FROM bronze.crm_detalhes_venda
where venda_dt_ordem <= 0 
OR LEN(venda_dt_ordem) <> 8
OR venda_dt_ordem > 20500101
OR venda_dt_ordem < 19000101

--verificar pedidos com data inválida
SELECT
*
FROM bronze.crm_detalhes_venda
WHERE venda_dt_ordem > venda_dt_envio OR venda_dt_ordem > venda_dt_vencimento

--Verifique a consistencia dos dados: Entre vendas, quantidade e preço
-- >> Vendas = Quantidade * Preço
-- > Os valores não devem ser null, zero ou negativos
-- Se as vendas forem negativas, zero ou nulas, utilize a formula de Quantidade * Preço;
-- Se for nulo ou zero, calcular a partir das vendas e da quantidade;
-- Se o preço for negativo, converta para positivo;
SELECT DISTINCT
venda_vendas,
venda_qtde,
venda_preco
FROM bronze.crm_detalhes_venda
WHERE venda_vendas <> venda_qtde * venda_preco
or venda_vendas is null or venda_qtde is null or venda_preco is null
OR venda_vendas <= 0 OR venda_qtde <= 0 or venda_preco <= 0
ORDER BY venda_vendas, venda_qtde, venda_preco

-- 2. Consulta que realiza transformação e limpeza dos dados:

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
FROM bronze.crm_detalhes_venda


-- 3. Inserir os dados limpos:

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
FROM bronze.crm_detalhes_venda


-- Tabela:bronze.erp_custo_az12 para prata.erp_custo_az12

-- 1. Identificar datas fora do intervalo:
--verificando se tem data de aniversário futuro
  SELECT DISTINCT 
  aniversario
  FROM bronze.erp_custo_az12
  WHERE aniversario < '1924-01-01' OR aniversario > GETDATE()


--Padronização e Consistencia
SELECT DISTINCT 
genero AS old_genero,
CASE WHEN UPPER(TRIM(genero)) IN ('F', 'FEMALE') then 'Femea'
	 WHEN UPPER(TRIM(genero)) IN ('M', 'MALE') then 'Macho'
	 ELSE 'n/a'
END AS genero
FROM bronze.erp_custo_az12


-- 2. Consulta que realiza transformação e limpeza dos dados:
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(cid))
	 ELSE cid
END AS cid,
CASE WHEN aniversario > GETDATE() THEN NULL -- Define datas de nascimento futuras como nulas 
	 ELSE aniversario
END AS aniversario, 
CASE WHEN UPPER(TRIM(genero)) IN ('F', 'FEMALE') then 'Femea' 
	 WHEN UPPER(TRIM(genero)) IN ('M', 'MALE') then 'Macho'
	 ELSE 'n/a'
END AS genero
FROM bronze.erp_custo_az12




-- 3. Inserir os dados limpos:
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
FROM bronze.erp_custo_az12



-- Tabela:bronze.erp_loc_a101 para prata.erp_loc_a101

-- 1. Filtrar dados incomparáveis:
 SELECT 
 REPLACE(cid, '-', '') AS cid,
 pais
 FROM bronze.erp_loc_a101
 where  REPLACE(cid, '-', '') NOT IN
(SELECT clt_chave FROM prata.crm_informacoes_cliente)


--Padronização e Consistencia
SELECT DISTINCT pais 
FROM bronze.erp_loc_a101
ORDER BY pais

SELECT DISTINCT 
pais AS old_pais,
 CASE WHEN TRIM(pais) = 'DE' THEN 'Germany'
	  WHEN TRIM(pais) IN ('US', 'USA') THEN 'United States'
	  WHEN TRIM(pais) = ''  OR pais IS NULL THEN 'n/a'
	  ELSE TRIM(pais)
END AS pais
FROM bronze.erp_loc_a101
ORDER BY pais


-- 2. Consulta que realiza transformação e limpeza dos dados:
 SELECT 
 REPLACE(cid, '-', '') AS cid,
 CASE WHEN TRIM(pais) = 'DE' THEN 'Germany'
	  WHEN TRIM(pais) IN ('US', 'USA') THEN 'United States'
	  WHEN TRIM(pais) = ''  OR pais IS NULL THEN 'n/a'
	  ELSE TRIM(pais)
END AS pais
 FROM bronze.erp_loc_a101



-- 3. Inserir os dados limpos:
 INSERT INTO prata.erp_loc_a101
 (cid, pais) 
 SELECT 
 REPLACE(cid, '-', '') AS cid,
 CASE WHEN TRIM(pais) = 'DE' THEN 'Germany'
	  WHEN TRIM(pais) IN ('US', 'USA') THEN 'United States'
	  WHEN TRIM(pais) = ''  OR pais IS NULL THEN 'n/a'
	  ELSE TRIM(pais)
END AS pais
 FROM bronze.erp_loc_a101



-- Tabela:bronze.erp_px_categoria_g1v2 para prata.erp_px_categoria_g1v2

-- 1. Consulta que realiza verificação de qualidade:
-- Expectativa de Resultado: Sem retorno de espaços em branco nesse caso ou nulo

--Verificando se há espaços indesejados(Em tudo que tem STRING)
--Expectativa de Resultado: Sem retorno de dados(confirma que está correto) 

SELECT 
id,
categoria,
subcategoria,
manutencao
FROM bronze.erp_px_categoria_g1v2
--a função(TRIM) remove espaços em branco, seja no inicio ou fim do dado
WHERE categoria <> TRIM(categoria) OR subcategoria <> TRIM(subcategoria)  OR manutencao <> TRIM(manutencao)


--Padronização e Consistencia
select distinct
categoria,
subcategoria,
manutencao
FROM bronze.erp_px_categoria_g1v2

-- 2. Os dados estão perfeitos, sem precisar alterar nada

-- 3. Inserir os dados limpos:
INSERT INTO prata.erp_px_categoria_g1v2
(id, categoria,subcategoria,manutencao)
select 
id,
categoria,
subcategoria,
manutencao
FROM bronze.erp_px_categoria_g1v2