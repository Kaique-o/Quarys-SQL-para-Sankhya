SELECT DISTINCT

    -- Seleciona o número único da nota fiscal
    ITE.NUNOTA AS "id da nota",

    -- Código do cliente (ID do cadastro)
    PAR.CODPARC AS "código do cliente",

    -- Concatena o código da empresa com a razão social abreviada
    ITE.CODEMP || ' - ' || EMP.RAZAOABREV AS "empresa",

    -- Formata a data de negociação no formato 'DD/MM/YYYY'
    TO_CHAR(CAB.DTNEG, 'DD/MM/YYYY') AS "data de negociação",

    -- Descrição do produto
    PRO.DESCRPROD AS "produto",

    -- SKU (código de referência do produto)
    PRO.REFERENCIA AS "sku",

    -- Família do produto
    GRU.DESCRGRUPOPROD AS "família",

    -- Determina o tipo fiscal com base no tipo de movimento
    CASE 
        WHEN CAB.TIPMOV = 'V' THEN 'VENDA' 
        WHEN CAB.TIPMOV = 'D' THEN 'DEVOLUÇÃO DE VENDA' 
        ELSE '' 
    END AS "tipo fiscal",

    -- Quantidade negociada, ajustando se for devolução
    CASE 
        WHEN CAB.TIPMOV = 'D' THEN TO_CHAR((ITE.QTDNEG * -1), 'FM9999999990') 
        WHEN CAB.TIPMOV = 'V' THEN TO_CHAR(ITE.QTDNEG, 'FM9999999990') 
        ELSE NULL 
    END AS "quantidade",

    -- Valor unitário, ajustando para devoluções
    CASE 
        WHEN CAB.TIPMOV = 'D' THEN (ITE.VLRUNIT * -1) 
        WHEN CAB.TIPMOV = 'V' THEN ITE.VLRUNIT 
        ELSE NULL 
    END AS "valor unitário",

    -- Valor total do item, considerando descontos e ajustando para devoluções
    CASE 
        WHEN CAB.TIPMOV = 'D' THEN ((ITE.VLRUNIT * ITE.QTDNEG) * -1) - ITE.VLRDESC 
        WHEN CAB.TIPMOV = 'V' THEN (ITE.VLRUNIT * ITE.QTDNEG) - ITE.VLRDESC 
        ELSE NULL 
    END AS "valor total",

    -- Custo do item, ajustado para devoluções
    CASE 
        WHEN CAB.TIPMOV = 'D' THEN ((CUS3.CUSREP * ITE.QTDNEG) * -1) 
        WHEN CAB.TIPMOV = 'V' THEN (CUS3.CUSREP * ITE.QTDNEG) 
        ELSE NULL 
    END AS "custo",

    -- Lucro bruto, calculado subtraindo o custo do valor unitário, ajustado para devoluções
    CASE 
        WHEN CAB.TIPMOV = 'D' THEN (((ITE.VLRUNIT * ITE.QTDNEG) - (CUS.CUSMEDICM * ITE.QTDNEG)) * -1) 
        WHEN CAB.TIPMOV = 'V' THEN ((ITE.VLRUNIT * ITE.QTDNEG) - (CUS.CUSMEDICM * ITE.QTDNEG)) 
        ELSE NULL 
    END AS "lucro Bruto",

    -- Canal de vendas
    CUS5.DESCRCENCUS AS "canal",

    -- Indica se a movimentação foi uma devolução (1 = devolução, 0 = venda)
    CASE 
        WHEN CAB.TIPMOV = 'V' THEN '0' 
        WHEN CAB.TIPMOV = 'D' THEN '1' 
        ELSE '' 
    END AS "devolução",

    -- Marca do produto
    PRO.MARCA AS "marca",

    -- Descrição da interação
    INTE.DESCRICAO AS "interação",

    -- Descrição do macro grupo
    INTE2.DESCRICAO AS "macro grupo",

    -- Curva ABC do produto, substitui valores nulos por 'D'
    NVL(ABC.CURVA, 'D') AS "curva",

    -- Custo médio, ajustado para devoluções
    CASE 
        WHEN CAB.TIPMOV = 'D' THEN ((CUS.CUSMEDICM * ITE.QTDNEG) * -1) 
        WHEN CAB.TIPMOV = 'V' THEN (CUS.CUSMEDICM * ITE.QTDNEG) 
        ELSE NULL 
    END AS "custo médio",

    -- Data da última alteração no produto
    PRO.DTALTER AS "data de alteração",

    -- Nome do cliente
    PAR.NOMEPARC AS "cliente",

    -- Apelido do vendedor responsável
    VEN.APELIDO AS "vendedor",

    -- ID do produto
    PRO.CODPROD AS "id do produto"
    
