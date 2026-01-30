# Catálogo de dados para camada de ouro

## Visão geral
A Camada Ouro é a representação de dados em nível de negócios, estruturada para dar suporte a casos de uso analíticos e de geração de relatórios. Ela consiste em **tabelas de dimensão** e **tabelas de fatos** para métricas de negócios específicas.



---

### 1. **ouro.dim_clientes**
- **Finalidade:** Armazen detalhes do cliente enriquecidos com dados demográficos e geográficos.
- **Colunas:**

| Nome da Coluna   | Tipo de dados | Descrição                                                                                      |
|------------------|---------------|------------------------------------------------------------------------------------------------|
| chave_cliente    | INT           | Chave substituta que identifica exclusivamente cada registro de cliente na tabela de dimensões.|
| id_cliente       | INT           | Identificador numérico único atribuído a cada cliente.                                         |
| numero_cliente   | NVARCHAR(50)  | Identificador alfanumérico que representa o cliente, usado para rastreamento e referência.     |
| primeiro_nome    | NVARCHAR(50)  | O primeiro nome do cliente, conforme registrado no sistema.                                    |
| ultimo_nome      | NVARCHAR(50)  | O sobrenome ou nome de família do cliente.                                                     |
| pais             | NVARCHAR(50)  | O país de residência do cliente (ex.: 'Austrália').                                            |
| status_civil     | NVARCHAR(50)  | O estado civil do cliente (ex.: 'Casado', 'Solteiro').                                         |
| genero           | NVARCHAR(50)  | O gênero do cliente (ex.: 'Masculino', 'Feminino', 'Não aplicável').                           |
| data_aniversario | DATE          | A data de nascimento do cliente, formatada como AAAA-MM-DD (ex.: 1971-10-06).                  |
| create_date      | DATE          | A data e a hora em que o registro do cliente foi criado no sistema.                            |

---

### 2. **ouro.dim_produtos**
- **Finalidade:** Provides information about the products and their attributes.
- **Colunas:**

| Nome da Coluna      | Tipo de dados | Descrição                                                                                                                    |
|---------------------|---------------|------------------------------------------------------------------------------------------------------------------------------|
| chave_produto       | INT           | Chave substituta que identifica exclusivamente cada registro de produto na tabela de dimensões do produto.                   |
| produto_id          | INT           | Um identificador único atribuído ao produto para fins de rastreamento e referência internos.                                 |
| numero_produto      | NVARCHAR(50)  | Um código alfanumérico estruturado que representa o produto, frequentemente usado para categorização ou controle de estoque. |
| nome_produto        | NVARCHAR(50)  | Nome descritivo do produto, incluindo detalhes importantes como tipo, cor e tamanho.                                         |
| categoria_id        | NVARCHAR(50)  | Um identificador único para a categoria do produto, que o vincula à sua classificação de alto nível.                         |
| categoria           | NVARCHAR(50)  | A classificação mais ampla do produto (por exemplo, Bicicletas, Componentes) para agrupar itens relacionados.                |
| subcategoria        | NVARCHAR(50)  | Uma classificação mais detalhada do produto dentro da categoria, como por exemplo, o tipo de produto.                        |
| manutencao          | NVARCHAR(50)  | Indica se o produto necessita de manutenção (ex.: 'Sim', 'Não').                                                             |
| custo               | INT           | O custo ou preço base do produto, medido em unidades monetárias.                                                             |
| linha_produto       | NVARCHAR(50)  | A linha de produtos ou série específica à qual o produto pertence (ex.: Estrada, Montanha).                                  |
| data_inicio         | DATE          | A data em que o produto ficou disponível para venda ou uso, armazenada em                                                    |

---

### 3. **ouro.fato_vendas**
- **Finalidade:** Armazena dados de vendas transacionais para fins analíticos.
- **Colunas:**

| Nome da Coluna  | Tipo de dados | Descrição                                                                                        |
|-----------------|---------------|--------------------------------------------------------------------------------------------------|
| numero_pedido   | NVARCHAR(50)  | Um identificador alfanumérico único para cada pedido de venda (ex.: 'SO54496').                  |
| chave_produto   | INT           | Chave substituta que vincula o pedido à tabela de dimensões do produto.                          |
| chave_cliente   | INT           | Chave substituta que vincula o pedido à tabela de dimensões do cliente.                          |
| data_pedido     | DATE          | A data em que o pedido foi feito.                                                                |
| data_envio      | DATE          | A data em que o pedido foi enviado ao cliente.                                                   | 
| data_vencimento | DATE          | A data em que o pagamento do pedido vencia.                                                      | 
| valor_vendas    | INT           | O valor monetário total da venda do item, em unidades monetárias inteiras (ex.: 25).             |
| quantidade      | INT           | O número de unidades do produto encomendadas para o item em questão (ex.: 1).                    |
| preco           | INT           | O preço por unidade do produto para o item em questão, em unidades monetárias inteiras (ex.: 25).|