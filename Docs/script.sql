CREATE DATABASE padaria_forno_lusitano
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
 
USE padaria_forno_lusitano;
 
CREATE TABLE Cliente (
    id_cliente   INT          NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(120) NOT NULL,
    telefone     VARCHAR(20)  NOT NULL,
    cep          VARCHAR(9)   NOT NULL,
    cidade       VARCHAR(80)  NOT NULL,
    logradouro   VARCHAR(120) NOT NULL,
    bairro       VARCHAR(80)  NOT NULL,
    numero       INT          NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT ck_cliente_numero CHECK (numero > 0),
    INDEX idx_cliente_nome (nome),
    INDEX idx_cliente_telefone (telefone)
);
 
CREATE TABLE Funcionario (
    id_funcionario   INT          NOT NULL AUTO_INCREMENT,
    nome_funcionario VARCHAR(120) NOT NULL,
    CPF              VARCHAR(11)  NOT NULL,
    cargo            VARCHAR(60)  NOT NULL,
    telefone         VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
    CONSTRAINT uq_funcionario_cpf UNIQUE (CPF),
    CONSTRAINT ck_funcionario_cpf CHECK (CPF REGEXP '^[0-9]{11}$')
);
 
CREATE TABLE Categoria (
    id_categoria INT         NOT NULL AUTO_INCREMENT,
    descricao    VARCHAR(60) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
);
 
CREATE TABLE Fornecedor (
    id_fornecedor   INT          NOT NULL AUTO_INCREMENT,
    nome_fornecedor VARCHAR(120) NOT NULL,
    CNPJ            VARCHAR(14)  NOT NULL,
    telefone        VARCHAR(20)  NOT NULL,
    email           VARCHAR(120) NULL,
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
    CONSTRAINT uq_fornecedor_cnpj UNIQUE (CNPJ),
    CONSTRAINT ck_fornecedor_cnpj CHECK (CNPJ REGEXP '^[0-9]{14}$')
);
 
CREATE TABLE Ingrediente (
    id_ingrediente     INT          NOT NULL AUTO_INCREMENT,
    nome_ingrediente   VARCHAR(100) NOT NULL,
    unidade_medida     VARCHAR(10)  NOT NULL,
    quantidade_estoque INT          NOT NULL DEFAULT 0,
    estoque_minimo     INT          NOT NULL,
    CONSTRAINT pk_ingrediente PRIMARY KEY (id_ingrediente),
    CONSTRAINT ck_ingrediente_quantidade CHECK (quantidade_estoque >= 0),
    CONSTRAINT ck_ingrediente_minimo CHECK (estoque_minimo >= 0),
    INDEX idx_ingrediente_nome (nome_ingrediente)
);
 
CREATE TABLE Produto (
    id_produto     INT           NOT NULL AUTO_INCREMENT,
    nome_produto   VARCHAR(100)  NOT NULL,
    preco          DECIMAL(10,2) NOT NULL,
    quantidade     INT           NOT NULL DEFAULT 0,
    estoque_minimo INT           NOT NULL,
    unidade_medida VARCHAR(10)   NOT NULL,
    id_categoria   INT           NULL,
    codigo_barra   VARCHAR(20)   NULL,
    ativo          BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT uq_produto_codigo_barra UNIQUE (codigo_barra),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
        REFERENCES Categoria (id_categoria) ON DELETE RESTRICT,
    CONSTRAINT ck_produto_preco CHECK (preco > 0),
    CONSTRAINT ck_produto_quantidade CHECK (quantidade >= 0),
    CONSTRAINT ck_produto_minimo CHECK (estoque_minimo >= 0),
    INDEX idx_produto_categoria (id_categoria),
    INDEX idx_produto_nome (nome_produto)
);
 
