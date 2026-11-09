## RELATÓRIO COMPLETO DE ELICITAÇÃO E LEVANTAMENTO DE REQUISITO

<div align="justify">

### 1. IDENTIFICAÇÃO E METODOLOGIA

- **Organização:** Padaria Forno Lusitano
- **Entrevistado:** Severino (Gerente)
- **Integrantes participantes:** Alex (Vitória), Christini dos Santos e Lucas Oliveira
- **Horário de Funcionamento:** Segunda a Domingo, das 06h às 22h (operação ininterrupta)
- **Metodologia:** Para a elicitação de requisitos, adotou-se a técnica de entrevista presencial semiestruturada com a gerência do estabelecimento. O objetivo principal foi compreender a dinâmica operacional da padaria, mapeando regras de negócio, volumetria de dados, fluxos de trabalho e pontos críticos de controle. Devido ao porte da organização e à alta taxa de consolidação das informações na sessão inicial, o levantamento foi encerrado com sucesso em uma única etapa de campo.

</div>

<hr>

<div align="justify">

### 2. ROTEIRO DE INVESTIGAÇÃO

O grupo elaborou um roteiro focado em extrair todos os elementos necessários para a futura construção dos diagramas Entidade-Relacionamento (DER/MER).

#### 2.1. Processos Operacionais e Atendimento ao Cliente
- Como é iniciado, mantido e finalizado o atendimento ao cliente no balcão e no caixa?
- De que forma os produtos vendidos por peso (almoço self-service e pães) se diferenciam dos produtos vendidos por unidade na captura de dados?
- Quais são as políticas de pagamento aceitas e como são tratadas as vendas não quitadas na hora?

#### 2.2. Gestão de Produtos, Cozinha e Estoque
- Como é realizado o cadastro de novos produtos, preços e categorias?
- Qual é o fluxo de entrada de insumos vindos de fornecedores e como ocorre a baixa no estoque?
- Como funciona o controle de produção interna (fornadas e cozinha) em relação à perda por validade ou sobra diária?

#### 2.3. Gestão de Pessoas e Infraestrutura
- Como é dividida a jornada de trabalho dos colaboradores ao longo do horário de funcionamento?
- Quais são os papéis operacionais (caixa, ativador de comanda, atendente de balcão, gerente)?

#### 2.4. Volumetria e Problemas da Gestão Atual
- Qual é a média diária de clientes, volume de vendas diárias e dimensão do catálogo de produtos?
- Quais os gargalos do modelo atual baseado em apontamentos manuais em papel?

</div>

<hr>

<div align="justify">

### 3. MAPEAMENTO DAS ENTIDADES E DADOS IDENTIFICADOS

A partir da entrevista, foram identificados os principais "objetos" de informação que precisarão ser estruturados no banco de dados:

| Entidade Candidata | Descrição no Negócio | Atributos Principais Identificados |
| :--- | :--- | :--- |
| **Cliente / Comanda** | Identificador temporário da visita do cliente no estabelecimento. | Número da comanda, código de barras, status (Livre, Ocupada, Paga). |
| **Produto** | Itens comercializados (fabricação própria ou revenda). | Código interno, descrição, preço unitário, tipo de unidade (UN/KG), categoria. |
| **Venda / Atendimento** | Registro da transação financeira e fechamento da comanda. | Número da venda, data/hora, valor total, forma de pagamento, funcionário responsável. |
| **Item da Venda** | Relação N:M entre Venda e Produto (itens lançados na comanda). | Quantidade/peso lançado, subtotal do item, horário do lançamento. |
| **Colaborador** | Funcionários que atuam na operação. | CPF/Matrícula, nome, cargo, turno de trabalho, status. |
| **Registro de Perda** | Apontamento de descartes de produtos sobressalentes ou vencidos. | Data do descarte, produto, quantidade descartada, motivo (sobra/validade). |

</div>

<hr>

<div align="justify">

### 4. REGRAS DE NEGÓCIOS E RESTRIÇÕES 