FROM TGFITE ITE

-- JOIN para trazer informações da nota fiscal (cabeçalho)
INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA

-- JOIN para trazer informações do cliente
INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC

-- JOIN para trazer informações do vendedor
INNER JOIN TGFVEN VEN ON VEN.CODVEND = ITE.CODVEND

-- JOIN para trazer informações da empresa
INNER JOIN TSIEMP EMP ON ITE.CODEMP = EMP.CODEMP

-- JOIN para trazer informações do produto
INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD

-- JOIN para trazer informações da família do produto
INNER JOIN TGFGRU GRU ON PRO.CODGRUPOPROD = GRU.CODGRUPOPROD

-- JOIN para trazer informações do tipo de operação
INNER JOIN TGFTOP TOP ON TOP.TIPMOV = CAB.TIPMOV

-- JOIN para trazer informações do canal de vendas
INNER JOIN TSICUS CUS5 ON CAB.CODCENCUS = CUS5.CODCENCUS

-- LEFT JOIN para trazer a curva ABC do produto, se existir
LEFT JOIN AD_CABCPRO ABC ON PRO.CODPROD = ABC.CODPROD

-- LEFT JOIN para calcular o custo médio do produto com base na data da negociação
LEFT JOIN TGFCUS CUS ON CUS.CODPROD = ITE.CODPROD
    AND CUS.DTATUAL = (
        SELECT MAX(CUS2.DTATUAL)
        FROM TGFCUS CUS2
        WHERE CUS2.CODPROD = ITE.CODPROD
        AND CUS2.DTATUAL <= CAB.DTNEG
    )

-- LEFT JOIN para trazer o custo de reposição do produto
LEFT JOIN TGFCUS CUS3 ON CUS3.CODPROD = ITE.CODPROD
    AND CUS3.DTATUAL = (
        SELECT MAX(CUS4.DTATUAL)
        FROM TGFCUS CUS4
        WHERE CUS4.CODPROD = ITE.CODPROD
        AND CUS4.DTATUAL <= CAB.DTNEG
    )

-- LEFT JOIN para trazer informações da interação e macro grupo (categorias)
LEFT JOIN (
    SELECT
        CAN.DESCRICAO,
        CAN.CODCANENT
    FROM AD_CANENT CAN
    INNER JOIN TGFCAB CAB ON CAN.CODCANENT = SUBSTR(CAB.AD_CODCANENT,0,3) || '0000'
    WHERE CAN.CODCANENT = SUBSTR(CAB.AD_CODCANENT,0,3) || '0000'
) INTE ON CAB.AD_CODCANENT = INTE.CODCANENT

-- LEFT JOIN para trazer informações do macro grupo (categoria principal)
LEFT JOIN (
    SELECT
        CAN.DESCRICAO,
        CAN.CODCANENT
    FROM AD_CANENT CAN
    INNER JOIN TGFCAB CAB ON CAN.CODCANENT = SUBSTR(CAB.AD_CODCANENT,0,4) || '0000'
    WHERE CAN.CODCANENT = SUBSTR(CAB.AD_CODCANENT,0,4) || '0000'
) INTE2 ON CAB.AD_CODCANENT = INTE2.CODCANENT


-- FILTROS


WHERE

    -- Filtra o tipo de movimentação para incluir apenas vendas e devoluções
    CAB.TIPMOV IN ('V', 'D')

    -- Filtra pelas operações fiscais específicas
    AND CAB.CODTIPOPER IN (3021, 3022, 4201, 4056, 4057, 4025, 4028, 4029, 4021, 1201)

    -- Ignora notas fiscais não confirmadas
    AND ITE.NUNOTA <> 0

    -- Exclui notas fiscais específicas que foram lançadas incorretamente
    AND ITE.NUNOTA NOT IN (9935, 10008, 14311)

    -- Filtra pela data de negociação
    AND CAB.DTNEG BETWEEN '07/08/2024' AND '07/08/2024'
    
    -- (Comentado) Filtro alternativo para um intervalo de datas
    -- AND CAB.DTNEG BETWEEN '01/07/2024' AND TRUNC(SYSDATE)-1

    -- Considera apenas notas fiscais com status liberado
    AND CAB.STATUSNOTA = 'L'

    -- Garante que a data atual e o custo médio não sejam nulos
    AND (CUS.DTATUAL IS NOT NULL OR CUS3.CUSREP IS NOT NULL)

    -- Para Caso Queira puxar apenas um Pedido
    AND cab.nunota = 35918


-- ORDENA E CLASSIFICA  


-- Ordena Resultado por data da negociacao
ORDER BY
    TO_CHAR(CAB.DTNEG, 'DD/MM/YYYY') ASC,
    ITE.NUNOTA ASC