CREATE TABLE Comanda (
    id_comanda         INT         NOT NULL AUTO_INCREMENT,
    status_comanda     VARCHAR(10) NOT NULL DEFAULT 'aberta',
    horario_abertura   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    horario_fechamento DATETIME    NULL,
    id_funcionario     INT         NOT NULL,
    id_cliente         INT         NULL,
    CONSTRAINT pk_comanda PRIMARY KEY (id_comanda),
    CONSTRAINT fk_comanda_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES Funcionario (id_funcionario) ON DELETE RESTRICT,
    CONSTRAINT fk_comanda_cliente FOREIGN KEY (id_cliente)
        REFERENCES Cliente (id_cliente) ON DELETE RESTRICT,
    CONSTRAINT ck_comanda_status CHECK (status_comanda IN ('aberta', 'paga')),
    CONSTRAINT ck_comanda_fechamento CHECK (
        (status_comanda = 'aberta' AND horario_fechamento IS NULL)
        OR (status_comanda = 'paga' AND horario_fechamento IS NOT NULL
            AND horario_fechamento >= horario_abertura)
    ),
    INDEX idx_comanda_funcionario (id_funcionario),
    INDEX idx_comanda_cliente (id_cliente),
    INDEX idx_comanda_status (status_comanda)
);
 
CREATE TABLE Venda (
    id_venda             INT      NOT NULL AUTO_INCREMENT,
    id_comanda           INT      NOT NULL,
    data_hora_lancamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_venda PRIMARY KEY (id_venda),
    CONSTRAINT fk_venda_comanda FOREIGN KEY (id_comanda)
        REFERENCES Comanda (id_comanda) ON DELETE RESTRICT,
    INDEX idx_venda_comanda (id_comanda),
    INDEX idx_venda_data (data_hora_lancamento)
);
 
CREATE TABLE Item_venda (
    id_item_venda      INT           NOT NULL AUTO_INCREMENT,
    id_venda           INT           NOT NULL,
    id_produto         INT           NOT NULL,
    quantidade_vendida DECIMAL(10,3) NOT NULL,
    preco_unitario     DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_item_venda PRIMARY KEY (id_item_venda),
    CONSTRAINT fk_item_venda_venda FOREIGN KEY (id_venda)
        REFERENCES Venda (id_venda) ON DELETE RESTRICT,
    CONSTRAINT fk_item_venda_produto FOREIGN KEY (id_produto)
        REFERENCES Produto (id_produto) ON DELETE RESTRICT,
    CONSTRAINT ck_item_venda_quantidade CHECK (quantidade_vendida > 0),
    CONSTRAINT ck_item_venda_preco CHECK (preco_unitario > 0),
    INDEX idx_item_venda_venda (id_venda),
    INDEX idx_item_venda_produto (id_produto)
);
 
CREATE TABLE Nota_Fiscal (
    id_nota_fiscal INT           NOT NULL AUTO_INCREMENT,
    id_venda       INT           NOT NULL,
    numero_nota    INT           NOT NULL,
    serie          INT           NOT NULL,
    chave_acesso   VARCHAR(44)   NOT NULL,
    data_emissao   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total    DECIMAL(10,2) NOT NULL,
    status         VARCHAR(10)   NOT NULL DEFAULT 'emitida',
    CONSTRAINT pk_nota_fiscal PRIMARY KEY (id_nota_fiscal),
    CONSTRAINT fk_nota_fiscal_venda FOREIGN KEY (id_venda)
        REFERENCES Venda (id_venda) ON DELETE RESTRICT,
    CONSTRAINT uq_nota_fiscal_venda UNIQUE (id_venda),
    CONSTRAINT uq_nota_fiscal_chave UNIQUE (chave_acesso),
    CONSTRAINT uq_nota_fiscal_numero_serie UNIQUE (numero_nota, serie),
    CONSTRAINT ck_nota_fiscal_valor CHECK (valor_total > 0),
    CONSTRAINT ck_nota_fiscal_status CHECK (status IN ('emitida', 'cancelada')),
    INDEX idx_nota_fiscal_data (data_emissao)
);
 
