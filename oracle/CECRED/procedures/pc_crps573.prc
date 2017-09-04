CREATE OR REPLACE PROCEDURE CECRED.pc_crps573(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps573 (Fontes/crps573.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme
       Data    : Agosto/2010                       Ultima atualizacao: 15/08/2017

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Gerar arquivo(3040) Dados Individualizados de Risco de Credito
                   Juncao do 3020 com o 3030
                   Geracao de relatorio para conferencia
                   Solicitacao : 80
                   Ordem do programa na solicitacao = 4.
                   Relatorio 566 e 567.
                   Programa baseado no crps368
                   Programa baseado no crps369 (tag <Agreg>)

       Alteracoes : 03/03/2011 - Retirar critica acima de 5milhoes e tratamento
                                 para garantia nao fidejussoria (Guilherme).

                    12/07/2011 - Realizado alteracao para atender ao novo layout
                                 (Adriano).

                    05/08/2011 - Incluido atributo VarCamb. (Irlan)

                    08/08/2011 - Incluido atibuto DiaAtraso (Irlan)

                    12/09/2011 - Não permitir faturamento anual negativo (Irlan)

                    04/10/2011 - Inserido Cosif e PercIndx (Irlan)

                    19/10/2011 - Incluido os dados da central de risco no
                                 cabecalho do arquivo 3040 (Adriano).

                    29/12/2011 - Mudança de critério para sobre operações de
                                 crédito por solicitação do Banco Central
                                 (Irlan/Lucas).

                    05/06/2012 - Ajuste na provisao (Gabriel).

                    17/08/2012 - Removido Procedure
                                 verifica_garantidores_nao_fidejussorio
                                 e sua chamada. (Lucas R.)

                    25/09/2012 - Inicializado aux_cddesemp com 1 ao inves de zero
                                 (Irlan)

                    10/10/2012 - Tratar campo de modalidade quando 299, 499
                                 (Gabriel).

                    22/11/2012 - Ajuste divida estancada (Tiago).
                               - Ajustar lanctos da crapris com cdorigem 4 e 5
                                 como um unico lancto (Rafael).

                    04/01/2013 - Criada procedure verifica_conta_altovale_573
                                 para desprezar as contas migradas (Tiago).

                    14/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                                 consulta da craptco (Tiago).

                    21/01/2013 - Gerar as saídas das operações. (Tiago)

                    21/01/2013 - Inclusao do UNFORMATTED na inpressao da tag < inf
                                 e inclusao multiplicacao por 100 para buscar o valor
                                 inteiro (Lucas R.).

                    22/01/2013 - Incluir validacao para para alterar modalidade
                                 0203 para 0206 somente se for pessoa fisica
                                 (Lucas R.)

                    08/02/2013 - Ajustes processo de geracao entradas e saidas (Daniel).

                    14/02/2013 - Ajustes processo de geracao entradas e saidas para tratar
                                 re-geracao do arquivo.(Daniel).

                    01/04/2013 - Incluso procedure verifica_garantia_alienacao_fiduciaria
                                 (Daniel).

                    24/04/2013 - Incluso tratamento para empresimos/financiamentos migrados para
                                 Altovale, incluso registro <Inf Tp="1001" nos casos de
                                 cdnatuop = "02" (Daniel).

                    17/05/2013 - Incluido tratamento de arredondamento na rotina
                                 normaliza_juros, acrescentado ao indice tt-agreg
                                 o campo cdvencto e adicionado chamada da procedure
                                 busca_modalidade para retirar repeticao de codigo
                                 (Tiago).

                    17/06/2013 - Tratamento para emprestimos do BNDES; leitura
                                 da crapebn quando crapvri.cdmodali = 0499 ou 0299.
                                 (Fabricio)

                    11/07/2013 - Ajustes no arq3040 devido a quebra por cpf nao
                                 estar apresentando os resultados conforme desejado
                                 foi necessario realizar a mesma pegando apenas as
                                 8 primeiras posicoes do cpf (Tiago).

                    05/08/2013 - Chamada da procedure busca_taxeft nos pontos
                                 em que se precisa calcular a taxa efetiva anual.
                                 (Fabricio)

                    14/08/2013 - Incluida procedure verifica_inf_chassi que cria
                                 tag <inf> quando modalidade=04 e sub=01 e conter
                                 informacoes do chassi (Tiago).

                    26/08/2013 - Incluida regra na procedure verifica_inf_chassi
                                 para considerar apenas ("AUTOMOVEL,MOTO,CAMINHAO")
                                 do campo crapbpr.dscatbem (Tiago).

                    29/08/2013 - incluida procedure
                                 verifica_inf_aplicacao_regulatoria que cria tag
                                 <inf> para contratos com linha de credito "DIM"
                                 (Tiago).

                    17/03/2013 - Ajustado os valores de referencia de faturamento
                                 anual para definicao do porte de cliente PJ
                                 (Adriano)

                    05/12/2013 - Renomeada procedure verifica_conta_altovale_573
                                 para verifica_conta_migracao_573 que despreza
                                 as contas migradas (Tiago).

                    17/12/2013 - Inserido PAs da migracao na condicao da craptco
                                 na procedure verifica_conta_migracao_573 (Tiago).

                    30/12/2013 - Ajuste para considerar radical do cpf/cnpj no
                                 "FOR EACH tt-ris" Adriano).

                    09/01/2014 - Ajuste tratamento migracao e corrigido erro na
                                 totalizacao tt-agreg (Daniel).

                    27/01/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

                    16/01/2014 - Incluso Total de Clientes (TotalCli) no cabecalho,
                                 incluso renda anual para pessoa fisica <FatAnual>
                                 (Daniel).

                    07/02/2014 - Incluso ajuste apara adequacao Oracle, conforme
                                 solicitacao Andrino, softdesk 125051 (Daniel).

                    10/02/2014 - Ajuste calculo desempenho da operação (Daniel).

                    07/03/2014 - Ajuste regra para tratamento modalidade "0203" e
                                 "0206" (Daniel).
                                 
                    02/05/2014 - Ajustes Legais Maio/2014: Quando emprestimo BNDES
                                 enviar Origem Recurso como 0202 e nao 0199.
                                 Alterada procedure pc_busca_modalidade: Novo 
                                 param de entrada (origem), e novo de saida(orgrec)
                                (Guilherme/SUPERO).

                    07/05/2014 - Ajustes para montagem do valor da divida com mascara
                                 mais ampla, pois estava estourando as informações 
                                 (Marcos-Supero)             

                    15/05/2014 - Ajuste na variavel vr_dtfimctr, pois quando nulo
                                 gera crítica no Validador do Banco Central.
                                 Ajuste na pc_busca_taxeft, quando pr_cdmodali = 0201
                                 nao era inicializada a variavel vr_txeanual, deixando
                                 ela como NULL, gerando critica no Validador do BC
                                 (Guilherme/SUPERO)
                                 
                    30/06/2014 - Correção nas modalidades de capital de giro, antes usavamos
                                 o calculo para encerramento do empréstimo para definir se 
                                 ele era 0215(capital de giro com prazo de vencimento até 365 d)
                                 ou 0216 (capital de giro com prazo vencimento superior 365 d)
                                 mas na verdade temos de considerar a data de contratação 
                                 frente a data atual, e se for um empréstimo de periodo maior
                                 que 365 então gerar o 0215. (Marcos-Supero)
                                 
                    01/07/2014 - Melhorias na codificação com comentários, remoção de codificação
                                 duplicada, e correção de lógicas errôneas (Marcos-Supero)
                                 
                    03/07/2014 - Alterações para adicionar novos campos do Fluxo Financeiro 
                                 (DtaProxParcela, VlrProxParcela e QtdParcelas) (Marcos-Supero)   
                                 
                    19/09/2014 - Correção na busca da conta cosif para considerar a modalidade
                                 enviada ao 3040 e não mais a modalidade do risco (Marcos-Supero)
                                 
                    10/10/2014 - Correção na busca da conta cosif para modalidade de Repasse
                                 (Marcos-Supero)    
                                 
                    12/11/2014 - Correção na busca de detalhes dos Borderôs de Titulo e Cheque já 
                                 que agora o nrctremp não contém mais o contrato de limite, mas sim 
                                 o número do Borderô. (Marcos-Supero)  
                                 
                    19/12/2014 - Inclusão das informações de Ente Consignante quando empréstimo ou
                                 financiamento consignado em folha (Marcos-Supero)             
                                 
                    16/01/2015 - Ajustes no campo para definir o vencimento da operação de empréstimos
                                 que deve verificar a data da ultima parcela (produto novo) e usar o 
                                 calculo de meses * parcelas a partir da primeira (produto antigo)
                               - Também removi a lógica para teste de incorporação, pois em novembro
                                 já enviamos os contratos incorporados (Marcos-Supero)

                    02/02/2015 - Remoção da procedure pc_busca_modalidade, passamos a usar a função
                                 de banco fn_busca_modalidade para evitar retrabalho e reaproveitarmos
                                 o código da mesma no cadastro de positivos, no crps573 e crps280
                               - Também ajustamos do Doc3040 para envio das informações de Limite
                                 não Utilizado - Modalidade 1901. (Marcos-Supero)    
                                 
                    24/04/2015 - Correção da lógica de busca das saídas de Desconto de Titulos (0301)
                                 onde havia agrupamento apenas por CPF, onde o correto é considerar
                                 também o número do contrato (Borderô), pois cada borderô é um novo 
                                 contrato e estávamos enviando apenas um registro de saída, gerando os
                                 questionamentos Q1, onde operações não aparecem nem ativas nem inativas
                                 (Marcos-Supero)   
                                 
                    30/04/2015 - Correção no envio do Ente Consignante. Quando empréstimos em prejuízo
                                 não mais enviaremos o CNPJ do Ente, mais sim a informação Cd="1",
                                 que para o Bacen significa que a operação foi desconsignada 
                               - Implementação de nova regra (or) para marcar contratos resultantes
                                 de renegociação, onde contratos que possuem alguma liquidação (nrctrliq)
                                 marcaremos com CarctEspecial="1" (Marcos-Supero)
                    
                    06/05/2015 - Novo ajuste quanto ao Ente Consignante, para se não houver Cnpj na CaDEMP,
                                 pegarmos a informação da aba Comercial da tela CONTAS (Marcos-Supero)
                                 
                    07/05/2015 - Remoção do digito verificador para as contas cosif, conforme email enviado
                                 Bacen e atrelado ao SD283602 (Marcos-Supero)      
                                 
                    08/05/2015 - Após reunião com diretoria e áreas de crédito e controles internos, foi 
                                 solicitado para enviarmos ao BAcen os contratos como negociação somente
                                 observando se o mesmo liquidou algum outro, e não mais observar a linha de 
                                 crédito ou qualificador da Operação, ficando desta forma sincronizado
                                 a regra de marcação de saída e de novo contrato (Marcos-Supero) 
                                 
                    06/07/2015 - Ajustes na busca da linha de desconto quando Desconto de Cheque ou Titulo,
                                 que após ajuste para envio dos contratos separadamente do contrato de limite
                                 unificamos a busca e sempre usavamos o tipo de desconto = 2, e quando desconto
                                 de titulo deve ser igual a 3 - (Marcos-Supero).     
                               
                    06/07/2015 - Ajuste na informacao "Data Fim do Contrato" para o AD, para buscar o inicio
                                 da data que teve o estouro de conta. (James)
                                 
                    24/11/2015 - Ajuste para enviar o Grupo Economico para as operações Ativas. (James)
                    
                    24/11/2015 - Ajuste para enviar a data de vencimento da operacao nas operacoes de Baixas. (James)
                               
                    04/01/2016 - Ajuste na tag dtVencOp, para pegar a informacao do campo crapris.dtvencop(Chamado:367635).(James)

                    10/03/2016 - Projeto 306 - Implantacao Provisao de risco de credito sobre garantias prestadas. (James)
                    
                    31/03/2016 - Ajuste para informar como Origem do Recurso 0203 as operações do BNDES-Finame 
                                 no arquivo 3040. (SD 426476 - Carlos Rafael Tanholi)
                                
                    05/04/2016 - Ajuste para pegar a taxa efetiva anual do cartão da tabela crapprm. (James)
                    
                    20/04/2016 - Ajuste para dividir o arquivo em partes. (James)
                    
                    10/05/2016 - Ajuste no numero do contrato para enviar a modalidade que vai na tag modalidade. (James)
                    
                    24/05/2016 - Ajuste para enviar o "Ente Consignante" como 1502. (James)

                    09/06/2016 - Ajustes complementares para dividir o arquivo 3040 em partes 
                                 SD422373 (Odirlei-AMcom)

                    10/03/2016 - Projeto 306 - Implantacao Provisao de risco de credito sobre garantias prestadas. (James)
                    
                    31/03/2016 - Ajuste para informar como Origem do Recurso 0203 as operações do BNDES-Finame 
                                 no arquivo 3040. (SD 426476 - Carlos Rafael Tanholi)
                                
                    05/04/2016 - Ajuste para pegar a taxa efetiva anual do cartão da tabela crapprm. (James)
                    
                    10/05/2016 - Ajuste no numero do contrato para enviar a modalidade que vai na tag modalidade. (James)
                    
                    24/05/2016 - Ajuste para enviar o "Ente Consignante" como 1502. (James)
                    
                    24/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.(Carlos Rafael Tanholi).
                    
                    20/07/2016 - Resolucao dos chamados 491068, 488220 e 486570. (James)
                    
                    01/08/2016 - Resolucao do chamado 497022 - Operacoes de saida 0305. (James)

			        26/09/2016 - Ajustes na rotina pc_carrega_base_risco para o envio correto 
                                 da data de vencimento e quantidade de dias atraso.
                                 SD488220 (Odirlei-AMcom)

					24/10/2016 - Alterado o Ident de 1 para 2 conforme solicitação realizada no chamado 541753
                                 ( Renato Darosci - Supero )
                                 
                    03/11/2016 - Alterada a função de classificação do porte de pessoa física, para que sejam considerados
                                 como "sem redimento", rendas mensais de até 0.01 (inclusive) e não mais rendas com valor 
                                 zero apenas. Esta alteração corrige o problema relatado no chamado SD 549969, onde contas
                                 cadastradas com rendimento igual a 0.01 estavam sendo enviadas com código de porte igual
                                 a 2 - ATÉ 1 SALÁRIO MÍNIMO. (Renato Darosci - Supero)
                                 
                    06/01/2017 - Ajuste para desprezar contas migradas da Transulcred para Transpocred antes da incorporação.
                                 PRJ342 - Incorporação Transulcred (Odirlei-AMcom)
                                 
					24/02/2017 - Ajuste na tratativa do campo Ident, o qual estava verificando campos incorretos para
					             informar a baixa do gravames (Daniel - Chamado: 615103) 

				    08/03/2017 - Alteracao na regra de porte cliente juridico (Daniel - Chamado: 626161) 

                    13/04/2016 - Ajustes PRJ343 - Cessao de Credito (Odirlei-AMcom)

                    11/05/2017 - Incluso tratativa para caracteristica especial 17 (Daniel - Chamado: 639510)

                    18/05/2017 - P408 - Inclusão dos contratos inddocto=5 - Provisão de Garantias Prestas
                                 Andrei - Mouts
                                 
                    15/08/2017 - Alterar cursores onde efetuavam leitura da tabela crapbpr
                                 pelo cr_tbepr_bens_hst que chama a tabela tbepr_bens_hst
                                 (Lucas Ranghetti #734912)
                                 
.............................................................................................................................*/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS573';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
              ,cop.dsnomscr
              ,cop.dsemascr
              ,cop.dstelscr
              ,cop.nrcepend
              ,cop.cdufdcop
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop   cr_crapcop%ROWTYPE;
      rw_crapcop_2 cr_crapcop%ROWTYPE;
      rw_crapcop_3 cr_crapcop%ROWTYPE; -- Para central
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- busca a data de parametro com base nos dados da Solicitacao
      CURSOR cr_crapsol IS
        SELECT to_date(crapsol.dsparame,'DD/MM/YYYY') dsparame
          FROM crapsol,
               crapprg
         WHERE crapprg.cdcooper = pr_cdcooper
           AND crapprg.cdprogra = vr_cdprogra
           AND crapsol.cdcooper = crapprg.cdcooper
           AND crapsol.nrsolici = crapprg.nrsolici;

      -- Busca informacoes da central de risco
      CURSOR cr_crapris_2(pr_dtrefere DATE) IS
        SELECT crapris.*
              ,ROW_NUMBER () OVER (PARTITION BY crapris.nrcpfcgc ORDER BY crapris.nrcpfcgc) nrseq
              ,COUNT(1)      OVER (PARTITION BY crapris.nrcpfcgc ORDER BY crapris.nrcpfcgc) qtreg
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.dtrefere = pr_dtrefere
           AND crapris.inddocto = 1 -- documento 3020
          ORDER BY crapris.nrcpfcgc, crapris.innivris, crapris.nrdconta; 

      -- Cursor de contas transferidas entre cooperativas
      CURSOR cr_craptco (pr_nrdconta craptco.nrdconta%TYPE) IS
        SELECT 1
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.nrdconta = pr_nrdconta
           AND craptco.tpctatrf <> 3;
      rw_craptco cr_craptco%ROWTYPE;

      -- Cursor de contas transferidas entre cooperativas
      CURSOR cr_craptco_b (pr_nrdconta     crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.nrdconta = pr_nrdconta
           AND craptco.tpctatrf <> 3
           AND craptco.cdageant IN (2, 4, 6, 7, 11);
      rw_craptco_b cr_craptco_b%ROWTYPE;

      -- Cursor sobre o cadastro de emprestimos
      CURSOR cr_crapepr IS
        select epr.nrdconta
              ,epr.nrctremp
              ,epr.dtmvtolt
              ,epr.cdlcremp
              ,epr.vlpreemp
              ,epr.vlemprst
              ,epr.dtprejuz
              ,epr.inprejuz
              ,epr.nrctaav1
              ,epr.nrctaav2
              ,epr.qtpreemp
              ,epr.dtdpagto          -- Prx Pagto
              ,wpr.dtdpagto dtdpripg -- Pri Pagto
              ,wpr.nrctrliq##1+
               wpr.nrctrliq##2+
               wpr.nrctrliq##3+
               wpr.nrctrliq##4+
               wpr.nrctrliq##5+
               wpr.nrctrliq##6+
               wpr.nrctrliq##7+
               wpr.nrctrliq##8+
               wpr.nrctrliq##9+
               wpr.nrctrliq##10 qtctrliq -- Se houver qq contrato, teremos a soma + 0          
          from crapepr epr
              ,crawepr wpr
         where epr.cdcooper = pr_cdcooper
           and epr.cdcooper = wpr.cdcooper (+)
           and epr.nrdconta = wpr.nrdconta (+)
           and epr.nrctremp = wpr.nrctremp (+);

      -- Cursor sobre a tabela de vencimento do risco buscando o maior codigo de vencimento
      CURSOR cr_crapvri (pr_nrdconta crapvri.nrdconta%TYPE,
                         pr_dtrefere DATE,
                         pr_innivris crapvri.innivris%TYPE,
                         pr_cdmodali crapvri.cdmodali%TYPE,
                         pr_nrctremp crapvri.nrctremp%TYPE) IS
        SELECT MAX(cdvencto) cdvencto
          FROM crapvri
         WHERE crapvri.cdcooper = pr_cdcooper
           AND crapvri.nrdconta = pr_nrdconta
           AND crapvri.dtrefere = pr_dtrefere
           AND crapvri.innivris = pr_innivris
           AND crapvri.cdmodali = pr_cdmodali
           AND crapvri.nrctremp = pr_nrctremp;
      rw_crapvri cr_crapvri%ROWTYPE;

      -- Cursor sobre a tabela de vencimento do risco
      CURSOR cr_crapvri_venct (pr_nrdconta crapvri.nrdconta%TYPE,
                               pr_dtrefere DATE,
                               pr_cdmodali crapvri.cdmodali%TYPE,
                               pr_nrctremp crapvri.nrctremp%TYPE) IS
        SELECT cdvencto,
               vldivida,
               ROW_NUMBER () OVER (PARTITION BY crapvri.nrdconta, crapvri.cdvencto ORDER BY crapvri.nrdconta, crapvri.nrctremp) nrseq,
               COUNT(1)      OVER (PARTITION BY crapvri.nrdconta, crapvri.cdvencto ORDER BY crapvri.nrdconta, crapvri.nrctremp) qtreg
          FROM crapvri
         WHERE crapvri.cdcooper = pr_cdcooper
           AND crapvri.nrdconta = pr_nrdconta
           AND crapvri.dtrefere = pr_dtrefere
           AND crapvri.cdmodali = pr_cdmodali
           AND crapvri.nrctremp = pr_nrctremp;


      -- Cursor sobre a tabela de vencimento do risco
      CURSOR cr_crapvri_b(pr_dtrefere DATE) IS
         SELECT cdvencto,
                vldivida,
                nrdconta,
                innivris,
                cdmodali,
                nrseqctr,
                nrctremp
           FROM crapvri
          WHERE crapvri.cdcooper = pr_cdcooper
            AND crapvri.dtrefere = pr_dtrefere
           ORDER BY cdvencto DESC;

      -- Cursor para busca dos percentuais de risco
      CURSOR cr_craptab IS
        SELECT dstextab
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND UPPER(nmsistem) = 'CRED'
           AND UPPER(tptabela) = 'GENERI'
           AND cdempres = 00
           AND UPPER(cdacesso) = 'PROVISAOCL';
      rw_craptab cr_craptab%ROWTYPE;

      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nrcpfcgc,
               inpessoa,
               dsnivris,
               dtadmiss
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor para busca dos titulares da conta
      CURSOR cr_crapttl(pr_nrdconta crapttl.nrdconta%TYPE) IS
        SELECT vlsalari,
               vldrendi##1,
               vldrendi##2,
               vldrendi##3,
               vldrendi##4,
               vldrendi##5,
               vldrendi##6
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Cursor para busca dos dados financeiros de PJ
      CURSOR cr_crapjfn(pr_nrdconta crapttl.nrdconta%TYPE) IS
        SELECT vlrftbru##1 + vlrftbru##2 + vlrftbru##3 + vlrftbru##4  + vlrftbru##5  + vlrftbru##6 +
               vlrftbru##7 + vlrftbru##8 + vlrftbru##9 + vlrftbru##10 + vlrftbru##11 + vlrftbru##12 vlrftbru
          FROM crapjfn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;

        -- Verificacao no cadastro de emprestimos do BNDES
        CURSOR cr_crapebn IS
          SELECT cdsubmod,
                 vlropepr,
                 dtinictr,
                 dtfimctr,
                 dtprejuz,
                 txefeanu,
                 nrdconta,
                 nrctremp,
                 dtvctpro,
                 vlparepr,
                 qtparctr
            FROM crapebn
           WHERE crapebn.cdcooper = pr_cdcooper;
        
        -- Busca taxa de Juros Cartao BB e Bancoob
        CURSOR cr_tbrisco_prod IS
          SELECT tparquivo
                ,vltaxa_juros
            FROM tbrisco_provisgarant_prodt
           WHERE tparquivo IN('Cartao_Bancoob','Cartao_BB');
        vr_vltxabb NUMBER(6,2);
        vr_vltxban NUMBER(6,2);
        
        -- Cursor para buscar os dados do cartao de credito
        CURSOR cr_tbcrd_risco (pr_cdcooper IN tbcrd_risco.cdcooper%TYPE
                              ,pr_dtrefere IN tbcrd_risco.dtrefere%TYPE) IS
          SELECT tbcrd_risco.nrdconta,
                 tbcrd_risco.nrcontrato,
                 tbcrd_risco.cdtipo_cartao,
                 SUM(tbcrd_risco.vlsaldo_devedor) vlropcrd
            FROM tbcrd_risco
           WHERE tbcrd_risco.cdcooper = pr_cdcooper
             AND tbcrd_risco.dtrefere = pr_dtrefere
        GROUP BY tbcrd_risco.nrdconta,
                 tbcrd_risco.nrcontrato,
                 tbcrd_risco.cdtipo_cartao;

        -- Busca de linhas de credito
        CURSOR cr_craplcr IS
          SELECT cdlcremp
                ,cdmodali
                ,cdsubmod
                ,txjurfix
                ,dsorgrec
                ,cdusolcr
            FROM craplcr
           WHERE craplcr.cdcooper = pr_cdcooper;

        -- Cursor sobre a tabela de limite de credito
        CURSOR cr_craplim (pr_nrdconta craplim.nrdconta%TYPE,
                           pr_nrctremp craplim.nrctrlim%TYPE,
                           pr_tpctrlim craplim.tpctrlim%TYPE) IS
          SELECT cddlinha,
                 dtinivig,
                 vllimite,
                 nrctaav1,
                 nrctaav2,
                 qtdiavig
            FROM craplim
           WHERE craplim.cdcooper = pr_cdcooper
             AND craplim.nrctrlim = pr_nrctremp
             AND craplim.nrdconta = pr_nrdconta
             AND craplim.tpctrlim = pr_tpctrlim;
        rw_craplim cr_craplim%ROWTYPE;
        
        -- Detalhes do Borderô Cheque para busca do limite
        CURSOR cr_crapbdc (pr_nrdconta crapbdc.nrdconta%TYPE,
                           pr_nrborder crapbdc.nrborder%TYPE) IS
          SELECT nrctrlim
            FROM crapbdc
           WHERE crapbdc.cdcooper = pr_cdcooper
             AND crapbdc.nrdconta = pr_nrdconta
             AND crapbdc.nrborder = pr_nrborder;
        
        -- Detalhes do Borderô Titulo para busca do limite
        CURSOR cr_crapbdt (pr_nrdconta crapbdt.nrdconta%TYPE,
                           pr_nrborder crapbdt.nrborder%TYPE) IS
          SELECT nrctrlim
            FROM crapbdt
           WHERE crapbdt.cdcooper = pr_cdcooper
             AND crapbdt.nrdconta = pr_nrdconta
             AND crapbdt.nrborder = pr_nrborder;
             
        vr_nrctrlim crapbdt.nrctrlim%TYPE;             

        -- Descricao dos bens da proposta de emprestimo do cooperado.
        CURSOR cr_crapbpr(pr_nrdconta crapebn.nrdconta%TYPE,
                          pr_nrctremp crapebn.nrctremp%TYPE,
                          pr_tpctrpro crapbpr.tpctrpro%TYPE,
                          pr_idordena PLS_INTEGER) IS  -- 1=Ordem ascendente, 0=Ordem descendente
          SELECT nrcpfbem,
                 vlperbem,
                 upper(dscatbem) dscatbem,
                 vlmerbem,
                 dschassi
            FROM crapbpr
           WHERE crapbpr.cdcooper = pr_cdcooper
             AND crapbpr.nrdconta = pr_nrdconta
             AND crapbpr.nrctrpro = pr_nrctremp
             AND crapbpr.tpctrpro = pr_tpctrpro
             AND crapbpr.flgbaixa = 0
             AND crapbpr.flcancel = 0
             AND crapbpr.nrcpfbem <> 0
           ORDER BY progress_recid * pr_idordena, progress_recid DESC;
        rw_crapbpr cr_crapbpr%ROWTYPE;

        -- Descricao dos bens da proposta de emprestimo do cooperado.
        CURSOR cr_tbepr_bens_hst_2(pr_nrdconta crapebn.nrdconta%TYPE,
                            pr_nrctremp crapebn.nrctremp%TYPE,
                                   pr_tpctrpro crapbpr.tpctrpro%TYPE,
                                   pr_dtrefere DATE) IS
          SELECT nrcpfbem,
                 vlperbem,
                 upper(dscatbem) dscatbem,
                 vlmerbem,
                 dschassi
            FROM tbepr_bens_hst hst
           WHERE hst.cdcooper = pr_cdcooper
             AND hst.nrdconta = pr_nrdconta
             AND hst.nrctrpro = pr_nrctremp
             AND hst.tpctrpro = pr_tpctrpro
             AND hst.flgbaixa = 0
             AND hst.flcancel = 0
             AND hst.vlmerbem > 0
             AND hst.flgalien = 1
             AND hst.dtrefere = last_day(pr_dtrefere);

        -- Descricao dos bens da proposta de emprestimo do cooperado.
        CURSOR cr_crapbpr_3(pr_nrdconta crapebn.nrdconta%TYPE,
                            pr_nrctremp crapebn.nrctremp%TYPE,
                            pr_tpctrpro crapbpr.tpctrpro%TYPE) IS
          SELECT nrcpfbem,
                 vlperbem,
                 upper(dscatbem) dscatbem,
                 vlmerbem,
                 dschassi
            FROM crapbpr
           WHERE crapbpr.cdcooper = pr_cdcooper
             AND crapbpr.nrdconta = pr_nrdconta
             AND crapbpr.nrctrpro = pr_nrctremp
             AND crapbpr.tpctrpro = pr_tpctrpro
             AND crapbpr.flgbaixa = 0
             AND crapbpr.flcancel = 0
             AND crapbpr.nrcpfbem = 0;

        -- Descricao dos bens da proposta de emprestimo do cooperado.
        CURSOR cr_tbepr_bens_hst_4(pr_nrdconta crapebn.nrdconta%TYPE,
                            pr_nrctremp crapebn.nrctremp%TYPE,
                                   pr_tpctrpro crapbpr.tpctrpro%TYPE,
                                   pr_dtrefere DATE) IS
          SELECT nrcpfbem,
                 vlperbem,
                 upper(dscatbem) dscatbem,
                 vlmerbem,
                 dschassi,
                 flgbaixa,
                 flcancel,
                 cdsitgrv,
                 dtdbaixa,
                 dtcancel,
                 dtatugrv,
                 dtmvtolt
            FROM tbepr_bens_hst hst
           WHERE hst.cdcooper = pr_cdcooper
             AND hst.nrdconta = pr_nrdconta
             AND hst.nrctrpro = pr_nrctremp
             AND hst.tpctrpro = pr_tpctrpro             
             AND hst.flgalien = 1
             AND hst.dtrefere = last_day(pr_dtrefere);

      --> Verificar se é emprestimo de cessao de credito
      CURSOR cr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                        pr_nrdconta crapepr.nrdconta%TYPE,
                        pr_nrctremp crapepr.nrctremp%TYPE)  IS
        SELECT 1 flcessao
          FROM tbcrd_cessao_credito ces
         WHERE ces.cdcooper = pr_cdcooper 
           AND ces.nrdconta = pr_nrdconta
           AND ces.nrctremp = pr_nrctremp;
      rw_cessao cr_cessao%ROWTYPE;
      
      --> Busca os movimentos digitados manualmente para os contratos inddocto=5
      CURSOR cr_movtos_garprest(pr_cdcooper crapcop.cdcooper%TYPE
                               ,pr_dtrefere DATE) IS
        SELECT idmovto_risco
              ,risc0003.fn_valor_opcao_dominio(mvt.idorigem_recurso) dsorigem
              ,risc0003.fn_valor_opcao_dominio(mvt.idindexador) dsindexa
              ,mvt.perindexador prindexa
              ,risc0003.fn_valor_opcao_dominio(mvt.idnat_operacao) dsnature
              ,mvt.vltaxa_juros vltaxajr
              ,risc0003.fn_valor_opcao_dominio(prd.idconta_cosif) dsccosif
              ,risc0003.fn_valor_opcao_dominio(prd.idvariacao_cambial) dsvarcam
              ,risc0003.fn_valor_opcao_dominio(prd.idcaract_especial) dscarces
              ,prd.idorigem_cep idorgcep
              ,mvt.vloperacao vloperac
          FROM tbrisco_provisgarant_prodt prd
              ,tbrisco_provisgarant_movto mvt
         WHERE mvt.idproduto = prd.idproduto
           AND mvt.cdcooper  = pr_cdcooper
           AND mvt.dtbase    = pr_dtrefere;
      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      
      -- Definicao do tipo de tabela do crapris
      TYPE typ_reg_saida IS
       RECORD(nrdconta crapris.nrdconta%TYPE,
              dtrefere crapris.dtrefere%TYPE,
              innivris crapris.innivris%TYPE,
              qtdiaatr crapris.qtdiaatr%TYPE,
              vldivida crapris.vldivida%TYPE,
              vlvec180 crapris.vlvec180%TYPE,
              vlvec360 crapris.vlvec360%TYPE,
              vlvec999 crapris.vlvec999%TYPE,
              vldiv060 crapris.vldiv060%TYPE,
              vldiv180 crapris.vldiv180%TYPE,
              vldiv360 crapris.vldiv360%TYPE,
              vldiv999 crapris.vldiv999%TYPE,
              vlprjano crapris.vlprjano%TYPE,
              vlprjaan crapris.vlprjaan%TYPE,
              inpessoa crapris.inpessoa%TYPE,
              nrcpfcgc crapris.nrcpfcgc%TYPE,
              vlprjant crapris.vlprjant%TYPE,
              inddocto crapris.inddocto%TYPE,
              cdmodali crapris.cdmodali%TYPE,
              nrctremp crapris.nrctremp%TYPE,
              nrseqctr crapris.nrseqctr%TYPE,
              dtinictr crapris.dtinictr%TYPE,
              cdorigem crapris.cdorigem%TYPE,
              cdagenci crapris.cdagenci%TYPE,
              innivori crapris.innivori%TYPE,
              cdcooper crapris.cdcooper%TYPE,
              vlprjm60 crapris.vlprjm60%TYPE,
              dtdrisco crapris.dtdrisco%TYPE,
              qtdriclq crapris.qtdriclq%TYPE,
              nrdgrupo crapris.nrdgrupo%TYPE,
              vljura60 crapris.vljura60%TYPE,
              inindris crapris.inindris%TYPE,
              cdinfadi crapris.cdinfadi%TYPE,
              nrctrnov crapris.nrctrnov%TYPE,
              cdmodnov crapris.cdmodali%TYPE,
              dsinfnov crapris.dsinfaux%TYPE,
              flgindiv crapris.flgindiv%TYPE,
              sbcpfcgc VARCHAR2(14),
              dsinfaux crapris.dsinfaux%TYPE,
              dtprxpar crapris.dtprxpar%TYPE,
              vlprxpar crapris.vlprxpar%TYPE,
              qtparcel crapris.qtparcel%TYPE,
              dtvencop crapris.dtvencop%TYPE);
      TYPE typ_tab_saida IS
        TABLE OF typ_reg_saida
          INDEX BY VARCHAR2(34); -- CPF/CNPJ(14) + Contrato(10) + Sequencia (10)

      -- Vetor para armazenar as saídas de Operação da Central
      vr_tab_saida typ_tab_saida;
      
      -- Variavel para o indice
      vr_vlcont_crapris PLS_INTEGER := 0;
      vr_indice_crapris VARCHAR2(34);

      
      -- Tabela temporaria work da CRAPRIS
      TYPE typ_reg_individ IS
       RECORD(cdcooper crapris.cdcooper%TYPE,
              nrdconta crapris.nrdconta%TYPE,
              innivris crapris.innivris%TYPE,
              inpessoa crapris.inpessoa%TYPE,
              nrcpfcgc crapris.nrcpfcgc%TYPE,
              cdmodali crapris.cdmodali%TYPE,
              nrctremp crapris.nrctremp%TYPE,
              nrseqctr crapris.nrseqctr%TYPE,
              vldivida crapris.vldivida%TYPE,
              dtinictr crapris.dtinictr%TYPE,
              cdorigem crapris.cdorigem%TYPE,
              nrdocnpj VARCHAR2(15),
              qtdiaatr crapris.qtdiaatr%TYPE,
              qtdriclq crapris.qtdriclq%TYPE,
              vljura60 crapris.vljura60%TYPE,
              inddocto crapris.inddocto%TYPE,
              cdinfadi crapris.cdinfadi%TYPE,
              dsinfaux crapris.dsinfaux%TYPE,
              dtprxpar crapris.dtprxpar%TYPE,
              vlprxpar crapris.vlprxpar%TYPE,
              qtparcel crapris.qtparcel%TYPE,
              nrdgrupo crapris.nrdgrupo%TYPE,
              dtvencop crapris.dtvencop%TYPE,
              flcessao INTEGER);
      TYPE typ_tab_individ IS
        TABLE OF typ_reg_individ
          INDEX BY VARCHAR2(34); --> CPF/CNPJ(14) + Contrato(10) + Sequencial(10)
      -- Vetor para armazenar os dados da central de risco para uma tabela work
      vr_tab_individ typ_tab_individ;
      -- Variavel para o indice
      vr_idx_individ VARCHAR2(34);

      -- Tabela temporaria auxiliar da vr_tab_agreg
      TYPE typ_reg_agreg IS
       RECORD(cdcooper crapris.cdcooper%TYPE
             ,nrdconta crapris.nrdconta%TYPE
             ,innivris crapris.innivris%TYPE
             ,inpessoa crapris.inpessoa%TYPE
             ,nrcpfcgc crapris.nrcpfcgc%TYPE
             ,cdmodali crapris.cdmodali%TYPE
             ,nrctremp crapris.nrctremp%TYPE
             ,nrseqctr crapris.nrseqctr%TYPE
             ,vldivida crapris.vldivida%TYPE
             ,dtinictr crapris.dtinictr%TYPE
             ,cdorigem crapris.cdorigem%TYPE
             ,qtoperac PLS_INTEGER
             ,qtcooper PLS_INTEGER
             ,cddfaixa PLS_INTEGER
             ,nrdocnpj VARCHAR(15)
             ,cddesemp PLS_INTEGER
             ,vljura60 crapris.vljura60%TYPE
             ,cdnatuop VARCHAR2(04)
             ,inddocto crapris.inddocto%TYPE
             ,dsinfaux crapris.dsinfaux%TYPE);
      TYPE typ_tab_agreg IS
        TABLE OF typ_reg_agreg
          INDEX BY VARCHAR2(18);
      -- Vetor para armazenar os dados da typ_tab_agreg
      vr_tab_agreg typ_tab_agreg;
      -- Variavel para o indice
      vr_indice_agreg VARCHAR2(18);


      -- Tabela de vencimentos da typ_reg_agreg
      TYPE typ_reg_venc_agreg IS
       RECORD(cdmodali crapris.cdmodali%TYPE
             ,innivris crapris.innivris%TYPE
             ,cddfaixa PLS_INTEGER
             ,inpessoa crapris.inpessoa%TYPE
             ,cdvencto PLS_INTEGER
             ,vldivida NUMBER(17,2)
             ,cddesemp PLS_INTEGER
             ,cdnatuop VARCHAR2(04));
      TYPE typ_tab_venc_agreg IS
        TABLE OF typ_reg_venc_agreg
          INDEX BY VARCHAR2(23);
      -- Vetor para armazenar os dados da typ_tab_venc_agreg
      vr_tab_venc_agreg typ_tab_venc_agreg;
      -- Variavel para o indice
      vr_indice_venc_agreg VARCHAR2(23);


      -- Tabela temporaria para os percentuais de risco
      TYPE typ_reg_percentual IS
       RECORD(percentual NUMBER(7,2));
      TYPE typ_tab_percentual IS
        TABLE OF typ_reg_percentual
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os percentuais de risco
      vr_tab_percentual typ_tab_percentual;

      -- Tabela temporaria para os valores das dividas
      TYPE typ_reg_divida IS
       RECORD(divida NUMBER(21,2));
      TYPE typ_tab_divida IS
        TABLE OF typ_reg_divida
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os valores das dividas
      vr_tab_divida typ_tab_divida;


      -- Tabela temporaria para os vencimento
      TYPE typ_reg_venc IS
       RECORD(cdvencto PLS_INTEGER,
              vldivida NUMBER(17,2));
      TYPE typ_tab_venc IS
        TABLE OF typ_reg_venc
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os percentuais de risco
      vr_tab_venc typ_tab_venc;
      -- Variavel para o indice
      vr_indice_venc PLS_INTEGER;

      -- As Pl/Tables abaixos foram incluidas para melhora da performance
      TYPE typ_reg_crapvri IS
       RECORD(cdvencto crapvri.cdvencto%TYPE,
              vldivida crapvri.vldivida%TYPE);
      TYPE typ_tab_crapvri IS
        TABLE OF typ_reg_crapvri
          INDEX BY VARCHAR2(42);

      -- Vetor para armazenar os vencimentos de risco quando o vencimento for menor que 190
      vr_tab_crapvri_b typ_tab_crapvri;
      -- Variavel para o indice dos vencimentos de risco quando o vencimento for menor que 190
      vr_indice_crapvri_b VARCHAR2(42);


      -- Definicao do tipo da tabela de Emprestimos do BNDES
      TYPE typ_reg_crapebn IS
       RECORD(cdsubmod crapebn.cdsubmod%TYPE,
              vlropepr crapebn.vlropepr%TYPE,
              dtinictr crapebn.dtinictr%TYPE,
              dtfimctr crapebn.dtfimctr%TYPE,
              dtprejuz crapebn.dtprejuz%TYPE,
              txefeanu crapebn.txefeanu%TYPE,
              nrdconta crapebn.nrdconta%TYPE,
              dtvctpro crapebn.dtvctpro%TYPE,
              vlparepr crapebn.vlparepr%TYPE,
              qtparctr crapebn.qtparctr%TYPE);
      TYPE typ_tab_crapebn IS
        TABLE OF typ_reg_crapebn
          INDEX BY VARCHAR2(30);
      -- Vetor para armazenar os dados da tabela de emprestimos do Bndes
      vr_tab_crapebn typ_tab_crapebn;
      -- Variavel para o indice
      vr_ind_ebn VARCHAR2(30);

      -- Definicao do tipo da tabela de emprestimos
      TYPE typ_reg_crapepr IS
       RECORD(dtmvtolt crapepr.dtmvtolt%TYPE
             ,cdlcremp crapepr.cdlcremp%TYPE
             ,vlpreemp crapepr.vlpreemp%TYPE
             ,vlemprst crapepr.vlemprst%TYPE
             ,dtprejuz crapepr.dtprejuz%TYPE
             ,nrctaav1 crapepr.nrctaav1%TYPE
             ,nrctaav2 crapepr.nrctaav2%TYPE
             ,qtpreemp crapepr.qtpreemp%TYPE
             ,dtdpagto crapepr.dtdpagto%TYPE
             ,dtdpripg crawepr.dtdpagto%TYPE
             ,qtctrliq NUMBER
             ,inprejuz crapepr.inprejuz%TYPE);
      TYPE typ_tab_crapepr IS
        TABLE OF typ_reg_crapepr
          INDEX BY VARCHAR2(30);
      -- Vetor para armazenar os dados da tabela de emprestimos
      vr_tab_crapepr typ_tab_crapepr;
      -- Variavel para o indice
      vr_ind_epr VARCHAR2(30);

      -- Definicao do tipo da tabela de risco do cartao de credito
      TYPE typ_reg_tbcrd_risco IS
       RECORD(vlropcrd tbcrd_risco.vlsaldo_devedor%TYPE
             ,cdtipcar tbcrd_risco.cdtipo_cartao%TYPE);
       
      TYPE typ_tab_tbcrd_risco IS
        TABLE OF typ_reg_tbcrd_risco
          INDEX BY VARCHAR2(20);
      -- Vetor para armazenar os dados da tabela de emprestimos
      vr_tab_tbcrd_risco typ_tab_tbcrd_risco;
      -- Variavel para o indice
      vr_ind_crd VARCHAR2(20);

      -- Definicao do tipo da tabela para vencimentos
      TYPE typ_reg_vencimento IS
       RECORD(cdcooper crapvri.cdcooper%TYPE,
              dtrefere crapvri.dtrefere%TYPE,
              cdmodali crapvri.cdmodali%TYPE,
              nrdconta crapvri.nrdconta%TYPE,
              nrctremp crapvri.nrctremp%TYPE,
              cdvencto crapvri.cdvencto%TYPE,
              flgpreju BOOLEAN,
              vldivida crapris.vldivida%TYPE,
              inddocto crapris .inddocto%TYPE);
      TYPE typ_tab_vencimento IS
        TABLE OF typ_reg_vencimento
          INDEX BY VARCHAR2(30); -- Ver ordenacao com Andrino
      -- Vetor para armazenar os dados de vencimentos
      vr_tab_vencimento typ_tab_vencimento;
      vr_ind_vecto VARCHAR2(30);

      -- Definicao do tipo da tabela para linhas de credito
      TYPE typ_reg_craplcr IS
       RECORD(cdmodali craplcr.cdmodali%TYPE,
              cdsubmod craplcr.cdsubmod%TYPE,
              txjurfix craplcr.txjurfix%TYPE,
              dsorgrec craplcr.dsorgrec%TYPE,
              cdusolcr craplcr.cdusolcr%TYPE);	
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER; -- Codigo da Linha
      -- Vetor para armazenar os dados de Linha de Credito
      vr_tab_craplcr typ_tab_craplcr;

      -- Estrutura para armazenar os totais das modalidades no arquivo
      TYPE typ_tab_totmodali IS
        TABLE OF NUMBER
          INDEX BY PLS_INTEGER; --> A modalidade será a chave
      vr_tab_totmodali typ_tab_totmodali;    
      vr_idx_totmodali PLS_INTEGER;
      
      -- Estrutura para armazenar as informações digitadas nos 
      -- movimentos de origem dos contratos inddocto=5
      TYPE typ_reg_movto_garant_prestad IS
        RECORD(idmovto_risco NUMBER
              ,dsorigem VARCHAR2(100)
              ,dsindexa VARCHAR2(100)
              ,prindexa NUMBER
              ,dsnature VARCHAR2(100)
              ,vltaxajr NUMBER
              ,dsccosif VARCHAR2(100)
              ,dsvarcam VARCHAR2(100)
              ,dscarces VARCHAR2(100)
              ,idorgcep VARCHAR2(1)
              ,vloperac NUMBER);
      TYPE typ_tab_movto_garant_prestad IS
        TABLE OF typ_reg_movto_garant_prestad
          INDEX BY PLS_INTEGER;
      vr_tab_mvto_garant_prest typ_tab_movto_garant_prestad;    
        
      
      ------------------------------- VARIAVEIS -------------------------------
      -- Variaveis de nomenclatura de arquivos
      vr_dtrefere DATE;

      -- Variaveis de XML
      vr_xml_3040      CLOB;
      vr_xml_3040_temp VARCHAR2(32767);
      vr_xml_566       CLOB;
      vr_xml_566_temp  VARCHAR2(32767);
      vr_xml_567       CLOB;
      vr_xml_567_temp  VARCHAR2(32767);

      -- Variaveis gerais
      vr_vlsalmin NUMBER(17,2);          -- Valor do salario minimo
      vr_dstextab craptab.dstextab%TYPE; -- Variavel de texto do risco bacen
      vr_vldivida_0301 crapris.vldivida%TYPE; -- Variavel acumulativa do valor da divida
      vr_qtregarq PLS_INTEGER := 0;           -- Variavel contadora de registros
      vr_nrdocnpj VARCHAR2(14);
      vr_nrdocnpj2 VARCHAR2(14);
      vr_cdnatuop VARCHAR2(02);
      vr_vtomaior PLS_INTEGER;
      vr_cdmodali VARCHAR2(04);
      vr_dsorgrec VARCHAR2(04);
      vr_fatanual NUMBER(17,2);
      vr_vlrrendi NUMBER(17,2);
      vr_portecli PLS_INTEGER;
      vr_dtabtcct DATE;
      vr_classcli VARCHAR2(05);
      vr_vldivida NUMBER(17,2);
      vr_caracesp VARCHAR2(100);
      vr_vlrctado NUMBER(17,2); --> Valor contratado
      vr_dsvlrctd VARCHAR2(50); --> Descritivo do valor contratado
      vr_stgpecon VARCHAR2(100);
      vr_stdiasat VARCHAR2(100);
      vr_stperidx VARCHAR2(50);
      vr_ctacosif VARCHAR2(10);
      vr_dtfimctr DATE;         -- Data de Fim do Contrato
      vr_diasvenc PLS_INTEGER;  -- Guardar quantidade de dias do vencimento
      vr_cdvencto crapvri.cdvencto%TYPE;
      vr_indice_crapvri VARCHAR2(42);
      vr_vlrdivid NUMBER(17,2);
      vr_cloperis VARCHAR2(03);
      vr_innivris PLS_INTEGER;
      vr_coddindx PLS_INTEGER;
      -- Taxas anuais
      vr_txeanual     NUMBER(10,4);
      vr_txeanual_tab NUMBER(10,4);
      --
      vr_vlpercen NUMBER(17,4);
      vr_vlpreatr NUMBER(17,2) := 0;
      vr_flgatras NUMBER(01);
      vr_qtcalcat PLS_INTEGER;
      vr_ttldivid NUMBER(17,2); -- Total da divida
      vr_vljurfai NUMBER(17,2);
      vr_flgfirst PLS_INTEGER;
      vr_vlacumul NUMBER(17,2);
      vr_vldivnor NUMBER(17,2);
      vr_stsnrcal BOOLEAN;
      vr_inpessoa INTEGER;
      vr_iddident VARCHAR2(04);
      -- Variaveis para os arquivos
      vr_nom_direto VARCHAR2(100);
      vr_nom_dirsal VARCHAR2(100);
      vr_nom_dirmic VARCHAR2(100);
      -- Variaveis de valores de vencimento conforme prazo
      vr_rsvec180 number(17,2);
      vr_rsvec360 number(17,2);
      vr_rsvec999 number(17,2);
      vr_rsdiv060 number(17,2);
      vr_rsdiv180 number(17,2);
      vr_rsdiv360 number(17,2);
      vr_rsdiv999 number(17,2);
      vr_rsprjano number(17,2);
      vr_rsprjaan number(17,2);
      vr_rsdivida number(17,2);
      vr_rsprjant number(17,2);
      vr_nrcpfcgc varchar2(14);
      vr_vlprjano number(17,2) := 0;
      vr_vlprjaan number(17,2) := 0;
      vr_vlprjant number(17,2) := 0;
      vr_totgeral number(17,2) := 0;
      vr_qtreg9   PLS_INTEGER  := 0;
      vr_crapvri  PLS_INTEGER  := 0;
      vr_idcpfcgc VARCHAR2(08);
      vr_totalcli PLS_INTEGER := 0;
      vr_flgarant BOOLEAN; --> Flag de controle de envio dos avalistas
      vr_nrcontrato_3040 VARCHAR2(40);         -- Numero do contrato formatado
      vr_numparte        PLS_INTEGER := 0;     -- Numero da participar do arquivo 3040
      vr_contacli        PLS_INTEGER := 0;     -- Variavel para contar a quantidade de clientes      
      vr_qtregarq_3040   PLS_INTEGER := 50000; -- Quantidade de clientes por arquivo no 3040
      vr_flgfimaq        BOOLEAN     := FALSE; -- Variavel de controle para informar qual sera o ultimo arquivo
      vr_nmarqsai_tot VARCHAR2(1000) := NULL;

      --------------------------- SUBROTINAS INTERNAS --------------------------
	    
      -- Retorno do código de localidade cfme UF
      FUNCTION fn_localiza_uf(pr_sig_UF IN VARCHAR2) RETURN NUMBER IS
      BEGIN
        -- De acordo com a UF da cooperativa, busca o codigo localizador
        CASE pr_sig_UF 
          WHEN 'AC' THEN
            RETURN 10012;
          WHEN 'AL'THEN
            RETURN 10036;
          WHEN 'AM' THEN
            RETURN 10013;
          WHEN 'AP' THEN
            RETURN 10014;
          WHEN 'BA' THEN
            RETURN 10039;
          WHEN 'CE' THEN
            RETURN 10032;
          WHEN 'DF' THEN
            RETURN 10096;
          WHEN 'ES' THEN
            RETURN 10092;
          WHEN 'GO' THEN
            RETURN 10092;
          WHEN 'MA' THEN
            RETURN 10030;
          WHEN 'MG' THEN
            RETURN 10050;
          WHEN 'MS' THEN
            RETURN 10091;
          WHEN 'MT' THEN
            RETURN 10090;
          WHEN 'PA' THEN
            RETURN 10017;
          WHEN 'PB' THEN
            RETURN 10034;
          WHEN 'PE' THEN
            RETURN 10035;
          WHEN 'PI' THEN
            RETURN 10031;
          WHEN 'PR' THEN
            RETURN 10073;
          WHEN 'RJ' THEN
            RETURN 10054;
          WHEN 'RN' THEN
            RETURN 10033;
          WHEN 'RO' THEN
            RETURN 10093;
          WHEN 'RR' THEN
            RETURN 10018;
          WHEN 'RS' THEN
            RETURN 10077;
          WHEN 'SC' THEN
            RETURN 10075;
          WHEN 'SE' THEN
            RETURN 10038;
          WHEN 'SP' THEN
            RETURN 10058;
          WHEN 'TO' THEN
            RETURN 10094;
          ELSE
            RETURN 0;
        END CASE;
      END fn_localiza_uf;
      
      -- Procedure para verificar se eh conta de migracao da cooperativa AltoVale
      FUNCTION fn_eh_conta_migracao_573(pr_cdcooper IN  crapris.cdcooper%TYPE
                                       ,pr_nrdconta IN  crapris.nrdconta%TYPE
                                       ,pr_dtrefere IN  DATE) RETURN BOOLEAN IS
        -- Cursor de contas transferidas entre cooperativas
        CURSOR cr_craptco (pr_nrdconta     crapass.nrdconta%TYPE,
                           pr_cdcooper_ant crapass.cdcooper%TYPE) IS
          SELECT 1
            FROM craptco
           WHERE craptco.cdcooper = pr_cdcooper
             AND craptco.cdcopant = pr_cdcooper_ant
             AND craptco.nrdconta = pr_nrdconta
             AND craptco.tpctatrf <> 3
             AND (pr_cdcooper_ant <> 2 OR craptco.cdageant IN (2, 4, 6, 7, 11));
        rw_craptco cr_craptco%ROWTYPE;

      BEGIN
        -- Migracao Viacredi -> Altovale
        IF pr_cdcooper = 16 AND pr_dtrefere <= to_date('31/12/2012','dd/mm/yyyy') THEN
          -- Verifica se a conta eh de transferencia entre cooperativas
          OPEN cr_craptco(pr_nrdconta, 1);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            RETURN true;
          END IF;
          CLOSE cr_craptco;
        -- Migracao Acredicop -> Viacredi
        ELSIF pr_cdcooper = 1 AND pr_dtrefere <= to_date('31/12/2013','dd/mm/yyyy') THEN
          -- Verifica se a conta eh de transferencia entre cooperativas
          OPEN cr_craptco(pr_nrdconta, 2);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            RETURN true;
          END IF;
          CLOSE cr_craptco;
        --> Incorporação Tranculcred -> Tranpocred
        ELSIF pr_cdcooper = 9 AND pr_dtrefere <= to_date('31/12/2016','dd/mm/yyyy') THEN
          -- Verifica se a conta eh de transferencia entre cooperativas
          OPEN cr_craptco(pr_nrdconta, 17);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            RETURN true;
          END IF;
          CLOSE cr_craptco;
        END IF;
        -- Não é migracao
        RETURN false;
      END fn_eh_conta_migracao_573;

      -- Busca os dias de vencimento de acordo com o codigo de vencimento
      FUNCTION fn_busca_dias_vencimento(pr_codvenci IN PLS_INTEGER) RETURN NUMBER IS
      BEGIN
        CASE pr_codvenci 
          WHEN 110 THEN  -- Se o vencimento for para 1 dia
            RETURN 1;
          WHEN 120 THEN -- Se o vencimento for para 31 dias
            RETURN 31;
          WHEN 130 THEN -- Se o vencimento for para 61 dias
            RETURN 61;
          WHEN 140 THEN -- Se o vencimento for para 91 dias
            RETURN 91;
          WHEN 150 THEN -- Se o vencimento for para 181 dias
            RETURN 181;
          WHEN 160 THEN -- Se o vencimento for para 361 dias
            RETURN 361;
          WHEN 165 THEN -- Se o vencimento for para 165 dias
            RETURN 721;
          WHEN 170 THEN -- Se o vencimento for para 1081 dias
            RETURN 1081;
          WHEN 175 THEN -- Se o vencimento for para 1441 dias
            RETURN 1441;
          WHEN 180 THEN -- Se o vencimento for para 1801 dias
            RETURN 1801;
          WHEN 190 THEN -- Se o vencimento for para 5401 dias
            RETURN 5401;
          ELSE
            RETURN null;  
        END CASE;
      END fn_busca_dias_vencimento;

      -- Busca a origem do recurso
      FUNCTION fn_busca_dsorgrec(pr_cdmodali      IN PLS_INTEGER
                                ,pr_nrdconta      IN crapepr.nrdconta%TYPE
                                ,pr_nrctremp      IN crapepr.nrctremp%TYPE
                                ,pr_cdorigem      IN crapris.cdorigem%TYPE
                                ,pr_dsinfaux      IN crapris.dsinfaux%TYPE) RETURN VARCHAR2 IS
        vr_dsorgrec_out VARCHAR2(4);
      BEGIN
        -- Apenas uma condicao altera pr_dsorgrec_out
        vr_dsorgrec_out := '0199';
        -- Para Emprestimos ou Financiamentos
        IF pr_cdmodali in(0299,0499) AND pr_cdorigem = 3 THEN
          -- Para empréstimo Ayllos
          IF pr_dsinfaux != 'BNDES' THEN
            -- Buscaremos da Linha de Crédito Cfme Crapepr
            vr_ind_epr := lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');  
            -- Somente se existir linha de credito
            IF vr_tab_craplcr.EXISTS(vr_tab_crapepr(vr_ind_epr).cdlcremp) THEN
              -- Se Origem Recurso BNDES, altera para '0202'
              IF vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).dsorgrec LIKE '%BNDES%' THEN
                vr_dsorgrec_out := '0202';
              END IF;
            END IF;
		      ELSE --se for BNDES - SD 426476
            vr_dsorgrec_out := '0203'; 			
          END IF;
        -- Para Contratos de Garantias Prestadas
        ELSIF pr_cdorigem = 7 THEN
          -- Verificar se existe o movimento na tabela de origem das informações
          IF vr_tab_mvto_garant_prest.exists(pr_dsinfaux) THEN 
            -- Usaremos a origem de recurso gravada
            vr_dsorgrec_out := vr_tab_mvto_garant_prest(pr_dsinfaux).dsorigem;
          END IF;  
        END IF;
        -- Retornar
        RETURN vr_dsorgrec_out;
      END fn_busca_dsorgrec;

      -- Formata o codigo da modalidade
      FUNCTION fn_formata_numero_contrato(pr_cdcooper IN crapris.cdcooper%TYPE
                                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                                         ,pr_nrctremp IN crapris.nrctremp%TYPE
                                         ,pr_cdmodali IN crapris.cdmodali%TYPE) RETURN VARCHAR2 IS
        vr_nrmodalidade VARCHAR2(40);
      BEGIN
        vr_nrmodalidade := LPAD(pr_cdcooper,5,'0')  ||
                           LPAD(pr_nrdconta,15,'0') ||
                           LPAD(pr_nrctremp,15,'0') ||
                           LPAD(pr_cdmodali,5,'0');
        -- Retornar
        RETURN vr_nrmodalidade;
        
      END fn_formata_numero_contrato;   
      
      -- Buscar variacao cambial
      FUNCTION fn_varcambial(pr_inddocto IN crapris.inddocto%TYPE
                            ,pr_dsinfaux IN crapris.dsinfaux%TYPE) RETURN NUMBER IS
      BEGIN
        -- Para indocto = 5 a variação cambial está em cadastro
        IF pr_inddocto = 5 AND vr_tab_mvto_garant_prest.exists(pr_dsinfaux)THEN
          RETURN vr_tab_mvto_garant_prest(pr_dsinfaux).dsvarcam;
        ELSE
          -- Outros casos é fixo
          RETURN '790';
        END IF;
      END;     
      
      -- Buscar CEP
      FUNCTION fn_cepende(pr_inddocto IN crapris.inddocto%TYPE
                         ,pr_dsinfaux IN crapris.dsinfaux%TYPE) RETURN NUMBER IS
      BEGIN
        -- Para indocto = 5 temos de ver como está definido o CEP 
        IF pr_inddocto = 5 AND vr_tab_mvto_garant_prest.exists(pr_dsinfaux)THEN
          IF vr_tab_mvto_garant_prest(pr_dsinfaux).idorgcep = 'C' THEN 
            -- Usar cep da central
            RETURN rw_crapcop_3.nrcepend;
          ELSE
            -- Usar da Singular
            RETURN rw_crapcop.nrcepend;
          END IF;
        ELSE
          -- Outros Usar da Singular
          RETURN rw_crapcop.nrcepend;
        END IF;
      END;     
      
      -- Carregar a base de risco, separando os contratos em individuais e agregados 
      PROCEDURE pc_carrega_base_risco(pr_dtrefere DATE) IS
        -- Busca informacoes da central de risco
        CURSOR cr_crapris_geral(pr_dtrefere DATE) IS
          SELECT crapris.nrdconta,
                 crapris.dtrefere,
                 crapris.innivris,
                 crapris.qtdiaatr,
                 crapris.vldivida,
                 crapris.vlvec180,
                 crapris.vlvec360,
                 crapris.vlvec999,
                 crapris.vldiv060,
                 crapris.vldiv180,
                 crapris.vldiv360,
                 crapris.vldiv999,
                 crapris.vlprjano,
                 crapris.vlprjaan,
                 crapris.inpessoa,
                 crapris.nrcpfcgc,
                 crapris.vlprjant,
                 crapris.inddocto,
                 crapris.cdmodali,
                 crapris.nrctremp,
                 crapris.nrseqctr,
                 crapris.dtinictr,
                 crapris.cdorigem,
                 crapris.cdagenci,
                 crapris.innivori,
                 crapris.cdcooper,
                 crapris.vlprjm60,
                 crapris.dtdrisco,
                 crapris.qtdriclq,
                 crapris.nrdgrupo,
                 crapris.vljura60,
                 crapris.inindris,
                 crapris.cdinfadi,
                 crapris.nrctrnov,
                 crapris.flgindiv,
                 crapris.progress_recid,
                 crapris.dsinfaux,
                 crapris.dtprxpar,
                 crapris.vlprxpar,
                 crapris.qtparcel,
                 crapris.dtvencop,
                 0 flcessao
            FROM crapris
           WHERE crapris.cdcooper = pr_cdcooper
             AND crapris.dtrefere = pr_dtrefere
             AND crapris.inddocto IN(1,3,4,5) -- Operações Ativas, Limite Não Utilizado, Cartão de Crédito e Garantias Prestadas
             AND crapris.cdmodali <> 0301 -- Dsc Tit 
             AND crapris.inpessoa IN (1,2)-- Deve ser CPF ou CNPJ
             AND crapris.vldivida <> 0    -- Com divida
             AND nvl(crapris.cdinfadi,' ') <> '0301' -- Remover saidas para Inddocto=5
            ORDER BY DECODE(inddocto,3,1,0) desc,nrcpfcgc, nrctremp, cdmodali; --> IndDocto 3 virão primeiro... 

        -- Busca informacoes da central de risco de Dsc Titulo
        CURSOR cr_crapris_dsctit(pr_dtrefere DATE) IS
          SELECT crapris.*
                ,ROW_NUMBER () OVER (PARTITION BY crapris.nrdconta, crapris.nrctremp ORDER BY crapris.nrdconta, crapris.nrctremp) nrseq
                ,COUNT(1)      OVER (PARTITION BY crapris.nrdconta, crapris.nrctremp ORDER BY crapris.nrdconta, crapris.nrctremp) qtreg
            FROM crapris
           WHERE crapris.cdcooper = pr_cdcooper
             AND crapris.dtrefere = pr_dtrefere
             AND crapris.inddocto = 1     -- documento 3020
             AND crapris.cdmodali = 0301  -- Dsc Tit 
             AND crapris.cdorigem IN(4,5) -- 4 - Desconto Titulos
             AND crapris.inpessoa IN (1,2)        -- Deve ser CPF ou CNPJ             
             AND vldivida <> 0;
        
        --> temptable dos dados dados da tabela de risco
        TYPE typ_rec_ris IS RECORD
            (nrdconta   crapris.nrdconta%TYPE, 
             dtrefere   crapris.dtrefere%TYPE, 
             innivris   crapris.innivris%TYPE, 
             qtdiaatr   crapris.qtdiaatr%TYPE, 
             vldivida   crapris.vldivida%TYPE, 
             vlvec180   crapris.vlvec180%TYPE, 
             vlvec360   crapris.vlvec360%TYPE, 
             vlvec999   crapris.vlvec999%TYPE, 
             vldiv060   crapris.vldiv060%TYPE, 
             vldiv180   crapris.vldiv180%TYPE, 
             vldiv360   crapris.vldiv360%TYPE, 
             vldiv999   crapris.vldiv999%TYPE, 
             vlprjano   crapris.vlprjano%TYPE, 
             vlprjaan   crapris.vlprjaan%TYPE, 
             inpessoa   crapris.inpessoa%TYPE, 
             nrcpfcgc   crapris.nrcpfcgc%TYPE, 
             vlprjant   crapris.vlprjant%TYPE, 
             inddocto   crapris.inddocto%TYPE, 
             cdmodali   crapris.cdmodali%TYPE, 
             nrctremp   crapris.nrctremp%TYPE, 
             nrseqctr   crapris.nrseqctr%TYPE, 
             dtinictr   crapris.dtinictr%TYPE, 
             cdorigem   crapris.cdorigem%TYPE, 
             cdagenci   crapris.cdagenci%TYPE, 
             innivori   crapris.innivori%TYPE, 
             cdcooper   crapris.cdcooper%TYPE, 
             vlprjm60   crapris.vlprjm60%TYPE, 
             dtdrisco   crapris.dtdrisco%TYPE, 
             qtdriclq   crapris.qtdriclq%TYPE, 
             nrdgrupo   crapris.nrdgrupo%TYPE, 
             vljura60   crapris.vljura60%TYPE, 
             inindris   crapris.inindris%TYPE, 
             cdinfadi   crapris.cdinfadi%TYPE, 
             nrctrnov   crapris.nrctrnov%TYPE, 
             flgindiv   crapris.flgindiv%TYPE, 
             progress_recid crapris.progress_recid%TYPE, 
             dsinfaux   crapris.dsinfaux%TYPE, 
             dtprxpar   crapris.dtprxpar%TYPE, 
             vlprxpar   crapris.vlprxpar%TYPE, 
             qtparcel   crapris.qtparcel%TYPE,              
             dtvencop   crapris.dtvencop%TYPE,
             flcessao   INTEGER);
        
        -- Definicao do tipo da tabela de central de risco
        TYPE typ_tab_ris IS
          TABLE OF typ_rec_ris ---> crapris%ROWTYPE
            INDEX BY VARCHAR2(24); -- CPF/CNPJ(14) || Sequencial (10)
        -- Vetor para armazenar os dados da central de risco
        vr_tab_ris typ_tab_ris;

        -- Variavel para o indice
        vr_vlcont_ris PLS_INTEGER := 0;
        vr_indice_ris VARCHAR2(24);      
        
        -- Vetor para armazenar os dados da central de risco (temporario)
        vr_tab_crapris_temp typ_tab_ris;

        -- Variavel para o indice
        vr_indice_temp VARCHAR2(24);
        
        -- Vetor para armazenar os dados da central de risco para uma tabela work temporaria
        vr_tab_individ_copy typ_tab_individ;

        -- Variavel para o indice
        vr_vlcont_copy PLS_INTEGER := 0;
        vr_indice_copy VARCHAR2(34);
        
        -- Auxiliares
        vr_cpf      VARCHAR2(11);
        vr_cddfaixa PLS_INTEGER;
        vr_cddesemp PLS_INTEGER;
        
        vr_dtprxpar crapris.dtprxpar%TYPE;
        vr_vlprxpar crapris.vlprxpar%TYPE;
        vr_qtparcel crapris.qtparcel%TYPE;
        vr_dtvencop crapris.dtvencop%TYPE;
        vr_qtdiaatr crapris.qtdiaatr%TYPE;
             
      BEGIN
        -- Efetua loop sobre os dados da central de risco (Exceto 301 - Dsc Titulos)
        FOR rw_crapris IN cr_crapris_geral(vr_dtrefere) LOOP
          -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
          IF pr_cdcooper IN (1,16,9) THEN
            -- Se for uma conta migrada nao deve processar
            IF fn_eh_conta_migracao_573(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapris.nrdconta
                                       ,pr_dtrefere => rw_crapris.dtrefere) THEN
              continue; -- Volta para o inicio do for
            END IF;
          END IF;
          
          -- Incrementar contador
          vr_vlcont_ris := vr_vlcont_ris + 1;
          vr_indice_ris := lpad(rw_crapris.nrcpfcgc,14,'0')||lpad(vr_vlcont_ris,10,'0');
          -- Adicionar a tabela
          vr_tab_ris(vr_indice_ris) := rw_crapris;        
          
          IF rw_crapris.inddocto = 1 AND 
             rw_crapris.cdmodali IN(0299,0499) THEN -- Contratos de Emprestimo/Financiamento
          
            rw_cessao := NULL;
            --> Verificar se é emprestimo de cessao de credito
            OPEN cr_cessao (pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => rw_crapris.nrdconta,
                            pr_nrctremp => rw_crapris.nrctremp);
            FETCH cr_cessao INTO rw_cessao;
            CLOSE cr_cessao;
            
            vr_tab_ris(vr_indice_ris).flcessao := rw_cessao.flcessao;
            
          END IF;
          
        END LOOP; -- Fim do loop sobre a tabela crapris
        
        -- Efetua loop sobre os dados da central de risco de Dsc Titulos
        FOR rw_crapris_dsctit IN cr_crapris_dsctit(vr_dtrefere) LOOP
          -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred
          IF pr_cdcooper IN (1,16,9) THEN
            -- Se for uma conta migrada nao deve processar
            IF fn_eh_conta_migracao_573(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapris_dsctit.nrdconta
                                       ,pr_dtrefere => rw_crapris_dsctit.dtrefere) THEN
              continue; -- Volta para o inicio do for
            END IF;
          END IF;
          -- Acumula o valor da divida
          vr_vldivida_0301 := nvl(vr_vldivida_0301,0) + rw_crapris_dsctit.vldivida;
          -- No primeiro registro, inicializamos as variaveis
          IF rw_crapris_dsctit.nrseq = 1 THEN
            vr_dtprxpar := NULL;
            vr_vlprxpar := 0;
            vr_qtparcel := 0;
            vr_dtvencop := rw_crapris_dsctit.dtvencop;
            vr_qtdiaatr := 0;
          END IF;
          -- Sempre acumularemos a maior quantidade de parcelas 
          vr_qtparcel := greatest(vr_qtparcel,rw_crapris_dsctit.qtparcel);
          -- Se o próximo pagamento armazenado não estiver no mesmo mês do registro atual
          IF trunc(vr_dtprxpar,'mm') != trunc(rw_crapris_dsctit.dtprxpar,'mm') THEN
            -- Iremos zerar a quantidade acumulada do próximo pagamento
            vr_vlprxpar := 0;
          END IF;
          -- O próximo pagamento deve sempre será o mais próximo
          vr_dtprxpar := least(vr_dtprxpar,rw_crapris_dsctit.dtprxpar);
          -- Se o registro atual possuir o próximo pagamento no mesmo
          -- mes do pagamento mais próximo
          IF trunc(vr_dtprxpar,'mm') = trunc(rw_crapris_dsctit.dtprxpar,'mm') THEN
            -- Acumularemos o valor a vencer deste registro, pois ele vence no 
            -- mesmo mÊs da próxima parcela mais próxima.
            vr_vlprxpar := vr_vlprxpar + rw_crapris_dsctit.vlprxpar;
          END IF;          
          --Guardar a maior data de vencimento
          vr_dtvencop := GREATEST(rw_crapris_dsctit.dtvencop,vr_dtvencop);
          vr_qtdiaatr := GREATEST(rw_crapris_dsctit.qtdiaatr,vr_qtdiaatr);
          
          -- Se for o ultimo registro da conta / contrato de limite do bordero, grava os valores
          IF rw_crapris_dsctit.nrseq = rw_crapris_dsctit.qtreg THEN
            -- Incrementar contador
            vr_vlcont_ris := vr_vlcont_ris + 1;
            vr_indice_ris := lpad(rw_crapris_dsctit.nrcpfcgc,14,'0')||lpad(vr_vlcont_ris,10,'0');
            -- Criar novo registro
            vr_tab_ris(vr_indice_ris).nrdconta := rw_crapris_dsctit.nrdconta;
            vr_tab_ris(vr_indice_ris).dtrefere := rw_crapris_dsctit.dtrefere;
            vr_tab_ris(vr_indice_ris).innivris := rw_crapris_dsctit.innivris;
            vr_tab_ris(vr_indice_ris).qtdiaatr := vr_qtdiaatr;
            vr_tab_ris(vr_indice_ris).vldivida := vr_vldivida_0301;
            vr_tab_ris(vr_indice_ris).vlvec180 := rw_crapris_dsctit.vlvec180;
            vr_tab_ris(vr_indice_ris).vlvec360 := rw_crapris_dsctit.vlvec360;
            vr_tab_ris(vr_indice_ris).vlvec999 := rw_crapris_dsctit.vlvec999;
            vr_tab_ris(vr_indice_ris).vldiv060 := rw_crapris_dsctit.vldiv060;
            vr_tab_ris(vr_indice_ris).vldiv180 := rw_crapris_dsctit.vldiv180;
            vr_tab_ris(vr_indice_ris).vldiv360 := rw_crapris_dsctit.vldiv360;
            vr_tab_ris(vr_indice_ris).vldiv999 := rw_crapris_dsctit.vldiv999;
            vr_tab_ris(vr_indice_ris).vlprjano := rw_crapris_dsctit.vlprjano;
            vr_tab_ris(vr_indice_ris).vlprjaan := rw_crapris_dsctit.vlprjaan;
            vr_tab_ris(vr_indice_ris).inpessoa := rw_crapris_dsctit.inpessoa;
            vr_tab_ris(vr_indice_ris).nrcpfcgc := rw_crapris_dsctit.nrcpfcgc;
            vr_tab_ris(vr_indice_ris).vlprjant := rw_crapris_dsctit.vlprjant;
            vr_tab_ris(vr_indice_ris).inddocto := rw_crapris_dsctit.inddocto;
            vr_tab_ris(vr_indice_ris).cdmodali := rw_crapris_dsctit.cdmodali;
            vr_tab_ris(vr_indice_ris).nrctremp := rw_crapris_dsctit.nrctremp;
            vr_tab_ris(vr_indice_ris).nrseqctr := rw_crapris_dsctit.nrseqctr;
            vr_tab_ris(vr_indice_ris).dtinictr := rw_crapris_dsctit.dtinictr;
            vr_tab_ris(vr_indice_ris).cdorigem := 4; -- Desconto Titulos 
            vr_tab_ris(vr_indice_ris).cdagenci := rw_crapris_dsctit.cdagenci;
            vr_tab_ris(vr_indice_ris).innivori := rw_crapris_dsctit.innivori;
            vr_tab_ris(vr_indice_ris).cdcooper := rw_crapris_dsctit.cdcooper;
            vr_tab_ris(vr_indice_ris).vlprjm60 := rw_crapris_dsctit.vlprjm60;
            vr_tab_ris(vr_indice_ris).dtdrisco := rw_crapris_dsctit.dtdrisco;
            vr_tab_ris(vr_indice_ris).qtdriclq := rw_crapris_dsctit.qtdriclq;
            vr_tab_ris(vr_indice_ris).nrdgrupo := rw_crapris_dsctit.nrdgrupo;
            vr_tab_ris(vr_indice_ris).vljura60 := rw_crapris_dsctit.vljura60;
            vr_tab_ris(vr_indice_ris).inindris := rw_crapris_dsctit.inindris;
            vr_tab_ris(vr_indice_ris).cdinfadi := rw_crapris_dsctit.cdinfadi;
            vr_tab_ris(vr_indice_ris).nrctrnov := rw_crapris_dsctit.nrctrnov;
            vr_tab_ris(vr_indice_ris).flgindiv := rw_crapris_dsctit.flgindiv;
            vr_tab_ris(vr_indice_ris).dsinfaux := rw_crapris_dsctit.dsinfaux;
            vr_tab_ris(vr_indice_ris).dtprxpar := rw_crapris_dsctit.dtprxpar;
            vr_tab_ris(vr_indice_ris).vlprxpar := rw_crapris_dsctit.vlprxpar;
            vr_tab_ris(vr_indice_ris).qtparcel := rw_crapris_dsctit.qtparcel;
            vr_tab_ris(vr_indice_ris).dtvencop := vr_dtvencop;
            -- Zera a variavel acumuladora
            vr_vldivida_0301 := 0;
          END IF;
        END LOOP; -- Fim do loop sobre a tabela crapris
        
        --Acessar primeiro registro da tabela de memoria
        vr_indice_ris := vr_tab_ris.FIRST;
        -- Varre a tabela de memoria vr_tab_crapris
        WHILE vr_indice_ris IS NOT NULL LOOP
          -- Conta o total de registros
          vr_qtregarq := vr_qtregarq + 1;
          -- Busca o CPF e CNPJ
          IF vr_tab_ris(vr_indice_ris).inpessoa = 1 THEN
            vr_cpf := substr(vr_tab_ris(vr_indice_ris).nrcpfcgc,1,11);
            vr_nrdocnpj := 0;
          ELSE
            vr_nrdocnpj := lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0');
            vr_cpf      := SUBSTR(lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0'),1,8);
          END IF;
          -- Copia o registro da tabela temporaria CRAPRIS para uma tabela TEMP
          vr_tab_crapris_temp(vr_indice_ris) := vr_tab_ris(vr_indice_ris);
          -- monta o indice para a tabela temporaria work
          vr_vlcont_copy := vr_vlcont_copy + 1;
          vr_indice_copy := lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0')
                         || lpad(vr_tab_ris(vr_indice_ris).nrctremp,'0',10) 
                         || lpad(vr_vlcont_copy,10,'0');
          -- atualiza a tabela temporaria WORK
          vr_tab_individ_copy(vr_indice_copy).cdcooper := vr_tab_ris(vr_indice_ris).cdcooper;
          vr_tab_individ_copy(vr_indice_copy).nrdconta := vr_tab_ris(vr_indice_ris).nrdconta;
          vr_tab_individ_copy(vr_indice_copy).innivris := vr_tab_ris(vr_indice_ris).innivris;
          vr_tab_individ_copy(vr_indice_copy).inpessoa := vr_tab_ris(vr_indice_ris).inpessoa;
          vr_tab_individ_copy(vr_indice_copy).cdorigem := vr_tab_ris(vr_indice_ris).cdorigem;
          vr_tab_individ_copy(vr_indice_copy).cdmodali := vr_tab_ris(vr_indice_ris).cdmodali;
          vr_tab_individ_copy(vr_indice_copy).nrctremp := vr_tab_ris(vr_indice_ris).nrctremp;
          vr_tab_individ_copy(vr_indice_copy).nrseqctr := vr_tab_ris(vr_indice_ris).nrseqctr;
          vr_tab_individ_copy(vr_indice_copy).vldivida := vr_tab_ris(vr_indice_ris).vldivida;
          vr_tab_individ_copy(vr_indice_copy).dtinictr := vr_tab_ris(vr_indice_ris).dtinictr;
          vr_tab_individ_copy(vr_indice_copy).nrcpfcgc := vr_cpf;
          vr_tab_individ_copy(vr_indice_copy).nrdocnpj := vr_nrdocnpj;
          vr_tab_individ_copy(vr_indice_copy).qtdiaatr := vr_tab_ris(vr_indice_ris).qtdiaatr;
          vr_tab_individ_copy(vr_indice_copy).qtdriclq := vr_tab_ris(vr_indice_ris).qtdriclq;
          vr_tab_individ_copy(vr_indice_copy).vljura60 := vr_tab_ris(vr_indice_ris).vljura60;
          vr_tab_individ_copy(vr_indice_copy).inddocto := vr_tab_ris(vr_indice_ris).inddocto;
          vr_tab_individ_copy(vr_indice_copy).cdinfadi := vr_tab_ris(vr_indice_ris).cdinfadi;
          vr_tab_individ_copy(vr_indice_copy).dsinfaux := vr_tab_ris(vr_indice_ris).dsinfaux;
          vr_tab_individ_copy(vr_indice_copy).dtprxpar := vr_tab_ris(vr_indice_ris).dtprxpar;
          vr_tab_individ_copy(vr_indice_copy).vlprxpar := vr_tab_ris(vr_indice_ris).vlprxpar;
          vr_tab_individ_copy(vr_indice_copy).qtparcel := vr_tab_ris(vr_indice_ris).qtparcel;
          vr_tab_individ_copy(vr_indice_copy).nrdgrupo := vr_tab_ris(vr_indice_ris).nrdgrupo;
          vr_tab_individ_copy(vr_indice_copy).dtvencop := vr_tab_ris(vr_indice_ris).dtvencop;
          vr_tab_individ_copy(vr_indice_copy).flcessao := vr_tab_ris(vr_indice_ris).flcessao;
          
          -- Verifica se eh o ultimo registro ou se o proximo registro possui o CNPJ / CPF do registro atual
          IF vr_tab_ris.next(vr_indice_ris) IS NULL OR
             vr_tab_ris(vr_indice_ris).nrcpfcgc <> vr_tab_ris(vr_tab_ris.next(vr_indice_ris)).nrcpfcgc THEN
             -- Acumula Total de Clientes para informar no Cabecalho 
             vr_totalcli := vr_totalcli + 1;
            -- Se nao for uma operacao individualizada do BC
            IF vr_tab_ris(vr_indice_ris).flgindiv = 0 THEN
              vr_cdnatuop := '01';
              vr_indice_temp := lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0')||'000000';
              vr_indice_temp := vr_tab_crapris_temp.next(vr_indice_temp);
              WHILE vr_indice_temp IS NOT NULL LOOP
                -- Sair do loop quando o nrcpfcgc for diferente do que esta sendo processado
                IF vr_tab_crapris_temp(vr_indice_temp).nrcpfcgc <> vr_tab_ris(vr_indice_ris).nrcpfcgc THEN
                  EXIT;
                END IF;
                vr_cdnatuop := '01';
                -- Tratamento Natureza operacao CONTA MIGRADA Acredicoop 
                -- 0299= Emprst, 0499=Financ 
                -- 3 - Emprestimos/Financiamentos 
                IF pr_cdcooper = 1 AND vr_tab_crapris_temp(vr_indice_temp).cdmodali IN (0299, 0499) AND vr_tab_crapris_temp(vr_indice_temp).cdorigem = 3 THEN 
                  -- Abre o cursor de contas transferidas
                  OPEN cr_craptco_b(vr_tab_crapris_temp(vr_indice_temp).nrdconta);
                  FETCH cr_craptco_b INTO rw_craptco_b;
                  --Conta transferida e o empréstimo não é BNDES
                  IF cr_craptco_b%FOUND AND vr_tab_crapris_temp(vr_indice_temp).dsinfaux <> 'BNDES' THEN 
                    -- Verifica se possui emprestimo para o contrato e conta
                    vr_ind_epr := lpad(vr_tab_crapris_temp(vr_indice_temp).nrdconta,10,'0')||
                                  lpad(vr_tab_crapris_temp(vr_indice_temp).nrctremp,10,'0');
                    -- Se o empréstimo for inferior a 31/12/2013
                    IF vr_tab_crapepr(vr_ind_epr).dtmvtolt <= to_date('31/12/2013','dd/mm/yyyy') THEN
                      vr_cdnatuop := '02';
                    END IF;
                  END IF;
                  CLOSE cr_craptco_b;
                END IF;
                -- Tratamento Natureza operacao CONTA MIGRADA Altovale
                -- 0299 = Emprst, 0499 = Financ 
                -- 3 - Emprestimos/Financiamentos 
                IF vr_tab_crapris_temp(vr_indice_temp).cdcooper = 16 AND vr_tab_crapris_temp(vr_indice_temp).cdmodali IN (299,499) AND vr_tab_crapris_temp(vr_indice_temp).cdorigem = 3 THEN 
                  -- Verifica se a conta eh de transferencia entre cooperativas
                  OPEN cr_craptco(vr_tab_crapris_temp(vr_indice_temp).nrdconta);
                  FETCH cr_craptco INTO rw_craptco;
                  --Conta transferida e o empréstimo não é BNDES
                  IF cr_craptco%FOUND AND vr_tab_crapris_temp(vr_indice_temp).dsinfaux <> 'BNDES' THEN 
                    -- Verifica se possui emprestimo para o contrato e conta
                    vr_ind_epr := lpad(vr_tab_crapris_temp(vr_indice_temp).nrdconta,10,'0')||
                                  lpad(vr_tab_crapris_temp(vr_indice_temp).nrctremp,10,'0');
                    -- Se o empréstimo for inferior a 31/12/2013
                    IF vr_tab_crapepr(vr_ind_epr).dtmvtolt < to_date('31/12/2012','dd/mm/yyyy') THEN
                      vr_cdnatuop := '02';
                    END IF;
                  END IF;
                  CLOSE cr_craptco;
                END IF;      
                
                --> Verificar se é cessao de credito
                IF vr_tab_crapris_temp(vr_indice_temp).flcessao = 1 THEN
                  vr_cdnatuop := '02';
                END IF;                        
                
                -- Verificar se é Garantia Prestada
                IF vr_tab_crapris_temp(vr_indice_temp).inddocto = 5 THEN
                  -- Buscar a natureza no cadastro do movimento
                  IF vr_tab_mvto_garant_prest.exists(vr_tab_crapris_temp(vr_indice_temp).dsinfaux) THEN 
                    vr_cdnatuop := vr_tab_mvto_garant_prest(vr_tab_crapris_temp(vr_indice_temp).dsinfaux).dsnature;
                  END IF;
                END IF;    
                
                -- Encontrar a faixa de valor conforme tabela
                --   Anexo 14: Faixa de valor da operação - FaixaVlr	
                --   Domínio   Descrição
                --         1   Acima de 0 a R$ 99,99
                --         2   R$ 100,00 a R$ 499,99
                --         3   R$ 500,00 a R$ 999,99
                --         4   R$ 1.000,00 a R$ 4.999,99
                --         5   acima de R$4999,99
                IF (vr_tab_crapris_temp(vr_indice_temp).vldivida - vr_tab_crapris_temp(vr_indice_temp).vljura60 ) < 100 THEN
                  vr_cddfaixa := 1;
                ELSIF (vr_tab_crapris_temp(vr_indice_temp).vldivida - vr_tab_crapris_temp(vr_indice_temp).vljura60 ) < 500 THEN
                  vr_cddfaixa := 2;
                ELSIF (vr_tab_crapris_temp(vr_indice_temp).vldivida - vr_tab_crapris_temp(vr_indice_temp).vljura60 ) < 1000 THEN
                  vr_cddfaixa := 3;
                ELSIF (vr_tab_crapris_temp(vr_indice_temp).vldivida - vr_tab_crapris_temp(vr_indice_temp).vljura60 ) < 5000 THEN
                  vr_cddfaixa := 4;  
                ELSE
                  vr_cddfaixa := 5;  
                END IF;
                vr_vtomaior := 0;
                vr_cddesemp := 1;
                -- Buscar o desempenho da operacao a partir do crapvri.cdvencto 
                OPEN cr_crapvri(pr_nrdconta => vr_tab_crapris_temp(vr_indice_temp).nrdconta,
                                pr_dtrefere => vr_dtrefere,
                                pr_innivris => vr_tab_crapris_temp(vr_indice_temp).innivris,
                                pr_cdmodali => vr_tab_crapris_temp(vr_indice_temp).cdmodali,
                                pr_nrctremp => vr_tab_crapris_temp(vr_indice_temp).nrctremp);
                FETCH cr_crapvri INTO rw_crapvri;
                IF cr_crapvri%FOUND THEN
                  IF rw_crapvri.cdvencto    >= 310  THEN
                    vr_cddesemp := 06;
                  ELSIF rw_crapvri.cdvencto >= 240  THEN
                    vr_cddesemp := 05;
                  ELSIF rw_crapvri.cdvencto >= 230  THEN
                    vr_cddesemp := 04;
                  ELSIF rw_crapvri.cdvencto >= 220  THEN
                    vr_cddesemp := 03;
                  ELSIF rw_crapvri.cdvencto >= 210  THEN
                    vr_cddesemp := 02;
                  ELSIF rw_crapvri.cdvencto >= 205  THEN
                    vr_cddesemp := 01;
                  ELSE
                    IF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr = 0 OR vr_tab_crapris_temp(vr_indice_temp).cdmodali = 1901  THEN
                      vr_cddesemp := 01;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr <= 30  THEN
                      vr_cddesemp := 02;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr <= 60  THEN
                      vr_cddesemp := 03;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr <= 90  THEN
                      vr_cddesemp := 04;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr > 90  THEN
                      vr_cddesemp := 05;
                    END IF;
                    -- Prejuizo 
                    IF vr_tab_crapris_temp(vr_indice_temp).innivris = 10  THEN
                      vr_cddesemp := 06;
                    END IF;
                  END IF;
                END IF;
                CLOSE cr_crapvri;
                                    
                -- Busca a modalidade com base nos emprestimos
                vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                                        ,pr_cdcooper
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrctremp
                                                        ,vr_tab_crapris_temp(vr_indice_temp).inpessoa
                                                        ,vr_tab_crapris_temp(vr_indice_temp).cdorigem
                                                        ,vr_tab_crapris_temp(vr_indice_temp).dsinfaux);
                -- Busca a origem recurso
                vr_dsorgrec := fn_busca_dsorgrec(vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                                ,vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                ,vr_tab_crapris_temp(vr_indice_temp).nrctremp
                                                ,vr_tab_crapris_temp(vr_indice_temp).cdorigem
                                                ,vr_tab_crapris_temp(vr_indice_temp).dsinfaux);                                                                      
                                    
                -- Monta a chave do indice da tabela vr_tab_agreg
                vr_indice_agreg := lpad(vr_cdmodali,5,'0')||
                                   lpad(vr_tab_crapris_temp(vr_indice_temp).innivris,5,'0')||
                                   vr_cddfaixa||
                                   vr_tab_crapris_temp(vr_indice_temp).inpessoa||
                                   lpad(vr_cdnatuop,4,'0')||
                                   lpad(vr_cddesemp,2,'0');
                -- Verifica se o registro nao existe na tabela temporaria, para poder criar
                IF NOT vr_tab_agreg.EXISTS(vr_indice_agreg) THEN
                  vr_tab_agreg(vr_indice_agreg).cdcooper := vr_tab_crapris_temp(vr_indice_temp).cdcooper;
                  vr_tab_agreg(vr_indice_agreg).nrdconta := vr_tab_crapris_temp(vr_indice_temp).nrdconta;
                  vr_tab_agreg(vr_indice_agreg).innivris := vr_tab_crapris_temp(vr_indice_temp).innivris;
                  vr_tab_agreg(vr_indice_agreg).inpessoa := vr_tab_crapris_temp(vr_indice_temp).inpessoa;
                  vr_tab_agreg(vr_indice_agreg).cdorigem := vr_tab_crapris_temp(vr_indice_temp).cdorigem;
                  vr_tab_agreg(vr_indice_agreg).cdmodali := vr_cdmodali;
                  vr_tab_agreg(vr_indice_agreg).nrctremp := vr_tab_crapris_temp(vr_indice_temp).nrctremp;
                  vr_tab_agreg(vr_indice_agreg).nrseqctr := vr_tab_crapris_temp(vr_indice_temp).nrseqctr;
                  vr_tab_agreg(vr_indice_agreg).vldivida := vr_tab_crapris_temp(vr_indice_temp).vldivida;
                  vr_tab_agreg(vr_indice_agreg).dtinictr := vr_tab_crapris_temp(vr_indice_temp).dtinictr;
                  vr_tab_agreg(vr_indice_agreg).vljura60 := vr_tab_crapris_temp(vr_indice_temp).vljura60;
                  vr_tab_agreg(vr_indice_agreg).nrcpfcgc := vr_cpf;
                  vr_tab_agreg(vr_indice_agreg).nrdocnpj := vr_nrdocnpj;
                  vr_tab_agreg(vr_indice_agreg).cddfaixa := vr_cddfaixa;
                  vr_tab_agreg(vr_indice_agreg).qtoperac := 1;
                  vr_tab_agreg(vr_indice_agreg).qtcooper := 1;
                  vr_tab_agreg(vr_indice_agreg).cddesemp := vr_cddesemp;
                  vr_tab_agreg(vr_indice_agreg).cdnatuop := vr_cdnatuop;
                  vr_tab_agreg(vr_indice_agreg).inddocto := vr_tab_crapris_temp(vr_indice_temp).inddocto;
                  vr_tab_agreg(vr_indice_agreg).dsinfaux := vr_tab_crapris_temp(vr_indice_temp).dsinfaux;
                ELSE
                  -- Atualizar somente se o cpf for diferente
                  IF vr_tab_agreg(vr_indice_agreg).nrcpfcgc <> vr_cpf THEN
                    vr_tab_agreg(vr_indice_agreg).qtcooper := vr_tab_agreg(vr_indice_agreg).qtcooper + 1;
                  END IF;
                  vr_tab_agreg(vr_indice_agreg).vldivida := vr_tab_agreg(vr_indice_agreg).vldivida + vr_tab_crapris_temp(vr_indice_temp).vldivida;
                  vr_tab_agreg(vr_indice_agreg).vljura60 := vr_tab_agreg(vr_indice_agreg).vljura60 + vr_tab_crapris_temp(vr_indice_temp).vljura60;
                  vr_tab_agreg(vr_indice_agreg).qtoperac := vr_tab_agreg(vr_indice_agreg).qtoperac + 1;
                END IF;
                -- efetua loop sobre os vencimentos do risco
                FOR rw_crapvri_venct IN cr_crapvri_venct(vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                        ,vr_dtrefere
                                                        ,vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrctremp) LOOP
                  -- Monta o indice para a pesquisa
                  vr_indice_venc_agreg := lpad(vr_cdmodali,5,'0')
                                       || lpad(vr_tab_crapris_temp(vr_indice_temp).innivris,5,'0')
                                       || vr_cddfaixa
                                       || vr_tab_crapris_temp(vr_indice_temp).inpessoa
                                       || lpad(vr_cdnatuop,4,'0')
                                       || lpad(vr_cddesemp,2,'0')
                                       || lpad(rw_crapvri_venct.cdvencto,5,'0');
                  -- Verifica se nao existe o registro. Se nao existir ira criar
                  IF NOT vr_tab_venc_agreg.EXISTS(vr_indice_venc_agreg) THEN
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali := vr_cdmodali;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).innivris := vr_tab_crapris_temp(vr_indice_temp).innivris;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa := vr_cddfaixa;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa := vr_tab_crapris_temp(vr_indice_temp).inpessoa;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto := rw_crapvri_venct.cdvencto;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida := rw_crapvri_venct.vldivida;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp := vr_cddesemp;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop := vr_cdnatuop;
                  ELSE
                    vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida := vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida + rw_crapvri_venct.vldivida;
                  END IF;
                END LOOP;
                --Encontrar o proximo registro da tabela de memoria
                vr_indice_temp := vr_tab_crapris_temp.next(vr_indice_temp);
              END LOOP; -- Loop sobre a vr_tab_crapris_temp
            ELSE
              --Acessar primeiro registro da tabela de memoria
              vr_indice_copy := vr_tab_individ_copy.FIRST;
              -- Varre a tabela de memoria vr_tab_crapris
              WHILE vr_indice_copy IS NOT NULL LOOP
                -- Recriar o indice
                vr_vlcont_copy := vr_vlcont_copy + 1;
                vr_idx_individ := lpad(vr_tab_individ_copy(vr_indice_copy).nrcpfcgc,14,'0')
                            || lpad(vr_tab_individ_copy(vr_indice_copy).nrctremp,10,'0') 
                            || lpad(vr_vlcont_copy,10,'0');
                -- Copiar o registro novo 
                vr_tab_individ(vr_idx_individ) := vr_tab_individ_copy(vr_indice_copy);
                -- Vai para o proximo registro
                vr_indice_copy := vr_tab_individ_copy.next(vr_indice_copy);
              END LOOP;
            END IF; -- Final do flgindiv = 0
            --limpeza das tabelas temporarias
            vr_tab_individ_copy.delete;
            vr_tab_crapris_temp.delete;
          END IF; -- Final do if de verificacao de CNPJ / CPF diferente do proximo
          --Encontrar o proximo registro da tabela de memoria
          vr_indice_ris := vr_tab_ris.next(vr_indice_ris);
        END LOOP; -- fim do loop sobre a tabela de memoria vr_tab_crapris
      END;
    
      -- Carrega a temp-table vr_tab_saida com base na tabela CRAPRIS
      PROCEDURE pc_carrega_base_saida(pr_dtrefere DATE) IS

        -- Descricao dos bens da proposta de emprestimo do cooperado.
        CURSOR cr_crapris_renegociacao(pr_cdcooper crapris.cdcooper%TYPE,
                                       pr_nrdconta crapris.nrdconta%TYPE,
                                       pr_nrctremp crapris.nrctremp%TYPE,
                                       pr_dtrefere crapris.dtrefere%TYPE) IS
          SELECT cdmodali,
                 dsinfaux
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND dtrefere = pr_dtrefere
             AND cdorigem = 3
             AND inddocto = 1
             AND rownum   = 1;
        rw_crapris_renegociacao cr_crapris_renegociacao%ROWTYPE;
        
        -- Cursor sobre a tabela de risco com modalidade diferente de 301
        CURSOR cr_crapris IS
          SELECT nrdconta,
                 dtrefere,
                 innivris,
                 qtdiaatr,
                 vldivida,
                 vlvec180,
                 vlvec360,
                 vlvec999,
                 vldiv060,
                 vldiv180,
                 vldiv360,
                 vldiv999,
                 vlprjano,
                 vlprjaan,
                 inpessoa,
                 nrcpfcgc,
                 vlprjant,
                 inddocto,
                 cdmodali,
                 nrctremp,
                 nrseqctr,
                 dtinictr,
                 cdorigem,
                 cdagenci,
                 innivori,
                 cdcooper,
                 vlprjm60,
                 dtdrisco,
                 qtdriclq,
                 nrdgrupo,
                 vljura60,
                 inindris,
                 cdinfadi,
                 nrctrnov,
                 flgindiv,
                 DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)) sbcpfcgc,
                 dsinfaux,
                 dtprxpar,
                 vlprxpar,
                 qtparcel,
                 dtvencop,
                 ROW_NUMBER () OVER (PARTITION BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)) ORDER BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8))) nrseq,
                 COUNT(1)      OVER (PARTITION BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)) ORDER BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8))) qtreg
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = pr_dtrefere
             AND inddocto IN(2,5) -- Saida ou Garantias Prestadas com Saida
             AND nvl(cdinfadi,' ') <> ' '
             AND cdmodali <> 0301; -- Dsc Tit

        -- Cursor sobre a tabela de risco com modalidade igual a 301
        CURSOR cr_crapris_dsctit IS
          SELECT nrdconta,
                 dtrefere,
                 innivris,
                 qtdiaatr,
                 vldivida,
                 vlvec180,
                 vlvec360,
                 vlvec999,
                 vldiv060,
                 vldiv180,
                 vldiv360,
                 vldiv999,
                 vlprjano,
                 vlprjaan,
                 inpessoa,
                 nrcpfcgc,
                 vlprjant,
                 inddocto,
                 cdmodali,
                 nrctremp,
                 nrseqctr,
                 dtinictr,
                 cdorigem,
                 cdagenci,
                 innivori,
                 cdcooper,
                 vlprjm60,
                 dtdrisco,
                 qtdriclq,
                 nrdgrupo,
                 vljura60,
                 inindris,
                 cdinfadi,
                 nrctrnov,
                 flgindiv,
                 dsinfaux,
                 DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)) sbcpfcgc,
                 dtprxpar,
                 vlprxpar,
                 qtparcel,
                 dtvencop,
                 ROW_NUMBER () OVER (PARTITION BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)),nrdconta,nrctremp ORDER BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)),nrdconta,nrctremp) nrseq,
                 COUNT(1)      OVER (PARTITION BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)),nrdconta,nrctremp ORDER BY DECODE(inpessoa,1,SUBSTR(lpad(nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(nrcpfcgc,14,'0'),1,8)),nrdconta,nrctremp) qtreg
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = pr_dtrefere
             AND inddocto = 2
             AND cdmodali = 0301 -- Dsc Tit 
             AND cdorigem IN(4,5);       /* Desconto Titulos */

      BEGIN

        -- leitura sobre a tabela de riscos onde a modalidade for diferente de 301
        FOR rw_crapris IN cr_crapris LOOP
          -- copia os dados do cursor para a tabela temporaria
          vr_vlcont_crapris := vr_vlcont_crapris + 1;
          vr_indice_crapris := lpad(rw_crapris.nrcpfcgc,14,'0')||lpad(rw_crapris.nrctremp,10,'0')||lpad(vr_vlcont_crapris,10,'0');
          vr_tab_saida(vr_indice_crapris).nrdconta := rw_crapris.nrdconta;
          vr_tab_saida(vr_indice_crapris).dtrefere := rw_crapris.dtrefere;
          vr_tab_saida(vr_indice_crapris).innivris := rw_crapris.innivris;
          vr_tab_saida(vr_indice_crapris).qtdiaatr := rw_crapris.qtdiaatr;
          vr_tab_saida(vr_indice_crapris).vldivida := rw_crapris.vldivida;
          vr_tab_saida(vr_indice_crapris).vlvec180 := rw_crapris.vlvec180;
          vr_tab_saida(vr_indice_crapris).vlvec360 := rw_crapris.vlvec360;
          vr_tab_saida(vr_indice_crapris).vlvec999 := rw_crapris.vlvec999;
          vr_tab_saida(vr_indice_crapris).vldiv060 := rw_crapris.vldiv060;
          vr_tab_saida(vr_indice_crapris).vldiv180 := rw_crapris.vldiv180;
          vr_tab_saida(vr_indice_crapris).vldiv360 := rw_crapris.vldiv360;
          vr_tab_saida(vr_indice_crapris).vldiv999 := rw_crapris.vldiv999;
          vr_tab_saida(vr_indice_crapris).vlprjano := rw_crapris.vlprjano;
          vr_tab_saida(vr_indice_crapris).vlprjaan := rw_crapris.vlprjaan;
          vr_tab_saida(vr_indice_crapris).inpessoa := rw_crapris.inpessoa;
          vr_tab_saida(vr_indice_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
          vr_tab_saida(vr_indice_crapris).vlprjant := rw_crapris.vlprjant;
          vr_tab_saida(vr_indice_crapris).inddocto := rw_crapris.inddocto;
          vr_tab_saida(vr_indice_crapris).cdmodali := rw_crapris.cdmodali;
          vr_tab_saida(vr_indice_crapris).nrctremp := rw_crapris.nrctremp;
          vr_tab_saida(vr_indice_crapris).nrseqctr := rw_crapris.nrseqctr;
          vr_tab_saida(vr_indice_crapris).dtinictr := rw_crapris.dtinictr;
          vr_tab_saida(vr_indice_crapris).cdorigem := rw_crapris.cdorigem;
          vr_tab_saida(vr_indice_crapris).cdagenci := rw_crapris.cdagenci;
          vr_tab_saida(vr_indice_crapris).innivori := rw_crapris.innivori;
          vr_tab_saida(vr_indice_crapris).cdcooper := rw_crapris.cdcooper;
          vr_tab_saida(vr_indice_crapris).vlprjm60 := rw_crapris.vlprjm60;
          vr_tab_saida(vr_indice_crapris).dtdrisco := rw_crapris.dtdrisco;
          vr_tab_saida(vr_indice_crapris).qtdriclq := rw_crapris.qtdriclq;
          vr_tab_saida(vr_indice_crapris).nrdgrupo := rw_crapris.nrdgrupo;
          vr_tab_saida(vr_indice_crapris).vljura60 := rw_crapris.vljura60;
          vr_tab_saida(vr_indice_crapris).inindris := rw_crapris.inindris;
          vr_tab_saida(vr_indice_crapris).cdinfadi := rw_crapris.cdinfadi;
          vr_tab_saida(vr_indice_crapris).nrctrnov := rw_crapris.nrctrnov;
          vr_tab_saida(vr_indice_crapris).flgindiv := rw_crapris.flgindiv;
          vr_tab_saida(vr_indice_crapris).dsinfaux := rw_crapris.dsinfaux;
          vr_tab_saida(vr_indice_crapris).dtprxpar := rw_crapris.dtprxpar;
          vr_tab_saida(vr_indice_crapris).vlprxpar := rw_crapris.vlprxpar;
          vr_tab_saida(vr_indice_crapris).qtparcel := rw_crapris.qtparcel;
          vr_tab_saida(vr_indice_crapris).sbcpfcgc := rw_crapris.sbcpfcgc;
          vr_tab_saida(vr_indice_crapris).dtvencop := rw_crapris.dtvencop;
          
          -- Vamos verificar se o contrato é de renegociacao
          IF vr_tab_saida(vr_indice_crapris).nrctrnov > 0 THEN
            -- Busca as informacoes do novo contrato
            OPEN cr_crapris_renegociacao(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => vr_tab_saida(vr_indice_crapris).nrdconta
                                        ,pr_nrctremp => vr_tab_saida(vr_indice_crapris).nrctrnov
                                        ,pr_dtrefere => vr_tab_saida(vr_indice_crapris).dtrefere);
            FETCH cr_crapris_renegociacao INTO rw_crapris_renegociacao;
            IF cr_crapris_renegociacao%FOUND THEN
              CLOSE cr_crapris_renegociacao;
              vr_tab_saida(vr_indice_crapris).cdmodnov := rw_crapris_renegociacao.cdmodali;
              vr_tab_saida(vr_indice_crapris).dsinfnov := rw_crapris_renegociacao.dsinfaux;
            ELSE
              CLOSE cr_crapris_renegociacao;
            END IF;  
          END IF;
          
        END LOOP;

        vr_vldivida_0301 := 0;

        -- leitura sobre a tabela de riscos onde a modalidade for igual a 301
        FOR rw_crapris IN cr_crapris_dsctit LOOP
          vr_vldivida_0301 := vr_vldivida_0301 + rw_crapris.vldivida;
          -- Se for o ultimo registro com base na conta e numero do contrato, insere na tabela temporaria
          IF rw_crapris.nrseq = rw_crapris.qtreg THEN
            vr_vlcont_crapris := vr_vlcont_crapris + 1;
            vr_indice_crapris := lpad(rw_crapris.nrcpfcgc,14,'0')||lpad(rw_crapris.nrctremp,10,'0')||lpad(vr_vlcont_crapris,10,'0');
            vr_tab_saida(vr_indice_crapris).nrdconta := rw_crapris.nrdconta;
            vr_tab_saida(vr_indice_crapris).dtrefere := rw_crapris.dtrefere;
            vr_tab_saida(vr_indice_crapris).innivris := rw_crapris.innivris;
            vr_tab_saida(vr_indice_crapris).qtdiaatr := rw_crapris.qtdiaatr;
            vr_tab_saida(vr_indice_crapris).vldivida := vr_vldivida_0301;
            vr_tab_saida(vr_indice_crapris).vlvec180 := rw_crapris.vlvec180;
            vr_tab_saida(vr_indice_crapris).vlvec360 := rw_crapris.vlvec360;
            vr_tab_saida(vr_indice_crapris).vlvec999 := rw_crapris.vlvec999;
            vr_tab_saida(vr_indice_crapris).vldiv060 := rw_crapris.vldiv060;
            vr_tab_saida(vr_indice_crapris).vldiv180 := rw_crapris.vldiv180;
            vr_tab_saida(vr_indice_crapris).vldiv360 := rw_crapris.vldiv360;
            vr_tab_saida(vr_indice_crapris).vldiv999 := rw_crapris.vldiv999;
            vr_tab_saida(vr_indice_crapris).vlprjano := rw_crapris.vlprjano;
            vr_tab_saida(vr_indice_crapris).vlprjaan := rw_crapris.vlprjaan;
            vr_tab_saida(vr_indice_crapris).inpessoa := rw_crapris.inpessoa;
            vr_tab_saida(vr_indice_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
            vr_tab_saida(vr_indice_crapris).vlprjant := rw_crapris.vlprjant;
            vr_tab_saida(vr_indice_crapris).inddocto := rw_crapris.inddocto;
            vr_tab_saida(vr_indice_crapris).cdmodali := rw_crapris.cdmodali;
            vr_tab_saida(vr_indice_crapris).nrctremp := rw_crapris.nrctremp;
            vr_tab_saida(vr_indice_crapris).nrseqctr := rw_crapris.nrseqctr;
            vr_tab_saida(vr_indice_crapris).dtinictr := rw_crapris.dtinictr;
            vr_tab_saida(vr_indice_crapris).cdorigem := rw_crapris.cdorigem;
            vr_tab_saida(vr_indice_crapris).cdagenci := rw_crapris.cdagenci;
            vr_tab_saida(vr_indice_crapris).innivori := rw_crapris.innivori;
            vr_tab_saida(vr_indice_crapris).cdcooper := rw_crapris.cdcooper;
            vr_tab_saida(vr_indice_crapris).vlprjm60 := rw_crapris.vlprjm60;
            vr_tab_saida(vr_indice_crapris).dtdrisco := rw_crapris.dtdrisco;
            vr_tab_saida(vr_indice_crapris).qtdriclq := rw_crapris.qtdriclq;
            vr_tab_saida(vr_indice_crapris).nrdgrupo := rw_crapris.nrdgrupo;
            vr_tab_saida(vr_indice_crapris).vljura60 := rw_crapris.vljura60;
            vr_tab_saida(vr_indice_crapris).inindris := rw_crapris.inindris;
            vr_tab_saida(vr_indice_crapris).cdinfadi := rw_crapris.cdinfadi;
            vr_tab_saida(vr_indice_crapris).nrctrnov := rw_crapris.nrctrnov;
            vr_tab_saida(vr_indice_crapris).flgindiv := rw_crapris.flgindiv;
            vr_tab_saida(vr_indice_crapris).dsinfaux := rw_crapris.dsinfaux;
            vr_tab_saida(vr_indice_crapris).dtprxpar := rw_crapris.dtprxpar;
            vr_tab_saida(vr_indice_crapris).vlprxpar := rw_crapris.vlprxpar;
            vr_tab_saida(vr_indice_crapris).qtparcel := rw_crapris.qtparcel;            
            vr_tab_saida(vr_indice_crapris).sbcpfcgc := rw_crapris.sbcpfcgc;
            vr_tab_saida(vr_indice_crapris).dtvencop := rw_crapris.dtvencop;
            -- Zera variavel acumulativa
            vr_vldivida_0301 := 0;
          END IF;
        END LOOP;
      END pc_carrega_base_saida;

      -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
      FUNCTION fn_classifica_risco(pr_innivris in number) RETURN VARCHAR2 IS
      BEGIN
        CASE pr_innivris 
          WHEN 1 THEN
            RETURN 'AA';
          WHEN 2 THEN
            RETURN 'A';
          WHEN 3 THEN
            RETURN 'B';
          WHEN 4 THEN
            RETURN 'C';
          WHEN 5 THEN
            RETURN 'D';
          WHEN 6 THEN
            RETURN 'E';
          WHEN 7 THEN
            RETURN 'F';
          WHEN 8 THEN
            RETURN 'G';
          WHEN 9 THEN
            RETURN 'H';
          ELSE
            RETURN 'HH';
        END CASE;
      END fn_classifica_risco;

      -- Com base nos emprestimos / linhas de credito / linhas de desconto eh buscado a taxa efetiva anual
      FUNCTION fn_busca_taxeft(pr_cdmodali IN PLS_INTEGER
                              ,pr_nrdconta IN craplim.nrdconta%TYPE
                              ,pr_nrctremp IN crapvri.nrctremp%TYPE
                              ,pr_inddocto in crapris.inddocto%TYPE
                              ,pr_inpessoa IN crapris.inpessoa%TYPE
                              ,pr_dsinfaux IN crapris.dsinfaux%TYPE
                              ,pr_cdorigem IN crapris.cdorigem%TYPE) RETURN NUMBER IS

        -- Cursor sobre a tabela de linhas de credito rotativo
        CURSOR cr_craplrt (pr_inpessoa crapass.inpessoa%TYPE,
                           pr_cddlinha craplim.cddlinha%TYPE) IS
          SELECT txmensal
            FROM craplrt
           WHERE craplrt.cdcooper = pr_cdcooper
             AND craplrt.tpdlinha = pr_inpessoa
             AND craplrt.cddlinha = pr_cddlinha;
        rw_craplrt cr_craplrt%ROWTYPE;

        -- Cursor sobre a tabela de linhas de desconto
        CURSOR cr_crapldc (pr_cddlinha craplim.cddlinha%TYPE,
                           pr_tpdescto crapldc.tpdescto%TYPE) IS
          SELECT txjurmor
            FROM crapldc
           WHERE crapldc.cdcooper = pr_cdcooper
             AND crapldc.cddlinha = pr_cddlinha
             AND crapldc.tpdescto = pr_tpdescto;
        rw_crapldc cr_crapldc%ROWTYPE;
        
        -- Armazenamento da taxa
        vr_txeanual NUMBER(10,4) := 0;
        
        -- Tipo de contrato de limite para busca
        vr_tpctrlim craplim.tpctrlim%TYPE;
      BEGIN
        -- Para Garantias Prestadas
        IF pr_inddocto = 5 THEN 
          -- Buscar a taxa no cadastro do movimento
          IF vr_tab_mvto_garant_prest.exists(pr_dsinfaux) THEN 
            vr_txeanual := vr_tab_mvto_garant_prest(pr_dsinfaux).vltaxajr;
          END IF;
        -- Para cartões BB e Bancoob
        ELSIF pr_inddocto = 4 THEN
          -- Buscar taxa conforme cartão
          vr_ind_crd  := LPAD(pr_nrdconta,10,'0') || LPAD(pr_nrctremp,10,'0');
          IF vr_tab_tbcrd_risco.exists(vr_ind_crd) THEN 
            IF vr_tab_tbcrd_risco(vr_ind_crd).cdtipcar = 1 THEN
              vr_txeanual := vr_vltxban;
            ELSIF vr_tab_tbcrd_risco(vr_ind_crd).cdtipcar = 2 THEN 
              vr_txeanual := vr_vltxabb;
            ELSE 
              vr_txeanual := 0;
            END IF;
          ELSE 
            vr_txeanual := 0;
          END IF;
        -- Para Cheque especial e Limite não utilizado 
        ELSIF pr_cdmodali IN(0201,1901,0302,0301) THEN
          -- PAra Cheq Esp e Limite não Utilizado, já temos o contrato
          IF pr_cdmodali IN(0201,1901) THEN
            vr_nrctrlim := pr_nrctremp;
            -- Tipo 1
            vr_tpctrlim := 1;
          ELSE   
            -- Busca o número do contrato de limite de credito pelo Borderô
            vr_nrctrlim := 0;
            -- Buscar tabela de borderô conforme o tipo
            IF pr_cdmodali = 0302 THEN
              OPEN cr_crapbdc (pr_nrdconta => pr_nrdconta
                              ,pr_nrborder => pr_nrctremp);
              FETCH cr_crapbdc
               INTO vr_nrctrlim;
              CLOSE cr_crapbdc;
              -- Tipo 2
              vr_tpctrlim := 2;
            ELSE
              OPEN cr_crapbdt (pr_nrdconta => pr_nrdconta
                              ,pr_nrborder => pr_nrctremp);
              FETCH cr_crapbdt
               INTO vr_nrctrlim;
              CLOSE cr_crapbdt; 
              -- Tipo 3
              vr_tpctrlim := 3;
            END IF;  
          END IF;  
          -- Somente Se encontrou contrato de limite
          IF vr_nrctrlim <> 0 THEN
            -- busca sobre a tabela de limite de credito
            OPEN cr_craplim(pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => vr_nrctrlim
                           ,pr_tpctrlim => vr_tpctrlim);
            FETCH cr_craplim INTO rw_craplim;
            IF cr_craplim%FOUND THEN
              -- Para Cheque Especial e Limite não Utilizado
              IF pr_cdmodali IN(0201,1901) THEN
                -- busca sobre a tabela de linhas de credito rotativo
                OPEN cr_craplrt(pr_inpessoa, rw_craplim.cddlinha );
                FETCH cr_craplrt INTO rw_craplrt;
                IF cr_craplrt%FOUND THEN
                  vr_txeanual := ROUND((POWER(1 + (rw_craplrt.txmensal / 100),12) - 1) * 100,2);
                ELSE
                  vr_txeanual := 0;
                END IF;
                CLOSE cr_craplrt;
              -- PAra descontos de Cheque e Titulos
              ELSE
                vr_vlrctado := rw_craplim.vllimite;
                -- Taxa Efetiva Anual conforme tipo de desconto
                IF pr_cdmodali = 0302 THEN
                  -- Tipo de desconto = 2
                  OPEN cr_crapldc(rw_craplim.cddlinha,2);
                ELSE
                  -- Tipo de desconto = 3
                  OPEN cr_crapldc(rw_craplim.cddlinha,3);
                END IF;  
                FETCH cr_crapldc INTO rw_crapldc;
                IF cr_crapldc%FOUND THEN
                  vr_txeanual := ROUND((POWER(1 + (rw_crapldc.txjurmor / 100),12) - 1) * 100,2);
                ELSE
                  vr_txeanual := 0;
                END IF;
                CLOSE cr_crapldc;
              END IF;  
            ELSE
              vr_txeanual := 0;
            END IF;
            CLOSE cr_craplim;
          ELSE
            vr_txeanual := 0;
          END IF; 
        -- 0299 - Emprest / 0499 - Financ  com origem 3
        ELSIF pr_cdmodali IN(0299,0499) AND pr_cdorigem = 3 THEN
          -- Busca sobre o cadastro de emprestimo do bndes
          IF pr_dsinfaux = 'BNDES' THEN         
            vr_ind_ebn := lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
            vr_txeanual := vr_tab_crapebn(vr_ind_ebn).txefeanu;
          ELSE
            -- busca sobre o cadastro de emprestimos
            vr_ind_epr := lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
            -- Buscaremos a taxa de juros da linha de crédito
            IF vr_tab_craplcr.exists(vr_tab_crapepr(vr_ind_epr).cdlcremp) THEN
              -- Usar taxa da linha
              vr_txeanual := ROUND((POWER(1 + (vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).txjurfix /100),12) - 1) * 100,2);
            ELSE
              -- Não há taxa
              vr_txeanual := 0;
            END IF;
          END IF;
        ELSE
          vr_txeanual := 0;
        END IF;
        -- Efetuar o retorno
        RETURN vr_txeanual;
      END fn_busca_taxeft;

      -- Com base nas faixas de vencimento, eh buscado o total da divida
      FUNCTION fn_total_divida(pr_faixasde IN  PLS_INTEGER
                              ,pr_faixapar IN  PLS_INTEGER
                              ,pr_tab_venc IN OUT NOCOPY typ_tab_venc) RETURN NUMBER IS
         -- Variavel para o indice
         vr_indice_venc_prm PLS_INTEGER;
         -- Total a acumular
         vr_ttldivid NUMBER(17,2);      
      BEGIN
        -- Inicializar
        vr_ttldivid := 0;
        -- Leitura da pltable para acumulo conforme faixas enviadas
        vr_indice_venc_prm := pr_tab_venc.first;
        WHILE vr_indice_venc_prm IS NOT NULL LOOP
          IF pr_tab_venc(vr_indice_venc_prm).cdvencto >= pr_faixasde AND pr_tab_venc(vr_indice_venc_prm).cdvencto <= pr_faixapar THEN
            vr_ttldivid := vr_ttldivid + pr_tab_venc(vr_indice_venc_prm).vldivida;
          END IF;
          -- Posicionar no proximo registro
          vr_indice_venc_prm := pr_tab_venc.next(vr_indice_venc_prm);
        END LOOP;
        -- Retornar valor acumulado
        RETURN vr_ttldivid;
      END fn_total_divida;

      -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
      FUNCTION fn_normaliza_juros(pr_ttldivid  IN NUMBER
                                 ,pr_vldivida  IN NUMBER
                                 ,pr_vljura60  IN NUMBER
                                 ,pr_flgtrunc  IN BOOLEAN) RETURN NUMBER IS
        -- Auxiliares ao calculo
        vr_vlacumul NUMBER;
        vr_vlpercen NUMBER(17,10);
      BEGIN
        -- Valor percentual com relação ao total da divida frente ao atual
        vr_vlpercen := pr_vldivida / pr_ttldivid;
        -- Valor total é a relação do percentual pendente * juros
        vr_vlacumul := pr_vldivida - (pr_vljura60 * vr_vlpercen);
        -- Se for para truncar em duas casas decimais no calculo
        if pr_flgtrunc THEN 
          vr_vlacumul := round(round(vr_vlacumul*100,2)/100,2);
        else
          vr_vlacumul := round(vr_vlacumul,2);
        end if;
        -- Retornar o valor calculado
        RETURN vr_vlacumul;
      END fn_normaliza_juros;

      -- Retorna os avalistas dos emprestimos e atualiza o arquivo com os mesmos
      PROCEDURE pc_verifica_garantidores IS
        vr_nrctaav1  crapass.nrdconta%TYPE; -- Avalista 01
        vr_nrctaav2  crapass.nrdconta%TYPE; -- Avalista 02
        vr_cpfcgcav crapass.nrcpfcgc%TYPE; -- Testes no cpgcgc
        vr_vlperbem VARCHAR2(50);           -- Percentual do bem
      BEGIN
        -- Limpar variaveis auxiliares
        vr_nrctaav1 := 0;
        vr_nrctaav2 := 0;
        vr_cpfcgcav := 0;
        vr_vlperbem := '';
        
        -- Busca dos avalistas conforme origem e Modalidade
        -- Para Origem 1 - Conta e Modalidade 2012 - Cheque Especial ou 1901 - Limite não Utilizado
        IF vr_tab_individ(vr_idx_individ).cdorigem = 1 AND vr_tab_individ(vr_idx_individ).cdmodali in(0201,1901) THEN 
          -- Busca os dados do limite de credito
          OPEN cr_craplim(vr_tab_individ(vr_idx_individ).nrdconta,
                          vr_tab_individ(vr_idx_individ).nrctremp,
                          1);
          FETCH cr_craplim INTO rw_craplim;
          IF cr_craplim%FOUND THEN
            vr_nrctaav1 := rw_craplim.nrctaav1;
            vr_nrctaav2 := rw_craplim.nrctaav2;
          END IF;
          CLOSE cr_craplim;
        -- Origem 2 - Desconto Cheques
        ELSIF vr_tab_individ(vr_idx_individ).cdorigem = 2  THEN 
          -- Busca o número do contrato de limite de credito pelo Borderô
          OPEN cr_crapbdc (pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                          ,pr_nrborder => vr_tab_individ(vr_idx_individ).nrctremp);
          FETCH cr_crapbdc
           INTO vr_nrctrlim;
          -- Somente Se encontrar
          IF cr_crapbdc%FOUND THEN
            -- Então com o contrato de limite, buscar os avalistas
            OPEN cr_craplim(pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                           ,pr_nrctremp => vr_nrctrlim
                           ,pr_tpctrlim => 2);
            FETCH cr_craplim INTO rw_craplim;
            IF cr_craplim%FOUND THEN
              vr_nrctaav1 := rw_craplim.nrctaav1;
              vr_nrctaav2 := rw_craplim.nrctaav2;
            END IF;
            CLOSE cr_craplim;
          END IF;
          CLOSE cr_crapbdc;  
        -- Origem 3 - Emprestimos/Financiamentos
        ELSIF vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN 
          -- Se empréstimo for do BNDES
          IF vr_tab_individ(vr_idx_individ).dsinfaux = 'BNDES' THEN
            -- Descricao dos bens da proposta de emprestimo do cooperado.
            vr_ind_ebn := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0') ||
                          lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
            -- Busca a descricao dos bens da proposta de emprestimo
            OPEN cr_crapbpr(vr_tab_individ(vr_idx_individ).nrdconta,
                            vr_tab_individ(vr_idx_individ).nrctremp,
                            95,
                            1); -- Ordenacao ascendente

            FETCH cr_crapbpr INTO rw_crapbpr;
            IF cr_crapbpr%FOUND THEN
              CLOSE cr_crapbpr;

              vr_nrdocnpj := rw_crapbpr.nrcpfbem;
              vr_vlperbem := rw_crapbpr.vlperbem;

              --Validar o cpf/cnpj
              gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrdocnpj
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_inpessoa => vr_inpessoa);

              IF vr_inpessoa = 1 THEN
                vr_nrdocnpj := to_char(rw_crapbpr.nrcpfbem,'fm00000000000');
              ELSE
                vr_nrdocnpj := to_char(rw_crapbpr.nrcpfbem,'fm00000000000000');
              END IF;
                
              -- Enviar Garantidor
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '            <Gar Tp="09' || to_char(vr_inpessoa,'fm00') 
                                                        || '" Ident="' || vr_nrdocnpj 
                                                        || '" PercGar="'
                                                        ||  vr_vlperbem || '"/>' || chr(10));

              -- Descricao dos bens da proposta de emprestimo do cooperado.
              OPEN cr_crapbpr(vr_tab_individ(vr_idx_individ).nrdconta,
                              vr_tab_individ(vr_idx_individ).nrctremp,
                              95,
                              0);  -- Ordenacao descendente
              FETCH cr_crapbpr INTO rw_crapbpr;
              CLOSE cr_crapbpr;
              vr_nrdocnpj2 := rw_crapbpr.nrcpfbem;
              vr_vlperbem  := rw_crapbpr.vlperbem;

              --Validar o cpf/cnpj
              gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrdocnpj2
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_inpessoa => vr_inpessoa);

              IF vr_inpessoa = 1 THEN
                vr_nrdocnpj2 := to_char(rw_crapbpr.nrcpfbem,'fm00000000000');
              ELSE
                vr_nrdocnpj2 := to_char(rw_crapbpr.nrcpfbem,'fm00000000000000');
              END IF;

              IF vr_nrdocnpj <> vr_nrdocnpj2 THEN
                -- Enviar garantidor
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => '            <Gar Tp="09' ||to_char(vr_inpessoa,'fm00')
                                                          || '" Ident="' || vr_nrdocnpj2 
                                                          || '" PercGar="' 
                                                          || vr_vlperbem ||'"/>' ||chr(10));
              END IF;
            END IF; --cr_crapbpr%FOUND
            -- Se o cursor ainda estiver aberto, fecha o mesmo
            IF cr_crapbpr%ISOPEN THEN
              CLOSE cr_crapbpr;
            END IF;
          ELSE
            -- Buscaremos do cadastro de empréstimos
            vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')||
                        lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
            vr_nrctaav1 := vr_tab_crapepr(vr_ind_epr).nrctaav1;
            vr_nrctaav2 := vr_tab_crapepr(vr_ind_epr).nrctaav2;
          END IF; -- Se BNDES
        -- Desconto Titulos
        ELSIF vr_tab_individ(vr_idx_individ).cdorigem = 4  THEN    
          -- Busca o número do contrato de limite de credito pelo Borderô
          OPEN cr_crapbdt (pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                          ,pr_nrborder => vr_tab_individ(vr_idx_individ).nrctremp);
          FETCH cr_crapbdt
           INTO vr_nrctrlim;
          -- Somente Se encontrar
          IF cr_crapbdt%FOUND THEN
            -- Então com o contrato de limite, buscar os avalistas
            OPEN cr_craplim(pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                           ,pr_nrctremp => vr_nrctrlim
                           ,pr_tpctrlim => 3);
            FETCH cr_craplim INTO rw_craplim;
            IF cr_craplim%FOUND THEN
              vr_nrctaav1 := rw_craplim.nrctaav1;
              vr_nrctaav2 := rw_craplim.nrctaav2;
            END IF;
            CLOSE cr_craplim;
          END IF;
          CLOSE cr_crapbdt;          
        END IF;
        
        -- Se encontrou avalista 1
        IF  vr_nrctaav1 <> 0 THEN
          -- Busca seu cadastro de associado
          OPEN cr_crapass(vr_nrctaav1);
          FETCH cr_crapass INTO rw_crapass;
          IF cr_crapass%FOUND THEN
            -- Guardar o CPF/CGC
            vr_cpfcgcav := rw_crapass.nrcpfcgc;
            
            -- Montar cpf/cgc cfme tipo de pessoa
            IF rw_crapass.inpessoa = 1 THEN
              vr_nrdocnpj := to_char(rw_crapass.nrcpfcgc,'fm00000000000');
            ELSE
              vr_nrdocnpj := to_char(rw_crapass.nrcpfcgc,'fm00000000000000');
            END IF;

            --Validar o cpf/cnpj
            gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => rw_crapass.nrcpfcgc
                                        ,pr_stsnrcal => vr_stsnrcal
                                        ,pr_inpessoa => vr_inpessoa);
            
            -- Enviar Garantidor
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                  ,pr_texto_novo     => '            <Gar Tp="09' || to_char(vr_inpessoa,'fm00') 
                                                     || '" Ident="' ||vr_nrdocnpj  
                                                     || '" PercGar="100.00"/>' || chr(10));
          END IF;
          CLOSE cr_crapass;
        END IF;
       
        -- Se existe avalista 2 e for diferente do avalista 1
        IF vr_nrctaav2 <> 0  AND vr_nrctaav2 <> vr_nrctaav1 THEN

          -- Busca seu cadastro de associados
          OPEN cr_crapass(vr_nrctaav2);
          FETCH cr_crapass INTO rw_crapass;
          -- Se encontrou e o CPF/CGC do avalista 1 é diferente deste
          IF cr_crapass%FOUND AND vr_cpfcgcav <> rw_crapass.nrcpfcgc THEN
            
            IF rw_crapass.inpessoa = 1 THEN
              vr_nrdocnpj := to_char(rw_crapass.nrcpfcgc,'fm00000000000');
            ELSE
              vr_nrdocnpj := to_char(rw_crapass.nrcpfcgc,'fm00000000000000');
            END IF;
          
            --Validar o cpf/cnpj
            gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => rw_crapass.nrcpfcgc
                                        ,pr_stsnrcal => vr_stsnrcal
                                        ,pr_inpessoa => vr_inpessoa);
          
            -- Enviar Garantidor
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '            <Gar Tp="09' || to_char(vr_inpessoa,'fm00') 
                                                      || '" Ident="' ||vr_nrdocnpj  
                                                      || '" PercGar="100.00"/>' || chr(10));
          END IF;
          CLOSE cr_crapass;

        END IF;
      END pc_verifica_garantidores;

      -- Busca o tipo de alienacao e atualiza o arquivo com base no tipo
      PROCEDURE pc_garantia_alienacao_fid IS
        -- Tipo do atributo cfme descrição do bem
        vr_tpatribu INTEGER;
      BEGIN

        -- Se emprestimo (0299) ou financiamento (0499).  
        IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499) THEN
          -- Descricao dos bens da proposta de emprestimo do cooperado.
          vr_ind_ebn := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0') ||
                        lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
          IF NOT vr_tab_crapebn.exists(vr_ind_ebn) THEN
            -- Pesquisar os bens alienados dos contratos e caso exista gravar como garantia da operaçao.
            FOR rw_tbepr_bens_hst IN cr_tbepr_bens_hst_2(vr_tab_individ(vr_idx_individ).nrdconta,
                                           vr_tab_individ(vr_idx_individ).nrctremp,
                                                         90,
                                                         vr_dtrefere) LOOP
              -- Realizar de-para da categoria do bem cadastrado no sistema
              --  crapbpr.dscatbem com os codigos de garantias do Bacen. 
              IF rw_tbepr_bens_hst.dscatbem = 'AUTOMOVEL' THEN
                vr_tpatribu := 0424;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'CASA' THEN
                vr_tpatribu := 0426;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'TERRENO' THEN
                vr_tpatribu := 0427;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'MOTO' THEN
                vr_tpatribu := 0424;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'EQUIPAMENTO' THEN
                vr_tpatribu := 0423;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'CAMINHAO' THEN
                vr_tpatribu := 0424;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'APARTAMENTO' THEN
                vr_tpatribu := 0426;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'MAQUINA DE COSTURA' THEN
                vr_tpatribu := 0423;
              ELSE
                vr_tpatribu := 0499;
              END IF;
              -- Enviar Garantidor
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '            <Gar Tp="' || to_char(vr_tpatribu,'fm0000')
                                                        || '" VlrOrig="' ||replace(to_char(rw_tbepr_bens_hst.vlmerbem,'fm99999999999990D00'),',','.') 
                                                        || '"/>' ||CHR(10));
            END LOOP;
          ELSE --cr_crapebn%FOUND
            FOR rw_crapbpr IN cr_crapbpr_3(vr_tab_individ(vr_idx_individ).nrdconta,
                                           vr_tab_individ(vr_idx_individ).nrctremp,
                                           95) LOOP

              IF rw_crapbpr.dscatbem = 'EQUIPAMENTOS' THEN
                vr_tpatribu := 0423;
              ELSIF rw_crapbpr.dscatbem = 'VEICULOS' THEN
                vr_tpatribu := 0424;
              ELSIF rw_crapbpr.dscatbem = 'IMOVEIS RESIDENCIAIS' THEN
                vr_tpatribu := 0426;
              ELSIF rw_crapbpr.dscatbem = 'OUTROS IMOVEIS' THEN
                vr_tpatribu := 0427;
              ELSIF rw_crapbpr.dscatbem = 'OUTROS' THEN
                vr_tpatribu := 0499;
              END IF;
              -- Enviar Garantidor
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '            <Gar Tp="' || to_char(vr_tpatribu,'fm0000')  
                                                        || '" VlrOrig="' || replace(to_char(rw_crapbpr.vlmerbem,'fm999999999999990D00'),',','.') || '"/>' 
                                                        || chr(10));
            END LOOP;
          END IF; --cr_crapebn%notfound
        END IF;
      END pc_garantia_alienacao_fid;


      -- Imprime o tipo informando que eh aplicacao regulatoria, quando o emprestimo possuir linhas de credito
      PROCEDURE pc_inf_aplicacao_regulatoria(pr_nrdconta crapris.nrdconta%TYPE,
                                             pr_nrctremp crapris.nrctremp%TYPE,
                                             pr_cdmodali crapris.cdmodali%TYPE,
                                             pr_cdorigem crapris.cdorigem%TYPE,
                                             pr_dsinfaux crapris.dsinfaux%TYPE) IS
      BEGIN
        -- Para origem 3 - Empr/Financ
        -- E modalidade 0299 - Emprest / 0499 - Financ
        IF pr_cdorigem = 3 AND pr_cdmodali IN(0299,0499) THEN 
          -- Se não for empréstimo BNDES
          IF pr_dsinfaux != 'BNDES' THEN
            -- Busca os dados de emprestimos
            vr_ind_epr := lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
            -- Somente se encontrou linha de credito e origem DIM
            IF vr_tab_craplcr.EXISTS(vr_tab_crapepr(vr_ind_epr).cdlcremp) AND vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).dsorgrec LIKE '%DIM%' THEN
              -- Enviar Informação do Financiamento
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '            <Inf Tp="1408" />' ||chr(10));
            END IF;
          END IF;
        END IF;
      END pc_inf_aplicacao_regulatoria;

      -- Caso o emprestimo for para automovel, moto ou caminhao, imprime o codigo do chassi do mesmo.
      PROCEDURE pc_verifica_inf_chassi(pr_nrdconta crapris.nrdconta%TYPE,
                                       pr_nrctremp crapris.nrctremp%TYPE,
                                       pr_cdmodali crapris.cdmodali%TYPE,
                                       pr_cdorigem crapris.cdorigem%TYPE,
                                       pr_dsinfaux crapris.dsinfaux%TYPE) IS
      BEGIN
        -- Para Emprst ou Financ
        IF pr_cdmodali IN(0299,0499) THEN
          -- Busca a descricao dos bens da proposta de emprestimo
          FOR rw_tbepr_bens_hst IN cr_tbepr_bens_hst_4(pr_nrdconta, pr_nrctremp, 90, vr_dtrefere) LOOP
            IF (rw_tbepr_bens_hst.dschassi <> ' ') AND UPPER(rw_tbepr_bens_hst.dscatbem) IN ('AUTOMOVEL','MOTO','CAMINHAO') THEN
              -- Somente para empréstimo da COOP com origem 3
              IF pr_dsinfaux <> 'BNDES' AND pr_cdorigem = 3 THEN              
                -- Busca o cadastro de emprestimos
                vr_ind_epr := lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
                -- Somente se encontrar Linha de Credito e a linha for Financiamento (Mod=4)
                -- e (Sub=01) Aquis de bens – veic automotores
                IF vr_tab_craplcr.EXISTS(vr_tab_crapepr(vr_ind_epr).cdlcremp) AND vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdmodali = '04' AND vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdsubmod = '01' THEN
                   
                   IF (rw_tbepr_bens_hst.cdsitgrv = 4 AND rw_tbepr_bens_hst.dtdbaixa <= vr_dtrefere ) OR 
                      (rw_tbepr_bens_hst.cdsitgrv = 5 AND rw_tbepr_bens_hst.dtcancel <= vr_dtrefere) THEN
                     /*********************************************************************************
                     ** Alterado o Ident de 1 para 2 conforme solicitação realizada no chamado 541753
                     ** Renato Darosci - Supero
                     ** 24/10/2016
                     *********************************************************************************/
                   
                   	 -- Informação do Empréstimo
                     gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                            ,pr_texto_completo => vr_xml_3040_temp
                                            ,pr_texto_novo     => '            <Inf Tp="0401" Ident="2" />' || chr(10));
                     
                   ELSE
                   
                     IF rw_tbepr_bens_hst.dtmvtolt <= vr_dtrefere THEN
                       -- Informação do Empréstimo
                       gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                              ,pr_texto_completo => vr_xml_3040_temp
                                              ,pr_texto_novo     => '            <Inf Tp="0401" Cd="'  
                                                                 || rw_tbepr_bens_hst.dschassi || '" />' || chr(10));
                     END IF;
                       
                     
                   END IF;
                END IF;
              END IF;  
            END IF;
          END LOOP;
        END IF;
      END pc_verifica_inf_chassi;

      -- Com base na modaliade retorna o Cosif (Plano Contábil das Instituições do Sistema Financeiro Nacional)
      FUNCTION fn_busca_cosif(pr_cdmodali IN VARCHAR2
                             ,pr_inpessoa IN NUMBER
                             ,pr_inddocto IN NUMBER
                             ,pr_dsinfaux IN VARCHAR2) RETURN VARCHAR2 IS
        vr_cdmodali VARCHAR2(4);
      BEGIN
        -- Para Garantia de Operacao
        IF pr_inddocto = 5 THEN
          -- Buscar a Conta COSIF no cadastro do movimento
          IF vr_tab_mvto_garant_prest.exists(pr_dsinfaux) THEN 
            RETURN vr_tab_mvto_garant_prest(pr_dsinfaux).dsccosif;
          END IF;
        ELSE 
          -- Garantir 4 posições
          vr_cdmodali := to_char(pr_cdmodali,'fm0000');
          -- Adiantamento Depositante
          IF vr_cdmodali LIKE '01%' THEN
            RETURN '1611000';
          -- Cheque especial ou Empréstimos
          ELSIF vr_cdmodali LIKE '02%' THEN 
            RETURN '1612000';
          -- Dsc Chq ou Dsc Tit
          ELSIF vr_cdmodali LIKE '03%' THEN
            RETURN '1613000';
          -- Financiamentos 
          ELSIF vr_cdmodali LIKE '04%' THEN
            RETURN '1621000';
          -- Repasse
          ELSIF vr_cdmodali LIKE '14%' THEN
            RETURN '1439000';
          -- Coobrigacao  
          ELSIF vr_cdmodali LIKE '15%' THEN
            RETURN '3013090';  
          -- Limite Não Utilizado PF
          ELSIF pr_cdmodali = 1901 AND pr_inpessoa = 1 THEN
            RETURN '3098620';
          -- Limite Não Utilizado PJ  
          ELSIF pr_cdmodali = 1901 AND pr_inpessoa = 2 THEN
            -- PJ
            RETURN '3098610';
          -- Cessao de credito  
          ELSIF pr_cdmodali = 1301 THEN
            RETURN '1811000';
          END IF;
        END IF;  
        RETURN '';
      END fn_busca_cosif;
      
      -- Incluir informações do fluxo financeiro
      PROCEDURE pc_gera_fluxo_financeiro(pr_nrdconta IN crapris.nrdconta%type
                                        ,pr_dtrefere IN crapris.dtrefere%type
                                        ,pr_innivris IN crapris.innivris%type
                                        ,pr_inddocto IN crapris.inddocto%TYPE
                                        ,pr_cdinfadi IN crapris.cdinfadi%TYPE
                                        ,pr_cdmodali IN crapris.cdmodali%type
                                        ,pr_nrctremp IN crapris.nrctremp%type
                                        ,pr_nrseqctr IN crapris.nrseqctr%type
                                        ,pr_dtprxpar IN crapris.dtprxpar%type
                                        ,pr_vlprxpar IN crapris.vlprxpar%type
                                        ,pr_qtparcel IN crapris.qtparcel%type) IS
        -- Observações: Estes campos compreendem a necessidade da Circular 
        -- 3.649, de 09 de abril de 2014, onde os seguintes atributos referentes 
        -- ao fluxo financeiro esperado da operação de crédito deverão ser preenchidos a 
        -- partir da data-base Agosto/2014:
        --  >> "DtaProxParcela" - data da próxima prestação a vencer;
        --  >> "VlrProxParcela" - valor da próxima prestação a vencer;
        --  >> "QtdParcelas" - quantidade de prestações do contrato
        --  Fica dispensado o preenchimento dos campos para as seguintes submodalidades
        --  >> "0101 - Adiantamentos a depositantes"
        --  >> "0213 – Cheque especial"
        --  >> "0214 – Conta garantida"
        --  >> "0204 - Crédito rotativo vinculado a cartão de crédito"
        --  >> "15xx – Coobrigações"
        --  >> "18xx – Títulos de crédito (fora da carteira classificada)"
        --  >> "19xx – Limite"
        --  >> "20xx - Retenção de risco".
        
        -- Somente trataremos as modalidades Cecred:
        -- >> 302 - Dsc Chq 
        -- >> 301 - Dsc Tit
        -- >> 299 - Empréstimo
        -- >> 499 - Financiamento
        
        -- Busca de vencimentos inferiores a v205, ou seja, pelo menos um a vencer
        CURSOR cr_crapvri_vencer IS
          SELECT count(1)
            FROM crapvri vri
           WHERE vri.cdcooper = pr_cdcooper
             AND vri.nrdconta = pr_nrdconta
             AND vri.dtrefere = pr_dtrefere
             AND vri.innivris = pr_innivris
             AND vri.cdmodali = pr_cdmodali
             AND vri.nrctremp = pr_nrctremp
             AND vri.nrseqctr = pr_nrseqctr
             -- Pelo menos um a vencer
             AND vri.cdvencto < 205;
        vr_qtvencer PLS_INTEGER := 0;
        
        -- Busca de vencimentos de prejuízo
        CURSOR cr_crapvri_prejuz IS
          SELECT 1
            FROM crapvri vri
           WHERE vri.cdcooper = pr_cdcooper
             AND vri.nrdconta = pr_nrdconta
             AND vri.dtrefere = pr_dtrefere
             AND vri.innivris = pr_innivris
             AND vri.cdmodali = pr_cdmodali
             AND vri.nrctremp = pr_nrctremp
             AND vri.nrseqctr = pr_nrseqctr
             -- Somente de prejuizo
             AND vri.cdvencto >= 310 AND vri.cdvencto <= 330;
        vr_inprejuz PLS_INTEGER := 0;
        
      BEGIN
        -- A Circular preve que as informações de Fluxo sejam enviadas somente
        -- a partir de Agostro de 2014
        IF pr_dtrefere < to_date('01/08/2014','dd/mm/yyyy') THEN
          RETURN;
        END IF;
        -- As informações de fluxo financeiro devem ser omitidas quando
        -- a operação possuir informação adicional de saída (indocto = 2)
        IF pr_inddocto = 2 OR (pr_inddocto = 5 AND pr_cdinfadi = '0301' ) THEN
          -- Sair
          RETURN;
        END IF;
        -- Somente contemplaremos as modalides Cecred ou Inddocto=5 onde qualquer modalidade é aceita
        --   >> 302 - Dsc Chq 
        --   >> 301 - Dsc Tit
        --   >> 299 - Empréstimo
        --   >> 499 - Financiamento
        IF pr_cdmodali NOT IN(299,301,302,499) OR pr_inddocto = 5 THEN
          -- Sair
          RETURN;
        END IF;
        -- Validações abaixo não se aplicam a inddocto=5
        IF pr_inddocto <> 5 THEN 
          -- Buscar se a operação possui pelo menos um vertice de vencimento a vencer
          OPEN cr_crapvri_vencer;
          FETCH cr_crapvri_vencer
           INTO vr_qtvencer;
            CLOSE cr_crapvri_vencer;
          -- As informações de Fluxo Financeiro referem-se a parcelas a vencer
          -- e se a operação possuir 0 vencimentos a vencer, não devemos enviá-las
          IF vr_qtvencer = 0 THEN
            -- Sair
            RETURN;
          END IF;
          -- Para Emprst(299) ou Financ(499)
          IF pr_cdmodali IN(299,499) THEN
            -- Tratar § 1º : Os campos não deverão ser preenchidos no caso de 
            -- operações baixadas como prejuízo, e de avais e fianças prestadas ao cliente.
            OPEN cr_crapvri_prejuz;
            FETCH cr_crapvri_prejuz
             INTO vr_inprejuz;
            CLOSE cr_crapvri_prejuz; 
            -- Somente continuar em caso de não houver prejuizo
            IF vr_inprejuz > 0 THEN
              -- Sair
              RETURN;
            END IF;
          END IF;
        END IF;  
        -- Se chegamos até este pont, então todas as condições foram
        -- aceitas e utilizaremos as informações já preenchidas no risco
        -- para enviarmos ao Fluxo Financeiro - Desde que existam
        IF pr_dtprxpar IS NOT NULL AND NVL(pr_vlprxpar,0) > 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => ' DtaProxParcela="' || to_char(pr_dtprxpar,'YYYY-MM-DD')||'"'
                                                    || ' VlrProxParcela="' || replace(to_char(pr_vlprxpar,'fm99999999999999990D00'),',','.')||'"');
        END IF;        
        IF NVL(pr_qtparcel,0) > 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => ' QtdParcelas="' || to_char(pr_qtparcel,'fm9990')||'"');
        END IF;        
      END;
      
      -- Verificação / envio do Ente Consignante
      PROCEDURE pc_inf_ente_consignante(pr_nrdconta IN crapris.nrdconta%type
                                       ,pr_nrctremp IN crapris.nrctremp%type
                                       ,pr_cdmodali IN crapris.cdmodali%type
                                       ,pr_dsinfaux IN crapris.dsinfaux%TYPE) IS
        -- Observações: Informação do ente consignante atrelado à operação de crédito
        --
        --  Atributos de <Inf>: Tp, Ident e Cd.
        --  Onde: 
        --    Tp: tipo da informação adicional – 15XX, onde XX deve ser:
        --        01  público 
        --        02  privado 
        --        03  INSS 
        --
        --    Ident: CNPJ do Ente Consignante (com 14 dígitos).
        --
        --    Cd: Informação de Situação da Operação. Deve ser omitido se a operação
        --        estiver em seu curso normal; e deve ser preenchido com “1” se a 
        --        operação estiver desconsignada.
        -- 
        -- Somente trataremos as modalidades Cecred:
        -- >> 299 - Empréstimo
        -- >> 499 - Financiamento
        
        -- E dentre as mesmas, iremos na linha de crédito para verificar se a 
        -- a mesma é uma linha com consignação em Folha de Pagamento
        
        -- Testar se a linha de crédito do Empréstimo/Financiamento é 
        -- Consignação em Folha de Pagamento e já trazer a empresa
        CURSOR cr_consigna IS
          SELECT decode(emp.nrdocnpj,0,ttl.nrcpfemp,emp.nrdocnpj) nrdocnpj
                ,epr.cdempres
                ,epr.inprejuz
            FROM crapttl ttl
                ,crapemp emp
                ,craplcr lcr
                ,crapepr epr
           WHERE epr.cdcooper = lcr.cdcooper
             AND epr.cdlcremp = lcr.cdlcremp 
             AND epr.cdcooper = emp.cdcooper
             AND epr.cdempres = emp.cdempres
             AND epr.cdcooper = ttl.cdcooper
             AND epr.nrdconta = ttl.nrdconta
             AND ttl.idseqttl = 1 --> Somente o titular
             AND epr.cdcooper = pr_cdcooper
             AND epr.nrdconta = pr_nrdconta
             AND epr.nrctremp = pr_nrctremp 
             AND lcr.tpdescto = 2; --> 2-Consig. Folha
        rw_consigna cr_consigna%ROWTYPE;
        
      BEGIN
        -- Empréstimos BNDES não são contemplados
        IF pr_dsinfaux = 'BNDES' THEN
          RETURN;
        END IF;
        -- Somente contemplaremos as modalides Cecred:
        --   >> 299 - Empréstimo
        --   >> 499 - Financiamento    
        IF pr_cdmodali IN(299,499) THEN
          -- Testar se a linha é de consignação em folha
          -- e quando for, já trazer também os dados da empresa
          OPEN cr_consigna;
          FETCH cr_consigna
           INTO rw_consigna;
          -- Se encontrou, é consignação
          IF cr_consigna%FOUND THEN
            CLOSE cr_consigna;
            -- Para casos de empréstimos em prejuizo
            IF rw_consigna.inprejuz = 1 THEN
              -- Enviavmos a informação adicional com Cd=1, que significa que a operação foi desconsignada
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '            <Inf Tp="1502" Cd="1"/>'|| chr(10));  
            
            ELSE
              -- Devemos enviar a informação adicional com o CNPJ do Ente Consignante
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '            <Inf Tp="1502" Ident="' || SUBSTR(lpad(rw_consigna.nrdocnpj,14,'0'),1,14) || '"/>'|| chr(10));
            END IF;
          ELSE
            CLOSE cr_consigna;
          END IF;
        END IF;
      END;    
      
      -- Com base na modalidade retorna o codigo indexador e o percentual de indexacao
      PROCEDURE pc_busca_coddindx(pr_cdmodali IN crapris.cdmodali%TYPE
                                 ,pr_inddocto IN crapris.inddocto%TYPE
                                 ,pr_dsinfaux IN crapris.dsinfaux%TYPE
                                 ,pr_coddindx OUT PLS_INTEGER
                                 ,pr_stperidx OUT VARCHAR2) IS
      BEGIN
        pr_coddindx := 0;
        pr_stperidx := '';
        
        -- Para Garantias PRestadas 
        IF pr_inddocto = 5 AND vr_tab_mvto_garant_prest.exists(pr_dsinfaux) THEN 
          -- Buscar indexador e percentual do cadastro de movimento
          pr_coddindx := vr_tab_mvto_garant_prest(pr_dsinfaux).dsindexa;
          pr_stperidx := ' PercIndx="'||replace(to_char(vr_tab_mvto_garant_prest(pr_dsinfaux).prindexa,'fm9990D0000000'),',','.')||'"';
        ELSE 
          -- Para 0201 - Cheq Especial / 0101 - Adiant. Deposit / 1901 - Limite não Utilizado
          IF pr_cdmodali IN (0201,0101,1901) THEN
            pr_coddindx := 21;
            pr_stperidx := ' PercIndx="100"';
          ELSE -- Todas outras
            pr_coddindx := 11;
            pr_stperidx := ' PercIndx="0"';
          END IF;
        END IF;
      END pc_busca_coddindx;

      -- Busca a identificacao da sub-modalidade do emprestimo
      FUNCTION fn_busca_submodal(pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                ,pr_cdmodali IN crapris.cdmodali%TYPE
                                ,pr_cdorigem IN crapris.cdorigem%TYPE
                                ,pr_dsinfaux IN crapris.dsinfaux%TYPE) RETURN VARCHAR2 IS
      BEGIN
        -- Sair em caso de empréstimo BNDES ou Origem <> 3
        IF pr_dsinfaux = 'BNDES' OR pr_cdorigem <> 3 THEN
          RETURN NULL;
        ELSE  
          -- monta a chave para a busca do emprestimo
          vr_ind_epr := lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
          -- Se não existir Linha de Credito para o EPR
          IF NOT vr_tab_craplcr.EXISTS(vr_tab_crapepr(vr_ind_epr).cdlcremp) THEN
            -- Se não existir a linha deve retornar Sem SubModal
            RETURN NULL;
          ELSE
            -- Se a linha de credito possuir modalidade s submodalidade
            IF trim(vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdmodali) IS NOT NULL AND
               trim(vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdsubmod) IS NOT NULL THEN
              -- Concatena as duas e retorna a submodalidade
              RETURN SUBSTR(vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdmodali,1,2) || SUBSTR(vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdsubmod,1,2);
            ELSE
              -- Usar a Modalidade
              RETURN to_char(pr_cdmodali,'fm0000');
            END IF;
          END IF;
        END IF;    
      END fn_busca_submodal;

      -- Envio da operação de saída enviada
      PROCEDURE pc_imprime_saida(pr_innivris crapris.innivris%TYPE
                                ,pr_idxsaida IN VARCHAR2) IS
        vr_dtvencop DATE := NULL;
        vr_stdtvenc VARCHAR(100);
      BEGIN
        vr_stdtvenc := '';
        -- Iniciar nova Operação
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '        <Op');
        
        -- Para juridica, enviar CNPJ completo
        IF vr_tab_saida(pr_idxsaida).inpessoa <> 1 THEN 
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => ' DetCli="' || to_char(vr_tab_saida(pr_idxsaida).nrcpfcgc,'fm00000000000000')||'"');
        END IF;
          
        -- Trecho comum      
        vr_caracesp := '';
        vr_innivris := pr_innivris;

        -- Com base na modalidade retorna o codigo indexador e o percentual de indexacao
        pc_busca_coddindx(vr_tab_saida(pr_idxsaida).cdmodali
                         ,vr_tab_saida(pr_idxsaida).inddocto
                         ,vr_tab_saida(pr_idxsaida).dsinfaux
                         ,vr_coddindx
                         ,vr_stperidx);

        -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
        vr_cloperis := fn_classifica_risco(pr_innivris => vr_innivris);

        -- Busca a modalidade com base nos emprestimos
        vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_saida(pr_idxsaida).cdmodali
                                                ,pr_cdcooper
                                                ,vr_tab_saida(pr_idxsaida).nrdconta
                                                ,vr_tab_saida(pr_idxsaida).nrctremp
                                                ,vr_tab_saida(pr_idxsaida).inpessoa
                                                ,vr_tab_saida(pr_idxsaida).cdorigem
                                                ,vr_tab_saida(pr_idxsaida).dsinfaux);
        -- Busca a organização
        vr_dsorgrec := fn_busca_dsorgrec(vr_tab_saida(pr_idxsaida).cdmodali
                                        ,vr_tab_saida(pr_idxsaida).nrdconta
                                        ,vr_tab_saida(pr_idxsaida).nrctremp
                                        ,vr_tab_saida(pr_idxsaida).cdorigem
                                        ,vr_tab_saida(pr_idxsaida).dsinfaux);
                              
        -- Com base na modalidade encontrada retornar o Cosif
        vr_ctacosif := fn_busca_cosif(vr_cdmodali
                                     ,vr_tab_saida(pr_idxsaida).inpessoa
                                     ,vr_tab_saida(pr_idxsaida).inddocto
                                     ,vr_tab_saida(pr_idxsaida).dsinfaux);     
        
        -- Para Adiantamento Depositante, Limite não Utilizado, Cheque Especial, Desconto de Titulos, Desconto de Cheques, Emprestimo OU Inddocto=5
        IF vr_tab_saida(pr_idxsaida).cdmodali IN(0101,1901,0201,0301,0302,0499,0299) OR vr_tab_saida(pr_idxsaida).inddocto=5 THEN
          vr_dtvencop := vr_tab_saida(pr_idxsaida).dtvencop;
        END IF; -- modalidade
        
        -- 0101 - Para adiantamento depositante, utilizar o CL no calculo 
        IF vr_tab_saida(pr_idxsaida).cdmodali = 0101 AND vr_tab_saida(pr_idxsaida).inddocto <> 5 THEN
          -- Usar Taxa Efetiva Anual - TAB0004
          vr_txeanual := vr_txeanual_tab;
        
          -- Para:
          -- 0302 - Dsc Chq
          -- 0301 - Dsc Tit
          -- 0201 - Chq Especial
          -- 1901 - Lim Não Utzd
          -- 0299 - Empréstimos
          -- 0499 - Financiamentos
          -- OU Indocto=5
        ELSIF vr_tab_saida(pr_idxsaida).cdmodali IN(0302,0301,0201,1901,0299,0499) OR vr_tab_saida(pr_idxsaida).inddocto=5  THEN 
          -- Buscar Taxa Efetiva
          vr_txeanual := fn_busca_taxeft(vr_tab_saida(pr_idxsaida).cdmodali
                                        ,vr_tab_saida(pr_idxsaida).nrdconta
                                        ,vr_tab_saida(pr_idxsaida).nrctremp
                                        ,vr_tab_saida(pr_idxsaida).inddocto
                                        ,vr_tab_saida(pr_idxsaida).inpessoa
                                        ,vr_tab_saida(pr_idxsaida).dsinfaux
                                        ,vr_tab_saida(pr_idxsaida).cdorigem);
        ELSE
          -- Sem taxa
          vr_txeanual := 0;
        END IF;
        -- Para prejuizo a taxa anual é utilizado fixo 1,00%
        --   Consensado com Roberto e Mirtes em 20/09/2010 
        IF vr_tab_saida(pr_idxsaida).innivris = 10  THEN
          vr_txeanual := ROUND((POWER(1 + (1 / 100),12) - 1) * 100,2);
        END IF;
        
        IF vr_dtvencop IS NOT NULL THEN
          vr_stdtvenc := ' DtVencOp="' || NVL(to_char(vr_dtvencop,'YYYY-MM-DD'),'0000-00-00') || '"';        
        END IF;
        
        -- Numero do contrato formatado para o arquivo 3040
        vr_nrcontrato_3040 := fn_formata_numero_contrato(pr_cdcooper => pr_cdcooper
                                                        ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                                                        ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                                                        ,pr_cdmodali => vr_cdmodali);
        -- Para inddocto=5 
        IF vr_tab_saida(pr_idxsaida).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(vr_tab_saida(pr_idxsaida).dsinfaux) THEN
          -- Buscar a natureza e caracteristica no cadastro do movimento
          vr_cdnatuop := vr_tab_mvto_garant_prest(vr_tab_saida(pr_idxsaida).dsinfaux).dsnature;
          vr_caracesp := vr_tab_mvto_garant_prest(vr_tab_saida(pr_idxsaida).dsinfaux).dscarces;
        ELSE
          vr_cdnatuop := '01';  
          vr_caracesp := '';
        END IF;
        
        
        -- Enviar detalhes do contrato
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => ' Contrt="' || TRIM(vr_nrcontrato_3040) || '"' 
                                                  || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                                                  || ' Cosif="' || vr_ctacosif || '"' 
                                                  || ' OrigemRec="' || vr_dsorgrec || '"' -- Era fixo '0199', agora, retorna do pc_busca_modalidade
                                                  || ' Indx="' || vr_coddindx || '"' 
                                                  || vr_stperidx 
                                                  || ' VarCamb="'||fn_varcambial(vr_tab_saida(pr_idxsaida).inddocto,vr_tab_saida(pr_idxsaida).dsinfaux)||'"' 
                                                  || ' CEP="' || fn_cepende(vr_tab_saida(pr_idxsaida).inddocto,vr_tab_saida(pr_idxsaida).dsinfaux) || '"' 
                                                  || ' VlrContr="' || replace(to_char(vr_tab_saida(pr_idxsaida).vldivida,'fm99999999999999990D00'),',','.') || '"' 
                                                  || ' TaxEft="' || replace(to_char(vr_txeanual,'fm990D00'),',','.') || '"' 
                                                  || ' DtContr="' || to_char(vr_tab_saida(pr_idxsaida).dtinictr,'yyyy-mm-dd') || '"' 
                                                  || ' NatuOp="'||vr_cdnatuop||'"'
                                                  || vr_stdtvenc
                                                  || ' ClassOp="' || vr_cloperis || '"' 
                                                  || ' CaracEspecial="' || vr_caracesp ||'"');
        -- Tratar campos do Fluxo Financeiro
        pc_gera_fluxo_financeiro(pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                                ,pr_dtrefere => vr_dtrefere
                                ,pr_innivris => vr_tab_saida(pr_idxsaida).innivris
                                ,pr_inddocto => vr_tab_saida(pr_idxsaida).inddocto
                                ,pr_cdinfadi => vr_tab_saida(pr_idxsaida).cdinfadi
                                ,pr_cdmodali => vr_tab_saida(pr_idxsaida).cdmodali
                                ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                                ,pr_nrseqctr => vr_tab_saida(pr_idxsaida).nrseqctr
                                ,pr_dtprxpar => vr_tab_saida(pr_idxsaida).dtprxpar
                                ,pr_vlprxpar => vr_tab_saida(pr_idxsaida).vlprxpar
                                ,pr_qtparcel => vr_tab_saida(pr_idxsaida).qtparcel);                                 
                                  
          
        -- Fechar a tah Op                                          
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '>' || chr(10));

        IF vr_tab_saida(vr_indice_crapris).cdinfadi = '0305' THEN
          -- Busca a identificacao da sub-modalidade do emprestimo
          vr_iddident := fn_busca_submodal(vr_tab_saida(pr_idxsaida).nrdconta
                                          ,vr_tab_saida(pr_idxsaida).nrctremp
                                          ,vr_tab_saida(pr_idxsaida).cdmodali
                                          ,vr_tab_saida(pr_idxsaida).cdorigem
                                          ,vr_tab_saida(pr_idxsaida).dsinfaux);

          -- Busca a modalidade com base nos emprestimos
          vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_saida(pr_idxsaida).cdmodnov
                                                  ,pr_cdcooper
                                                  ,vr_tab_saida(pr_idxsaida).nrdconta
                                                  ,vr_tab_saida(pr_idxsaida).nrctrnov
                                                  ,vr_tab_saida(pr_idxsaida).inpessoa
                                                  ,vr_tab_saida(pr_idxsaida).cdorigem
                                                  ,vr_tab_saida(pr_idxsaida).dsinfnov);
                                                  
          -- Formata o numero do contrato
          vr_nrcontrato_3040 := fn_formata_numero_contrato(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                                                          ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctrnov
                                                          ,pr_cdmodali => vr_cdmodali);

          -- Enviar informação adicional do contrato
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => '                        <Inf Tp="' || TRIM(vr_tab_saida(pr_idxsaida).cdinfadi) || '"' 
                                                    || ' Cd="' ||vr_nrcontrato_3040 || '"'  
                                                    || ' Ident="' || to_char(vr_iddident,'fm0000') || '"' 
                                                    || ' Valor="' || replace(to_char(vr_tab_saida(pr_idxsaida).vldivida,'fm99999999999999990D00'),',','.') || '"' 
                                                    || ' />' || chr(10));
        ELSE
          -- Enviar informação adicional do contrato
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => '                        <Inf Tp="' || TRIM(vr_tab_saida(pr_idxsaida).cdinfadi) || '" />' ||chr(10));
        END IF;
        -- Verificação do Ente Consignante
        pc_inf_ente_consignante(pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                               ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                               ,pr_cdmodali => vr_tab_saida(pr_idxsaida).cdmodali
                               ,pr_dsinfaux => vr_tab_saida(pr_idxsaida).dsinfaux);
        -- Fechar tag da operação de credito
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '        </Op>' || chr(10));
      END pc_imprime_saida;

      -- Com base na temp-table vr_tab_saida eh gerado os dados e impresso no arquivo XML 3040
      PROCEDURE pc_busca_saidas(pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                               ,pr_innivris crapris.innivris%TYPE
                               ,pr_inpessoa crapris.inpessoa%TYPE) IS
        vr_nrcpfcgc      VARCHAR2(14);
        vr_indice_delete VARCHAR2(34);
      BEGIN
        
        -- Se for pessoa juridica, utiliza somente a base do CNPJ
        IF pr_inpessoa = 2 THEN 
          vr_nrcpfcgc := lpad(pr_nrcpfcgc,8,'0');
          vr_indice_crapris := vr_nrcpfcgc||'000000000000';
        ELSE
          -- Se for pessoa fisica, utiliza todo o CPF
          vr_nrcpfcgc := lpad(pr_nrcpfcgc,14,'0');
          vr_indice_crapris := vr_nrcpfcgc||'000000';
        END IF;

        -- Posicionar na pltable de riscos sob o primeiro risco desta pessoa
        vr_indice_crapris := vr_tab_saida.next(vr_indice_crapris);
        
        -- varre a tabela vr_tab_saida
        WHILE vr_indice_crapris IS NOT NULL LOOP
          -- Sair se o  registro encontrado não for do CPF/CGC recebido
          IF vr_nrcpfcgc <> vr_tab_saida(vr_indice_crapris).sbcpfcgc THEN
            EXIT;
          END IF;        
          -- Chamar código comum para impressão da OP de saída
          pc_imprime_saida(pr_innivris => pr_innivris
                          ,pr_idxsaida => vr_indice_crapris);        
          -- Guardamos o indice para deleção posterior
          vr_indice_delete := vr_indice_crapris;
          -- Vai para o proximo registro
          vr_indice_crapris := vr_tab_saida.next(vr_indice_crapris);
          -- Apagamos da tabela o registro anterior, pois o mesmo
          -- não precisa ser mais ser enviado ao documento
          vr_tab_saida.delete(vr_indice_delete);
        END LOOP;
        
      END pc_busca_saidas;

      -- Com base nos parametros passado, eh percorrido a temp-table e calculado o valor total da divida
      FUNCTION fn_total_divida_agreg(pr_faixasde       IN PLS_INTEGER
                                    ,pr_faixapar       IN PLS_INTEGER
                                    ,pr_cdmodali       IN crapris.cdmodali%TYPE
                                    ,pr_innivris       IN crapris.innivris%TYPE
                                    ,pr_cddfaixa       IN PLS_INTEGER
                                    ,pr_inpessoa       IN crapris.inpessoa%TYPE
                                    ,pr_cddesemp       IN PLS_INTEGER
                                    ,pr_cdnatuop       IN VARCHAR2
                                    ,pr_tab_venc_agreg IN OUT NOCOPY typ_tab_venc_agreg) RETURN NUMBER IS
        -- Indice para busca
        vr_ind_venc_agreg VARCHAR2(23);
        -- Total a acumular
        vr_ttldivid NUMBER(17,2); 
      BEGIN
        -- Inicializar
        vr_ttldivid := 0;
        -- Vai para o primeiro regisgtro da temp-table
        vr_ind_venc_agreg := pr_tab_venc_agreg.first;
        -- Iterar sob a pltable
        WHILE vr_ind_venc_agreg IS NOT NULL LOOP
          -- Se os parametros passados forem iguais aos da temp-table acumula o valor da divida
          IF pr_tab_venc_agreg(vr_ind_venc_agreg).cdvencto >= pr_faixasde AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cdvencto <= pr_faixapar AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cdmodali = pr_cdmodali  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).innivris = pr_innivris  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cddfaixa = pr_cddfaixa  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).inpessoa = pr_inpessoa  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cddesemp = pr_cddesemp  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cdnatuop = pr_cdnatuop  THEN
            -- Acumular
            vr_ttldivid := vr_ttldivid + pr_tab_venc_agreg(vr_ind_venc_agreg).vldivida;
          END IF;
          -- Posicionar no próximo
          vr_ind_venc_agreg := pr_tab_venc_agreg.next(vr_ind_venc_agreg);
        END LOOP;
        -- Retornar valor acumular
        RETURN vr_ttldivid;
      END fn_total_divida_agreg;

      -- Carrega a temp-table vr_tab_vencimento com base na tabela de riscos de vencimentos
      PROCEDURE pc_efetua_carga_vencimento(pr_dtrefere DATE,
                                           pr_inddocto crapris.inddocto%TYPE) IS

        -- Cursor sobre a tabela de vencimentos dos riscos
        CURSOR cr_crapvri IS
          SELECT crapvri.cdvencto,
                 crapvri.cdcooper,
                 crapvri.dtrefere,
                 crapvri.cdmodali,
                 crapvri.nrdconta,
                 crapvri.nrctremp,
                 crapris.vldivida,
                 crapris.inddocto,
                 ROW_NUMBER () OVER (PARTITION BY crapvri.nrdconta, crapvri.nrctremp ORDER BY crapvri.nrdconta, crapvri.nrctremp) nrseq,
                 COUNT(1)      OVER (PARTITION BY crapvri.nrdconta, crapvri.nrctremp ORDER BY crapvri.nrdconta, crapvri.nrctremp) qtreg
            FROM crapvri,
                 crapris
           WHERE crapris.cdcooper = pr_cdcooper
             AND crapris.dtrefere = pr_dtrefere
             AND crapris.cdmodali IN (0299, 0499) -- Empresatimo ou financiamento
             AND crapris.cdorigem = 3  -- Emprestimos/Financiamentos
             AND crapris.inddocto = pr_inddocto
             AND crapvri.cdcooper = crapris.cdcooper
             AND crapvri.dtrefere = crapris.dtrefere
             AND crapvri.nrdconta = crapris.nrdconta
             AND crapvri.innivris = crapris.innivris
             AND crapvri.cdmodali = crapris.cdmodali
             AND crapvri.nrctremp = crapris.nrctremp
             AND crapvri.nrseqctr = crapris.nrseqctr
           ORDER BY crapvri.nrdconta, crapvri.nrctremp, crapvri.cdvencto;

        -- Variaveis gerais da rotina
        vr_maiorvenc PLS_INTEGER;
        vr_flgpreju  BOOLEAN;
      BEGIN
        vr_maiorvenc := 0;
         vr_flgpreju  := FALSE;

        -- Efetua loop sobre os riscos de vencimento
        FOR rw_crapvri IN cr_crapvri LOOP

          IF rw_crapvri.cdvencto <= 190 THEN -- Vencimento 190 = 5401 dias
            IF rw_crapvri.cdvencto > vr_vtomaior THEN
              vr_maiorvenc := rw_crapvri.cdvencto;
            END IF;
          ELSIF rw_crapvri.cdvencto >= 310 AND rw_crapvri.cdvencto <= 330 THEN -- Prejuizo
            vr_flgpreju := TRUE;
          END IF;

          -- Se for o ultimo registro
          IF rw_crapvri.nrseq = rw_crapvri.qtreg THEN
            -- Cria o indice do vencimento
            vr_ind_vecto := lpad(rw_crapvri.inddocto,5,'0')||
                            lpad(rw_crapvri.cdmodali,5,'0')||
                            lpad(rw_crapvri.nrdconta,10,'0')||
                            lpad(rw_crapvri.nrctremp,10,'0');

            -- Popula a tabela de vencimentos
            vr_tab_vencimento(vr_ind_vecto).cdcooper := rw_crapvri.cdcooper;
            vr_tab_vencimento(vr_ind_vecto).dtrefere := rw_crapvri.dtrefere;
            vr_tab_vencimento(vr_ind_vecto).cdmodali := rw_crapvri.cdmodali;
            vr_tab_vencimento(vr_ind_vecto).nrdconta := rw_crapvri.nrdconta;
            vr_tab_vencimento(vr_ind_vecto).nrctremp := rw_crapvri.nrctremp;
            vr_tab_vencimento(vr_ind_vecto).cdvencto := vr_maiorvenc;
            vr_tab_vencimento(vr_ind_vecto).flgpreju := vr_flgpreju;
            vr_tab_vencimento(vr_ind_vecto).vldivida := rw_crapvri.vldivida;
            vr_tab_vencimento(vr_ind_vecto).inddocto := rw_crapvri.inddocto;
            -- Limpa as variaveis de controle
            vr_maiorvenc := 0;
            vr_flgpreju  := FALSE;
          END IF;
        END LOOP;
      END pc_efetua_carga_vencimento;
      
      -- Classifica o porte do PF
      FUNCTION fn_classifi_porte_pf(pr_vlrrendi IN NUMBER) RETURN pls_integer IS
      BEGIN  
        
        --> 03/11/2016 - Renato Darosci - Alterado para considerar faixa "sem rendimento" até 0.01 - SD 549969
      
        IF pr_vlrrendi <= 0.01 THEN
          RETURN 1;
        ELSIF pr_vlrrendi > 0.01 AND pr_vlrrendi <= vr_vlsalmin THEN
          RETURN 2;
        ELSIF pr_vlrrendi > vr_vlsalmin AND pr_vlrrendi <= (vr_vlsalmin * 2) THEN
          RETURN 3;
        ELSIF pr_vlrrendi > vr_vlsalmin * 2 AND pr_vlrrendi <= vr_vlsalmin * 3 THEN
          RETURN 4;
        ELSIF pr_vlrrendi > vr_vlsalmin * 3 AND pr_vlrrendi <= vr_vlsalmin * 5 THEN
          RETURN 5;
        ELSIF pr_vlrrendi > vr_vlsalmin * 5 AND pr_vlrrendi <= vr_vlsalmin * 10 THEN
          RETURN 6;
        ELSIF pr_vlrrendi > vr_vlsalmin * 10 AND pr_vlrrendi <= vr_vlsalmin * 20 THEN
          RETURN 7;
        ELSIF pr_vlrrendi > vr_vlsalmin * 20 THEN
          RETURN 8;
        ELSE
          RETURN 0;
        END IF;
      END;
      
      -- Classifica o porte do PJ
      FUNCTION fn_classifi_porte_pj(pr_fatanual IN NUMBER) RETURN pls_integer IS
      BEGIN  
        IF pr_fatanual <= 360000 THEN
          RETURN 1;
        ELSIF pr_fatanual > 360000 AND pr_fatanual <= 4800000 THEN
          RETURN 2;
        ELSIF pr_fatanual > 4800000 AND pr_fatanual <= 300000000 THEN
          RETURN 3;
        ELSIF pr_fatanual > 300000000 THEN
          RETURN 4;
        END IF;
      END;
      
      -- Procedure para gerar o arquivo 3040 particionado
      PROCEDURE pc_solicita_relato_3040(pr_nrdocnpj      IN crapcop.nrdocnpj%TYPE      -- CNPJ da cooperativa
                                       ,pr_dsnomscr      IN crapcop.dsnomscr%TYPE      -- Nome do responsavel
                                       ,pr_dsemascr      IN crapcop.dsemascr%TYPE      -- Email do Responsavel
                                       ,pr_dstelscr      IN crapcop.dstelscr%TYPE      -- Telefone do Responsavel
                                       ,pr_cdprogra      IN crapprg.cdprogra%TYPE      -- Codigo do Programa
                                       ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE      -- Data de Movimento
                                       ,pr_dtrefere      IN DATE                       -- Data de Referencia
                                       ,pr_flgfimaq      IN BOOLEAN                    -- Define a ultima parte do arquivo
                                       ,pr_totalcli      IN INTEGER                    -- Total de Cliente
                                       ,pr_nom_direto    IN VARCHAR2                   -- Diretorio da cooperativa
                                       ,pr_nom_dirmic    IN VARCHAR2                   -- Diretorio micros da cooperativa
                                       ,pr_numparte      IN OUT INTEGER           	   -- Numero da parte do arquivo
                                       ,pr_xml_3040      IN OUT NOCOPY CLOB            -- XML do arquivo 3040
                                       ,pr_xml_3040_temp IN OUT VARCHAR2               -- XML do arquivo 3040
                                       ,pr_cdcritic      OUT crapcri.cdcritic%TYPE     -- Codigo da critica
                                       ,pr_dscritic      OUT crapcri.dscritic%TYPE) IS -- Descricao da critica
                                       
        vr_xml_rel_parte        CLOB;            -- Variavel CLOB contendo o xml particionado      
        vr_xml_rel_parte_temp   VARCHAR2(32767); -- Variavel VARCHAR contendo o xml particionado
        vr_coopcnpj             VARCHAR2(14);    -- Armazenar o CNPJ da Cooperativa
        vr_nmarqsai             VARCHAR2(50);    -- Nome do arquivo 3040
      BEGIN
        pr_numparte := pr_numparte + 1;
        -- Definicao dos nomes dos arquivos de saida
        vr_nmarqsai := '3040' || LPAD(TO_CHAR(pr_numparte),2,'0') || to_char(pr_dtrefere,'MMYY')||'.xml';        
        
        -- Armazenar todos os arquivos gerados
        IF vr_nmarqsai_tot IS NULL THEN
          vr_nmarqsai_tot := pr_nom_dirmic||'/'||vr_nmarqsai;
        ELSE
          vr_nmarqsai_tot := vr_nmarqsai_tot||chr(10)||
                             pr_nom_dirmic||'/'||vr_nmarqsai;
        END IF;
        
        -- Armazenar o CNPJ da Cooperativa
        vr_coopcnpj := substr(lpad(pr_nrdocnpj,14,'0'),1,8);        
        -- Inicializar o CLOB do relatorio particionado
        dbms_lob.createtemporary(vr_xml_rel_parte, TRUE);
        dbms_lob.open(vr_xml_rel_parte, dbms_lob.lob_readwrite);
        -- Insere o cabecalho no arquivo 3040
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                               ,pr_texto_completo => vr_xml_rel_parte_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(10)
                                                     || '<Doc3040 DtBase="' || to_char(pr_dtrefere,'YYYY-MM') 
                                                     || '" CNPJ="'   || vr_coopcnpj 
                                                     || '" Remessa="1" Parte="'|| pr_numparte
                                                     || '" NomeResp="' || pr_dsnomscr 
                                                     || '" EmailResp="' || nvl(pr_dsemascr,'') 
                                                     || '" TelResp="' || pr_dstelscr
                                                     || '" TotalCli="' || pr_totalcli||'" ');
                                                     
        -- Condicao para verificar se eh a ultima parte do arquivo 3040
        IF pr_flgfimaq THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                                 ,pr_texto_completo => vr_xml_rel_parte_temp
                                 ,pr_texto_novo     => 'TpArq="F"');
        END IF;
        
        -- Fecha a tag do cabecalho
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                               ,pr_texto_completo => vr_xml_rel_parte_temp
                               ,pr_texto_novo     => '>' || chr(10)
                               ,pr_fecha_xml      => true);
        
        -- Concatena o corpo do XML
        dbms_lob.writeappend(pr_xml_3040, length(pr_xml_3040_temp), pr_xml_3040_temp);
        -- Concatena o Cabecalho + Corpo do XML
        dbms_lob.append(vr_xml_rel_parte, pr_xml_3040);        
        -- Fecha a tag do arquivo XML
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                               ,pr_texto_completo => vr_xml_rel_parte_temp
                               ,pr_texto_novo     => '</Doc3040>'|| chr(10)
                               ,pr_fecha_xml      => true);

        -- gera o arquivo xml 3040
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper 
                                           ,pr_cdprogra  => pr_cdprogra
                                           ,pr_dtmvtolt  => pr_dtmvtolt
                                           ,pr_dsxml     => vr_xml_rel_parte
                                           ,pr_dsarqsaid => pr_nom_direto ||'/'|| vr_nmarqsai
                                           ,pr_cdrelato  => null
                                           ,pr_flg_gerar => 'S'              --> Apenas submeter
                                           ,pr_dspathcop => pr_nom_dirmic    --> Copiar para a Micros
                                           ,pr_fldoscop  => 'S'              --> Efetuar cópia com Ux2Dos
                                           ,pr_dscmaxcop => '| tr -d "\032"'
                                           ,pr_des_erro  => pr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_xml_rel_parte);
        dbms_lob.freetemporary(vr_xml_rel_parte);
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(pr_xml_3040);
        dbms_lob.freetemporary(pr_xml_3040);
        -- Limpa as variaveis
        pr_xml_3040      := NULL;
        pr_xml_3040_temp := NULL;
        
        -- Somente vamos criar, quando nao for o ultimo arquivo
        IF NOT pr_flgfimaq THEN
          -- Inicializar o CLOB do relatorio particionado
          dbms_lob.createtemporary(pr_xml_3040, TRUE);
          dbms_lob.open(pr_xml_3040, dbms_lob.lob_readwrite);        
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
          
      END pc_solicita_relato_3040;      
      
    BEGIN -- Rotina Principal
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Buscar dados da Central
      OPEN cr_crapcop(3);
      FETCH cr_crapcop
       INTO rw_crapcop_3;
      CLOSE cr_crapcop;
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      -- Buscar data da solicitação
      BEGIN
        OPEN cr_crapsol;
        FETCH cr_crapsol 
         INTO vr_dtrefere;
        -- Não existe crapsol
        IF cr_crapsol%NOTFOUND THEN
          CLOSE cr_crapsol;
          vr_dscritic := 'Nao encontrado solicitacao para o programa (CRAPSOL).';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapsol;
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida;
        WHEN others THEN  
          vr_dscritic := 'Problema ao retornar a data da solicitacao (CRAPSOL).';
          RAISE vr_exc_saida;
      END;
      
      --Verificar se o programa deve ser executado
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 0);
      IF substr(vr_dstextab,1,1) <> '1' THEN
        vr_cdcritic := 411; --Tabela de execucao nao liberada
        RAISE vr_exc_saida;
      ELSE
        -- Busca o valor do salario minimo
        vr_vlsalmin := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,13,11));
      END IF;
      -- Busca Taxa Efetiva Anual - TAB0004
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'JUROSNEGAT'
                                               ,pr_tpregist => 001);
      -- Se encontrou
      IF trim(vr_dstextab) IS NOT NULL THEN
        BEGIN
          -- Converte a informação para number
          vr_txeanual_tab := SUBSTR(vr_dstextab,1,10);
          vr_txeanual_tab := ROUND((POWER(1 + (vr_txeanual_tab / 100),12) - 1) * 100,2);
        EXCEPTION
          WHEN OTHERS THEN
            vr_txeanual_tab := 0;
        END;  
      END IF;
      
      -- Busca do rl
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      
      -- busca o diretorio salvar da coop
      vr_nom_dirsal := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'salvar');
                                            
      -- busca o diretorio micros contab
      vr_nom_dirmic := gene0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'contab');
                                            
      -- Inicializar o CLOB 3040
      dbms_lob.createtemporary(vr_xml_3040, TRUE);
      dbms_lob.open(vr_xml_3040, dbms_lob.lob_readwrite);
      
      -- Carrega as tabelas temporarias de vencimentos de risco
      FOR rw_crapvri_b IN cr_crapvri_b(vr_dtrefere) LOOP
        vr_crapvri := vr_crapvri + 1;

        IF rw_crapvri_b.vldivida <> 0 THEN -- Carrega a tabela vr_tab_crapvri_b
          vr_indice_crapvri_b := lpad(rw_crapvri_b.nrdconta,10,'0') ||
                                 lpad(rw_crapvri_b.innivris,5,'0') ||
                                 lpad(rw_crapvri_b.cdmodali,5,'0') ||
                                 lpad(rw_crapvri_b.nrseqctr,5,'0') ||
                                 lpad(rw_crapvri_b.nrctremp,10,'0') ||
                                 lpad(vr_crapvri,7,'0');
          vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto := rw_crapvri_b.cdvencto;
          vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida := rw_crapvri_b.vldivida;
        END IF;
      END LOOP;
      
      -- Carrega a tabela temporaria de emprestimos do Bndes
      FOR rw_crapebn IN cr_crapebn LOOP
        vr_ind_ebn := lpad(rw_crapebn.nrdconta,10,'0')||lpad(rw_crapebn.nrctremp,10,'0');
        vr_tab_crapebn(vr_ind_ebn).cdsubmod := rw_crapebn.cdsubmod;
        vr_tab_crapebn(vr_ind_ebn).vlropepr := rw_crapebn.vlropepr;
        vr_tab_crapebn(vr_ind_ebn).dtinictr := rw_crapebn.dtinictr;
        vr_tab_crapebn(vr_ind_ebn).dtfimctr := rw_crapebn.dtfimctr;
        vr_tab_crapebn(vr_ind_ebn).dtprejuz := rw_crapebn.dtprejuz;
        vr_tab_crapebn(vr_ind_ebn).txefeanu := rw_crapebn.txefeanu;
        vr_tab_crapebn(vr_ind_ebn).nrdconta := rw_crapebn.nrdconta;
        vr_tab_crapebn(vr_ind_ebn).dtvctpro := rw_crapebn.dtvctpro;
        vr_tab_crapebn(vr_ind_ebn).vlparepr := rw_crapebn.vlparepr;
        vr_tab_crapebn(vr_ind_ebn).qtparctr := rw_crapebn.qtparctr;
      END LOOP;
      
      -- Carrega a tabela temporaria do cartao de credito
      FOR rw_tbcrd_risco IN cr_tbcrd_risco(pr_cdcooper => pr_cdcooper
                                          ,pr_dtrefere => vr_dtrefere) LOOP
        vr_ind_crd := LPAD(rw_tbcrd_risco.nrdconta,10,'0') || LPAD(rw_tbcrd_risco.nrcontrato,10,'0');
        vr_tab_tbcrd_risco(vr_ind_crd).vlropcrd := rw_tbcrd_risco.vlropcrd;
        vr_tab_tbcrd_risco(vr_ind_crd).cdtipcar := rw_tbcrd_risco.cdtipo_cartao;
      END LOOP;
      
      -- Busca taxa de Juros Cartao BB e Bancoob
      FOR rw_car IN cr_tbrisco_prod LOOP
        IF rw_car.tparquivo = 'Cartao_BB' THEN
          vr_vltxabb := rw_car.vltaxa_juros;
        ELSE
          vr_vltxban := rw_car.vltaxa_juros;
        END IF;  
      END LOOP;
      
      -- Carrega a tabela temporaria de emprestimos
      FOR rw_crapepr IN cr_crapepr LOOP
        vr_ind_epr := lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0');
        vr_tab_crapepr(vr_ind_epr).dtmvtolt := rw_crapepr.dtmvtolt;
        vr_tab_crapepr(vr_ind_epr).cdlcremp := rw_crapepr.cdlcremp;
        vr_tab_crapepr(vr_ind_epr).vlpreemp := rw_crapepr.vlpreemp;
        vr_tab_crapepr(vr_ind_epr).vlemprst := rw_crapepr.vlemprst;
        vr_tab_crapepr(vr_ind_epr).dtprejuz := rw_crapepr.dtprejuz;
        vr_tab_crapepr(vr_ind_epr).nrctaav1 := rw_crapepr.nrctaav1;
        vr_tab_crapepr(vr_ind_epr).nrctaav2 := rw_crapepr.nrctaav2;
        vr_tab_crapepr(vr_ind_epr).qtpreemp := rw_crapepr.qtpreemp;
        vr_tab_crapepr(vr_ind_epr).dtdpagto := rw_crapepr.dtdpagto; -- epr.dtdpagto
        vr_tab_crapepr(vr_ind_epr).dtdpripg := rw_crapepr.dtdpripg; -- wpr.dtdpagto
        vr_tab_crapepr(vr_ind_epr).qtctrliq := rw_crapepr.qtctrliq; -- Testes de existência de liquidação
        vr_tab_crapepr(vr_ind_epr).inprejuz := rw_crapepr.inprejuz;
      END LOOP;    
      
      -- Carregar PLTABLE de Linhas de Credito
      FOR rw_craplcr IN cr_craplcr LOOP
        vr_tab_craplcr(rw_craplcr.cdlcremp).cdmodali := rw_craplcr.cdmodali;
        vr_tab_craplcr(rw_craplcr.cdlcremp).cdsubmod := rw_craplcr.cdsubmod;
        vr_tab_craplcr(rw_craplcr.cdlcremp).txjurfix := rw_craplcr.txjurfix;
        vr_tab_craplcr(rw_craplcr.cdlcremp).dsorgrec := rw_craplcr.dsorgrec;
        vr_tab_craplcr(rw_craplcr.cdlcremp).cdusolcr := rw_craplcr.cdusolcr;
      END LOOP;
      
      -- Processo responsavel em efetuar carga dos vencimentos inddocto = 1
      pc_efetua_carga_vencimento(vr_dtrefere,1);
      -- Processo responsavel em efetuar carga dos vencimentos inddocto = 2
      pc_efetua_carga_vencimento(vr_dtrefere,2);
      
      -- Carregar a pltable de riscos
      pc_carrega_base_saida(vr_dtrefere);
      
      -- Carregar a base de risco, separando os contratos em individuais e agregados 
      pc_carrega_base_risco(vr_dtrefere);
      
      -- Carrega os percentuais de risco
      FOR rw_craptab IN cr_craptab LOOP
        vr_tab_percentual(substr(rw_craptab.dstextab,12,2)).percentual := SUBSTR(rw_craptab.dstextab,1,6);
      END LOOP;
      -- De acordo com o BCB, no arquivo 3040 o prejuizo deve ser provisionado 100% igual risco H (9) 
      vr_tab_percentual(10).percentual := vr_tab_percentual(9).percentual;
      
      -- Busca os movimentos digitados manualmente para os contratos inddocto=5
      FOR rw_movtos IN cr_movtos_garprest(pr_cdcooper => pr_cdcooper
                                         ,pr_dtrefere => vr_dtrefere) LOOP
        -- Alimentar pltable
        vr_tab_mvto_garant_prest(rw_movtos.idmovto_risco) := rw_movtos;
      END LOOP;
      
      -- Acessar primeiro registro da tabela de memoria
      vr_idx_individ := vr_tab_individ.FIRST;
      -- Varre a tabela de memoria dos contratos individualizados
      WHILE vr_idx_individ IS NOT NULL LOOP  
        vr_fatanual := 0;
        vr_vlrrendi := 0;
        vr_portecli := 0;
        vr_stgpecon := '';
        -- Informacoes do Cliente 
        IF vr_tab_individ.prior(vr_idx_individ) IS NULL OR  -- Se for o primeiro registro
           vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_tab_individ(vr_tab_individ.prior(vr_idx_individ)).nrcpfcgc THEN -- Se o CGC/CPF for diferente do anterior
           
          -- Zerar controle de avalistas
          vr_flgarant := FALSE;
          -- Busca os dados dos associados
          OPEN cr_crapass(vr_tab_individ(vr_idx_individ).nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          -- Se nao encontrar o associado encerra o programa com erro
          IF cr_crapass%NOTFOUND THEN
            CLOSE cr_crapass;
            vr_cdcritic := 9;
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_crapass; -- Fecha o cursor de associados
          -- Se a data de admissao for vazia, ou se o ano de admissao for inferior a 1000
          IF rw_crapass.dtadmiss IS NULL OR to_char(rw_crapass.dtadmiss,'YYYY') < 1000 THEN 
            -- Atribui a data atual sem a hora
            vr_dtabtcct := trunc(SYSDATE); 
          ELSE
            -- Usar da tabela
            vr_dtabtcct := rw_crapass.dtadmiss;
          END IF;
          -- busca a classe do cliente
          IF rw_crapass.dsnivris = 'HH' THEN
            vr_classcli := 'H';
          ELSIF TRIM(rw_crapass.dsnivris) IS NOT NULL THEN
            vr_classcli := rw_crapass.dsnivris;
          ELSE
            vr_classcli := 'A';
          END IF;
          -- Se for pessoa fisica
          IF vr_tab_individ(vr_idx_individ).inpessoa = 1 THEN
            -- Busca o titular da conta
            OPEN cr_crapttl(vr_tab_individ(vr_idx_individ).nrdconta);
            FETCH cr_crapttl INTO rw_crapttl;
            IF cr_crapttl%FOUND THEN
              -- Somar salário + aplicações
              vr_vlrrendi := rw_crapttl.vlsalari + rw_crapttl.vldrendi##1 + rw_crapttl.vldrendi##2 + rw_crapttl.vldrendi##3 +
                          rw_crapttl.vldrendi##4 + rw_crapttl.vldrendi##5 + rw_crapttl.vldrendi##6;
            END IF;
            CLOSE cr_crapttl; -- Fecha o cursor de titulares
            -- Busca o porte do cliente
            vr_portecli := fn_classifi_porte_pf(vr_vlrrendi);
            -- Valor do rendimento nao pode ser zero
            IF vr_vlrrendi = 0 THEN
              vr_vlrrendi := 0.01;
            END IF;

            IF vr_tab_individ(vr_idx_individ).nrdgrupo > 0 THEN
              vr_stgpecon := ' CongEcon="' || To_CHAR(vr_tab_individ(vr_idx_individ).nrdgrupo) || '"';              
            END IF;              

            -- Enviar detalhes do cliente fisico
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                      ,pr_texto_completo => vr_xml_3040_temp
                                      ,pr_texto_novo     => '    <Cli Cd="' || lpad(vr_tab_individ(vr_idx_individ).nrcpfcgc,11,'0') || '"' 
                                                         || ' Tp="1"' 
                                                         || ' Autorzc="S"' 
                                                         || ' PorteCli="' || TRIM(vr_portecli) || '"' 
                                                         || ' IniRelactCli="' ||to_char(vr_dtabtcct,'YYYY-MM-DD') || '"' 
                                                         || ' FatAnual="' || replace(to_char(vr_vlrrendi,'fm9999999999990D00'),',','.') || '"' 
                                                         || vr_stgpecon
                                                         || ' ClassCli="' || vr_classcli || '">' ||chr(10));
          ELSE -- Se for pessoa juridica
            -- busca o valor de faturamento
            OPEN cr_crapjfn(vr_tab_individ(vr_idx_individ).nrdconta);
            FETCH cr_crapjfn INTO vr_fatanual;
            CLOSE cr_crapjfn; -- Fecha o cursor dos dados financeiros de PJ
            -- Validador nao aceita faturamento zerado nem negativo
            IF vr_fatanual <= 0 THEN
              vr_fatanual := 1;
            END IF;
            
            IF vr_tab_individ(vr_idx_individ).nrdgrupo > 0 THEN
              vr_stgpecon := ' CongEcon="' || To_CHAR(vr_tab_individ(vr_idx_individ).nrdgrupo) || '"';              
            END IF; 
            
            -- Classifica o porte do PJ
            vr_portecli := fn_classifi_porte_pj(vr_fatanual);
            -- Enviar detalhes do cliente Juridico
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '    <Cli Cd="' || lpad(vr_tab_individ(vr_idx_individ).nrcpfcgc,8,'0') || '"' 
                                                      || ' Tp="2"' 
                                                      || ' Autorzc="S"' 
                                                      || ' PorteCli="' || TRIM(vr_portecli) || '"' 
                                                      || ' TpCtrl="01"' 
                                                      || ' IniRelactCli="' || to_char(vr_dtabtcct,'YYYY-MM-DD') || '"' 
                                                      || ' FatAnual="' || replace(to_char(vr_fatanual, 'fm99999999999999990D00'),',','.') || '"' 
                                                      || vr_stgpecon
                                                      || ' ClassCli="' || vr_classcli ||'">' ||chr(10));
          END IF; -- Validacao de pessoa fisica ou jurisica
        END IF; -- Validacao do primeiro cpj/cnpj do cliente
        -- Limpar variaveis temporarias
        vr_tab_venc.delete;
        vr_vldivida := 0;
        vr_caracesp := '';
        vr_vlrctado := 0;
        vr_stperidx := '';
        vr_ctacosif := '';
        
        -- Para inddocto=5 
        IF vr_tab_individ(vr_idx_individ).inddocto =5 AND vr_tab_mvto_garant_prest.exists(vr_tab_individ(vr_idx_individ).dsinfaux) THEN
          -- Buscar a natureza no cadastro do movimento e já aproveitamos 
          -- a leitura para busca da data de vencimento da operação
          vr_cdnatuop := vr_tab_mvto_garant_prest(vr_tab_individ(vr_idx_individ).dsinfaux).dsnature;
        ELSE
          vr_cdnatuop := '01';  
        END IF;
        
        -- Efetua um loop sobre os vencimentos do risco
        FOR rw_crapvri_venct IN cr_crapvri_venct(vr_tab_individ(vr_idx_individ).nrdconta,
                                                 vr_dtrefere,
                                                 vr_tab_individ(vr_idx_individ).cdmodali,
                                                 vr_tab_individ(vr_idx_individ).nrctremp) LOOP
          -- Zerar qtde dias vcto
          vr_diasvenc := 0;
          
          -- Se for o ultimo registro
          IF rw_crapvri_venct.nrseq = rw_crapvri_venct.qtreg THEN
            -- Guardar a data de inicio e nivel
            vr_innivris := vr_tab_individ(vr_idx_individ).innivris;
            -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
            vr_cloperis := fn_classifica_risco(pr_innivris => vr_innivris);
            -- Com base na modalidade retorna o codigo indexador e o percentual de indexacao
            pc_busca_coddindx(pr_cdmodali => vr_tab_individ(vr_idx_individ).cdmodali
                             ,pr_inddocto => vr_tab_individ(vr_idx_individ).inddocto
                             ,pr_dsinfaux => vr_tab_individ(vr_idx_individ).dsinfaux
                             ,pr_coddindx => vr_coddindx
                             ,pr_stperidx => vr_stperidx);
            -- Busca os dias de vencimento
            vr_diasvenc := fn_busca_dias_vencimento(rw_crapvri_venct.cdvencto);
            -- 0101 - Para adiantamento depositante ou INDDOCTO=5
            IF vr_tab_individ(vr_idx_individ).cdmodali = 0101 OR vr_tab_individ(vr_idx_individ).inddocto = 5 THEN
              vr_vlrctado := vr_tab_individ(vr_idx_individ).vldivida;
              vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
            -- Para Limite não Utilizado, Cheque Especial, Desconto de Titulos e Desconto de Cheques
            ELSIF vr_tab_individ(vr_idx_individ).cdmodali IN(1901,0201,0301,0302) THEN
              vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
            -- Cartões BB e Bancoob
            ELSIF vr_tab_individ(vr_idx_individ).inddocto = 4 THEN
              vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
              -- Valor contratado
              vr_ind_crd  := LPAD(vr_tab_individ(vr_idx_individ).nrdconta,10,'0') || LPAD(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
              IF vr_tab_tbcrd_risco.exists(vr_ind_crd) THEN 
                vr_vlrctado := vr_tab_tbcrd_risco(vr_ind_crd).vlropcrd;
              END IF;  
            -- 0299=Emprst,  0499=Financ e Origem 3  
            ELSIF vr_tab_individ(vr_idx_individ).cdmodali IN(0499,0299) AND vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN  
              vr_cdvencto := 0;
              vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
              -- Para empréstimo BNDES
              IF vr_tab_individ(vr_idx_individ).dsinfaux = 'BNDES' THEN
                -- Temos de buscar as informações da EBN
                vr_ind_ebn := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')||lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                -- Buscar informações que já existem na tabela                
                vr_vlrctado := vr_tab_crapebn(vr_ind_ebn).vlropepr;                
              ELSE
                -- Empréstimo da base Cecred
                vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')||lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                -- Armazenar valor contratado
                vr_vlrctado := vr_tab_crapepr(vr_ind_epr).vlemprst;                
                -- Tratamento da Natureza da Operacao de contratos de Empr/Fin Conta Migrada Altovale  
                IF pr_cdcooper = 16 THEN
                  -- Verifica se a conta eh de transferencia entre cooperativas
                  OPEN cr_craptco(vr_tab_individ(vr_idx_individ).nrdconta);
                  FETCH cr_craptco INTO rw_craptco;
                  -- Conta transferida 
                  IF cr_craptco%FOUND THEN 
                    -- Empréstimos anteriores a 2013
                    IF vr_tab_crapepr(vr_ind_epr).dtmvtolt <= to_date('31/12/2012','dd/mm/yyyy') THEN
                      vr_cdnatuop := '02';
                      vr_vlrdivid := vr_tab_individ(vr_idx_individ).vldivida - vr_tab_individ(vr_idx_individ).vljura60;
                    END IF;
                  END IF;
                  CLOSE cr_craptco;
                END IF;
                -- Tratamento da Natureza da Operacao de contratos de Empr/Fin Conta Migrada Acredicoop  
                IF pr_cdcooper = 1 THEN
                  -- Abre o cursor de contas transferidas
                  OPEN cr_craptco_b(vr_tab_individ(vr_idx_individ).nrdconta);
                  FETCH cr_craptco_b INTO rw_craptco_b;
                  -- Conta transferida 
                  IF cr_craptco_b%FOUND THEN 
                    -- Empréstimos anteriores a 2013
                    IF vr_tab_crapepr(vr_ind_epr).dtmvtolt <= to_date('31/12/2013','dd/mm/yyyy') THEN
                      vr_cdnatuop := '02';
                      vr_vlrdivid := vr_tab_individ(vr_idx_individ).vldivida - vr_tab_individ(vr_idx_individ).vljura60;
                    END IF;
                  END IF;
                  CLOSE cr_craptco_b;
                END IF;
                
                --> Verificar se é cessao de credito
                IF vr_tab_individ(vr_idx_individ).flcessao = 1 THEN
                  vr_cdnatuop := '02';
                  vr_vlrdivid := vr_tab_crapepr(vr_ind_epr).vlemprst;
                END IF;
                
              END IF; -- Crapebn%notfound
            END IF; -- modalidade
            
            vr_txeanual := 0;
            -- Para:
            -- 0302 - Dsc Chq
            -- 0301 - Dsc Tit
            -- 0201 - Chq Especial
            -- 1901 - Lim Não Utzd
            -- 0299 - Empréstimos
            -- 0499 - Financiamentos
            -- 1513 - Coobrigacao
            -- OU Inddocto=5
            IF vr_tab_individ(vr_idx_individ).cdmodali IN(0302,0301,0201,1901,0299,0499,1513) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN 
              -- Buscar Taxa Efetiva
              vr_txeanual := fn_busca_taxeft(vr_tab_individ(vr_idx_individ).cdmodali
                                            ,vr_tab_individ(vr_idx_individ).nrdconta
                                            ,vr_tab_individ(vr_idx_individ).nrctremp
                                            ,vr_tab_individ(vr_idx_individ).inddocto
                                            ,vr_tab_individ(vr_idx_individ).inpessoa
                                            ,vr_tab_individ(vr_idx_individ).dsinfaux
                                            ,vr_tab_individ(vr_idx_individ).cdorigem);
            -- 0101 - Para adiantamento depositante, utilizar o CL no calculo 
            ELSIF vr_tab_individ(vr_idx_individ).cdmodali = 0101  THEN
              -- Usar Taxa Efetiva Anual - TAB0004
              vr_txeanual := vr_txeanual_tab;
            -- Para emprestimo/financia utilizar a data regular do final 
            ELSE
              vr_txeanual := 0;
            END IF;
            -- Para prejuizo a taxa anual é utilizado fixo 1,00%
            --   Consensado com Roberto e Mirtes em 20/09/2010 
            IF vr_tab_individ(vr_idx_individ).innivris = 10  THEN
              vr_txeanual := ROUND((POWER(1 + (1 / 100),12) - 1) * 100,2);
            END IF;            
            
          END IF; -- ultimo registro quebrado por conta e condigo de vencimento
          
          -- Se for vencimentos que ainda nao venceram
          IF rw_crapvri_venct.cdvencto >= 110 AND rw_crapvri_venct.cdvencto <= 290  THEN 
            vr_vldivida := vr_vldivida + rw_crapvri_venct.vldivida;
          END IF;
          -- Se for um vencimento ja vencido ha mais de 1621 dias
          IF rw_crapvri_venct.cdvencto = 330 THEN 
            vr_caracesp := '11';
          END IF;
          
          -- Acumula cada vencimento e seu valor 
          IF vr_tab_venc.EXISTS(rw_crapvri_venct.cdvencto) THEN
            vr_tab_venc(rw_crapvri_venct.cdvencto).vldivida := vr_tab_venc(rw_crapvri_venct.cdvencto).vldivida +
                                                               rw_crapvri_venct.vldivida;
          ELSE
            vr_tab_venc(rw_crapvri_venct.cdvencto).cdvencto := rw_crapvri_venct.cdvencto;
            vr_tab_venc(rw_crapvri_venct.cdvencto).vldivida := rw_crapvri_venct.vldivida;
          END IF;
        END LOOP; -- loop sobre a cr_crapvri_venct
        
        -- Prejuizo com calc diferenciado 
        IF vr_vldivida <> 0  THEN 
          vr_vlpercen := vr_tab_percentual(vr_tab_individ(vr_idx_individ).innivris).percentual / 100;
          vr_vlpreatr := ROUND(( (vr_vldivida - vr_tab_individ(vr_idx_individ).vljura60) * vr_vlpercen),2);
        END IF;
        -- Inicio da TAG de operacoes de credito <Op> 
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '        <Op');
        -- Se for pessoa juridica
        IF vr_tab_individ(vr_idx_individ).inpessoa = 2 THEN
          -- Imprime o numero do CNPJ
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => ' DetCli="' || lpad(vr_tab_individ(vr_idx_individ).nrdocnpj,14,'0') || '"');
        END IF;
        -- Tratamento para Dias de Atraso da Parcela mais Atrasada 
        vr_flgatras := 0;
        vr_stdiasat := '';
        vr_qtcalcat := 0;
        vr_indice_venc := vr_tab_venc.last;
        WHILE vr_indice_venc IS NOT NULL LOOP
          -- Buscar somente os vencimentos entre 205 e 330
          IF vr_tab_venc(vr_indice_venc).cdvencto >= 205 AND  -- Se for dias em atraso (ja vencidos)
             vr_tab_venc(vr_indice_venc).cdvencto <= 330 THEN
            -- Calculo da qtde de dias da parcela mais atrasada 
            -- Traz o intervalo válido para a parcela em atrazo 
            vr_flgatras := 1;
            -- Para empréstimo / financiamentos ou Inddocto=5
            IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499,301,302) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN
              vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdiaatr || '"';

              IF vr_tab_venc(vr_indice_venc).cdvencto = 205 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 1  OR
                                                                            vr_tab_individ(vr_idx_individ).qtdiaatr > 14) THEN
                vr_stdiasat := ' DiaAtraso = "1"';
              ELSIF vr_tab_venc(vr_indice_venc).cdvencto = 210 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 15 OR
                                                                               vr_tab_individ(vr_idx_individ).qtdiaatr > 30) THEN
                vr_stdiasat := ' DiaAtraso = "15"';
              ELSIF vr_tab_venc(vr_indice_venc).cdvencto = 220 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 31 OR
                                                                               vr_tab_individ(vr_idx_individ).qtdiaatr > 60) THEN
                vr_stdiasat := ' DiaAtraso = "31"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 230 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 61 OR
                                                                               vr_tab_individ(vr_idx_individ).qtdiaatr > 90) THEN
                vr_stdiasat := ' DiaAtraso = "61"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 240 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 91 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 120) THEN
                vr_stdiasat := ' DiaAtraso = "91"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 245 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 121 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 150) THEN
                vr_stdiasat := ' DiaAtraso = "121"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 250 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 151 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 180) THEN
                vr_stdiasat := ' DiaAtraso = "151"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 255 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 181 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 240) THEN
                vr_stdiasat := ' DiaAtraso = "181"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 260 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 241 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 300) THEN
                vr_stdiasat := ' DiaAtraso = "241"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 270 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 301 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 360) THEN
                vr_stdiasat := ' DiaAtraso = "301"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 280 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 361 OR
                                                                                vr_tab_individ(vr_idx_individ).qtdiaatr > 540) THEN
                vr_stdiasat := ' DiaAtraso = "361"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 290 AND vr_tab_individ(vr_idx_individ).qtdiaatr < 541 THEN
                vr_stdiasat := ' DiaAtraso = "541"';
              -- Baixado para prejuízo: Valores fixados
              ELSIF  (vr_tab_venc(vr_indice_venc).cdvencto = 310 OR vr_tab_venc(vr_indice_venc).cdvencto = 320)  THEN
                vr_stdiasat := ' DiaAtraso = "541"';
              ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 330 THEN
                vr_stdiasat := ' DiaAtraso = "1621"';
              END IF;
            ELSIF  vr_tab_individ(vr_idx_individ).cdmodali = 0101  THEN
              vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdriclq || '"';
            -- 1513 - Coobrigacao
            ELSIF  vr_tab_individ(vr_idx_individ).cdmodali = 1513  THEN
              vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdiaatr || '"';
            ELSE -- Para as demais modalidades nao terá operaçoes vencidas 
              vr_stdiasat := '';
            END IF;
            EXIT; -- Sai fora do while
          END IF;
          --ir para o registro anterior
          vr_indice_venc := vr_tab_venc.prior(vr_indice_venc);
        END LOOP;
        -- Se não encontrou no loop de atraso
        IF vr_flgatras = 0 THEN
          -- Limpar dias em atraso
          vr_stdiasat := '';
        END IF;
        -- Diferente de Cheque Especial / Conta Garantida / Limite não Utilizado ou INDDOCTO=5
        IF vr_tab_individ(vr_idx_individ).cdmodali NOT IN(0201,1901) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN
          -- Para empréstimos / financiamentos OU inddocto=5
          IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN
            -- Busca a modalidade com base nos emprestimos
            vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_individ(vr_idx_individ).cdmodali
                                                    ,pr_cdcooper
                                                    ,vr_tab_individ(vr_idx_individ).nrdconta
                                                    ,vr_tab_individ(vr_idx_individ).nrctremp
                                                    ,vr_tab_individ(vr_idx_individ).inpessoa
                                                    ,vr_tab_individ(vr_idx_individ).cdorigem
                                                    ,vr_tab_individ(vr_idx_individ).dsinfaux);
            -- Busca a organização
            vr_dsorgrec := fn_busca_dsorgrec(vr_tab_individ(vr_idx_individ).cdmodali
                                            ,vr_tab_individ(vr_idx_individ).nrdconta
                                            ,vr_tab_individ(vr_idx_individ).nrctremp
                                            ,vr_tab_individ(vr_idx_individ).cdorigem
                                            ,vr_tab_individ(vr_idx_individ).dsinfaux);
                                
            -- Buscar valor do contrato para inddocto = 5
            IF vr_tab_individ(vr_idx_individ).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(vr_tab_individ(vr_idx_individ).dsinfaux) THEN
              -- Verificar se existe o movimento na tabela de origem das informações
              vr_vlrctado := vr_tab_mvto_garant_prest(vr_tab_individ(vr_idx_individ).dsinfaux).vloperac;
            ELSE 
            
              -- Somente para emprestimos que não são do BNDES e origem 3
              IF vr_tab_individ(vr_idx_individ).dsinfaux <> 'BNDES' AND vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN              
                -- Se existir CrapEpr
                vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                           || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                -- Se o contrato for uma liquidação de outro contrato
                IF vr_tab_crapepr(vr_ind_epr).qtctrliq > 0 THEN
                  IF vr_caracesp IS NOT NULL THEN
                    vr_caracesp := vr_caracesp||';';
                  END IF;
                  vr_caracesp := vr_caracesp || '01';
                END IF;
              END IF; --Não BNDES
                        
              IF vr_tab_individ(vr_idx_individ).dsinfaux = 'BNDES' THEN
              
                vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                           || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                         
              
			    IF vr_tab_crapebn.exists(vr_ind_epr) THEN
			      IF vr_caracesp IS NULL THEN
  	                vr_caracesp := '17';
                  ELSE
				    vr_caracesp := vr_caracesp || ';17';
			      END IF;
			    END IF;
              
              ELSE
                -- Se existir crapepr
                vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                           || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                           
                -- Verifica se linha de microcredito
                IF vr_tab_craplcr.EXISTS(vr_tab_crapepr(vr_ind_epr).cdlcremp) THEN

                  IF vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).dsorgrec <> ' '
                    AND vr_tab_craplcr(vr_tab_crapepr(vr_ind_epr).cdlcremp).cdusolcr = 1  THEN
                
                    IF vr_caracesp IS NULL THEN
                      vr_caracesp := '17';
                    ELSE
                      vr_caracesp := vr_caracesp || ';17';
                    END IF;
                
                  END IF;  															
  
                END IF;
              
              END IF;
            END IF;
            
            
          ELSE
            vr_cdmodali := vr_tab_individ(vr_idx_individ).cdmodali;
            vr_dsorgrec := '0199';
          END IF;
          -- Se for pessoa juridica e modalidade igual a 203
          IF vr_tab_individ(vr_idx_individ).inpessoa = 2 AND vr_cdmodali = '0203' THEN
            -- substituir modalidade 0203 pela 0206 capital de giro 
            vr_cdmodali := '0206';
          END IF;
          -- Montar informação do Valor Contratado
          vr_dsvlrctd := ' VlrContr="' || replace(to_char(vr_vlrctado,'fm99999999999999990D00'),',','.') || '"' ;
          
        ELSE
          -- Mod. Excluida - Antiga Chq Esp. e Conta Garantida
          IF vr_tab_individ(vr_idx_individ).cdmodali = 0201 THEN 
            vr_cdmodali := '0213'; -- Cheque Especial
          ELSE
            vr_cdmodali := vr_tab_individ(vr_idx_individ).cdmodali;
          END IF;
          -- Usar fixo 0199
          vr_dsorgrec := '0199';
          -- Não existe valor contratado
          vr_dsvlrctd := ' ';
        END IF;
        
        -- Incluir caracteristica especial para inddocto=5
        IF vr_tab_individ(vr_idx_individ).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(vr_tab_individ(vr_idx_individ).dsinfaux) THEN
          -- Buscar a caracteris no cadastro do movimento
          -- Se já existir algo
          IF vr_caracesp IS NOT NULL THEN
            vr_caracesp := vr_caracesp||';';
          END IF;
          vr_caracesp := vr_caracesp||vr_tab_mvto_garant_prest(vr_tab_individ(vr_idx_individ).dsinfaux).dscarces;
        END IF;

        -- Com base na modalidade encontrada retorna o Cosif (Plano Contábil das Instituições do Sistema Financeiro Nacional)
        vr_ctacosif := fn_busca_cosif(vr_cdmodali
                                     ,vr_tab_individ(vr_idx_individ).inpessoa
                                     ,vr_tab_individ(vr_idx_individ).inddocto
                                     ,vr_tab_individ(vr_idx_individ).dsinfaux);
        
        -- Numero do contrato formatado para o arquivo 3040
        vr_nrcontrato_3040 := fn_formata_numero_contrato(pr_cdcooper => pr_cdcooper
                                                        ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                                        ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                                                        ,pr_cdmodali => vr_cdmodali);
                                                        
        -- Enviar detalhes da operação
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => ' Contrt="' || TRIM(vr_nrcontrato_3040) || '"' 
                                                  || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                                                  || ' Cosif="' || vr_ctacosif || '"' 
                                                  || ' OrigemRec="' || vr_dsorgrec || '"'  -- Era fixo '0199', agora, retorna do pc_busca_modalidade
                                                  || ' Indx="' || vr_coddindx || '"' 
                                                  || vr_stperidx 
                                                  || ' VarCamb="'||fn_varcambial(vr_tab_individ(vr_idx_individ).inddocto,vr_tab_individ(vr_idx_individ).dsinfaux)||'"' 
                                                  || ' CEP="' || fn_cepende(vr_tab_individ(vr_idx_individ).inddocto,vr_tab_individ(vr_idx_individ).dsinfaux) || '"' 
                                                  || ' TaxEft="' || replace(to_char(vr_txeanual,'fm990D00'),',','.') || '"' 
                                                  || ' DtContr="' || to_char(vr_tab_individ(vr_idx_individ).dtinictr,'yyyy-mm-dd') || '"' 
                                                  || vr_dsvlrctd
                                                  || ' NatuOp="' || TRIM(vr_cdnatuop) || '"' 
                                                  || ' DtVencOp="' || NVL(to_char(vr_dtfimctr,'YYYY-MM-DD'),'0000-00-00') || '"'  
                                                  || ' ClassOp="' || vr_cloperis || '"' 
                                                  || ' ProvConsttd="' ||replace(to_char(vr_vlpreatr,'fm99999999999999990D00'),',','.')||'"'
                                                  || vr_stdiasat 
                                                  || ' CaracEspecial="' || vr_caracesp ||'"');
        -- Tratar campos do Fluxo Financeiro
        pc_gera_fluxo_financeiro(pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                ,pr_dtrefere => vr_dtrefere
                                ,pr_inddocto => vr_tab_individ(vr_idx_individ).inddocto                                
                                ,pr_cdinfadi => vr_tab_individ(vr_idx_individ).cdinfadi
                                ,pr_innivris => vr_tab_individ(vr_idx_individ).innivris
                                ,pr_cdmodali => vr_tab_individ(vr_idx_individ).cdmodali
                                ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                                ,pr_nrseqctr => vr_tab_individ(vr_idx_individ).nrseqctr
                                ,pr_dtprxpar => vr_tab_individ(vr_idx_individ).dtprxpar
                                ,pr_vlprxpar => vr_tab_individ(vr_idx_individ).vlprxpar
                                ,pr_qtparcel => vr_tab_individ(vr_idx_individ).qtparcel); 
        -- Fechar a Tag Op                                         
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '>' || chr(10) 
                                                  ||'            <Venc');
        -- Inicializar valores em atraso  
        vr_vlpreatr := 0;
        -- tratamento de normalizacao de juros com cdvencto >=230 ou <=290
        vr_indice_venc := vr_tab_venc.first;
        WHILE vr_indice_venc IS NOT NULL LOOP
          IF vr_tab_venc(vr_indice_venc).cdvencto >= 230 AND vr_tab_venc(vr_indice_venc).cdvencto <= 290 THEN
            EXIT;
          END IF;
          vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
        END LOOP;
        -- Se encontrou vencimento
        IF vr_indice_venc IS NOT NULL THEN
          -- Calcular valor total da divida
          vr_ttldivid := fn_total_divida(230,290,vr_tab_venc);
          -- Acumula as faixas desprezando a primeira
          vr_vljurfai := 0;
          vr_flgfirst := 1;
          WHILE vr_indice_venc IS NOT NULL LOOP
            IF vr_tab_venc(vr_indice_venc).cdvencto >= 230 AND vr_tab_venc(vr_indice_venc).cdvencto <= 290 THEN
              IF vr_flgfirst = 1 THEN
                 vr_flgfirst := 0;
                 vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
                 continue;
              END IF;
              -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
              vr_vlacumul := fn_normaliza_juros(vr_ttldivid
                                               ,vr_tab_venc(vr_indice_venc).vldivida
                                               ,vr_tab_individ(vr_idx_individ).vljura60
                                               ,FALSE);
              vr_vljurfai := vr_vljurfai + vr_vlacumul;
            END IF;
            vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
          END LOOP;
         -- fim do acumula faixa 
        END IF;
        -- fim tratamento de normalizacao de juros 
        vr_flgfirst := 1;
        vr_indice_venc := vr_tab_venc.first;
        WHILE vr_indice_venc IS NOT NULL LOOP
          IF vr_tab_venc(vr_indice_venc).cdvencto >= 230 AND vr_tab_venc(vr_indice_venc).cdvencto <= 290 THEN
            IF vr_flgfirst = 1 THEN
               vr_vldivnor := vr_ttldivid - vr_tab_individ(vr_idx_individ).vljura60 - vr_vljurfai;
               vr_flgfirst := 0;
            ELSE
              -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
              vr_vldivnor := fn_normaliza_juros(vr_ttldivid
                                               ,vr_tab_venc(vr_indice_venc).vldivida
                                               ,vr_tab_individ(vr_idx_individ).vljura60
                                               ,true);
            END IF;
          ELSE
            vr_vldivnor := vr_tab_venc(vr_indice_venc).vldivida;
          END IF;
          -- Se a modalidade ainda não foi inicializada
          IF NOT vr_tab_totmodali.exists(vr_cdmodali) THEN
            vr_tab_totmodali(vr_cdmodali) := 0;
          END IF;

          IF vr_vldivnor <> 0 THEN             
          -- Acumular
          vr_tab_totmodali(vr_cdmodali) := vr_tab_totmodali(vr_cdmodali) + nvl(vr_vldivnor,0);          
          -- Enviar vencimento
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => ' v' || vr_tab_venc(vr_indice_venc).cdvencto 
                                                    || '="' || replace(to_char(vr_vldivnor,'fm99999999990D00'),',','.') 
                                                    || '"');
          END IF;  
                                                              
          vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
        END LOOP;
        -- Finaliza a TAG <Venc> 
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '/>'||chr(10));
        -- Quando existir mais de um contrato de origem = 1 (Conta)
        -- os garantidores devem ir preferencialmente no limite não utilizado (1901),
        -- então testamos a flag que é ativa quando já foram enviados os garantidores no CPF
        IF vr_tab_individ(vr_idx_individ).cdorigem = 1 THEN
          -- Enviar sempre que for de Limite não utilizado, ou do contrário enviar somente 
          -- se a flag estiver falsa ainda, ou seja, ainda não enviamos pelo 1901 ou inexiste
          IF vr_tab_individ(vr_idx_individ).cdmodali = 1901 OR NOT vr_flgarant THEN
            -- Enviar Avalistas 
            pc_verifica_garantidores;          
          END IF;          
          -- Ativamos a Flag
          vr_flgarant := TRUE;
        ELSE
          -- Enviamos os garantidores independente da modalidade
          pc_verifica_garantidores;          
        END IF;  
        -- Bens Alienados 
        pc_garantia_alienacao_fid;
        -- Imprime o tipo informando que eh aplicacao regulatoria, quando o emprestimo possuir linhas de credito
        pc_inf_aplicacao_regulatoria(vr_tab_individ(vr_idx_individ).nrdconta,
                                     vr_tab_individ(vr_idx_individ).nrctremp,
                                     vr_tab_individ(vr_idx_individ).cdmodali,
                                     vr_tab_individ(vr_idx_individ).cdorigem,
                                     vr_tab_individ(vr_idx_individ).dsinfaux);
        -- Imprime o codigo do chassi
        pc_verifica_inf_chassi(vr_tab_individ(vr_idx_individ).nrdconta,
                               vr_tab_individ(vr_idx_individ).nrctremp,
                               vr_tab_individ(vr_idx_individ).cdmodali,
                               vr_tab_individ(vr_idx_individ).cdorigem,
                               vr_tab_individ(vr_idx_individ).dsinfaux);
        vr_vlrdivid := vr_tab_individ(vr_idx_individ).vldivida - vr_tab_individ(vr_idx_individ).vljura60;
        -- TAG <Inf> para NatuOp="02" emprestimos/financiamentos migrados
        IF ( vr_cdnatuop = '02' ) THEN
          vr_idcpfcgc := '';
          -- Somente na Viacredi
          IF pr_cdcooper = 1 THEN
            -- Abre o cursor de cooperativas
            OPEN cr_crapcop(2);
            FETCH cr_crapcop INTO rw_crapcop_2;
            CLOSE cr_crapcop;
            vr_idcpfcgc := substr(lpad(rw_crapcop_2.nrdocnpj,14,'0'),1,8);
          -- Somente na AltoVale
          ELSIF pr_cdcooper = 16 THEN
            -- Abre o cursor de cooperativas
            OPEN cr_crapcop(1);
            FETCH cr_crapcop INTO rw_crapcop_2;
            CLOSE cr_crapcop;
            vr_idcpfcgc := substr(lpad(rw_crapcop_2.nrdocnpj,14,'0'),1,8);
          END IF;
          
          IF vr_tab_individ(vr_idx_individ).flcessao = 1 THEN
            -- Enviar informação adicional da operação
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '            <Inf Tp="1001" Cd="'|| to_char(vr_tab_individ(vr_idx_individ).dtinictr,'RRRR-MM-DD')
                                                      || '" Ident="02038232" '
                                                      || 'Valor="' || replace(to_char(vr_tab_crapepr(vr_ind_epr).vlemprst,'fm99999999999999990D00'),',','.')
                                                      || '"/>' || chr(10));
          ELSE          
            -- Enviar informação adicional da operação
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '            <Inf Tp="1001" Cd="2013-01-02" Ident="'||vr_idcpfcgc||'" '
                                                      || 'Valor="' || replace(to_char(vr_vlrdivid,'fm99999999999999990D00'),',','.')
                                                      || '"/>' || chr(10));
          
          END IF;
        END IF;
        -- Verificação do Ente Consignante
        pc_inf_ente_consignante(pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                               ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                               ,pr_cdmodali => vr_tab_individ(vr_idx_individ).cdmodali
                               ,pr_dsinfaux => vr_tab_individ(vr_idx_individ).dsinfaux);
        
        -- Finaliza a TAG <Op>
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '        </Op>' ||chr(10));
        -- Verifica se eh o ultimo registro da conta
        IF vr_tab_individ.next(vr_idx_individ) IS NULL OR vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_tab_individ(vr_tab_individ.next(vr_idx_individ)).nrcpfcgc THEN -- Se o CGC/CPF for diferente do proximo
          -- Imprimir as saidas deste cliente
          pc_busca_saidas(vr_tab_individ(vr_idx_individ).nrcpfcgc,
                          vr_tab_individ(vr_idx_individ).innivris,
                          vr_tab_individ(vr_idx_individ).inpessoa);
          -- Finaliza a tag do cliente
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => '    </Cli>' ||chr(10));
        END IF;
        
        IF vr_tab_individ.prior(vr_idx_individ) IS NULL OR  -- Se for o primeiro registro
           vr_tab_individ.next(vr_idx_individ)  IS NULL OR   -- ou se for o ultimo
           vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_tab_individ(vr_tab_individ.next(vr_idx_individ)).nrcpfcgc THEN -- Se o CGC/CPF for diferente do anterior
           -- Conta a quantidade de clientes do arquivo 3040
           vr_contacli := vr_contacli + 1;
           ------------------------------------------------------------------------------------------------
           -- INICIO PARA VERIFICAR A DIVISAO DO ARQUIVO 3040 EM PARTES
           ------------------------------------------------------------------------------------------------
           IF vr_contacli >= vr_qtregarq_3040 THEN
             -- Condicao para verificar se eh o ultimo arquivo particionado
             IF NOT vr_tab_individ.EXISTS(vr_tab_individ.NEXT(vr_idx_individ)) AND 
                vr_tab_saida.first IS NULL AND vr_tab_agreg.first IS NULL      THEN
                vr_flgfimaq := TRUE;
             END IF;
           
             -- Solicita para gerar o arquivo 3040 particionado
             pc_solicita_relato_3040(pr_nrdocnpj      => rw_crapcop.nrdocnpj
                                    ,pr_dsnomscr      => rw_crapcop.dsnomscr
                                    ,pr_dsemascr      => rw_crapcop.dsemascr
                                    ,pr_dstelscr      => rw_crapcop.dstelscr
                                    ,pr_cdprogra      => vr_cdprogra
                                    ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                    ,pr_dtrefere      => vr_dtrefere
                                    ,pr_flgfimaq      => vr_flgfimaq
                                    ,pr_totalcli      => vr_totalcli
                                    ,pr_nom_direto    => vr_nom_dirsal
                                    ,pr_nom_dirmic    => vr_nom_dirmic
                                    ,pr_numparte      => vr_numparte
                                    ,pr_xml_3040      => vr_xml_3040
                                    ,pr_xml_3040_temp => vr_xml_3040_temp
                                    ,pr_cdcritic      => vr_cdcritic
                                    ,pr_dscritic      => vr_dscritic);
                                    
             -- Condicao para verificar se houve erro
             IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             
             -- Zera o contador de cliente
             vr_contacli := 0;
           END IF;
        END IF;   
                
        -- Vai para o proximo registro
        vr_idx_individ := vr_tab_individ.next(vr_idx_individ);
      END LOOP; -- loop sobre a pl_table vr_tab_individ
      
      -- Imprimir contratos de saída da operação que ainda não foram enviados ao Doc3040
      -- OU seja, aqueles clientes que não possuiam nenhum contrato ativo
      vr_indice_crapris := vr_tab_saida.first;
      WHILE vr_indice_crapris IS NOT NULL LOOP
        vr_fatanual := 0;
        vr_vlrrendi := 0;
        vr_portecli := 0;
        -- Infos do Cliente
        IF vr_indice_crapris = vr_tab_saida.first OR -- Se for o primeiro registro
           vr_tab_saida(vr_indice_crapris).sbcpfcgc <> vr_tab_saida(vr_tab_saida.prior(vr_indice_crapris)).sbcpfcgc THEN -- Se o cpf/cnpj anterior for diferente do atual
          -- Busca o cadastro de associados
          OPEN cr_crapass(vr_tab_saida(vr_indice_crapris).nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          IF cr_crapass%NOTFOUND THEN
            vr_cdcritic := 009;
            RAISE vr_exc_saida;
          END IF;
          -- Fecha o cursor de associados
          CLOSE cr_crapass;
          IF rw_crapass.dtadmiss IS NULL OR to_char(rw_crapass.dtadmiss,'yyyy') < 1000 THEN
            vr_dtabtcct := trunc(SYSDATE);
          ELSE
            vr_dtabtcct := rw_crapass.dtadmiss;
          END IF;
          IF rw_crapass.dsnivris = 'HH' THEN
            vr_classcli := 'H';
          ELSIF TRIM(rw_crapass.dsnivris) IS NOT NULL THEN
            vr_classcli := rw_crapass.dsnivris;
          ELSE
            vr_classcli := 'A';  
          END IF;
          IF vr_tab_saida(vr_indice_crapris).inpessoa = 1 THEN
            -- Abre o cursor de titulares da conta
            OPEN cr_crapttl(vr_tab_saida(vr_indice_crapris).nrdconta);
            FETCH cr_crapttl INTO rw_crapttl;
            IF cr_crapttl%FOUND THEN -- Se encontrou registro
              -- Somar salário + aplicações
              vr_vlrrendi := rw_crapttl.vlsalari + rw_crapttl.vldrendi##1 + rw_crapttl.vldrendi##2 + rw_crapttl.vldrendi##3 +
                            rw_crapttl.vldrendi##4 + rw_crapttl.vldrendi##5 + rw_crapttl.vldrendi##6;
            END IF;
            CLOSE cr_crapttl; -- Fecha o cursor de titulares da conta
            -- Classifica o porte do cliente
            vr_portecli := fn_classifi_porte_pf(vr_vlrrendi);
            -- Valor do rendimento nao pode ser zero
            IF vr_vlrrendi = 0 THEN
              vr_vlrrendi := 0.01;
            END IF;
              
            -- Gerar tag do Cliente Fisico
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '    <Cli Cd="' || to_char(vr_tab_saida(vr_indice_crapris).nrcpfcgc,'fm00000000000') || '"' 
                                                      || ' Tp="1"' 
                                                      || ' Autorzc="S"' 
                                                      || ' PorteCli="' || vr_portecli || '"' 
                                                      || ' IniRelactCli="' || to_char(vr_dtabtcct,'yyyy-mm-dd') || '"' 
                                                      || ' FatAnual="' || replace(to_char(vr_vlrrendi,'fm9999999999990D00'),',','.') || '"' 
                                                      || ' ClassCli="' || vr_classcli || '">' || chr(10));
          ELSE --vr_tab_saida(vr_indice_crapris).inpessoa <> 1
            OPEN cr_crapjfn(vr_tab_saida(vr_indice_crapris).nrdconta);
            FETCH cr_crapjfn INTO vr_fatanual;
            CLOSE cr_crapjfn; -- Fecha o cursor dos dados financeiros de PJ
            -- Validador nao aceita faturamento zerado nem negativo 
            IF vr_fatanual <= 0 THEN
              vr_fatanual := 1;
            END IF;
            -- Classifica o porte do cliente
            vr_portecli := fn_classifi_porte_pj(vr_fatanual);
            -- Formatar cnpj
            vr_nrdocnpj := to_char(vr_tab_saida(vr_indice_crapris).nrcpfcgc,'fm00000000000000');
            -- Gerar Tag do cliente Juridico
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '    <Cli Cd="' || substr(vr_nrdocnpj,1,8) || '"' 
                                                      || ' Tp="2"' 
                                                      || ' Autorzc="S"' 
                                                      || ' PorteCli="' || vr_portecli || '"' 
                                                      || ' TpCtrl="01"' 
                                                      || ' IniRelactCli="' ||to_char(vr_dtabtcct,'yyyy-mm-dd') || '"' 
                                                      || ' FatAnual="' || replace(to_char(vr_fatanual,'fm99999999999999990D00'),',','.') ||'"' 
                                                      || ' ClassCli="' || vr_classcli || '">' || chr(10));
          END IF; -- vr_tab_saida(vr_indice_crapris).inpessoa = 1
        END IF; -- Primeiro CPF / CNPF diferente
        
        -- Chamar código comum para impressão da OP de saída
        pc_imprime_saida(pr_innivris => vr_tab_saida(vr_indice_crapris).innivris
                        ,pr_idxsaida => vr_indice_crapris); 
          
        -- Se for o ultimo registro
        IF vr_tab_saida.next(vr_indice_crapris) IS NULL OR vr_tab_saida(vr_indice_crapris).sbcpfcgc <> vr_tab_saida(vr_tab_saida.next(vr_indice_crapris)).sbcpfcgc THEN -- Se o cpf/cnpj posterior for diferente do atual
          -- Encerrar a tag do cliente
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '    </Cli>' || chr(10));
        END IF;
        vr_indice_crapris := vr_tab_saida.next(vr_indice_crapris);
      END LOOP;
      -- fim da impressao das saídas
      
      -- Por fim, geração das informações agregadas
      vr_indice_agreg := vr_tab_agreg.first;
      WHILE vr_indice_agreg IS NOT NULL LOOP
        vr_vlpreatr := 0;
        vr_innivris := vr_tab_agreg(vr_indice_agreg).innivris;
        -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
        vr_cloperis := fn_classifica_risco(pr_innivris => vr_innivris);
        -- Calcular a provisao 
        -- Para risco <> 10 soma as variveis de provisao 
        -- LImite não contratado (1901) também não calculará provisão
        IF vr_tab_agreg(vr_indice_agreg).innivris <> 10 AND vr_tab_agreg(vr_indice_agreg).cdmodali <> 1901 THEN
          vr_vlpercen := vr_tab_percentual(vr_tab_agreg(vr_indice_agreg).innivris).percentual / 100;
          vr_vlpreatr := ROUND(( (vr_tab_agreg(vr_indice_agreg).vldivida - vr_tab_agreg(vr_indice_agreg).vljura60 ) * vr_vlpercen),2);
        END IF;
        -- Busca a modalidade com base nos emprestimos
        vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_agreg(vr_indice_agreg).cdmodali
                                                ,pr_cdcooper
                                                ,vr_tab_agreg(vr_indice_agreg).nrdconta
                                                ,vr_tab_agreg(vr_indice_agreg).nrctremp
                                                ,vr_tab_agreg(vr_indice_agreg).inpessoa
                                                ,vr_tab_agreg(vr_indice_agreg).cdorigem
                                                ,vr_tab_agreg(vr_indice_agreg).dsinfaux);
        -- Busca a organização
        vr_dsorgrec := fn_busca_dsorgrec(vr_tab_agreg(vr_indice_agreg).cdmodali
                                        ,vr_tab_agreg(vr_indice_agreg).nrdconta
                                        ,vr_tab_agreg(vr_indice_agreg).nrctremp
                                        ,vr_tab_agreg(vr_indice_agreg).cdorigem
                                        ,vr_tab_agreg(vr_indice_agreg).dsinfaux);                              
        -- Enviar a informação agregada
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '    <Agreg' 
                                                  || ' NatuOp="' || vr_tab_agreg(vr_indice_agreg).cdnatuop || '"' 
                                                  || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                                                  || ' OrigemRec="0100"' 
                                                  || ' VincME="N"' 
                                                  || ' ClassOp="' || vr_cloperis || '"' 
                                                  || ' FaixaVlr="' || vr_tab_agreg(vr_indice_agreg).cddfaixa || '"' 
                                                  || ' Localiz="' || fn_localiza_uf(pr_sig_UF => rw_crapcop.cdufdcop) || '"' 
                                                  || ' TpCli="' || vr_tab_agreg(vr_indice_agreg).inpessoa || '"' 
                                                  || ' TpCtrl="01"' 
                                                  || ' DesempOp="' || to_char(vr_tab_agreg(vr_indice_agreg).cddesemp,'fm00') || '"' 
                                                  || ' ProvConsttd="' || replace(to_char(vr_vlpreatr,'fm999999990D00'),',','.') || '"' 
                                                  || ' QtdOp="' || vr_tab_agreg(vr_indice_agreg).qtoperac || '"' 
                                                  || ' QtdCli="' || vr_tab_agreg(vr_indice_agreg).qtcooper || '">' ||chr(10) 
                                                  || '        <Venc');
        -- tratamento de normalizacao de juros com cdvencto >=230 ou <=290
        vr_indice_venc_agreg := vr_tab_venc_agreg.first;
        WHILE vr_indice_venc_agreg IS NOT NULL LOOP
          IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto >= 230 AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto <= 290 AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali = vr_tab_agreg(vr_indice_agreg).cdmodali AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).innivris = vr_tab_agreg(vr_indice_agreg).innivris AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa = vr_tab_agreg(vr_indice_agreg).cddfaixa AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa = vr_tab_agreg(vr_indice_agreg).inpessoa AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp = vr_tab_agreg(vr_indice_agreg).cddesemp AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop = vr_tab_agreg(vr_indice_agreg).cdnatuop THEN
            EXIT;
          END IF;
          vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
        END LOOP;
        IF vr_indice_venc_agreg IS NOT NULL THEN
          -- Retorna o valor total da divida da faixa 230 a 290
          vr_ttldivid := fn_total_divida_agreg(230
                                              ,290
                                              ,vr_tab_agreg(vr_indice_agreg).cdmodali
                                              ,vr_tab_agreg(vr_indice_agreg).innivris
                                              ,vr_tab_agreg(vr_indice_agreg).cddfaixa
                                              ,vr_tab_agreg(vr_indice_agreg).inpessoa
                                              ,vr_tab_agreg(vr_indice_agreg).cddesemp
                                              ,vr_tab_agreg(vr_indice_agreg).cdnatuop
                                              ,vr_tab_venc_agreg);
          -- acumular faixas desprezando a primeira 
          vr_vljurfai := 0;
          vr_flgfirst := 1;
          WHILE vr_indice_venc_agreg IS NOT NULL LOOP
            IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto >= 230 AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto <= 290 AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali = vr_tab_agreg(vr_indice_agreg).cdmodali AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).innivris = vr_tab_agreg(vr_indice_agreg).innivris AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa = vr_tab_agreg(vr_indice_agreg).cddfaixa AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa = vr_tab_agreg(vr_indice_agreg).inpessoa AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp = vr_tab_agreg(vr_indice_agreg).cddesemp AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop = vr_tab_agreg(vr_indice_agreg).cdnatuop THEN
              IF vr_flgfirst = 1 THEN
                vr_flgfirst := 0;
                vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
                continue;
              END IF;
              -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
              vr_vlacumul := fn_normaliza_juros(vr_ttldivid
                                               ,vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida
                                               ,vr_tab_agreg(vr_indice_agreg).vljura60
                                               ,false);
              vr_vljurfai := vr_vljurfai + vr_vlacumul;
            END IF;
            vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
          END LOOP;
        END IF;
        -- fim tratamento de normalizacao de juros 
        vr_vlpreatr := 0;
        vr_flgfirst := 1;
        vr_indice_venc_agreg := vr_tab_venc_agreg.first;
        WHILE vr_indice_venc_agreg IS NOT NULL LOOP
          IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali = vr_tab_agreg(vr_indice_agreg).cdmodali AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).innivris = vr_tab_agreg(vr_indice_agreg).innivris AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa = vr_tab_agreg(vr_indice_agreg).cddfaixa AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa = vr_tab_agreg(vr_indice_agreg).inpessoa AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp = vr_tab_agreg(vr_indice_agreg).cddesemp AND
             vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop = vr_tab_agreg(vr_indice_agreg).cdnatuop THEN
            IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto >= 230 AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto <= 290 THEN
              IF vr_flgfirst = 1 THEN
                vr_vldivnor := vr_ttldivid - vr_tab_agreg(vr_indice_agreg).vljura60 - vr_vljurfai;
                vr_flgfirst := 0;
              ELSE
                -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
                vr_vldivnor := fn_normaliza_juros(vr_ttldivid
                                                 ,vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida
                                                 ,vr_tab_agreg(vr_indice_agreg).vljura60
                                                 ,true);
              END IF;
            ELSE
              vr_vldivnor := vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida;
            END IF;
            -- Se a modalidade ainda não foi inicializada
            IF NOT vr_tab_totmodali.exists(vr_cdmodali) THEN
              vr_tab_totmodali(vr_cdmodali) := 0;
            END IF;

            IF vr_vldivnor <> 0 THEN    
            -- Acumular
            vr_tab_totmodali(vr_cdmodali) := vr_tab_totmodali(vr_cdmodali) + nvl(vr_vldivnor,0);                      
            -- Enviar o vencimento
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => ' v' || vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto 
                                                      ||'="' || replace(to_char(vr_vldivnor, 'fm999999990D00'),',','.') || '"');
          END IF;
          END IF;
          vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
        END LOOP;
        -- Finaliza a TAG <Venc> 
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                               ,pr_texto_completo => vr_xml_3040_temp
                               ,pr_texto_novo     => '/>' || chr(10) || '    </Agreg>' || chr(10));
        vr_indice_agreg := vr_tab_agreg.next(vr_indice_agreg);
      END LOOP;
      
      -- Condicao para verificar se jah foi enviado a ultima parte do arquivo 3040
      IF NOT vr_flgfimaq THEN
        -- Solicita para gerar o arquivo 3040 particionado
        pc_solicita_relato_3040(pr_nrdocnpj      => rw_crapcop.nrdocnpj
                               ,pr_dsnomscr      => rw_crapcop.dsnomscr
                               ,pr_dsemascr      => rw_crapcop.dsemascr
                               ,pr_dstelscr      => rw_crapcop.dstelscr
                               ,pr_cdprogra      => vr_cdprogra
                               ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                               ,pr_dtrefere      => vr_dtrefere
                               ,pr_flgfimaq      => TRUE
                               ,pr_totalcli      => vr_totalcli
                               ,pr_nom_direto    => vr_nom_dirsal
                               ,pr_nom_dirmic    => vr_nom_dirmic
                               ,pr_numparte      => vr_numparte
                               ,pr_xml_3040      => vr_xml_3040
                               ,pr_xml_3040_temp => vr_xml_3040_temp
                               ,pr_cdcritic      => vr_cdcritic
                               ,pr_dscritic      => vr_dscritic);
                                    
        -- Condicao para verificar se houve erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      
      END IF; /* END IF NOT vr_flgfimaq THEN */
      
      -- Impressao Relatorios -566 - RISCO 9(Tambem acumula p/rel 566)---- 
      -- Instanciar o CLOB
      dbms_lob.createtemporary(vr_xml_566, TRUE);
      dbms_lob.open(vr_xml_566, dbms_lob.lob_readwrite);
      -- Incializar o XML
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                             ,pr_texto_completo => vr_xml_566_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="WINDOWS-1252"?>'
                                                || '<crrl566>'||'<tipo9>');
      -- efetua um loop sobre as informacoes da central de risco
      for rw_crapris in cr_crapris_2(vr_dtrefere) loop
        if rw_crapris.nrseq = 1 then
          vr_rsvec180 := 0;
          vr_rsvec360 := 0;  -- Totais Risco 9 
          vr_rsvec999 := 0;
          vr_rsdiv060 := 0;
          vr_rsdiv180 := 0;
          vr_rsdiv360 := 0;
          vr_rsdiv999 := 0;
          vr_rsprjano := 0;
          vr_rsprjaan := 0;
          vr_rsdivida := 0;
          vr_rsprjant := 0;
          vr_nrcpfcgc := '';
          -- Se for pessoa juridica utiliza somente a base do CNPJ
          IF rw_crapris.inpessoa = 2 THEN
             vr_nrcpfcgc := SUBSTR(lpad(rw_crapris.nrcpfcgc,14,'0'),1,8);
          end if;
        end if;
        -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
        IF pr_cdcooper IN (1,16,9) THEN
          -- Se for uma conta migrada nao deve processar
          IF fn_eh_conta_migracao_573(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapris.nrdconta
                                     ,pr_dtrefere => rw_crapris.dtrefere) THEN
            continue; -- Volta para o inicio do for
          END IF;
        END IF;
        -- Efetua o loop sobre o os vencimentos do risco
        vr_indice_crapvri_b := lpad(rw_crapris.nrdconta,10,'0') ||
                               lpad(rw_crapris.innivris,5,'0') ||
                               lpad(rw_crapris.cdmodali,5,'0') ||
                               lpad(rw_crapris.nrseqctr,5,'0') ||
                               lpad(rw_crapris.nrctremp,10,'0') ||
                               '0000000';
        vr_indice_crapvri := vr_indice_crapvri_b;
        vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
        WHILE vr_indice_crapvri_b IS NOT NULL LOOP
          -- Se nao for a mesma chave sai do loop
          IF substr(vr_indice_crapvri_b,1,35) <> substr(vr_indice_crapvri,1,35) THEN
            EXIT;
          END IF;
          -- Acumulando valores para o Resumo Rel.567 
          IF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 310 THEN
            vr_vlprjano := vr_vlprjano + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 320 THEN
            vr_vlprjaan := vr_vlprjaan + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 330 THEN
            vr_vlprjant := vr_vlprjant + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSE
            if vr_tab_divida.exists(rw_crapris.innivris) then
              vr_tab_divida(rw_crapris.innivris).divida :=
                    vr_tab_divida(rw_crapris.innivris).divida + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            else
              vr_tab_divida(rw_crapris.innivris).divida := vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            end if;
          end if;
          -- -- Risco 9 -- --
          IF rw_crapris.innivris = 9 THEN
            vr_rsdivida := vr_rsdivida + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            IF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 110    AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 140 THEN
              vr_rsvec180 := vr_rsvec180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto  = 150 THEN
              vr_rsvec360 := vr_rsvec360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >  150 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 199 THEN
              vr_rsvec999 := vr_rsvec999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 205 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 220 THEN
              vr_rsdiv060 := vr_rsdiv060 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 230 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 250 THEN
              vr_rsdiv180 := vr_rsdiv180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 255 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 270 THEN
              vr_rsdiv360 := vr_rsdiv360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 280 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 290 THEN
              vr_rsdiv999 := vr_rsdiv999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 310 THEN
              vr_rsprjano := vr_rsprjano + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 320 THEN
              vr_rsprjaan := vr_rsprjaan + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            ELSE
              vr_rsprjant := vr_rsprjant + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
            END IF;
          end if;
          -- Vai para o proximo registro da pl/table
          vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
        end loop; -- CRAPVRI
        -- Se for o ultimo registro
        if rw_crapris.nrseq = rw_crapris.qtreg and vr_rsdivida > 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                 ,pr_texto_completo => vr_xml_566_temp
                                 ,pr_texto_novo     => '<conta>'
                                                    || '<nrdconta>'||gene0002.fn_mask_conta(rw_crapris.nrdconta)||'</nrdconta>'
                                                    || '<innivris>'||to_char(rw_crapris.innivris,'00')          ||'</innivris>'
                                                    || '<nrcpfcgc_raiz>'||vr_nrcpfcgc                           ||'</nrcpfcgc_raiz>'
                                                    || '<nrcpfcgc>'||rw_crapris.nrcpfcgc                        ||'</nrcpfcgc>'
                                                    || '<rsdivida>'||to_char(vr_rsdivida,'999G999G990D00')      ||'</rsdivida>' 
                                                    || '<rsvec180>'||to_char(vr_rsvec180,'999G999G990D00')      ||'</rsvec180>' 
                                                    || '<rsvec360>'||to_char(vr_rsvec360,'999G999G990D00')      ||'</rsvec360>' 
                                                    || '<rsvec999>'||to_char(vr_rsvec999,'999G999G990D00')      ||'</rsvec999>' 
                                                    || '<rsdiv060>'||to_char(vr_rsdiv060,'999G999G990D00')      ||'</rsdiv060>' 
                                                    || '<rsdiv180>'||to_char(vr_rsdiv180,'999G999G990D00')      ||'</rsdiv180>' 
                                                    || '<rsdiv360>'||to_char(vr_rsdiv360,'999G999G990D00')      ||'</rsdiv360>' 
                                                    || '<rsdiv999>'||to_char(vr_rsdiv999,'999G999G990D00')      ||'</rsdiv999>' 
                                                    || '<rsprjano>'||to_char(vr_rsprjano,'999G999G990D00')      ||'</rsprjano>' 
                                                    || '<rsprjaan>'||to_char(vr_rsprjaan,'999G999G990D00')      ||'</rsprjaan>' 
                                                    || '<rsprjant>'||to_char(vr_rsprjant,'999G999G990D00')      ||'</rsprjant>' 
                                                    || '</conta>');
           vr_qtreg9 := vr_qtreg9 + 1;
        END IF;
      END loop; -- CRAPRIS
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                             ,pr_texto_completo => vr_xml_566_temp
                             ,pr_texto_novo     => '</tipo9>'
                                                || '<qtreg9>'||vr_qtreg9||'</qtreg9>'
                                                || '<vr1000>');
      -- Impressao Relatorios -566 - Valores > 1000 - Doc3040 --
      for rw_crapris in cr_crapris_2(vr_dtrefere) loop
        if rw_crapris.nrseq = 1 then
          vr_rsvec180 := 0;
          vr_rsvec360 := 0;  -- Vlr.> 1000 
          vr_rsvec999 := 0;
          vr_rsdiv060 := 0;
          vr_rsdiv180 := 0;
          vr_rsdiv360 := 0;
          vr_rsdiv999 := 0;
          vr_rsprjano := 0;
          vr_rsprjaan := 0;
          vr_rsdivida := 0;
          vr_rsprjant := 0;
          vr_nrcpfcgc := '';
          -- Se for pessoa juridica, utiliza somente a base do CNPJ
          IF rw_crapris.inpessoa = 2 THEN
             vr_nrcpfcgc := SUBSTR(lpad(rw_crapris.nrcpfcgc,14,'0'),1,8);
          end if;
        end if;
        -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
        IF pr_cdcooper IN (1,16,9) THEN
          -- Se for uma conta migrada nao deve processar
          IF fn_eh_conta_migracao_573(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapris.nrdconta
                                     ,pr_dtrefere => rw_crapris.dtrefere) THEN
            continue; -- Volta para o inicio do for
          END IF;
        END IF;
        -- Efetua o loop sobre o os vencimentos do risco
        vr_indice_crapvri_b := lpad(rw_crapris.nrdconta,10,'0') ||
                               lpad(rw_crapris.innivris,5,'0') ||
                               lpad(rw_crapris.cdmodali,5,'0') ||
                               lpad(rw_crapris.nrseqctr,5,'0') ||
                               lpad(rw_crapris.nrctremp,10,'0') ||
                               '0000000';
        vr_indice_crapvri := vr_indice_crapvri_b;
        vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
        WHILE vr_indice_crapvri_b IS NOT NULL LOOP
          -- Se nao for a mesma chave sai do loop
          IF substr(vr_indice_crapvri_b,1,35) <> substr(vr_indice_crapvri,1,35) THEN
            EXIT;
          END IF;
          vr_rsdivida := vr_rsdivida + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          IF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 110    AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 140 THEN
            vr_rsvec180 := vr_rsvec180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto  = 150 THEN
            vr_rsvec360 := vr_rsvec360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >  150 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 199 THEN
            vr_rsvec999 := vr_rsvec999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 205 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 220 THEN
            vr_rsdiv060 := vr_rsdiv060 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 230 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 250 THEN
            vr_rsdiv180 := vr_rsdiv180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 255 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 270 THEN
            vr_rsdiv360 := vr_rsdiv360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 280 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 290 THEN
            vr_rsdiv999 := vr_rsdiv999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 310 THEN
            vr_rsprjano := vr_rsprjano + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 320 THEN
            vr_rsprjaan := vr_rsprjaan + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          ELSE
            vr_rsprjant := vr_rsprjant + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
          END IF;
          -- Vai para o proximo registro da pl/table
          vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
        end loop;
        if rw_crapris.nrseq = rw_crapris.qtreg and rw_crapris.flgindiv > 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                 ,pr_texto_completo => vr_xml_566_temp
                                 ,pr_texto_novo     => '<conta>'
                                                    || '<nrdconta>'||gene0002.fn_mask_conta(rw_crapris.nrdconta)||'</nrdconta>'
                                                    || '<innivris>'||to_char(rw_crapris.innivris,'00')          ||'</innivris>'
                                                    || '<nrcpfcgc_raiz>'||vr_nrcpfcgc                           ||'</nrcpfcgc_raiz>'
                                                    || '<nrcpfcgc>'||rw_crapris.nrcpfcgc                        ||'</nrcpfcgc>'
                                                    || '<rsdivida>'||to_char(vr_rsdivida,'999G999G990D00')      ||'</rsdivida>' 
                                                    || '<rsvec180>'||to_char(vr_rsvec180,'999G999G990D00')      ||'</rsvec180>' 
                                                    || '<rsvec360>'||to_char(vr_rsvec360,'999G999G990D00')      ||'</rsvec360>' 
                                                    || '<rsvec999>'||to_char(vr_rsvec999,'999G999G990D00')      ||'</rsvec999>' 
                                                    || '<rsdiv060>'||to_char(vr_rsdiv060,'999G999G990D00')      ||'</rsdiv060>' 
                                                    || '<rsdiv180>'||to_char(vr_rsdiv180,'999G999G990D00')      ||'</rsdiv180>' 
                                                    || '<rsdiv360>'||to_char(vr_rsdiv360,'999G999G990D00')      ||'</rsdiv360>' 
                                                    || '<rsdiv999>'||to_char(vr_rsdiv999,'999G999G990D00')      ||'</rsdiv999>' 
                                                    || '<rsprjano>'||to_char(vr_rsprjano,'999G999G990D00')      ||'</rsprjano>' 
                                                    || '<rsprjaan>'||to_char(vr_rsprjaan,'999G999G990D00')      ||'</rsprjaan>' 
                                                    || '<rsprjant>'||to_char(vr_rsprjant,'999G999G990D00')      ||'</rsprjant>' 
                                                    ||'</conta>');
        END IF;
      END loop; -- CRAPRIS
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                             ,pr_texto_completo => vr_xml_566_temp
                             ,pr_texto_novo     => '</vr1000></crrl566>'
                             ,pr_fecha_xml      => true);
      
      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_xml_566,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl566',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl566.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl566.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 234,                            --> Quantidade de colunas
                                  pr_nmformul  => '234dh',                        --> Nome do formulario
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      -- Libera a memoria do clob vr_xml_566
      dbms_lob.close(vr_xml_566);
      dbms_lob.freetemporary(vr_xml_566);
      if vr_dscritic is not null then
        raise vr_exc_saida;
      end if;
      
      -- Impressao do relatorio resumido (567)
      -- Inicializando Clob
      dbms_lob.createtemporary(vr_xml_567, TRUE);
      dbms_lob.open(vr_xml_567, dbms_lob.lob_readwrite);
      
      -- Incializando xml
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="WINDOWS-1252"?>'
                                                || '<crrl567>'
                                                || '<dtrefere>' || to_char(vr_dtrefere,'YYYY/MM')          || '</dtrefere>' 
                                                || '<arquivos>' || vr_nmarqsai_tot       
                                                || '</arquivos>'
                                                || '<qtregarq>' || to_char(vr_qtregarq,'999G999G990') || '</qtregarq>');
      
      -- Inicializar a tabela de Riscos
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '<riscos>');      
      
      -- Montar tabela de níveis de risco e valor
      for idx IN 1..9 LOOP
        if vr_tab_divida.exists(idx) then
          vr_totgeral := vr_totgeral + vr_tab_divida(idx).divida;
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '<risco>'
                                                    || '<innivris>' || idx || '</innivris>'
                                                    || '<vldivida>'|| to_char(vr_tab_divida(idx).divida,'999G999G999G999G990D00') || '</vldivida>'
                                                    || '</risco>');
        end if;
      end loop;
      
      -- Fechar tabela de riscos
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '</riscos>');   
      
      -- Enviarmos os totais
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '<vlprjano>'|| to_char(vr_vlprjano,'9G999G999G990D00') || '</vlprjano>' 
                                                || '<vlprjaan>'|| to_char(vr_vlprjaan,'9G999G999G990D00') || '</vlprjaan>' 
                                                || '<vlprjant>'|| to_char(vr_vlprjant,'9G999G999G990D00') || '</vlprjant>' 
                                                || '<totgeral>'|| to_char(vr_totgeral + vr_vlprjano + vr_vlprjaan + vr_vlprjant,'9G999G999G990D00') || '</totgeral>');      
      -- Inicializar a tabela de modalidades
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '<tabmodali>');      
      -- Iterar sobrar a tabela de totais por modalidade
      vr_idx_totmodali := vr_tab_totmodali.first;
      LOOP
        EXIT WHEN vr_idx_totmodali IS NULL;
        -- Enviamos o nó correspondente a modalidade
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                               ,pr_texto_completo => vr_xml_567_temp
                               ,pr_texto_novo     => '<modali>' 
                                                  || '  <cdmodali>' || to_char(vr_idx_totmodali,'fm0000') || '</cdmodali>'
                                                  || '  <vlmodali>' || to_char(vr_tab_totmodali(vr_idx_totmodali),'fm999G999G999G999G990D00') || '</vlmodali>'
                                                  || '</modali>');
        -- Buscar o próximo
        vr_idx_totmodali := vr_tab_totmodali.next(vr_idx_totmodali);
      END LOOP;
      -- Encerrar a tabela de modalidades
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '</tabmodali>');      
      -- Encerrar o xml
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                             ,pr_texto_completo => vr_xml_567_temp
                             ,pr_texto_novo     => '</crrl567>'
                             ,pr_fecha_xml      => true);
      
      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_xml_567,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl567',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl567.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl567.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 80,                             --> Quantidade de colunas
                                  pr_nmformul  => '80col',                        --> Nome do formulario
                                  pr_sqcabrel  => 3,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      -- Libera a memoria do clob vr_xml_567
      dbms_lob.close(vr_xml_567);
      dbms_lob.freetemporary(vr_xml_567);
      if vr_dscritic is not null then
        raise vr_exc_saida;
      end if;
      
      -- Envio do log/mensagem para a contabilidade
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo normal
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || '663 --> '
                                                 || gene0001.fn_busca_critica(663) );
      -- Atualiza o indicador na tabela generica da cooperativa informando que o processo foi finalizado
      BEGIN
        UPDATE craptab
           SET dstextab = '2'||SUBSTR(dstextab,2,4000)
         WHERE craptab.cdcooper = pr_cdcooper
           AND upper(craptab.nmsistem) = 'CRED'
           AND upper(craptab.tptabela) = 'USUARI'
           AND craptab.cdempres = 11
           AND upper(craptab.cdacesso) = 'RISCOBACEN'
           AND craptab.tpregist = 000;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela CRAPTAB: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Salvar informações atualizadas
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps573;
/