#### 4.1. Regras de Atendimento e Vendas
- **RN01 - Uso Obrigatório de Comanda:** Todo cliente deve possuir uma comanda física ativa ao consumir produtos no estabelecimento.
- **RN02 - Identificação Dual de Produtos:** O sistema deve suportar precificação e lançamento por **unidade** (ex.: bebidas) e por **peso em quilos** (ex.: refeição self-service e pão francês).
- **RN03 - Vedação de Crédito (Fiado):** O estabelecimento opera estritamente via pagamentos à vista (Dinheiro, Cartão de Débito/Crédito e Pix). Não há cadastro para vendas a prazo ou caderneta de fiado.
- **RN04 - Fechamento Obrigatório:** A comanda só pode ser liberada para um novo cliente após a quitação integral do saldo devedor e confirmação no caixa.

#### 4.2. Regras de Estoque e Produção
- **RN05 - Baixa Automática por Cobrança:** A baixa do saldo dos produtos comercializados ocorre no instante da validação do pagamento da comanda no caixa.
- **RN06 - Política de Descarte Sem Doação:** Produtos de fabricação própria sobressalentes no final do dia (ex.: pães) ou com prazo de validade expirado devem ser registrados como perda no sistema e descartados, garantindo conformidade sanitária.
- **RN07 - Produção sob Demanda:** A cozinha opera com fornadas fracionadas ao longo do dia para manter o frescor nas vitrines e minimizar o volume diário de descartes.

</div>

<hr>

<div align="justify">

### 5. VOLUMETRIA DE DADOS E CAPACIDADE OPERACIONAL 

Para dimensionar os tipos de dados e a volumetria do banco de dados, mapearam-se as seguintes métricas:

- **Fluxo diário de Clientes:** ~500 clientes/dia.
- **Volume diário de Vendas efetuadas:** ~350 transações concluídas no caixa/dia.
- **Quadro de Colaboradores:** 25 funcionários ativos.
- **Escala de Trabalho:** 2 turnos diários (Manhã: 06h às 14h | Noite: 14h às 22h).
- **Estimativa Mensal de Registros na Tabela `Item_Venda`:** Considerado uma média de 4 itens por comanda, estima-se o armazenamento de aproximadamente **42.000 a 50.000 linhas de itens consumidos por mês**.

</div>

<hr>

<div align="justify">

### 6. TRATAMENTO DE ANOMALIAS

Durante o levantamento, também se investigou o procedimento adotado em situações atípicas da rotina diária:

- **Perda ou Danificação da Comanda Física:** Caso o cliente perca a comanda, o funcionário do caixa precisa consultar o histórico de lançamentos do período ou aplicar uma taxa fixa regulamentada pelo estabelecimento para liberar a saída.
- **Divergência de Código no Balcão:** Se o código digitado pelo funcionário não for localizado no catálogo, o item não pode ser associado à comanda até que a consulta seja realizada via sistema central ou por digitação manual pelo gerente.
- **Cancelamento de Item da Comanda:** O cancelamento de um item lançado por engano na comanda exige autorização/senha de um perfil com privilégio de supervisor (gerente).

</div>

<hr>

<div align="justify">

### 7. PRINCIPAIS DORES MAPEADAS E JUSTIFICATIVA DE AUTOMAÇÃO 

1. **Vulnerabilidade dos Registros em Papel:** O controle secundário e relatórios operacionais ainda dependem de anotações manuais em blocos de papel antes de serem consolidados, gerando alto risco de perda de dados e lentidão na tomada de decisão.
2. **Pressão no Tempo de Atendimento:** Com uma média de 500 clientes para 25 funcionários divididos em dois turnos, qualquer lentidão no lançamento manual da comanda no balcão gera filas acentuadas no self-service e no caixa.
3. **Ausência de Indicadores de Perda:** A falta de uma ferramenta digital rápida para registrar o peso/quantidade de sobras no encerramento do expediente impede o cálculo exato do prejuízo operacional diário com descartes.

</div>