CREATE TABLE Pagamento (
    id_pagamento        INT           NOT NULL AUTO_INCREMENT,
    id_nota_fiscal      INT           NOT NULL,
    forma_pagamento     VARCHAR(20)   NOT NULL,
    valor_pago          DECIMAL(10,2) NOT NULL,
    valor_troco         DECIMAL(10,2) NULL DEFAULT 0,
    data_hora_pagamento DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_pagamento    VARCHAR(15)   NOT NULL DEFAULT 'confirmado',
    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pagamento_nota_fiscal FOREIGN KEY (id_nota_fiscal)
        REFERENCES Nota_Fiscal (id_nota_fiscal) ON DELETE RESTRICT,
    CONSTRAINT ck_pagamento_forma CHECK (
        forma_pagamento IN ('dinheiro', 'cartao_credito', 'cartao_debito', 'pix')),
    CONSTRAINT ck_pagamento_valor CHECK (valor_pago > 0),
    CONSTRAINT ck_pagamento_troco CHECK (valor_troco >= 0),
    CONSTRAINT ck_pagamento_status CHECK (
        status_pagamento IN ('pendente', 'confirmado', 'cancelado')),
    INDEX idx_pagamento_nota_fiscal (id_nota_fiscal),
    INDEX idx_pagamento_data (data_hora_pagamento)
);
 
CREATE TABLE Produto_Ingrediente (
    id_produto           INT           NOT NULL,
    id_ingrediente       INT           NOT NULL,
    quantidade_utilizada DECIMAL(10,3) NOT NULL,
    CONSTRAINT pk_produto_ingrediente PRIMARY KEY (id_produto, id_ingrediente),
    CONSTRAINT fk_produto_ingrediente_produto FOREIGN KEY (id_produto)
        REFERENCES Produto (id_produto) ON DELETE RESTRICT,
    CONSTRAINT fk_produto_ingrediente_ingrediente FOREIGN KEY (id_ingrediente)
        REFERENCES Ingrediente (id_ingrediente) ON DELETE RESTRICT,
    CONSTRAINT ck_produto_ingrediente_quantidade CHECK (quantidade_utilizada > 0),
    INDEX idx_produto_ingrediente_ingrediente (id_ingrediente)
);
 
CREATE TABLE Abastecimento (
    id_abastecimento   INT           NOT NULL AUTO_INCREMENT,
    id_ingrediente     INT           NOT NULL,
    id_fornecedor      INT           NOT NULL,
    quantidade         INT           NOT NULL,
    preco_unitario     DECIMAL(10,2) NOT NULL,
    valor_total        DECIMAL(10,2) NOT NULL,
    data_abastecimento DATE          NOT NULL,
    CONSTRAINT pk_abastecimento PRIMARY KEY (id_abastecimento),
    CONSTRAINT fk_abastecimento_ingrediente FOREIGN KEY (id_ingrediente)
        REFERENCES Ingrediente (id_ingrediente) ON DELETE RESTRICT,
    CONSTRAINT fk_abastecimento_fornecedor FOREIGN KEY (id_fornecedor)
        REFERENCES Fornecedor (id_fornecedor) ON DELETE RESTRICT,
    CONSTRAINT ck_abastecimento_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_abastecimento_preco CHECK (preco_unitario > 0),
    CONSTRAINT ck_abastecimento_total CHECK (valor_total = quantidade * preco_unitario),
    INDEX idx_abastecimento_ingrediente (id_ingrediente),
    INDEX idx_abastecimento_fornecedor (id_fornecedor),
    INDEX idx_abastecimento_data (data_abastecimento)
);
 
