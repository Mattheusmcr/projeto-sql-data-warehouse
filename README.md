# projeto-sql-data-warehouse
Construção moderna de um DW (Data Warehouse) com SQL Server, incluindo processo de ETL, Modelagem de Dados e Analise.


A arquitetura de dados para este projeto segue as camadas Bronze, Prata e Ouro da Arquitetura Medallion:
<img width="761" height="411" alt="Arquitetura Data Warehouse drawio" src="https://github.com/user-attachments/assets/0e0264ef-ba1c-4426-96b0-79ab19e9ef25" />

1. Camada Bronze: Armazena os dados brutos tal como estão, provenientes dos sistemas de origem. Os dados são importados de arquivos CSV para um banco de dados SQL Server.
2. Camada Prateada: Esta camada inclui processos de limpeza, padronização e normalização de dados para preparar os dados para análise.
3. Camada de Ouro: Armazena dados prontos para uso comercial, modelados em um esquema em estrela, necessários para geração de relatórios e análises.

#Visão geral do projeto

Este projeto envolve:

1. Arquitetura de Dados: Projetar um Data Warehouse moderno usando a arquitetura Medallion nas camadas Bronze, Prata e Ouro.
2. Pipelines ETL: Extrair, transformar e carregar dados de sistemas de origem para o data warehouse.
3. Modelagem de Dados: Desenvolver tabelas de fatos e dimensões otimizadas para consultas analíticas.
4. Análise e Relatórios: Criar relatórios e dashboards baseados em SQL para insights acionáveis.
