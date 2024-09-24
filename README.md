### README: Relatório de Vendas e Devoluções com Análise de Custos e Lucro Bruto

---

## Descrição

Este projeto contém uma **query SQL** que gera um relatório detalhado de vendas e devoluções, apresentando dados financeiros e operacionais de cada transação. O relatório inclui informações sobre os clientes, produtos, empresas, e análises de custo e lucro bruto, permitindo uma avaliação completa do desempenho das operações comerciais.

## Funcionalidades

- Exibe informações de vendas e devoluções, incluindo:
  - Número da nota fiscal
  - Cliente (código e nome)
  - Produto (descrição, SKU, marca, e família)
  - Quantidade negociada e valor unitário
  - Custos, lucro bruto, e valor total da transação
  - Tipo de movimentação (venda ou devolução)
  - Canal de venda, vendedor e interação
- Filtra por período de data específico e apenas notas confirmadas.
- Exclui pedidos incorretos e itens com dados incompletos de custo médio.
- Ordena os resultados por data de negociação e número da nota.

## Pré-requisitos

- Banco de dados compatível com SQL (Ex: Oracle, PostgreSQL)
- Acesso às tabelas necessárias:
  - `TGFITE`, `TGFCAB`, `TGFPAR`, `TGFVEN`, `TGFPRO`, `TGFGRU`, `TSIEMP`, `TSICUS`, `AD_CANENT`
- Ambiente SQL configurado para executar a query.

## Uso

1. Clone o repositório:
   ```bash
   gh repo clone Kaique-o/Quarys-SQL-para-Sankhya
   ```

2. Abra a query no seu ambiente SQL preferido.

3. Ajuste as **datas** no filtro `CAB.DTNEG BETWEEN '07/08/2024' AND '07/08/2024'` conforme o período que deseja analisar.

4. Execute a query para gerar o relatório.

5. O relatório será retornado ordenado por data de negociação e número da nota.

## Estrutura

A query SQL contém os seguintes blocos principais:

1. **SELECT**: Seleciona e renomeia os campos importantes como `id da nota`, `código do cliente`, `produto`, `quantidade`, `valor total`, etc.
2. **JOINS**: Realiza junções entre várias tabelas para obter as informações necessárias sobre produtos, clientes, e movimentações fiscais.
3. **Filtros**: Filtra os resultados por tipo de movimentação, período de data, e status de confirmação da nota fiscal.
4. **ORDER BY**: Ordena os resultados pela data de negociação e número da nota.

## Contribuição

Sinta-se à vontade para abrir issues ou enviar pull requests para melhorar a query ou incluir novos recursos.


---

Feito por [Kaique](https://github.com/Kaique-o).