CREATE TABLE Contas_pagar (
    id_conta         INT           NOT NULL AUTO_INCREMENT,
    id_abastecimento INT           NOT NULL,
    valor            DECIMAL(10,2) NOT NULL,
    data_emissao     DATE          NOT NULL,
    data_vencimento  DATE          NOT NULL,
    data_pagamento   DATE          NULL,
    status           VARCHAR(10)   NOT NULL DEFAULT 'pendente',
    forma_pagamento  VARCHAR(20)   NULL,
    CONSTRAINT pk_contas_pagar PRIMARY KEY (id_conta),
    CONSTRAINT fk_contas_pagar_abastecimento FOREIGN KEY (id_abastecimento)
        REFERENCES Abastecimento (id_abastecimento) ON DELETE RESTRICT,
    CONSTRAINT ck_contas_pagar_valor CHECK (valor > 0),
    CONSTRAINT ck_contas_pagar_datas CHECK (data_vencimento >= data_emissao),
    CONSTRAINT ck_contas_pagar_status CHECK (status IN ('pendente', 'paga')),
    INDEX idx_contas_pagar_abastecimento (id_abastecimento),
    INDEX idx_contas_pagar_status_vencimento (status, data_vencimento)
);

-- quantidades de produtos abaixo do estoque minimo
SELECT id_produto, nome_produto, quantidade, estoque_minimo 
FROM produto 
WHERE quantidade < estoque_minimo;

-- quantidade de ingredientes abaixo do estoque minimo
SELECT id_ingrediente, nome_ingrediente, quantidade_estoque, estoque_minimo 
FROM ingrediente 
WHERE quantidade_estoque < estoque_minimo;

-- contas a pagar vencidas
select id_conta, valor, data_vencimento
from contas_pagar
where data_vencimento < CURDATE()
 and status != 'paga';
 
 -- quantidade de contas pendentes
select id_conta, valor, data_vencimento
from contas_pagar
where status = 'pendente'
 and data_vencimento > CURDATE();
 
 -- quantidade de pão francês vendida
 select id_venda, quantidade_vendida, preco_unitario
 from Item_venda
 where id_produto = 1;
 
 -- pagamentos feitos com dinheiro
 select id_pagamento, valor_pago, valor_troco
 from pagamento
 where forma_pagamento = 'dinheiro';
 
 -- produtos da categoria 'Bebidas'
 select id_produto, nome_produto
 from produto
 where id_categoria = 5;
 
 -- produtos da categoria Self-service
 select id_produto, nome_produto
 from produto
 where id_categoria = 7;
 
 -- Detalhamento de itens vendidos com nome do produto, categoria, cliente e funcionário
SELECT 
    v.id_venda,
    c.nome AS nome_cliente,
    f.nome_funcionario,
    p.nome_produto,
    cat.descricao AS categoria,
    iv.quantidade_vendida,
    iv.preco_unitario,
    ROUND(iv.quantidade_vendida * iv.preco_unitario, 2) AS subtotal
FROM Item_venda iv
INNER JOIN Venda v ON iv.id_venda = v.id_venda
INNER JOIN Comanda com ON v.id_comanda = com.id_comanda
INNER JOIN Funcionario f ON com.id_funcionario = f.id_funcionario
LEFT JOIN Cliente c ON com.id_cliente = c.id_cliente
INNER JOIN Produto p ON iv.id_produto = p.id_produto
LEFT JOIN Categoria cat ON p.id_categoria = cat.id_categoria;

-- Ficha técnica: Quais ingredientes compõem cada produto da padaria
SELECT 
    p.nome_produto,
    i.nome_ingrediente,
    pi.quantidade_utilizada,
    i.unidade_medida
FROM Produto_Ingrediente pi
INNER JOIN Produto p ON pi.id_produto = p.id_produto
INNER JOIN Ingrediente i ON pi.id_ingrediente = i.id_ingrediente
ORDER BY p.nome_produto;

-- Rastreamento de Contas a Pagar com dados do Fornecedor e Ingrediente abastecido
SELECT 
    cp.id_conta,
    forn.nome_fornecedor,
    forn.CNPJ,
    i.nome_ingrediente,
    ab.data_abastecimento,
    cp.valor,
    cp.data_vencimento,
    cp.status
