CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS171 (pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa solicitada
											  ,pr_flgresta IN PLS_INTEGER              --> Flag 0/1 para utilização de restar N/S
											  ,pr_stprogra OUT PLS_INTEGER             --> Saída de termino da execução
											  ,pr_infimsol OUT PLS_INTEGER             --> Saída de termino da solicitação
											  ,pr_cdoperad IN crapnrc.cdoperad%TYPE    --> Código do operador
											  ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Critica encontrada
											  ,pr_dscritic OUT VARCHAR2) IS            --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pc_crps171 (Antigo Fontes/crps171.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Outubro/96.                     Ultima atualizacao: 23/02/2017

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 001.
                   Debitar em conta corrente a prestacao dos emprestimos.
                   Emite relatorio 135.

       Alteracoes: 10/01/97 - Tratar CPMF (Odair).

                   04/02/97 - Arrumar calculo de saldo devido a abono (Odair)

                   27/08/97 - Alterado para incluir o campo flgproce na criacao
                              do crapavs (Deborah).

                   30/01/98 - Alterado para usar a rotina calcdata (Deborah).

                   16/02/98 - Alterar a data final do CPMF (Odair).

                   28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

                   02/06/1999 - Tratar CPMF (Deborah).

                   13/10/1999 - Imprimir fone quando ramal 9999. (Odair)

                   24/11/1999 - Colocar fone com 10 casas (Odair)

                   11/10/2000 - Alterar formato do telefone (Margarete/Planner)

                   06/03/2001 - Separar o relatorio por pac. (Ze Eduardo).

                   24/10/2001 - Tentar sempre debitar o atraso (Margarete).

                   25/02/2002 - Nao enxerga pagtos no caixa (Margarete).

                   04/03/2002 - Sempre descontar a prestacao do mes (Margarete).

                   10/05/2002 - Qdo 91 nao cobra o valor correto (Margarete).

                   28/05/2002 - Nao gerar mais o pedido de impressao (Deborah).

                   26/08/2002 - Para saldo varre >= glb_dtmvtolt (Margarete).

                   28/10/2002 - Tratar cobertura de saldos devedores (Deborah).

                   06/11/2002 - Qdo paga todo atraso no mes nao vira a data
                                corretamente (Margarete).

                   27/03/2003 - Incluir tratamento da Concredi (Margarete).

                   03/06/2004 - Quando pago por fora ainda estava mostrando
                                no crrl135 (Margarete).

                   21/06/2004 - Quando pago algo durante o mes nao mostrava o
                                saldo que ainda faltava pagar(Margarete).

                   22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

                   24/09/2004 - Tratamento para emprestimo em consignacao (Julio).

                   06/10/2004 - So vai lancar no craplcm se nao for emprestimo
                                consignado ou se o dia for maior que 10 (Julio)

                   15/06/2005 - So atualiza inliquid se realmente lancou na conta
                                (Julio)

                   29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                                craplcm, crapavs, craplem e craprej (Diego).

                   15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                                de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                                com craprda.dtmvtolt para pegar se lancamento com
                                abono ou nao (Margarete).

                   08/09/2005 - Faltando um pouco para pagar nao mostrava no
                                relatorio (Margarete).

                   10/12/2005 - Atualiza craplcm.nrdctitg (Magui).

                   15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   17/03/2006 - Quando vencimento depois do ultimo dia util do
                                mes nao cobrava correto (Magui).
                   19/04/2006 - Se pagamento antes do aniversario nao estava
                                descontado, queria cobrar tudo novamente (Magui).

                   15/05/2006 - Aumento da mascara para o numero do contrato
                                (Julio)

                   23/06/2006 - Incluido campo para Observacoes (David).

                   28/02/2007 - Carregar fones da tabela craptfc (David).

                   21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).

                   21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   17/11/2008 - Nao esta debitando quando a prestacao e menor
                                que o valor minimo do debito (Magui).

                   19/06/2009 - Nao permitir debito em conta corrente para
                                emprestimos com pagamentos via boleto (Fernando).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   23/10/2009 - Quando for criado um registro na craplem, inclui "9"
                                no numero de documento, caso o registro ja exista
                                (Elton).

                   26/03/2010 - Desativar o Rating quando liquidado o emprestimo
                                (Gabriel).

                   29/10/2010 - Alteracao para gerar relatorio em txt
                                (GATI-Sandro)

                   14/02/2011 - Inclusao para gerar txt para Acredicoop;
                              - Alteracao para mover arquivos para diretorio
                                salvar (GATI - Eder).

                   21/12/2011 - Aumentado o format do campo cdhistor
                                de "999" para "9999" (Tiago).

                   09/03/2012 - Declarado as variaveis necessarias para utilizacao
                                da include lelem.i (Tiago)

                   07/11/2012 - Alterado para debitar somente emprestimos do tipo zero
                                (Oscar)

                   27/12/2012 - Gerar arquivo TXT para AltoVale (Evandro).

                   13/06/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                                o restart (Marcos-Supero)

                   15/08/2013 - Incluido a chamada da procedure "atualiza_desconto"
                               "atualiza_emprestimo" para os contratos que
                               nao ocorreram debito (James).

                   26/09/2013 - Alterado para nao receber telefone da crapass
                               (Reinert).

                   01/10/2013 - Nova forma de chamar as agências, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   09/10/2013 - Atribuido valor 0 no campo crapcyb.cdagenci (James)

                   22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                                ser acionada em caso de saída para continuação da cadeia,
                                e não em caso de problemas na execução (Marcos-Supero)

                   17/10/2013 - GRAVAMES - Solicitacao Baixa Automatica
                               (Guilherme/SUPERO).

                   11/11/2013 - Alterado totalizador de PAs de 99 para 999.
                                (Reinert)

                   14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                                vip no cyber (James).

                   29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                                posicoes (Tiago/Gielow SD137074).

                   21/01/2015 - Alterado o formato do campo nrctremp para 8
                                caracters (Kelvin - 233714)

                   02/06/2015 - Colocar trava para nao cobrar as parcelas da 
                                conta: 3044831 e contrato: 146922 da Viacredi.
                                (Jaison/Gielow - SD: 293026)
                                
                   05/08/2015 - Ajuste da composicao do saldo, para somente 
                                verificar os lancamentos do dia. (James)
                                
                   10/11/2015 - Verificar parametro de bloqueio na TAB096 referente ao
                                pagto de boletos de emprestimo - Projeto 210 (Rafael)

                   22/04/2016 - Ajuste para bloquear a conta 8415005 para nao debitar
                                o emprestimo. (James)

                   13/05/2016 - Cobranca de Multa e Juros de Mora para emprestimos TR.
                                (Jaison/James)

                   19/05/2016 - Colocar trava para nao cobrar as parcelas da 
                                conta: 2496380 e contrato: 289361 da Viacredi.
                                (Tiago/Thiago - SD: 455213).                                

                   26/09/2016 - Inclusao de validacao de contrato de acordo,
                                Prj. 302 (Jean Michel)         

                   23/02/2016 - Incluída verificação de contas e contratos específicos com
                                bloqueio judicial para não debitar parcelas - AJFink SD#618307

                   31/03/2017 - Alterado calculo de saldo do cooperado para nao considerar valores
				                        bloqueados. 	Heitor (Mouts) - Melhoria 440

                   07/06/2018 - Ajuste para usar procedure que centraliza lancamentos na CRAPLCM 
                                (LANC0001.pc_gerar_lancamento_conta) e a criacao do lote (craplot). 
                                (PRJ450 - Teobaldo J - AMcom)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS171';

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_exc_next EXCEPTION;
      vr_exc_undo EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;      --> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);             --> String genérica com informações para restart
      vr_inrestar INTEGER;                    --> Indicador de Restart
      vr_nrctremp INTEGER := 0;               --> Número do contrato do Restart
      vr_qtregres NUMBER := 0;                --> Quantidade de registros ignorados por terem sido processados antes do restart

      -- Variaveis para gravação da craplot
      vr_cdagenci CONSTANT PLS_INTEGER := 1;
      vr_cdbccxlt CONSTANT PLS_INTEGER := 100;

      vr_cdindice VARCHAR2(30) := ''; -- Indice da tabela de acordos

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca o cadastro de linhas de crédito
      CURSOR cr_craplcr IS
        SELECT lcr.cdlcremp
              ,lcr.txdiaria
              ,lcr.cdusolcr
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.vllimcre
              ,ass.cdagenci
              ,ass.cdsecext
              ,ass.nrramemp
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper;

      -- Busca das informações de saldo cfme a conta
      CURSOR cr_crapsld IS
        SELECT sld.nrdconta
              ,sld.vlsdblfp
              ,sld.vlsdbloq
              ,sld.vlsdblpr
              ,sld.vlsddisp
              ,sld.vlipmfap
              ,sld.vlipmfpg
              ,sld.vlsdchsl
          FROM crapsld sld
         WHERE cdcooper = pr_cdcooper;

      -- Busca das informações de históricos de lançamento
      CURSOR cr_craphis IS
        SELECT his.cdhistor
              ,his.inhistor
              ,his.indoipmf
          FROM craphis his
         WHERE cdcooper = pr_cdcooper;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Busca dos empréstimos
      CURSOR cr_crapepr IS
        SELECT epr.rowid
              ,epr.cdcooper
              ,epr.cdorigem 
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.dtmvtolt
              ,epr.inprejuz
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.dtdpagto
              ,epr.flgpagto
              ,epr.qtmesdec
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.dtultpag
              ,epr.tpdescto
              ,epr.indpagto
              ,epr.cdagenci
              ,epr.cdfinemp
              ,epr.vlemprst
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper          --> Coop conectada
           AND epr.nrdconta >= vr_nrctares         --> Conta de restart (0 quando não houver)
           AND epr.inliquid = 0                    --> Somente não liquidados
           AND epr.indpagto = 0                    --> Nao pago no mês ainda
           AND epr.flgpagto = 0                    --> Débito em conta
           AND epr.tpemprst = 0                    --> Price
           AND epr.dtdpagto <= rw_crapdat.dtmvtolt
         ORDER BY epr.nrdconta
                 ,epr.nrctremp;

      -- Busca dos lançamentos de deposito a vista
      CURSOR cr_craplcm IS
        SELECT lcm.nrdconta
              ,lcm.dtrefere
              ,lcm.vllanmto
              ,lcm.dtmvtolt
              ,lcm.cdhistor
              ,ROW_NUMBER () OVER (PARTITION BY lcm.nrdconta, lcm.cdhistor
                                       ORDER BY lcm.nrdconta, lcm.cdhistor) sqatureg
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.cdhistor <> 289
           AND lcm.dtmvtolt = rw_crapdat.dtmvtolt
         ORDER BY lcm.cdhistor;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot(pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.dtmvtolt
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = vr_cdagenci
           AND lot.cdbccxlt = vr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      -- Criaremos um registro para cada tipo de lote utilizado
      rw_craplot_8457 cr_craplot%ROWTYPE; --> Lancamento de prestação de empréstimo
      rw_craplot_8453 cr_craplot%ROWTYPE; --> Lancamento de pagamento de empréstimo na CC

      -- Verificar se já existe outro lançamento para o lote atual
      CURSOR cr_craplem_nrdocmto(pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                ,pr_nrdolote craplot.nrdolote%TYPE
                                ,pr_nrdconta crapepr.nrdconta%TYPE
                                ,pr_nrdocmto craplem.nrdocmto%TYPE) IS
        SELECT count(1)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = vr_cdagenci
           AND cdbccxlt = vr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto;
      vr_qtd_lem_nrdocmto NUMBER;

      -- Leitura dos registros rejeitos do empréstimo
      CURSOR cr_craprej IS
        SELECT cdagenci
              ,nrdconta
              ,nraplica
              ,dtmvtolt
              ,cdpesqbb
              ,vlsdapli
              ,vldaviso
              ,vllanmto
              ,ROW_NUMBER () OVER (PARTITION BY cdagenci
                                       ORDER BY cdagenci) sqregpac
              ,COUNT (*) OVER (PARTITION BY cdagenci) qtregpac
          FROM craprej
         WHERE cdcooper = pr_cdcooper
           AND cdbccxlt = 171
           AND cdcritic = 171
        ORDER BY cdagenci
                ,nrdconta
                ,nraplica;

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;

      -- Busca dos telefones dos associados
      CURSOR cr_craptfc IS
        SELECT nrdconta
              ,tptelefo
              ,nrdddtfc
              ,nrtelefo
              ,ROW_NUMBER () OVER (PARTITION BY nrdconta
                                               ,tptelefo
                                       ORDER BY progress_recid) sqregtpt
          FROM craptfc
         WHERE cdcooper = pr_cdcooper
           AND tptelefo IN(1,2,3); -- Res, Cel e Com.

      -- Busca das empresas em titulares de conta
      CURSOR cr_crapttl IS
        SELECT nrdconta
              ,cdempres
              ,cdturnos
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1; --> Somente titulares

      -- Busca das empresas no cadastro de pessoas juridicas
      CURSOR cr_crapjur IS
        SELECT nrdconta
              ,cdempres
          FROM crapjur
         WHERE cdcooper = pr_cdcooper;
         
      -- Cursor para verificar se existe algum boleto em aberto
      CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
           SELECT cob.nrdocmto
             FROM crapcob cob
            WHERE cob.cdcooper = pr_cdcooper
              AND cob.incobran = 0
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN 
                  (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                     FROM tbrecup_cobranca cde /* 07/06/2018 - TJ era: tbepr_cobranca */
                    WHERE cde.cdcooper = pr_cdcooper
                      AND cde.nrdconta = pr_nrdconta
                      AND cde.nrctremp = pr_nrctremp);
      rw_cde cr_cde%ROWTYPE;
          
      -- Cursor para verificar se existe algum boleto pago pendente de processamento
      CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT cob.nrdocmto
            FROM crapcob cob, crapret ret
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto = pr_dtmvtolt
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                    FROM tbrecup_cobranca cde /* 07/06/2018 - TJ era: tbepr_cobranca */
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp)
             AND ret.cdcooper = cob.cdcooper
             AND ret.nrdconta = cob.nrdconta
             AND ret.nrcnvcob = cob.nrcnvcob
             AND ret.nrdocmto = cob.nrdocmto
             AND ret.dtocorre = cob.dtdpagto
             AND ret.cdocorre = 6
             AND ret.flcredit = 0;
      rw_ret cr_ret%ROWTYPE;                      

      -- Consulta contratos ativos de acordos
       CURSOR cr_ctr_acordo IS
       SELECT tbrecup_acordo_contrato.nracordo
             ,tbrecup_acordo_contrato.nrctremp
             ,tbrecup_acordo.cdcooper
             ,tbrecup_acordo.nrdconta
         FROM tbrecup_acordo_contrato
         JOIN tbrecup_acordo
           ON tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo
        WHERE tbrecup_acordo.cdsituacao = 1
          AND tbrecup_acordo_contrato.cdorigem IN (2,3);

       rw_ctr_acordo cr_ctr_acordo%ROWTYPE;

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definição dos lançamentos de deposito a vista
      TYPE typ_reg_craplcm_det IS
        RECORD(dtrefere craplcm.dtrefere%TYPE,
               vllanmto craplcm.vllanmto%TYPE,
               dtmvtolt craplcm.dtmvtolt%TYPE,
               cdhistor craplcm.cdhistor%TYPE,
               sqatureg NUMBER(05));
      TYPE typ_tab_craplcm_det IS
        TABLE OF typ_reg_craplcm_det
          INDEX BY PLS_INTEGER; -- Cod historico || sequencia registro

      TYPE typ_reg_craplcm IS
        RECORD(tab_craplcm typ_tab_craplcm_det);
      TYPE typ_tab_craplcm IS
        TABLE OF typ_reg_craplcm
          INDEX BY PLS_INTEGER; -- Numero da conta
      vr_tab_craplcm typ_tab_craplcm;

      -- Definição de tipo para armazenar informações da linha de crédito
      TYPE typ_reg_craplcr IS
        RECORD(txdiaria craplcr.txdiaria%TYPE
              ,cdusolcr craplcr.cdusolcr%TYPE);
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER; -- Cod linha de crédito
      vr_tab_craplcr typ_tab_craplcr;

      -- Definição de tipo para armazenar informações dos associados
      TYPE typ_reg_crapass IS
        RECORD(vllimcre crapass.vllimcre%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,cdsecext crapass.cdsecext%TYPE
              ,nrramemp crapass.nrramemp%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;

      -- Definição de tipo para armazenar informações dos saldos associados
      TYPE typ_reg_crapsld IS
        RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
              ,vlsdbloq crapsld.vlsdbloq%TYPE
              ,vlsdblpr crapsld.vlsdblpr%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,vlipmfap crapsld.vlipmfap%TYPE
              ,vlipmfpg crapsld.vlipmfpg%TYPE);
      TYPE typ_tab_crapsld IS
        TABLE OF typ_reg_crapsld
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapsld typ_tab_crapsld;

      -- Definição de tipo para armazenar as informações de histórico
      TYPE typ_reg_craphis IS
        RECORD(inhistor craphis.inhistor%TYPE
              ,indoipmf craphis.indoipmf%TYPE);
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
          INDEX BY PLS_INTEGER; --> Código do histórico
      vr_tab_craphis typ_tab_craphis;

      -- Definição de tipo para armazenar os telefones do associado
      TYPE typ_reg_craptfc IS
        RECORD(nrfonere VARCHAR2(30)
              ,nrfoncel VARCHAR2(30)
              ,nrfoncom VARCHAR2(30));
      TYPE typ_tab_craptfc IS
        TABLE OF typ_reg_craptfc
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_craptfc typ_tab_craptfc;

      -- Tipo para busca da empresa tanto de pessoa física quanto juridica
      -- Para fisica também armazena o turno
      TYPE typ_reg_empresa IS
        RECORD(cdempres crapttl.cdempres%TYPE
              ,cdturnos crapttl.cdturnos%TYPE);
      TYPE typ_tab_empresa IS
        TABLE OF typ_reg_empresa
          INDEX BY PLS_INTEGER; -- Obs. A chave é o número da conta
      vr_tab_empresa typ_tab_empresa;

      TYPE typ_tab_acordo   IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(30);
      vr_tab_acordo   typ_tab_acordo;
      ----------------------------- VARIAVEIS ------------------------------

      -- Variáveis auxiliares ao processo
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
      vr_tab_vlmindeb NUMBER;                 --> Valor mínimo a debitar por prestações de empréstimo
      vr_flgrejei     BOOLEAN;                --> Flag para indicação de empréstimo rejeitado
      vr_msdecatr     crapepr.qtmesdec%TYPE;  --> Meses decorridos do empréstimo
      vr_flgprepg     BOOLEAN;                --> Flag para indicação de prestações antecipadas
      vr_flgpgadt     BOOLEAN;                --> Flag para indicação de pagamentos antecipados
      vr_pgtofora     BOOLEAN;                --> Flag para indicação de pagamento por for
      vr_vlsldtot     NUMBER;                 --> Valor de saldo total
      vr_vlcalcob     NUMBER;                 --> Valor calculado de cobrança
      vr_vlpremes     NUMBER;                 --> Valor da prestação do mês
      vr_prxpagto     DATE;                   --> Data do próximo pagamento
      vr_nrdocmto     craplem.nrdocmto%TYPE;  --> Número do documento para a LEM
      vr_dtdpagto     crapepr.dtdpagto%TYPE;  --> Data do pagamento
      vr_ind_lcm      NUMBER(10);             --> Indice da tabela craplcm

      -- Variáveis para passagem a rotina pc_calcula_lelem
      vr_diapagto     INTEGER;
      vr_qtprepag     crapepr.qtprepag%TYPE;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      vr_vljuracu     crapepr.vljuracu%TYPE;
      vr_vljurmes     crapepr.vljurmes%TYPE;
      vr_dtultpag     crapepr.dtultpag%TYPE;
      vr_txdjuros     crapepr.txjuremp%TYPE;
      vr_vldescto     NUMBER(18,6);           --> Valor de desconto das parcelas
      vr_qtprecal crapepr.qtprecal%TYPE;      --> Quantidade de parcelas do empréstimo
      vr_vlsdeved NUMBER(14,2);               --> Saldo devedor do empréstimo
      vr_cdhismul INTEGER;
      vr_vldmulta NUMBER;
      vr_cdhismor INTEGER;
      vr_vljumora NUMBER;

      -- Variáveis de CPMF
      vr_dtinipmf DATE;
      vr_dtfimpmf DATE;
      vr_txcpmfcc NUMBER(12,6);
      vr_txrdcpmf NUMBER(12,6);
      vr_indabono INTEGER;
      vr_dtiniabo DATE;

      -- Variaveis para o CPMF cfme cada histório na craplcm
      vr_inhistor PLS_INTEGER;
      vr_indoipmf PLS_INTEGER;
      vr_txdoipmf NUMBER;

      -- Variaveis para os XMLs e relatórios
      vr_clobarq     CLOB;                  -- Clob para conter o dados do txt
      vr_clobxml     CLOB;                  -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo
      vr_dspathcopia VARCHAR2(4000);        -- Path para cópia do arquivo exportado
      vr_flgarqtx    BOOLEAN := FALSE;      -- Indicar que gerou o txt

      -- Campos para o relatório
      vr_nrramfon VARCHAR2(60);             -- Telefones
      vr_vlsdapli VARCHAR2(30);             -- Saldo devedor
      vr_vldaviso VARCHAR2(30);             -- Valor prestação
      vr_vllanmto VARCHAR2(30);             -- Valor débito
      vr_vlestour VARCHAR2(30);             -- Valor estouro
      vr_cdturnos NUMBER;                   -- Turno de trabalho
      
      -- Parametro de bloqueio de resgate de valores em c/c
      vr_blqresg_cc VARCHAR2(1);      

      -- Parametro de contas que nao podem debitar os emprestimos
      vr_dsctajud    crapprm.dsvlrprm%TYPE;
      -- Parametro de contas e contratos específicos que nao podem debitar os emprestimos SD#618307
      vr_dsctactrjud crapprm.dsvlrprm%TYPE := null;
      
      -- LANC0001 
      vr_incrineg       INTEGER;
      vr_tab_retorno    LANC0001.typ_reg_retorno;

      ----------------- SUBROTINAS INTERNAS --------------------

      -- Subrotina para checar a existência de lote cfme tipo passado
      PROCEDURE pc_cria_craplot(pr_dtmvtolt   IN craplot.dtmvtolt%TYPE
                               ,pr_nrdolote   IN craplot.nrdolote%TYPE
                               ,pr_tplotmov   IN craplot.tplotmov%TYPE
                               ,pr_rw_craplot IN OUT NOCOPY cr_craplot%ROWTYPE
                               ,pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Buscar as capas de lote cfme lote passado
        OPEN cr_craplot(pr_nrdolote => pr_nrdolote
                       ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplot
         INTO pr_rw_craplot; --> Rowtype passado
        -- Se não tiver encontrado
        IF cr_craplot%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplot;
          -- Efetuar a inserção de um novo registro
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr
                               ,cdhistor
                               ,tpdmoeda
                               ,cdoperad)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,vr_cdagenci
                               ,vr_cdbccxlt
                               ,pr_nrdolote --> Cfme enviado
                               ,pr_tplotmov --> Cfme enviado
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,1
                               ,'1')
                       RETURNING dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO pr_rw_craplot.dtmvtolt
                                ,pr_rw_craplot.cdagenci
                                ,pr_rw_craplot.cdbccxlt
                                ,pr_rw_craplot.nrdolote
                                ,pr_rw_craplot.tplotmov
                                ,pr_rw_craplot.nrseqdig
                                ,pr_rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||pr_nrdolote||'. Detalhes: '||sqlerrm;
          END;
        ELSE
          -- apenas fechar o cursor
          CLOSE cr_craplot;
        END IF;
      END;

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1 --true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Procedimento padrão de busca de informações de CPMF
      gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                            ,pr_dtinipmf  => vr_dtinipmf
                            ,pr_dtfimpmf  => vr_dtfimpmf
                            ,pr_txcpmfcc  => vr_txcpmfcc
                            ,pr_txrdcpmf  => vr_txrdcpmf
                            ,pr_indabono  => vr_indabono
                            ,pr_dtiniabo  => vr_dtiniabo
                            ,pr_cdcritic  => vr_cdcritic
                            ,pr_dscritic  => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        -- Gerar raise
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;

      -- Busca do cadastro de linhas de crédito de empréstimo
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Guardamos a taxa e o indicador de emissão de boletos
        vr_tab_craplcr(rw_craplcr.cdlcremp).txdiaria := rw_craplcr.txdiaria;
        vr_tab_craplcr(rw_craplcr.cdlcremp).cdusolcr := rw_craplcr.cdusolcr;
      END LOOP;

      -- Busca dos associados da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
        -- Adicionar ao vetor as informações chaveando pela conta
        vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
        vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
        vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;

      -- Busca dos lancamentos de deposito a vista
      FOR rw_craplcm IN cr_craplcm LOOP
        -- Adicionar ao vetor as informações chaveando pela conta
        vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtrefere := rw_craplcm.dtrefere;
        vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).vllanmto := rw_craplcm.vllanmto;
        vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtmvtolt := rw_craplcm.dtmvtolt;
        vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).cdhistor := rw_craplcm.cdhistor;
        vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).sqatureg := rw_craplcm.sqatureg;
      END LOOP;

      -- Carregar Contratos de Acordos
      FOR rw_ctr_acordo IN cr_ctr_acordo LOOP
        vr_cdindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.nrdconta,10,'0') ||
                       LPAD(rw_ctr_acordo.nrctremp,10,'0');
        vr_tab_acordo(vr_cdindice) := rw_ctr_acordo.nracordo;
      END LOOP;

      -- Busca das informações de saldo cfme a conta
      FOR rw_crapsld IN cr_crapsld LOOP
        -- Adicionar ao vetor as informações de saldo novamente chaveando pela conta
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := rw_crapsld.vlsdblfp;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := rw_crapsld.vlsdbloq;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := rw_crapsld.vlsdblpr;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfap := rw_crapsld.vlipmfap;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfpg := rw_crapsld.vlipmfpg;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;
      END LOOP;

      -- Busca do cadastro de histórico
      FOR rw_craphis IN cr_craphis LOOP
        -- Adicionar ao vetor utilizando o histórico como chave
        vr_tab_craphis(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
        vr_tab_craphis(rw_craphis.cdhistor).indoipmf := rw_craphis.indoipmf;
      END LOOP;

      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posição do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- É porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- Não existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- Não existe
        vr_inusatab := FALSE;
      END IF;

      -- Valor minimo para debito dos atrasos das prestacoes
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'VLMINDEBTO'
                                               ,pr_tpregist => 0);
      -- Se houver valor
      IF vr_dstextab IS NOT NULL THEN
        -- Converter o valor do parâmetro para number
        vr_tab_vlmindeb := nvl(gene0002.fn_char_para_number(vr_dstextab),0);
      ELSE
        -- Considerar o valor mínimo como zero
        vr_tab_vlmindeb := 0;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;

      -- Se ainda houver indicação de restart
      IF vr_inrestar > 0 THEN
        -- Converter a descrição do restart que contem o contrato de empréstimo
        vr_nrctremp := gene0002.fn_char_para_number(vr_dsrestar);
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;
      
      -- Parametro de bloqueio de resgate de valores em c/c
      -- ref ao pagto de contrato com boleto (Projeto 210)
      vr_blqresg_cc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'COBEMP_BLQ_RESG_CC');
      
      -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
      vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

      -- Lista de contas e contratos específicos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
      vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');

      -- Busca dos empréstimos
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Criar bloco para tratar desvio de fluxo (next record)
        BEGIN
          -- Trava para nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial
          IF (pr_cdcooper = 1 AND rw_crapepr.nrdconta = 3044831 AND rw_crapepr.nrctremp = 146922) THEN
            CONTINUE;
          END IF;

          -- Trava para nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial #455213
          IF (pr_cdcooper = 1 AND rw_crapepr.nrdconta = 2496380 AND rw_crapepr.nrctremp = 289361) THEN
            CONTINUE;
          END IF;
          
          -- Condicao para verificar se permite incluir as linhas parametrizadas
          IF INSTR(',' || vr_dsctajud || ',',',' || rw_crapepr.nrdconta || ',') > 0 THEN
            CONTINUE;
          END IF;

          -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
          IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(rw_crapepr.nrdconta))||','||trim(to_char(rw_crapepr.nrctremp))||')') > 0 THEN
            CONTINUE;
          END IF;

          /* verificar se existe boleto de contrato em aberto e se pode debitar do cooperado */
          /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
          IF vr_blqresg_cc = 'S' THEN   
                                                       
             -- inicializar rows de cursores
             rw_cde := NULL;
             rw_ret := NULL;
              
             /* 2º se permitir, verificar se possui boletos em aberto */
             OPEN cr_cde( pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapepr.nrdconta
                         ,pr_nrctremp => rw_crapepr.nrctremp);
             FETCH cr_cde INTO rw_cde;
             CLOSE cr_cde;

             /* 3º se existir boleto de contrato em aberto, nao debitar */
             IF nvl(rw_cde.nrdocmto,0) > 0 THEN           
                CONTINUE;
             ELSE              
                /* 4º cursor para verificar se existe boleto pago pendente de processamento, nao debitar */
                OPEN cr_ret( pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapepr.nrdconta
                            ,pr_nrctremp => rw_crapepr.nrctremp
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                FETCH cr_ret INTO rw_ret;
                CLOSE cr_ret;

                /* 6º se existir boleto de contrato pago pendente de processamento, nao debitar */
                IF nvl(rw_ret.nrdocmto,0) > 0 THEN           
                   CONTINUE;
                END IF;    
                
             END IF;
                                            
          END IF;
          
          vr_cdindice := LPAD(rw_crapepr.cdcooper,10,'0') || LPAD(rw_crapepr.nrdconta,10,'0') ||
                         LPAD(rw_crapepr.nrctremp,10,'0');

          IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
            RAISE vr_exc_next;
          END IF;

          -- Se há controle de restart e Se é a mesma conta, mas de uma aplicação anterior
          IF vr_inrestar > 0  AND rw_crapepr.nrdconta = vr_nrctares AND rw_crapepr.nrctremp <= vr_nrctremp THEN
            -- Ignorar o registro pois já foi processado
            RAISE vr_exc_next;
          END IF;
          -- Se não houver cadastro da linha de crédito do empréstimo
          IF NOT vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
            -- Gerar critica 363
            vr_cdcritic := 363;
            vr_dscritic := gene0001.fn_busca_critica(363) || ' LCR: ' || to_char(rw_crapepr.cdlcremp,'fm9990');
            RAISE vr_exc_undo;
          END IF;
          -- Nao debitar os emprestimos com emissao de boletos
          IF vr_tab_craplcr(rw_crapepr.cdlcremp).cdusolcr = 2 THEN
            -- Ignorá-lo
            RAISE vr_exc_next;
          END IF;
          -- Se está setado para utilizarmos a tabela de juros
          IF vr_inusatab THEN
            -- Iremos buscar a tabela de juros na linha de crédito
            vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp).txdiaria;
          ELSE
            -- Usar taxa cadastrada no empréstimo
            vr_txdjuros := rw_crapepr.txjuremp;
          END IF;
          -- Inicializar variaveis para o cálculo
          vr_flgrejei := FALSE;
          vr_diapagto := 0;
          vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
          vr_vlprepag := 0;
          vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
          vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
          vr_vljurmes := 0;
          vr_dtultpag := rw_crapepr.dtultpag;
          -- Chamar rotina de cálculo externa
          empr0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                                 ,pr_cdprogra    => vr_cdprogra
                                 ,pr_rw_crapdat  => rw_crapdat
                                 ,pr_nrdconta    => rw_crapepr.nrdconta
                                 ,pr_nrctremp    => rw_crapepr.nrctremp
                                 ,pr_dtcalcul    => NULL
                                 ,pr_diapagto    => vr_diapagto
                                 ,pr_txdjuros    => vr_txdjuros
                                 ,pr_qtprepag    => vr_qtprepag
                                 ,pr_qtprecal    => vr_qtprecal_lem
                                 ,pr_vlprepag    => vr_vlprepag
                                 ,pr_vljuracu    => vr_vljuracu
                                 ,pr_vljurmes    => vr_vljurmes
                                 ,pr_vlsdeved    => vr_vlsdeved
                                 ,pr_dtultpag    => vr_dtultpag
                                 ,pr_cdcritic    => vr_cdcritic
                                 ,pr_des_erro    => vr_dscritic);
          -- Se a rotina retornou com erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_undo;
          END IF;
          -- Garantir que o saldo devedor não fique zerado
          IF vr_vlsdeved < 0 THEN
            vr_vlsdeved := 0;
          END IF;

          -- Se o empréstimo não estiver ativo
          IF rw_crapepr.inliquid = 0 THEN
            -- Acumular a quantidade calculada com a da tabela
            vr_qtprecal := rw_crapepr.qtprecal + vr_qtprecal_lem;
          ELSE
            -- Utilizar apenas a quantidade de parcelas
            vr_qtprecal := rw_crapepr.qtpreemp;
          END IF;

          -- Inicializar variaveis para atualização do empréstimo
          vr_msdecatr := 0;
          vr_flgprepg := FALSE;
          vr_flgpgadt := FALSE;
          vr_pgtofora := FALSE;

          -- Se a parcela vence no mês corrente
          IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtdpagto,'mm') THEN
            -- Se ainda não foi pago
            IF rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt THEN
              -- Incrementar a quantidade de parcelas
              vr_msdecatr := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Consideramos a quantidade já calculadao
              vr_msdecatr := rw_crapepr.qtmesdec;
            END IF;
          -- Se foi paga no mês corrente
          ELSIF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtmvtolt,'mm') THEN
            -- Se for um contrato do mês
            IF to_char(rw_crapepr.dtdpagto,'mm') = to_char(rw_crapdat.dtmvtolt,'mm') THEN
              -- Devia ter pago a primeira no mes do contrato
              vr_msdecatr := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Paga a primeira somente no mes seguinte
              vr_msdecatr := rw_crapepr.qtmesdec;
            END IF;
          ELSE
            -- Se a parcela vai vencer E foi paga antes da data corrente
            IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND to_char(rw_crapepr.dtdpagto,'dd') <= to_char(rw_crapdat.dtmvtolt,'dd') THEN
              -- Incrementar a quantidade de parcelas
              vr_msdecatr := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Consideramos a quantidade já calculadao
              vr_msdecatr := rw_crapepr.qtmesdec;
            END IF;
          END IF;

          -- Se a Qtde de meses decorridos for superior a qtde de parcelas do empréstimo
          IF vr_msdecatr > rw_crapepr.qtpreemp THEN
            -- Considerar todo o saldo devedor como desconto
            vr_vldescto := vr_vlsdeved;
          -- Se a quantidade calculada for superior a quantidade de meses decorridos
          ELSIF rw_crapepr.qtprecal > rw_crapepr.qtmesdec THEN
            -- Pagamento antecipado de uma parcela
            vr_vldescto := rw_crapepr.vlpreemp;
            vr_flgprepg := TRUE;
          -- Se a qtdade de meses decorridos for superior a calculada
          ELSIF vr_msdecatr > vr_qtprecal THEN
            -- Valor do desconto é essa diferença * valor da parcela
            vr_vldescto := (vr_msdecatr - vr_qtprecal) * rw_crapepr.vlpreemp;
          -- Se for um associado em dia e o vencimento do empréstimo for depois do ultimo dia util do mes
          ELSIF trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtoan,'mm') AND rw_crapepr.dtdpagto > rw_crapdat.dtmvtoan
          AND rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND (vr_qtprecal >= vr_msdecatr) THEN
            -- Considerar o desconto de uma parcela de adiantamento
            vr_flgpgadt := FALSE;
            vr_vldescto := rw_crapepr.vlpreemp;
            vr_flgprepg := TRUE;
          -- Se é um empréstimo antecipado com pagamento no mês anterior
          ELSIF vr_qtprecal >= vr_msdecatr AND rw_crapepr.dtdpagto <= rw_crapdat.dtmvtoan THEN
            -- Não haverá desconto e indicar que houve pagamaento antecipado
            vr_vldescto := 0;
            vr_flgpgadt := TRUE;
          -- Pegar prestacao do mes quando vencto do mes passado foi depois do mensal
          ELSIF (vr_qtprecal > vr_msdecatr OR vr_qtprecal = vr_msdecatr)
          AND rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND rw_crapepr.dtdpagto > rw_crapdat.dtmvtoan THEN
            -- Considerar o desconto de uma parcela de adiantamento
            vr_flgpgadt := FALSE;
            vr_vldescto := rw_crapepr.vlpreemp;
            vr_flgprepg := TRUE;
          -- Se a quantidade calculada for superior a decorrida
          ELSIF vr_qtprecal > vr_msdecatr THEN
            -- Considerar o desconto de uma parcela de adiantamento
            vr_flgpgadt := TRUE;
            vr_vldescto := rw_crapepr.vlpreemp;
            vr_flgprepg := TRUE;
          -- Para associado em dia
          ELSIF vr_vlsdeved > rw_crapepr.vlpreemp AND rw_crapepr.qtpreemp > 1 THEN
            -- Considerar o desconto de uma parcela de adiantamento
            vr_vldescto := rw_crapepr.vlpreemp;
            vr_flgprepg := TRUE;
          -- Se for 1 prestação é por fora
          ELSIF vr_qtprecal = vr_msdecatr THEN
            -- Considerar o desconto de uma parcela de adiantamento
            vr_vldescto := rw_crapepr.vlpreemp;
            vr_flgprepg := TRUE;
          -- Por fim, se não chegou em nenhuma das alternativas acima
          ELSE
            -- Considerar o saldo devedor como desconto
            vr_vldescto := vr_vlsdeved;
          END IF;

          -- Garantir que o saldo devedor seja inferior ao desconto
          IF vr_vlsdeved < vr_vldescto THEN
            -- Considerar o saldo devedor como desconto
            vr_vldescto := vr_vlsdeved;
          END IF;

          -- Se houve prestação antecipada no mes
          IF vr_flgprepg AND vr_vlprepag <> 0 THEN
            -- Descontar o valor antecipado
            vr_vldescto := vr_vldescto - vr_vlprepag;
            -- Se o valor pago exceder o desconto
            IF vr_vldescto <= 0 THEN
              -- Houve pagamento por fora
              vr_vldescto := 0;
              vr_pgtofora := TRUE;
            END IF;
          END IF;

          -- Verificar se a conta não possui saldo
          IF NOT vr_tab_crapsld.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 10
            vr_cdcritic := 10;
            vr_dscritic := gene0001.fn_busca_critica(10) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_undo;
          END IF;

          -- Verificar se a conta não está na crapass
          IF NOT vr_tab_crapass.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 251
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(251) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_undo;
          END IF;

          -- Calcular o saldo total --
          vr_vlsldtot := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapass(rw_crapepr.nrdconta).vllimcre,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Calcular o saldo a cobrar --
          vr_vlcalcob := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdchsl,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0)
                       - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Se o valor a cobrar ficar negativo
          IF vr_vlcalcob < 0 THEN
            -- Descontar do total o valor absoluto a cobrar aplicando o * de CPMF
            vr_vlsldtot := vr_vlsldtot - (TRUNC((ABS(vr_vlcalcob)  * vr_txcpmfcc),2));
          END IF;

          -- Busca dos lançamentos de deposito a vista
          IF vr_tab_craplcm.EXISTS(rw_crapepr.nrdconta) THEN
            vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.first;
            WHILE vr_ind_lcm IS NOT NULL LOOP
              -- No primeiro registro do histórico atual
              IF vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg = 1 THEN
                -- Verificar se o histórico está cadastrado
                IF NOT vr_tab_craphis.EXISTS(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor) THEN
                  -- Gerar critica 83 no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || to_char(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor,'fm9900') || ' ' ||gene0001.fn_busca_critica(83) );
                  -- Limpar as variaveis de controle do cpmf
                  vr_inhistor := 0;
                  vr_indoipmf := 0;
                  vr_txdoipmf := 0;
                ELSE
                  -- Utilizaremos do cadastro do histórico
                  vr_inhistor := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor;
                  vr_indoipmf := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).indoipmf;
                  vr_txdoipmf := vr_txcpmfcc;
                  -- Se houver abono e o histórico for um dos abaixo:
                  -- CDHISTOR DSHISTOR
                  -- -------- --------------------------------------------------
                  -- 114 DB.APLIC.RDCA
                  -- 127 DB. COTAS
                  -- 160 DB.POUP.PROGR
                  -- 177 DB.APL.RDCA60
                  IF vr_indabono = 0 AND vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                    -- Indicar que não há CPMF
                    vr_indoipmf := 1;
                    vr_txdoipmf := 0;
                  END IF;
                END IF;
              END IF;

              -- Se houver abono e a data for inferior a data lançada e o histório estiver na lista abaixo:
              -- CDHISTOR DSHISTOR
              -- -------- --------------------------------------------------
              -- 186 CR.ANTEC.RDCA
              -- 187 CR.ANT.RDCA60
              -- 498 CR.ANTEC.RDCA
              -- 500 CR.ANT.RDCA60
              IF vr_indabono = 0 AND vr_dtiniabo <= vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere AND
                 vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                -- Descontar do saldo total este lançamento aplicando a taxa de CPMF cadastrada
                vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * vr_txcpmfcc),2));
              END IF;

              -- Se tivermos um lançamento de crédito da data atual --
              IF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN (1) AND rw_crapdat.dtmvtolt = vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Acumular ao saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot + (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas acumular o lançamento
                  vr_vlsldtot := vr_vlsldtot + vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              -- Senão, se tivermos um lançamento de débito --
              ELSIF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN(11,13,14,15) THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Diminuir do saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas diminuir o lançamento
                  vr_vlsldtot := vr_vlsldtot - vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              END IF;

              vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.next(vr_ind_lcm);
            END LOOP; -- Fim leitura craplcm
          END IF;

          -- Armazenar o valor original de desconto
          vr_vlpremes := vr_vldescto;

          -- Se o valor de desconto aplicando a CPMF for maior que o saldo total
          IF TRUNC((vr_vldescto * (1 + vr_txcpmfcc)),2) > vr_vlsldtot THEN
            -- Se houver saldo total
            IF vr_vlsldtot > 0 THEN
              -- Aplicar a taxa de CPMF
              vr_vldescto := TRUNC(vr_vlsldtot * vr_txrdcpmf,2);
            ELSE
              -- Utilizaremos zero
              vr_vldescto := 0;
            END IF;
            -- Se o valor original do desconto for superior ao desconto acima ajustado
            IF vr_vlpremes > vr_vldescto THEN
              -- Indicar que há rejeição
              vr_flgrejei := TRUE;
            END IF;
          END IF;

          -- Se a prestação for superior ou igual ao mínimo de débito e
          -- o valor de desconto inferior ao mínimo de débito e o
          -- saldo devedor superior ao valor de desconto
          IF rw_crapepr.vlpreemp >= vr_tab_vlmindeb AND vr_vldescto < vr_tab_vlmindeb AND vr_vlsdeved > vr_vldescto THEN
            -- Zerar o desconto
            vr_vldescto := 0;
          END IF;

          -- Se o registro ainda não estiver rejeitado
          IF NOT vr_flgrejei THEN
            -- Se o valor de desconto estiver zerado, não houver pagamento por fora e
            -- o valor original de desconto for superior ao desconto atual
            IF vr_vldescto = 0 AND NOT vr_pgtofora AND vr_vlpremes > vr_vldescto THEN
              -- Indicar que já rejeição
              vr_flgrejei := TRUE;
            END IF;
          END IF;

          -- Se estamos em outro mês e temos adiantamento
          IF vr_flgpgadt AND TRUNC(rw_crapepr.dtdpagto,'mm') <> TRUNC(rw_crapdat.dtmvtolt,'mm') THEN
            -- Adicionamos 1 mês a data de pagamento do empréstimo
            rw_crapepr.dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_crapepr.dtdpagto --> Data do pagamento anterior
                                                        ,pr_qtmesano => 1                   --> +1 mês
                                                        ,pr_tpmesano => 'M'
                                                        ,pr_des_erro => vr_dscritic);
            -- Parar se encontrar erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_undo;
            END IF;
          END IF;

          -- Quanto não houver desconto, a data do pagamento for superior a de movimento e estivermos no mesmo mês
          IF vr_vldescto = 0 AND rw_crapepr.dtdpagto > rw_crapdat.dtmvtolt
          AND TRUNC(rw_crapepr.dtdpagto,'mm') = TRUNC(rw_crapdat.dtmvtolt,'mm') THEN
            --atualizar a crapepr pois partirá pro proximo
            BEGIN
              UPDATE crapepr
                 SET dtdpagto = rw_crapepr.dtdpagto
               WHERE rowid = rw_crapepr.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar o empréstimo (CRAPEPR).'
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Processar o próximo empréstimo
            RAISE vr_exc_next;
          END IF;

          -- Se houver desconto E (tipo de empréstimo não for consignado Ou se for pagamento deve ser > dia 10)
          IF vr_vldescto > 0 AND (rw_crapepr.tpdescto = 1 OR to_char(rw_crapdat.dtmvtolt,'dd') > 10) THEN
            -- Testar se já retornado o registro de capas de lote para o 8457
            IF rw_craplot_8457.rowid IS NULL THEN
              -- Chamar rotina para buscá-lo, e se não encontrar, irá criá-lo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8457
                             ,pr_tplotmov   => 1
                             ,pr_rw_craplot => rw_craplot_8457
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;
            
            -- Efetuar lancamento na conta-corrente
            LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_craplot_8457.dtmvtolt
                                              ,pr_cdagenci => rw_craplot_8457.cdagenci
                                              ,pr_cdbccxlt => rw_craplot_8457.cdbccxlt
                                              ,pr_nrdolote => rw_craplot_8457.nrdolote 
                                              ,pr_cdpesqbb => ' ' 
                                              ,pr_nrdconta => rw_crapepr.nrdconta
                                              ,pr_nrdctabb => rw_crapepr.nrdconta
                                              ,pr_nrdctitg => to_char(rw_crapepr.nrdconta,'fm00000000')
                                              ,pr_nrdocmto => rw_crapepr.nrctremp
                                              ,pr_cdhistor => 108
                                              ,pr_nrseqdig => rw_craplot_8457.nrseqdig + 1
                                              ,pr_vllanmto => vr_vldescto          -- Valor de lancamento
                                              ,pr_inprolot => 0                    -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                              ,pr_tplotmov => 0                    -- Tipo Movimento 
                                              ,pr_cdcritic => vr_cdcritic          -- Codigo Erro
                                              ,pr_dscritic => vr_dscritic          -- Descricao Erro
                                              ,pr_incrineg => vr_incrineg          -- Indicador de crítica de negócio
                                              ,pr_tab_retorno => vr_tab_retorno ); -- Registro com dados do retorno

            -- Conforme tipo de erro realiza acao diferenciada
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              IF vr_incrineg = 0 THEN -- Erro de sistema/BD
                vr_dscritic := 'Erro ao criar lancamento de sobras para a conta corrente (CRAPLCM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
              ELSE -- Nao foi possivel debitar (critica de negocio)
                -- Avanca para o proximo registro, conforme demais tratamentos acima
                CONTINUE;
              END IF;
           END IF;

            -- Atualizar Pl table de conta corrente
            IF vr_tab_craplcm.exists(rw_crapepr.nrdconta) THEN
              vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.count + 1;
            ELSE
              vr_ind_lcm := 1;
            END IF;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere := NULL;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto := vr_vldescto;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt := rw_craplot_8457.dtmvtolt;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor := 108; --> Prest Empr.
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg := 1;

            -- Subtrai o valor pago do saldo disponivel
            vr_vlsldtot := vr_vlsldtot - vr_vldescto;

            -- Efetuar criação do avisos de débito em conta
            BEGIN
              INSERT INTO crapavs(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdempres
                                 ,cdhistor
                                 ,cdsecext
                                 ,dtdebito
                                 ,dtrefere
                                 ,insitavs
                                 ,nrdconta
                                 ,nrdocmto
                                 ,nrseqdig
                                 ,tpdaviso
                                 ,vldebito
                                 ,vlestdif
                                 ,vllanmto
                                 ,flgproce)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8457.dtmvtolt
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdagenci
                                 ,0
                                 ,108 -- Mesmo do lançamento
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdsecext
                                 ,rw_craplot_8457.dtmvtolt
                                 ,rw_craplot_8457.dtmvtolt
                                 ,0
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,rw_craplot_8457.nrseqdig + 1 
                                 ,2
                                 ,0
                                 ,0
                                 ,vr_vldescto
                                 ,0); -- false
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar aviso de débito em conta corrente (CRAPAVS) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Atualizar as informações no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfodb = vlinfodb + vr_vldescto
                    ,vlcompdb = vlcompdb + vr_vldescto
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8457.rowid
               RETURNING nrseqdig INTO rw_craplot_8457.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8457.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Testar se já retornado o registro de capas de lote para o 8453
            IF rw_craplot_8453.rowid IS NULL THEN
              -- Chamar rotina para buscá-lo, e se não encontrar, irá criálo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8453
                             ,pr_tplotmov   => 5
                             ,pr_rw_craplot => rw_craplot_8453
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;

            -- Inicializar número auxiliar de documento com o empréstimo
            vr_nrdocmto := rw_crapepr.nrctremp;

            -- Verificar se já existe outro lançamento para este lote
            vr_qtd_lem_nrdocmto := 0;
            OPEN cr_craplem_nrdocmto(pr_dtmvtolt => rw_craplot_8453.dtmvtolt
                                    ,pr_nrdolote => rw_craplot_8453.nrdolote
                                    ,pr_nrdconta => rw_crapepr.nrdconta
                                    ,pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplem_nrdocmto
             INTO vr_qtd_lem_nrdocmto;
            CLOSE cr_craplem_nrdocmto;
            -- Se encontrou somente um registro (FIND)
            IF vr_qtd_lem_nrdocmto = 1 THEN
              -- Concatenar o número 9 + o contrato do empréstimo já montado
              vr_nrdocmto := '9' || vr_nrdocmto;
            END IF;

            -- Cria lancamento de juros para o emprestimo
            BEGIN
              INSERT INTO craplem(cdcooper
                                 ,dtmvtolt
                                 ,dtpagemp
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrctremp
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,vllanmto
                                 ,txjurepr
                                 ,vlpreemp)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8453.dtmvtolt
                                 ,rw_craplot_8453.dtmvtolt
                                 ,rw_craplot_8453.cdagenci
                                 ,rw_craplot_8453.cdbccxlt
                                 ,rw_craplot_8453.nrdolote
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,vr_nrdocmto
                                 ,95 --> Pg Empr CC
                                 ,rw_craplot_8453.nrseqdig + 1
                                 ,vr_vldescto
                                 ,vr_txdjuros
                                 ,rw_crapepr.vlpreemp);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de juros para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Atualizar as informações no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfocr = vlinfocr + vr_vldescto
                    ,vlcompcr = vlinfocr + vr_vldescto
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8453.rowid
               RETURNING nrseqdig INTO rw_craplot_8453.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8453.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Atualizar informações no rowtype do empréstimo
            -- para atualização única da tabela posteriormente
            rw_crapepr.dtultpag := rw_crapdat.dtmvtolt;
            rw_crapepr.txjuremp := vr_txdjuros;

            -- Caso pagamento seja menor que data atual
            IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt THEN

              -- Procedure para lancar Multa e Juros de Mora para o TR
              EMPR0009.pc_efetiva_pag_atraso_tr(pr_cdcooper => pr_cdcooper
                                               ,pr_cdagenci => 0
                                               ,pr_nrdcaixa => 0
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nmdatela => vr_cdprogra
                                               ,pr_idorigem => 1
                                               ,pr_nrdconta => rw_crapepr.nrdconta
                                               ,pr_nrctremp => rw_crapepr.nrctremp
                                               ,pr_vlpreapg => vr_vldescto
                                               ,pr_qtmesdec => vr_msdecatr
                                               ,pr_qtprecal => vr_qtprecal
                                               ,pr_vlpagpar => vr_vldescto
                                               ,pr_vlsldisp => vr_vlsldtot
                                               ,pr_cdhismul => vr_cdhismul
                                               ,pr_vldmulta => vr_vldmulta
                                               ,pr_cdhismor => vr_cdhismor
                                               ,pr_vljumora => vr_vljumora
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
              -- Se houve retorno de erro
              IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                -- Verifica se foi passado apenas o codigo
                IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
                  vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);    
                END IF;
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || 'Erro ao debitar multa e juros de mora. '
                                                           || 'Conta: ' || rw_crapepr.nrdconta || ', '
                                                           || 'Contrato: ' || rw_crapepr.nrctremp || '. '
                                                           || 'Critica: ' || vr_dscritic );
                -- Reseta variaveis
                vr_cdcritic := 0;
                vr_dscritic := NULL;
              END IF;

              -- Se foi debitado multa
              IF vr_vldmulta > 0 THEN
                -- Atualizar Pl table de conta corrente
                IF vr_tab_craplcm.exists(rw_crapepr.nrdconta) THEN
                  vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.count + 1;
                ELSE
                  vr_ind_lcm := 1;
                END IF;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere := NULL;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto := vr_vldmulta;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt := rw_craplot_8457.dtmvtolt;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor := vr_cdhismul;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg := 1;
              END IF;

              -- Se foi debitado juros de mora
              IF vr_vljumora > 0 THEN
                -- Atualizar Pl table de conta corrente
                IF vr_tab_craplcm.exists(rw_crapepr.nrdconta) THEN
                  vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.count + 1;
                ELSE
                  vr_ind_lcm := 1;
                END IF;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere := NULL;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto := vr_vljumora;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt := rw_craplot_8457.dtmvtolt;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor := vr_cdhismor;
                vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg := 1;
              END IF;

            END IF;

          ELSE
            -- Zerar o valor de desconto
            vr_vldescto := 0;
          END IF;

          -- Se o saldo devedor for menor ou igual ao desconto da parcela
          IF vr_vlsdeved <= vr_vldescto THEN
            -- Indicar que o emprestimo está liquidado
            rw_crapepr.inliquid := 1;
            -- Desativar o Rating associado a esta operaçao
            rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                       ,pr_cdagenci   => 0                   --> Código da agência
                                       ,pr_nrdcaixa   => 0                   --> Número do caixa
                                       ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                       ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                       ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                       ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                       ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                       ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                       ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                       ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                       ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                       ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                       ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                       ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                       ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros

            --------------------------------------------------------------------
            ----- Não versão progress não testava se retornou erro aqui...  ----
            --------------------------------------------------------------------

            -- Se retornar erro
            --IF vr_des_reto = 'NOK' THEN
            --  -- Tenta buscar o erro no vetor de erro
            --  IF vr_tab_erro.COUNT > 0 THEN
            --    pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            --    pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
            --  ELSE
            --    pr_dscritic := 'Retorno "NOK" na rati0001.pc_desativa_rating e pr_vet_erro vazia! Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
            --  END IF;
            --  -- Levantar exceção
            --  RAISE vr_exc_erro;
            --END IF;

            /** GRAVAMES **/
            GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                                 ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                                 ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                                 ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                                 ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                                 ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                                 ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

            --------------------------------------------------------------------
            ----- Não versão progress não testava se retornou erro aqui...  ----
            --------------------------------------------------------------------
            -- Se retornar erro
            --IF vr_des_reto <> 'OK' THEN
            --  -- Tenta buscar o erro no vetor de erro
            --  IF vr_tab_erro.COUNT > 0 THEN
            --    pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            --    pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
            --  ELSE
            --    pr_dscritic := 'Retorno "NOK" na GRVM0001.pc_solicita_baixa_automatica e pr_vet_erro vazia! Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
            --  END IF;
            --  -- Levantar exceção
            --  RAISE vr_exc_erro;
            --END IF;

          ELSE
            -- Indicar que o emprestimo não está liquidado
            rw_crapepr.inliquid := 0;
          END IF;

          -- Para registros rejeitados
          IF vr_flgrejei THEN

            -- Cria o registro de rejeitos
            BEGIN
              INSERT INTO craprej(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdconta
                                 ,nraplica
                                 ,vllanmto
                                 ,vlsdapli
                                 ,vldaviso
                                 ,cdpesqbb
                                 ,cdcritic)
                           VALUES(pr_cdcooper
                                 ,rw_crapepr.dtdpagto
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdagenci
                                 ,171
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,vr_vldescto
                                 ,vr_vlsdeved
                                 ,rw_crapepr.vlpreemp
                                 ,to_char(ROUND(vr_vlpremes - vr_vldescto,2),'fm0g000g000d00')
                                 ,171); --> Guardar ou a regularizar
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de juros para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

          END IF;

          -- Buscar a data do próximo pagamento, iniciaremos pela
          -- data do pagamento atual adicionando um mês a mesma
          vr_dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_crapepr.dtdpagto --> Data do pagamento anterior
                                              ,pr_qtmesano => 1                   --> +1 mês
                                              ,pr_tpmesano => 'M'
                                              ,pr_des_erro => vr_dscritic);
          -- Parar se encontrar erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_undo;
          END IF;
          -- Iniciando a data do próximo
          vr_prxpagto := null;
          -- Se o valor da prestação do mes permanece igual ao de desconto
          IF vr_vlpremes = vr_vldescto THEN
            -- Se a data de pagamento ainda não venceu
            IF vr_dtdpagto < rw_crapdat.dtmvtolt THEN

              -- Sair quando a data de pagamento for superior ou igual ao movimento atual
              LOOP
                EXIT WHEN vr_dtdpagto >= rw_crapdat.dtmvtolt;
                -- Adicionar de 1 em 1 mês até a data alcançar a data atual
                vr_dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => vr_dtdpagto         --> Data do pagamento anterior
                                                    ,pr_qtmesano => 1                   --> +1 mês
                                                    ,pr_tpmesano => 'M'
                                                    ,pr_des_erro => vr_dscritic);
                -- Parar se encontrar erro
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_undo;
                END IF;
              END LOOP;
              -- Utilizar a data buscada acima
              vr_prxpagto := vr_dtdpagto;
            ELSE
              -- Próximo pagamento é 1 mes após o anterior
              vr_prxpagto := vr_dtdpagto;
            END IF;
          ELSE
            -- Próximo pagamento é igual ao pagamento atual
            vr_prxpagto := rw_crapepr.dtdpagto;
          END IF;

          -- Se a data do pagamento emprestimo for anterior a data util anterior
          -- ou estiver entre a data atual e a data util anterior
          IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtoan OR (rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND rw_crapepr.dtdpagto > rw_crapdat.dtmvtoan) THEN
            -- Se o valor da prestação for igual a de desconto
            IF vr_vlpremes = vr_vldescto THEN
              -- Se a data do pagamento for do mesmo mês da data corrente
              IF TRUNC(vr_dtdpagto,'MM') = TRUNC(rw_crapdat.dtmvtolt,'MM') THEN
                -- Considerar a parcela como em aberto
                rw_crapepr.indpagto := 0;
              ELSE
                -- Considerar a parcela como paga
                rw_crapepr.indpagto := 1;
              END IF;
            ELSE
              -- Considerar a parcela como em aberto
              rw_crapepr.indpagto := 0;
            END IF;
          -- Se o valor da prestação for igual a de desconto
          ELSIF vr_vlpremes = vr_vldescto THEN
            -- Considerar a parcela como paga
            rw_crapepr.indpagto := 1;
          ELSE
            -- Considerar a parcela como em aberto
            rw_crapepr.indpagto := 0;
          END IF;

          -- Se houve pagamento por fora
          IF vr_pgtofora THEN
            -- Considerar a parcela como paga
            rw_crapepr.indpagto := 1;
            -- Utilizar como próximo pagamento a data encontrada acima
            vr_prxpagto := vr_dtdpagto;
          END IF;

          -- Atualizar a data de pagamento do rowtype para atualização na tabela posteriormente
          rw_crapepr.dtdpagto := vr_prxpagto;

          -- Finalmente após todo o processamento, é atualizada a tabela de empréstimo CRAPEPR
          BEGIN
            UPDATE crapepr
               SET dtdpagto = rw_crapepr.dtdpagto
                  ,dtultpag = rw_crapepr.dtultpag
                  ,txjuremp = rw_crapepr.txjuremp
                  ,inliquid = rw_crapepr.inliquid
                  ,indpagto = rw_crapepr.indpagto
             WHERE rowid = rw_crapepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar o empréstimo (CRAPEPR).'
                          || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_undo;
          END;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informacoes no banco de dados a cada 10.000 registros processados,
            -- gravar tbm o controle de restart, pois qualquer rollback que será efetuado
            -- vai retornar a situação até o ultimo commit
            -- Obs. Descontamos da quantidade atual, a quantidade que não foi processada
            --      devido a estes registros terem sido processados anteriormente ao restart
            IF Mod(cr_crapepr%ROWCOUNT-vr_qtregres,10000) = 0 THEN
              -- Atualizar a tabela de restart
              BEGIN
                UPDATE crapres res
                   SET res.nrdconta = rw_crapepr.nrdconta             -- conta do emprestimo atual
                      ,res.dsrestar = LPAD(rw_crapepr.nrctremp,8,'0') -- emprestimo atual
                 WHERE res.rowid = rw_crapres.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||rw_crapepr.nrdconta
                              ||' CtrEmp:'||rw_crapepr.nrctremp||'. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
              -- Finalmente efetua commit
              COMMIT; 
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_next THEN
            -- Exception criada para desviar o fluxo para cá e
            -- não processar o restante das instruções após o RAISE
            -- e acumulamos o contador de registros processados
            vr_qtregres := vr_qtregres + 1;
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
            ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_erro;
        END;
      END LOOP; -- Fim leitura dos empréstimos

      -- Efetuamos o commit final após o processamento
      COMMIT; 

      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das empréstimos indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_erro;
      END IF;

      -- Efetuamos o commit final após o processamento
      COMMIT; 

      -- Buscar todos os telefones dos associados
      FOR rw_craptfc IN cr_craptfc LOOP
        -- Somente gravar o primeiro registro (find-first)
        IF rw_craptfc.sqregtpt = 1 THEN
          -- Gravar os campos residencial, celular ou comercial
          -- conforme o tipo de registro de telefone da tabela
          IF rw_craptfc.tptelefo = 1 THEN
            -- Residencial, armazena DDD e número
            vr_tab_craptfc(rw_craptfc.nrdconta).nrfonere := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
          ELSIF rw_craptfc.tptelefo = 3 THEN
            -- Comercial, armazena DDD e número
            vr_tab_craptfc(rw_craptfc.nrdconta).nrfoncom := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
          ELSE
            -- Celular armazena apenas o número
            vr_tab_craptfc(rw_craptfc.nrdconta).nrfoncel := rw_craptfc.nrtelefo;
          END IF;
        END IF;
      END LOOP;

      -- Carregar PLTABLE de titulares de conta
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_empresa(rw_crapttl.nrdconta).cdempres := rw_crapttl.cdempres;
        vr_tab_empresa(rw_crapttl.nrdconta).cdturnos := rw_crapttl.cdturnos;
      END LOOP;
      -- Carregar PLTABLE de empresas
      FOR rw_crapjur IN cr_crapjur LOOP
        vr_tab_empresa(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
      END LOOP;

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper);

      -- Buscar todos os registros rejeitados --
      FOR rw_craprej IN cr_craprej LOOP
        -- Se ainda não preparou o arquivo txt
        IF NOT vr_flgarqtx THEN
          -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobarq,'PA;CONTA/DV;EMP;RAMAL/TELEFONE;TU;NOME;CONTRATO;DIA;SLD DEVEDOR;PRESTACAO;VLR DEBITO;VLR ESTOURO'||chr(10));
          -- Indica que preparou
          vr_flgarqtx := TRUE;
        END IF;
        -- Para cada agencia nova
        IF rw_craprej.sqregpac = 1 THEN
          -- Buscar o nome do PAC
          vr_nmresage := NULL;
          OPEN cr_crapage(rw_craprej.cdagenci);
          FETCH cr_crapage
           INTO vr_nmresage;
          CLOSE cr_crapage;
          -- Se não encontrar descrição
          IF nvl(vr_nmresage, ' ') = ' ' THEN
            -- Usar descrição genérica
            vr_nmresage := 'PA NAO CADASTRADO';
          END IF;
          -- Cada PAC terá um arquivo diferente portanto
          -- preparar o CLOB para o relatório do PAC atual
          dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><pac cdagenci="'||rw_craprej.cdagenci||'" nmresage="'||vr_nmresage||'">');
        END IF;
        -- Validar se a conta atual existe na tabela de memória dos associados
        IF NOT vr_tab_crapass.EXISTS(rw_craprej.nrdconta) THEN
          -- Fechar os CLOBS para limpar a memória
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          dbms_lob.close(vr_clobarq);
          dbms_lob.freetemporary(vr_clobarq);
          -- Gerar critica 9
          pr_cdcritic := 9;
          pr_dscritic := gene0001.fn_busca_critica(251) || ' Cta: ' || gene0002.fn_mask_conta(rw_craprej.nrdconta);
          RAISE vr_exc_erro;
        END IF;
        -- Inicializar os campos do relatório
        vr_nrramfon := '';
        vr_vlsdapli := null;
        vr_vldaviso := null;
        vr_vllanmto := null;
        vr_vlestour := null;

        -- Se não existir registro na tabela de empresas
        IF NOT vr_tab_empresa.EXISTS(rw_craprej.nrdconta) THEN
          -- Inicializar um registro vazio para evitar erros futuros
          vr_tab_empresa(rw_craprej.nrdconta).cdempres := null;
        END IF;

        -- Busca dos telefones, primeiramente verifica se existe algum
        -- registro carregado na tabela de telefones (craptfc)
        IF vr_tab_craptfc.EXISTS(rw_craprej.nrdconta) THEN
          -- Se houver o telefone residencial
          IF vr_tab_craptfc(rw_craprej.nrdconta).nrfonere IS NOT NULL THEN
            -- Adicioná-lo
            vr_nrramfon := vr_tab_craptfc(rw_craprej.nrdconta).nrfonere;
          END IF;
          -- Se houver celelular
          IF vr_tab_craptfc(rw_craprej.nrdconta).nrfoncel IS NOT NULL THEN
            -- Adicioná-lo (com uma / caso já tenhamos enviado o residencial)
            IF vr_nrramfon IS NOT NULL THEN
              vr_nrramfon := vr_nrramfon || '/';
            END IF;
            vr_nrramfon := vr_nrramfon || vr_tab_craptfc(rw_craprej.nrdconta).nrfoncel;
          END IF;
          -- Se chegarmos neste ponto e não foi encontrado nenhum telefone
          IF vr_nrramfon IS NULL THEN
            -- Utilizaremos o telefone comercial da tabela
            vr_nrramfon := vr_tab_craptfc(rw_craprej.nrdconta).nrfoncom;
          END IF;
        END IF;

        -- Enviaremos os campos de saldo devedor, prestação, valor débito e valor estouro
        -- somente se o valor dor superior a zero, senão enviaremos null
        IF gene0002.fn_char_para_number(rw_craprej.cdpesqbb) > 0 THEN
          vr_vlestour := to_char(gene0002.fn_char_para_number(rw_craprej.cdpesqbb),'fm999g999g990d00');
        END IF;
        IF rw_craprej.vlsdapli > 0 THEN
          vr_vlsdapli := to_char(rw_craprej.vlsdapli,'fm999g999g990d00');
        END IF;
        IF rw_craprej.vldaviso > 0 THEN
          vr_vldaviso := to_char(rw_craprej.vldaviso,'fm999g999g990d00');
        END IF;
        IF rw_craprej.vllanmto > 0 THEN
          vr_vllanmto := to_char(rw_craprej.vllanmto,'fm999g999g990d00');
        END IF;

        -- Enviar o registro para o relatório
        pc_escreve_clob(vr_clobxml,'<rejeitos>'
                                 ||'  <nrdconta>'||LTRIM(gene0002.fn_mask_conta(rw_craprej.nrdconta))||'</nrdconta>'
                                 ||'  <cdempres>'||vr_tab_empresa(rw_craprej.nrdconta).cdempres||'</cdempres>'
                                 ||'  <nrramfon>'||substr(vr_nrramfon,1,20)||'</nrramfon>'
                                 ||'  <cdturnos>'||vr_tab_empresa(rw_craprej.nrdconta).cdturnos||'</cdturnos>'
                                 ||'  <nmprimtl>'||substr(vr_tab_crapass(rw_craprej.nrdconta).nmprimtl,1,26)||'</nmprimtl>'
                                 ||'  <nraplica>'||LTRIM(gene0002.fn_mask(rw_craprej.nraplica,'zzzz.zz9'))||'</nraplica>'
                                 ||'  <diapagto>'||to_char(rw_craprej.dtmvtolt,'dd')||'</diapagto>'
                                 ||'  <vlsdapli>'||vr_vlsdapli||'</vlsdapli>'
                                 ||'  <vldaviso>'||vr_vldaviso||'</vldaviso>'
                                 ||'  <vllanmto>'||vr_vllanmto||'</vllanmto>'
                                 ||'  <vlestour>'||vr_vlestour||'</vlestour>'
                                 ||'</rejeitos>');

        -- Se existe turno cadastrado
        IF vr_tab_empresa(rw_craprej.nrdconta).cdturnos IS NOT NULL THEN
          -- Usá-la
          vr_cdturnos := vr_tab_empresa(rw_craprej.nrdconta).cdturnos;
        ELSE
          -- Usar zero
          vr_cdturnos := 0;
        END IF;

        -- Enviaremos os campos de saldo devedor, prestação e valor débito
        -- somente se o valor dor superior a zero, senão enviaremos 0
        IF rw_craprej.vlsdapli > 0 THEN
          vr_vlsdapli := to_char(rw_craprej.vlsdapli,'999g990d00');
        ELSE
          vr_vlsdapli := to_char(0,'999g990d00');
        END IF;
        IF rw_craprej.vldaviso > 0 THEN
          vr_vldaviso := to_char(rw_craprej.vldaviso,'999g990d00');
        ELSE
          vr_vldaviso := to_char(0,'999g990d00');
        END IF;
        IF rw_craprej.vllanmto > 0 THEN
          vr_vllanmto := to_char(rw_craprej.vllanmto,'999g990d00');
        ELSE
          vr_vllanmto := to_char(0,'999g990d00');
        END IF;
        -- Quanto ao saldo devedor seguirá o mesmo esquema acima, ou seja, só envia se houver
        -- e a mascara neste ponto é um pouco diferente da versão no XML
        IF gene0002.fn_char_para_number(rw_craprej.cdpesqbb) > 0 THEN
          vr_vlestour := to_char(gene0002.fn_char_para_number(rw_craprej.cdpesqbb),'999g990d00');
        ELSE
          vr_vlestour := to_char(0,'999g990d00');
        END IF;

        -- Enviamos também as informações para o arquivo de exportação
        pc_escreve_clob(vr_clobarq,LPAD(rw_craprej.cdagenci,3,' ')||';'
                                   ||gene0002.fn_mask_conta(rw_craprej.nrdconta)||';'
                                   ||LPAD(vr_tab_empresa(rw_craprej.nrdconta).cdempres,5,' ')||';'
                                   ||RPAD(substr(vr_nrramfon,1,20),20,' ')||';'
                                   ||LPAD(vr_cdturnos,2,' ')||';'
                                   ||RPAD(substr(vr_tab_crapass(rw_craprej.nrdconta).nmprimtl,1,26),26,' ')||';'
                                   ||gene0002.fn_mask(rw_craprej.nraplica,'zzzz.zz9')||';'
                                   ||to_char(rw_craprej.dtmvtolt,'dd')||';'
                                   ||vr_vlsdapli||';'
                                   ||vr_vldaviso||';'
                                   ||vr_vllanmto||';'
                                   ||vr_vlestour
                                   ||chr(10));

        -- No ultimo registro do pac
        IF rw_craprej.sqregpac = rw_craprej.qtregpac THEN
          -- Encerrar a tag do pac atual
          pc_escreve_clob(vr_clobxml,'</pac>');

          -- Submeter o relatório 135
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/pac/rejeitos'                      --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl135.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl135_'||to_char(rw_craprej.cdagenci,'fm000')||'.lst' --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 2                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;

      -- Ao final do processamento, se foi ativada a flag do arquivo
      IF vr_flgarqtx THEN
        -- Tenta buscar o parâmetro para cópia do TXT para algum usuário
        IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL135_COPIA') IS NOT NULL THEN
          -- Efetuar a cópia do arquivo crrl35.txt também para diretório parametrizado
          vr_dspathcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL135_COPIA');
        END IF;
        -- Submeter a geração do arquivo txt puro
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobarq                           --> Arquivo XML de dados
                                           ,pr_cdrelato  => '135'                                --> Código do relatório
                                           ,pr_dsarqsaid => vr_nom_direto||'/salvar/crrl135.txt' --> Arquivo final com o path
                                           ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                           ,pr_dspathcop => vr_dspathcopia                       --> Copiar para o diretório
                                           ,pr_fldoscop  => 'S'                                  --> Copia convertendo para DOS
                                           ,pr_flgremarq => 'N'                                  --> Após cópia, remover arquivo de origem
                                           ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobarq);
        dbms_lob.freetemporary(vr_clobarq);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Ao final do processo irá eliminar os registros rejeitos
      BEGIN
        DELETE craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.cdbccxlt = 171
           AND rej.cdcritic = 171;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          vr_dscritic := 'Erro ao atualizar a limpeza na tabela de registros rejeitos (CRAPREJ). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT; 

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT; 

      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps171;
/