FROM Contas_pagar cp
INNER JOIN Abastecimento ab ON cp.id_abastecimento = ab.id_abastecimento
INNER JOIN Fornecedor forn ON ab.id_fornecedor = forn.id_fornecedor
INNER JOIN Ingrediente i ON ab.id_ingrediente = i.id_ingrediente;

-- Consultas Gerenciais.

-- G01 — Qual o faturamento total por período (mês/ano)?
-- Atende: P02 (dificuldade no acompanhamento do faturamento) e P06 (informações descentralizadas)
SELECT 
    DATE_FORMAT(nf.data_emissao, '%Y-%m') AS periodo_mes,
    COUNT(nf.id_nota_fiscal) AS qtd_notas_emitidas,
    SUM(nf.valor_total) AS faturamento_total
FROM Nota_Fiscal nf
WHERE nf.status = 'emitida'
GROUP BY DATE_FORMAT(nf.data_emissao, '%Y-%m')
ORDER BY periodo_mes;

-- G02 — Qual a quantidade de vendas e comandas atendidas por período e funcionário?
-- Atende: P01 (controle manual de comandas) e P05 (sobrecarga operacional da equipe)
SELECT 
    DATE_FORMAT(v.data_hora_lancamento, '%Y-%m') AS periodo_mes,
    f.id_funcionario,
    f.nome_funcionario,
    f.cargo,
    COUNT(DISTINCT c.id_comanda) AS comandas_atendidas,
    COUNT(v.id_venda) AS quantidade_vendas_realizadas
FROM Venda v
INNER JOIN Comanda c ON v.id_comanda = c.id_comanda
INNER JOIN Funcionario f ON c.id_funcionario = f.id_funcionario
GROUP BY DATE_FORMAT(v.data_hora_lancamento, '%Y-%m'), f.id_funcionario, f.nome_funcionario, f.cargo
ORDER BY periodo_mes, quantidade_vendas_realizadas DESC;

-- G03 — Qual o ticket médio obtido por venda em cada período?
-- Atende: P02 (dificuldade no acompanhamento do faturamento e análise de consumo)
SELECT 
    DATE_FORMAT(nf.data_emissao, '%Y-%m') AS periodo_mes,
    COUNT(nf.id_venda) AS total_vendas,
    ROUND(AVG(nf.valor_total), 2) AS ticket_medio,
    MIN(nf.valor_total) AS menor_venda,
    MAX(nf.valor_total) AS maior_venda
FROM Nota_Fiscal nf
WHERE nf.status = 'emitida'
GROUP BY DATE_FORMAT(nf.data_emissao, '%Y-%m')
ORDER BY periodo_mes;

-- G04 — Quais são os produtos mais vendidos em quantidade e receita?
-- Atende: P03 (inconsistências no controle de estoque e giro de mercadorias) e P02 (faturamento)
SELECT 
    p.id_produto,
    p.nome_produto,
    p.unidade_medida,
    SUM(iv.quantidade_vendida) AS quantidade_total_comercializada,
    ROUND(SUM(iv.quantidade_vendida * iv.preco_unitario), 2) AS receita_gerada
FROM Item_venda iv
INNER JOIN Produto p ON iv.id_produto = p.id_produto
GROUP BY p.id_produto, p.nome_produto, p.unidade_medida
ORDER BY quantidade_total_comercializada DESC, receita_gerada DESC
LIMIT 10;

-- G05 — Qual o faturamento gerado por cada categoria de produto?
-- Atende: P02 (dificuldade no acompanhamento do faturamento) e P06 (informações descentralizadas)
SELECT 
    IFNULL(cat.id_categoria, 0) AS id_categoria,
    IFNULL(cat.descricao, 'Sem Categoria') AS categoria,
    COUNT(iv.id_item_venda) AS qtd_itens_vendidos,
    ROUND(SUM(iv.quantidade_vendida * iv.preco_unitario), 2) AS faturamento_categoria
FROM Item_venda iv
INNER JOIN Produto p ON iv.id_produto = p.id_produto
LEFT JOIN Categoria cat ON p.id_categoria = cat.id_categoria
GROUP BY cat.id_categoria, cat.descricao
ORDER BY faturamento_categoria DESC;

-- G06 — Qual o volume de compras e o valor total gasto com cada fornecedor?
-- Atende: P04 (dificuldade no controle de compras e fornecedores)
SELECT 
    forn.id_fornecedor,
    forn.nome_fornecedor,
    forn.CNPJ,
    COUNT(ab.id_abastecimento) AS total_abastecimentos,
    SUM(ab.valor_total) AS total_gasto_compras
FROM Fornecedor forn
INNER JOIN Abastecimento ab ON forn.id_fornecedor = ab.id_fornecedor
GROUP BY forn.id_fornecedor, forn.nome_fornecedor, forn.CNPJ
ORDER BY total_gasto_compras DESC;

-- G07 — Quais produtos e ingredientes estão com quantidade igual ou abaixo do estoque mínimo?
-- Atende: P03 (inconsistências no controle de estoque e identificação de reposição - RN15)
SELECT 
    'Produto' AS tipo_item,
    p.id_produto AS codigo,
    p.nome_produto AS descricao,
    p.unidade_medida,
    p.quantidade AS estoque_atual,
    p.estoque_minimo,
    (p.estoque_minimo - p.quantidade) AS deficit_reposicao
FROM Produto p
WHERE p.quantidade <= p.estoque_minimo AND p.ativo = TRUE
UNION ALL
SELECT 
    'Ingrediente' AS tipo_item,
    i.id_ingrediente AS codigo,
    i.nome_ingrediente AS descricao,
    i.unidade_medida,
    i.quantidade_estoque AS estoque_atual,
    i.estoque_minimo,
    (i.estoque_minimo - i.quantidade_estoque) AS deficit_reposicao
FROM Ingrediente i
WHERE i.quantidade_estoque <= i.estoque_minimo
ORDER BY tipo_item, deficit_reposicao DESC;

-- G08 — Quais são as contas a pagar em aberto e o montante pendente por situação de vencimento?
-- Atende: P04 (dificuldade no controle de compras, fornecedores e contas a pagar)
SELECT 
    cp.id_conta,
    forn.nome_fornecedor,
    i.nome_ingrediente,
    cp.valor,
    cp.data_emissao,
    cp.data_vencimento,
    CASE 
        WHEN cp.data_vencimento < CURDATE() THEN 'Vencida'
        ELSE 'A vencer'
    END AS situacao_vencimento
FROM Contas_pagar cp
INNER JOIN Abastecimento ab ON cp.id_abastecimento = ab.id_abastecimento
INNER JOIN Fornecedor forn ON ab.id_fornecedor = forn.id_fornecedor
INNER JOIN Ingrediente i ON ab.id_ingrediente = i.id_ingrediente
WHERE cp.status = 'pendente'
ORDER BY cp.data_vencimento ASC;

-- Consultas de Auditoria.

-- A01 — Existe venda registrada sem nenhum item vinculado?
-- Verifica: RN01 (toda venda deve possuir ao menos um item em Item_venda)
SELECT 
    v.id_venda,
    v.id_comanda,
    v.data_hora_lancamento
FROM Venda v
LEFT JOIN Item_venda iv ON v.id_venda = iv.id_venda
WHERE iv.id_item_venda IS NULL;

-- A02 — O valor total da Nota Fiscal diverge da soma dos itens da venda?
-- Verifica: RN02 (consistência financeira entre soma de Item_venda e Nota_Fiscal.valor_total)
SELECT 
    nf.id_nota_fiscal,
    nf.id_venda,
    nf.valor_total AS valor_na_nota,
    ROUND(SUM(iv.quantidade_vendida * iv.preco_unitario), 2) AS soma_dos_itens,
    ROUND(nf.valor_total - SUM(iv.quantidade_vendida * iv.preco_unitario), 2) AS diferenca
FROM Nota_Fiscal nf
INNER JOIN Item_venda iv ON nf.id_venda = iv.id_venda
GROUP BY nf.id_nota_fiscal, nf.id_venda, nf.valor_total
HAVING valor_na_nota <> soma_dos_itens;

-- A03 — Existem notas fiscais emitidas cujo valor pago (descontando troco) diverge do valor da nota?
-- Verifica: RN03 (toda nota fiscal emitida deve ter pagamento confirmado igual ao valor_total)
SELECT 
    nf.id_nota_fiscal,
    nf.numero_nota,
    nf.valor_total AS valor_nota,
    IFNULL(SUM(p.valor_pago - IFNULL(p.valor_troco, 0)), 0) AS total_liquido_pago
FROM Nota_Fiscal nf
LEFT JOIN Pagamento p ON nf.id_nota_fiscal = p.id_nota_fiscal 
    AND p.status_pagamento = 'confirmado'
WHERE nf.status = 'emitida'
GROUP BY nf.id_nota_fiscal, nf.numero_nota, nf.valor_total
HAVING valor_nota <> total_liquido_pago;

-- A04 — Existem comandas marcadas como 'aberta' que já possuem pagamento confirmado?
-- Verifica: RN04 (sincronia de status entre fechamento de Comanda e confirmação de Pagamento)
SELECT 
    c.id_comanda,
    c.status_comanda,
    c.horario_abertura,
    v.id_venda,
    p.id_pagamento,
    p.status_pagamento
FROM Comanda c
INNER JOIN Venda v ON c.id_comanda = v.id_comanda
INNER JOIN Nota_Fiscal nf ON v.id_venda = nf.id_venda
INNER JOIN Pagamento p ON nf.id_nota_fiscal = p.id_nota_fiscal
WHERE c.status_comanda = 'aberta' 
  AND p.status_pagamento = 'confirmado';
  
-- A05 — O valor da Conta a Pagar diverge do valor total registrado no Abastecimento?
-- Verifica: RN05 (integridade entre o custo de entrada do estoque e o título financeiro gerado)
SELECT 
    cp.id_conta,
    ab.id_abastecimento,
    ab.valor_total AS valor_abastecimento,
    cp.valor AS valor_conta_pagar
FROM Contas_pagar cp
INNER JOIN Abastecimento ab ON cp.id_abastecimento = ab.id_abastecimento
WHERE cp.valor <> ab.valor_total;

-- 1. Reajuste de preço de um produto específico (ex: Pão Francês)
-- Atende: RF04 (alteração de preços de produtos) e manutenção de cardápio
UPDATE Produto 
SET preco = 17.90 
WHERE id_produto = 1 AND ativo = TRUE;

-- 2. Atualização do estoque mínimo e quantidade de um ingrediente crítico
-- Atende: Gestão de insumos e controle preventivo de rupturas
UPDATE Ingrediente 
SET quantidade_estoque = quantidade_estoque + 50, 
    estoque_minimo = 70 
WHERE id_ingrediente = 4;

-- 3. Alteração do status de uma comanda para 'paga' e registro do horário de fechamento
-- Atende: RN01 e RN04 (encerramento do consumo no momento do pagamento)
UPDATE Comanda 
SET status_comanda = 'paga', 
    horario_fechamento = CURRENT_TIMESTAMP 
WHERE id_comanda = 3 AND status_comanda = 'aberta';

-- 4. Atualização de dados cadastrais (telefone e logradouro) de um cliente
-- Atende: Atualização de cadastro para entregas (delivery)
UPDATE Cliente 
SET telefone = '(11) 98999-8888', 
    logradouro = 'Rua das Margaridas, 450' 
WHERE id_cliente = 1;

-- 5. Inativação lógica de um fornecedor que encerrou as atividades
-- Atende: Gestão de parceiros comerciais sem violar restrições de FK em Abastecimento
UPDATE Fornecedor 
SET ativo = FALSE, 
    email = NULL 
WHERE id_fornecedor = 14;