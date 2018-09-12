CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS133(pr_cdcooper  IN craptab.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo Agencia
                                             ,pr_idparale  IN crappar.idparale%TYPE --> Indicador de processoparalelo
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic out crapcri.cdcritic%TYPE
                                             ,pr_dscritic out varchar2) IS
/* ..........................................................................

   Programa: pc_crps133 (Antigo Fontes/crps133.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/95                      Ultima atualizacao: 06/08/2018

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 5.
               Gerar cadastro de informacoes gerenciais.
               Ordem do programa na solicitacao 2.

   Alteracoes: 23/02/96 - Alterado para tratar campo crapacc.cdempres e
                          crapger.cdempres (Odair)

               02/04/96 - Alterado para tratar qtctrrpp, vlctrrpp, qtaplrpp,
                          vlaplrpp (Odair).

               03/05/96 - Alterado para desprezar as poupancas que ainda nao
                          tenham iniciado o desconto (Deborah).

               14/08/96 - Alterado para tratar qtassapl (Odair).

               11/09/96 - Alterado para desmembrar para 168 (Odair).

               06/01/97 - Acumular juros de emprestimos tpregist = 6 (Odair).

               10/09/98 - Tratar tipo de conta 7 (Deborah).

               16/08/99 - Contar apenas qtd de associados com inmatric = 1
                          (Odair)

               02/07/2001 - Tratar contratos em prejuizo (Deborah).

               06/08/2001 - Tratar prejuizo de conta corrente (Margarete).

               21/10/2003 - Somente rodar se processo mensal(Mirtes).

               29/01/2004 - Contar apenas qtd de associados com saldo maior
                            que saldo medio do mes (Junior).

               08/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas crapacc
                            e crapger (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               20/01/2006 - Acerto na campo lancamentos e acresentada
                            leitura do campo cdcooper nas tabelas (Diego).

               01/03/2006 - Acerto no programa - crapcbb (Ze).

               05/05/2006 - Acertos nos indices (Mirtes)

               08/11/2006 - Otimizacao do programa e juncao do crps143
                            (Evandro).

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                          - Contabilizar desconto de titulos e juros (Gabriel).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               27/06/2011 - Consulta na crapltr desconsiderando alguns
                            historicos, pois, os lancamentos referentes aos
                            mesmos ja constam na craplcm. (Fabricio)

               11/02/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero)

               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas)

               09/10/2013 - Modificado o padrão das exceções para utilizar a rotina
                            pc_valida_fimprg (Edison - AMcom)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               06/12/2013 - Ajustes em problemas do programa. (Marcos-Supero)

               19/09/2014 - Acrescentado leitura da tabela craplac. (Reinert)

               24/04/2015 - Ajustar para gerar a critica de Associado não cadastrado no
                            LOG de mensagens, ao invés de gerar no LOG do processo.
                            (DOuglas - Chamado 273546)

               28/05/2015 - Realizando a retirada dos tratamentos de restart, pois o programa
                            apresentou erros no processo batch. Os códigos foram comentados e
                            podem ser removidos em futuras alterações do fonte. (Renato - Supero)
                            
               31/10/2017 - #755898 Correção de sintaxe de uso de índice no cursor cr_craplcm (Carlos)

               05/03/2018 - Substituída verificacao do tipo de conta "NOT IN (5,6,7,17,18)" para a 
                            modalidade do tipo de conta diferente de "2" e "3". PRJ366. (Lombardi)

               17/05/2018 - Projeto Revitalização Sistemas - Transformação do programa
			                em paralelo por Agência - Andreatta (MOUTs)

               06/08/2018 - Inclusao de maiores detalhes nos logs de erros - Andreatta (MOUTs) 
               
               11/08/2018 - Inclusão da aplicação programada no cursor cr_craplpp (Proj. 411.2 - CIS Corporate).

............................................................................. */
BEGIN

  DECLARE

    --- ################################ Variáveis ################################# ----

    -- Código do programa
    vr_cdprogra      crapprg.cdprogra%type;
    -- Data do movimento
    vr_flgmensa      boolean;
    vr_flganual      boolean;
    vr_insldmes      number(1);
    -- Tratamento de erros
    vr_exc_saida     exception;
    vr_exc_fimprg    exception;
    vr_cdcritic      crapcri.cdcritic%type;
    vr_dscritic      varchar2(4000);

    -- Variável para armazenar o saldo médio
    vr_dstextab      craptab.dstextab%TYPE;
    vr_vlsldmed      crapsld.vlsmstre##1%type;
    -- Código da empresa do associado (PF ou PJ)
    vr_cdempres      crapttl.cdempres%type;
    --
    vr_flghaepr      boolean;
    -- Variáveis para armazenar o código, tipo, quantidade e valor do lançamento
    vr_cdlanmto      crapacc.cdlanmto%type;
    vr_qtlancto      NUMBER;
    vr_vllancto      NUMBER(35,10);

    -- ID para o paralelismo
    vr_idparale      integer;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs       number;
    -- Job name dos processos criados
    vr_jobname       varchar2(30);
    -- Bloco PLSQL para chamar a execução paralela do pc_crps750
    vr_dsplsql       varchar2(4000);

    -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;
    vr_tpexecucao    tbgen_prglog.tpexecucao%type;
    vr_qterro        number := 0;

    --- ################################ Tipos e Registros de memória ################################# ----

    -- Registro para armazenar os dados gerais (PAC e empresa)
    type tab_geral is record (vr_codigo    number(10),
                              vr_tipo      varchar2(1), -- "A"gência ou "E"mpresa
                              vr_qtassoci  crapger.qtassoci%type,
                              vr_qtctacor  crapger.qtctacor%type,
                              vr_qtplanos  crapger.qtplanos%type,
                              vr_qtassepr  crapger.qtassepr%type,
                              vr_vlsmpmes  crapger.vlsmpmes%type,
                              vr_vlcaptal  crapger.vlcaptal%type,
                              vr_vlplanos  crapger.vlplanos%type);
    -- Definição da tabela para armazenar os registros de dados gerais
    type typ_tab_geral is table of tab_geral index by varchar2(11);
    -- Instâncias das tabelas. O índice será o tipo concatenado com o código.
    vr_tab_pac       typ_tab_geral;
    vr_tab_emp       typ_tab_geral;
    -- Variáveis utilizadas para indexar as PL/Tables
    vr_indice_pac    varchar2(11);
    vr_indice_emp    varchar2(11);

    -- Registro para armazenar os valores
    type tab_valores is record (vr_codigo    number(10),
                                vr_tipo      varchar2(1), -- "A"gência ou "E"mpresa
                                vr_cdhistor  number(5),
                                vr_qtlanmto  crapacc.qtlanmto%type,
                                vr_qteprlcr  crapacc.qtlanmto%type,
                                vr_qteprfin  crapacc.qtlanmto%type,
                                vr_qtsdvlcr  crapacc.qtlanmto%type,
                                vr_qtsdvfin  crapacc.qtlanmto%type,
                                vr_qtjurlcr  crapacc.qtlanmto%type,
                                vr_vllanmto  number(35,10),
                                vr_vleprlcr  number(35,10),
                                vr_vleprfin  number(35,10),
                                vr_vlsdvlcr  number(35,10),
                                vr_vlsdvfin  number(35,10),
                                vr_vljurlcr  number(35,10));
    -- Definição da tabela para armazenar os registros de valores
    type typ_tab_valores is table of tab_valores index by varchar2(16);
    -- Instância da tabela. O índice será a concatenação de tipo, código e histórico.
    vr_tab_val       typ_tab_valores;
    -- Variável utilizada para indexar a PL/Table
    vr_indice_val    varchar2(16);

    -- Definicao do tipo de tabela para os tipos de conta
    TYPE typ_reg_tipcta   IS RECORD(cdmodali tbcc_tipo_conta.cdmodalidade_tipo%TYPE);        
    TYPE typ_tab_tipcta_2 IS TABLE OF typ_reg_tipcta   INDEX BY PLS_INTEGER;        
    TYPE typ_tab_tipcta   IS TABLE OF typ_tab_tipcta_2 INDEX BY PLS_INTEGER;          
    -- Vetor para armazenar os dados para o processo definitivo
    vr_tab_tipcta typ_tab_tipcta;    

    -- PL Table para armazenar dados de aplicações pessoa jurídica
    TYPE typ_reg_crapjur IS
      RECORD(cdempres  crapjur.cdempres%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY VARCHAR2(10);
    vr_tab_crapjur typ_tab_crapjur;

    -- PL Table para armazenar dados de aplicações pessoa física
    TYPE typ_reg_crapttl IS
      RECORD(cdempres  crapttl.cdempres%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY VARCHAR2(10);
    vr_tab_crapttl typ_tab_crapttl;
    
    
    -- Tipos de memória para armazenar conta e subregistros da crapljd 
    TYPE typ_reg_crapljd IS RECORD(cdhistor NUMBER
                                  ,vlrestit NUMBER);   
    TYPE typ_tab_crapljd IS TABLE OF typ_reg_crapljd INDEX BY PLS_INTEGER;
    TYPE typ_reg_ljdass IS RECORD(vr_tab_crapljd typ_tab_crapljd);
    TYPE typ_tab_ljdass IS TABLE OF typ_reg_ljdass INDEX BY PLS_INTEGER;
    vr_tab_ljdass typ_tab_ljdass;
    vr_id_interno PLS_INTEGER;
    
    -- Tipo de memória para armazenar dados dos boletos de cheque
    TYPE typ_reg_CRAPCDB IS RECORD(qtdregis NUMBER
                                  ,vlliquid NUMBER);
    TYPE typ_tab_CRAPCDB IS TABLE OF typ_reg_CRAPCDB INDEX BY PLS_INTEGER;                           
    vr_tab_CRAPCDB typ_tab_CRAPCDB;
    
    -- Tipo de memória para armazenar dados dos custodia de cheque
    TYPE typ_reg_crapcst IS RECORD(qtdregis NUMBER
                                  ,vlcheque NUMBER);
    TYPE typ_tab_crapcst IS TABLE OF typ_reg_crapcst INDEX BY PLS_INTEGER;                           
    vr_tab_crapcst typ_tab_crapcst;    
    
    -- Tabela de memória para armazenar dados das Cotas
    TYPE typ_reg_crapcot IS RECORD(vlcotant NUMBER
                                  ,vlcapmes NUMBER);
    TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY PLS_INTEGER;                           
    vr_tab_crapcot typ_tab_crapcot; 
    
    -- Tabela de memória para armazenar dados de Saldo
    TYPE typ_reg_crapsld IS RECORD(vlsmstre NUMBER);
    TYPE typ_tab_crapsld IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER;                           
    vr_tab_crapsld typ_tab_crapsld; 
    
    -- Tabela de memória para armazenar plano de capital
    TYPE typ_reg_crappla IS RECORD(vlprepla NUMBER);
    TYPE typ_tab_crappla IS TABLE OF typ_reg_crappla INDEX BY PLS_INTEGER;                           
    vr_tab_crappla typ_tab_crappla;
    
    -- Tipos de memória para armazenar conta e subregistros da crapepr 
    TYPE typ_reg_crapepr IS RECORD(dtmvtolt crapepr.dtmvtolt%TYPE
                                  ,vlemprst crapepr.vlemprst%TYPE
                                  ,inprejuz crapepr.inprejuz%TYPE
                                  ,dtprejuz crapepr.dtprejuz%TYPE
                                  ,vljurmes crapepr.vljurmes%TYPE
                                  ,vlsdeved crapepr.vlsdeved%TYPE
                                  ,cdlcremp crapepr.cdlcremp%TYPE
                                  ,cdfinemp crapepr.cdfinemp%TYPE);   
    TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY PLS_INTEGER;
    TYPE typ_reg_eprass IS RECORD(vr_tab_crapepr typ_tab_crapepr);
    TYPE typ_tab_eprass IS TABLE OF typ_reg_eprass INDEX BY PLS_INTEGER;
    vr_tab_eprass typ_tab_eprass;

    --- #################################### CURSORES ############################################## ----

    -- Data do movimento
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -- Dados da cooperativa
    cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
      select 1
        from crapcop
       where crapcop.cdcooper = pr_cdcooper;
    rw_crapcop    cr_crapcop%rowtype;

    -- Lista das agências da Cooperativa
    CURSOR cr_crapage(pr_cdcooper in craprpp.cdcooper%type
                     ,pr_cdprogra in tbgen_batch_controle.cdprogra%type
                     ,pr_qterro   in number
                     ,pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%type) IS
      select distinct crapass.cdagenci
        from crapass
       where crapass.cdcooper  = pr_cdcooper
         and (pr_qterro = 0 or
             (pr_qterro > 0 and exists (select 1
                                          from tbgen_batch_controle
                                         where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                           and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                           and tbgen_batch_controle.tpagrupador = 1
                                           and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                           and tbgen_batch_controle.insituacao  = 1
                                           and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
      order by crapass.cdagenci;
      
    -- Buscar dados de aplicações pessoa física
    CURSOR cr_crapttl(pr_cdcooper IN craptab.cdcooper%TYPE --> Código da cooperativa
                     ,pr_cdagenci IN crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT cl.nrdconta
            ,cl.cdempres
        FROM crapttl cl
            ,crapass ass
       WHERE cl.cdcooper = ass.cdcooper
         AND cl.nrdconta = ass.nrdconta
         AND cl.cdcooper = pr_cdcooper
         and ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
         AND cl.idseqttl = 1;

    -- Buscar dados de aplicações pessoa jurídica
    CURSOR cr_crapjur(pr_cdcooper IN craptab.cdcooper%TYPE --> Código da cooperativa
                     ,pr_cdagenci IN crapass.cdagenci%TYPE) IS --> Código da agencia
      SELECT cj.nrdconta
            ,cj.cdempres
        FROM crapjur cj
            ,crapass ass
       WHERE cj.cdcooper = ass.cdcooper
         AND cj.nrdconta = ass.nrdconta
         AND cj.cdcooper = pr_cdcooper
         and ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);    
         

    -- Juros de descontos de cheques
    cursor cr_crapljd (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapass.cdagenci%type) is
      SELECT crap.nrdconta,
             998 cdhistor,
             crap.vlrestit
        from crapljd crap
            ,crapass ass
       where crap.cdcooper = ass.cdcooper
         AND crap.nrdconta = ass.nrdconta
         AND crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci);  
         
    -- Busca informações referentes a empréstimos
    cursor cr_crapepr (pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapass.cdagenci%type) is
      SELECT crapepr.nrdconta,
             crapepr.dtmvtolt,
             crapepr.vlemprst,
             crapepr.inprejuz,
             crapepr.dtprejuz,
             crapepr.vljurmes,
             crapepr.vlsdeved,
             crapepr.cdlcremp,
             crapepr.cdfinemp
        from crapepr
            ,crapass
       where crapepr.cdcooper = crapass.cdcooper
         AND crapepr.nrdconta = crapass.nrdconta
         AND crapepr.cdcooper = pr_cdcooper
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);  

    -- Busca informações do associado
    cursor cr_crapass (pr_cdcooper in crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapass.cdagenci%TYPE) is
      select cdagenci
            ,nrdconta
            ,dtdemiss
            ,inpessoa
            ,inmatric
            ,cdtipcta
            ,cdsitdct
        from crapass
       where cdcooper = pr_cdcooper
         and cdagenci = decode(pr_cdagenci,0,cdagenci,pr_cdagenci);
         
    TYPE typ_crapass IS TABLE OF cr_crapass%ROWTYPE INDEX BY PLS_INTEGER;
    rw_crapass typ_crapass;          

    -- Busca o saldo médio mensal do associado
    cursor cr_crapsld (pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapass.cdagenci%type,
                       pr_insldmes in number) is
      select crapsld.nrdconta
            ,decode(pr_insldmes,
                    1, crapsld.vlsmstre##1,
                    2, crapsld.vlsmstre##2,
                    3, crapsld.vlsmstre##3,
                    4, crapsld.vlsmstre##4,
                    5, crapsld.vlsmstre##5,
                    6, crapsld.vlsmstre##6,
                    0) vlsmstre
        from crapsld
            ,crapass 
       where crapsld.cdcooper = crapass.cdcooper
         AND crapsld.nrdconta = crapass.nrdconta
         AND crapsld.cdcooper = pr_cdcooper
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

    -- Busca o valor capital do mês (cotas e recursos)
    cursor cr_crapcot(pr_cdcooper in crapcop.cdcooper%type,
                      pr_cdagenci in crapass.cdagenci%type,
                      pr_mes in number) is
      select crapcot.nrdconta,
             crapcot.vlcotant,
             decode(pr_mes,
                    1, crapcot.vlcapmes##1,
                    2, crapcot.vlcapmes##2,
                    3, crapcot.vlcapmes##3,
                    4, crapcot.vlcapmes##4,
                    5, crapcot.vlcapmes##5,
                    6, crapcot.vlcapmes##6,
                    7, crapcot.vlcapmes##7,
                    8, crapcot.vlcapmes##8,
                    9, crapcot.vlcapmes##9,
                    10, crapcot.vlcapmes##10,
                    11, crapcot.vlcapmes##11,
                    12, crapcot.vlcapmes##12,
                    0) vlcapmes
        from crapcot
            ,crapass 
       where crapcot.cdcooper = crapass.cdcooper
         AND crapcot.nrdconta = crapass.nrdconta
         AND crapcot.cdcooper = pr_cdcooper
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

    -- Busca o valor da prestação do plano de capitalização
    cursor cr_crappla (pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapass.cdagenci%type) is
      SELECT crappla.nrdconta
            ,crappla.vlprepla
        from crappla
            ,crapass 
       where crappla.cdcooper = crapass.cdcooper
         AND crappla.nrdconta = crapass.nrdconta
         AND crappla.cdcooper = pr_cdcooper
         AND crappla.cdsitpla = 1
         AND crappla.tpdplano = 1
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

    -- Cursores para buscar os valores a serem registrados
    --
    -- Lançamentos em depósitos a vista
    cursor cr_craplcm (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from craplcm crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos em empréstimos
    cursor cr_craplem (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from craplem crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos em cotas / capital
    cursor cr_craplct (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from craplct crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos de aplicações RDCA
    cursor cr_craplap (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from craplap crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos de aplicações de captação
    CURSOR cr_craplac (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                      ,pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta in crapass.nrdconta%type) IS
      SELECT lac.nrdconta
            ,lac.cdhistor
            ,lac.vllanmto
        FROM craplac lac
       WHERE lac.dtmvtolt = pr_dtmvtolt
         AND lac.cdcooper = pr_cdcooper
         and lac.nrdconta = pr_nrdconta;

    -- Lançamentos automáticos
    cursor cr_craplau (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanaut
        from craplau crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos de cobrança
    cursor cr_craplcb (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from craplcb crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos da conta de investimento
    cursor cr_craplci (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from craplci crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.nrdconta = pr_nrdconta;

    -- Lançamentos de aplicações de poupança
    cursor cr_craplpp (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT lpp.nrdconta,
             lpp.cdhistor,
             lpp.vllanmto
        from craplpp lpp
       where lpp.dtmvtolt = pr_dtmvtolt
         and lpp.cdcooper = pr_cdcooper
         and lpp.nrdconta = pr_nrdconta
       UNION
      SELECT lac.nrdconta,
             lac.cdhistor,
             lac.vllanmto
        from craplac lac
       where lac.dtmvtolt = pr_dtmvtolt
         and lac.cdcooper = pr_cdcooper
         and lac.nrdconta = pr_nrdconta;

    -- Transações nos caixas e auto-atendimento
    cursor cr_crapltr (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT crap.nrdconta,
             crap.cdhistor,
             crap.vllanmto
        from crapltr crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.cdhistor not in (316, 375, 376, 377, 767, 918, 920)
         and crap.nrdconta = pr_nrdconta;

    -- Todas Custódias de cheques
    cursor cr_crapcst(pr_dtmvtolt in crapdat.dtmvtolt%type,
                      pr_cdcooper in crapcop.cdcooper%type,
                      pr_cdagenci in crapass.cdagenci%type) is
      SELECT crap.nrdconta
            ,COUNT(1) qtdregis
            ,SUM(crap.vlcheque) vlcheque
        from crapcst crap
            ,crapass ass
       where crap.cdcooper = pr_cdcooper
         AND crap.dtmvtolt = pr_dtmvtolt 
         AND crap.cdcooper = ass.cdcooper
         AND crap.nrdconta = ass.nrdconta
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
        GROUP BY crap.nrdconta;

    -- Todos Borderôs de desconto de cheques
    cursor cr_crapcdb(pr_dtmvtolt in crapdat.dtmvtolt%type,
                      pr_cdcooper in crapcop.cdcooper%type,
                      pr_cdagenci in crapass.cdagenci%type) is
      SELECT crap.nrdconta
            ,COUNT(1) qtdregis
            ,SUM(crap.vlliquid) vlliquid
        FROM crapcdb crap 
            ,crapass ass
       WHERE crap.cdcooper = pr_cdcooper
         AND crap.dtmvtolt = pr_dtmvtolt 
         AND crap.cdcooper = ass.cdcooper
         AND crap.nrdconta = ass.nrdconta
         AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
        GROUP BY crap.nrdconta;
        
    -- Borderô de descontos de títulos
    cursor cr_crapbdt (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select bdt.nrdconta,
             tdb.vlliquid
        from crapbdt bdt
            ,craptdb tdb
       where tdb.cdcooper = bdt.cdcooper
         AND tdb.nrdconta = bdt.nrdconta
         AND tdb.nrborder = bdt.nrborder
         AND bdt.dtmvtolt = pr_dtmvtolt
         and bdt.cdcooper = pr_cdcooper
         and bdt.nrdconta = pr_nrdconta;
         
    --
    -- Tabelas que contam somente por PAC
    --
    -- Autenticações
    cursor cr_crapaut (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapage.cdagenci%type) is
      SELECT crap.cdagenci,
             995 cdhistor,
             crap.vldocmto
        from crapaut crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.cdagenci = decode(pr_cdagenci,0,crap.cdagenci,pr_cdagenci);

    -- Lançamentos extra-sistema (boletim de caixa)
    cursor cr_craplcx (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapage.cdagenci%type) is
      SELECT crap.cdagenci,
             crap.cdhistor,
             crap.vldocmto
        from craplcx crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.cdagenci = decode(pr_cdagenci,0,crap.cdagenci,pr_cdagenci);

    -- Lançamentos de faturas
    cursor cr_craplft (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapage.cdagenci%type) is
      SELECT crap.cdagenci,
             crap.cdhistor,
             (crap.vllanmto + nvl(crap.vlrmulta, 0) + nvl(crap.vlrjuros, 0)) vllanmto
        from craplft crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.cdagenci = decode(pr_cdagenci,0,crap.cdagenci,pr_cdagenci);

    -- Títulos acolhidos
    cursor cr_craptit (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapage.cdagenci%type) is
      SELECT crap.cdagenci,
             994 cdhistor,
             crap.vldpagto
        from craptit crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.cdagenci = decode(pr_cdagenci,0,crap.cdagenci,pr_cdagenci);

    -- Movimento Correspondente Bancário - Banco do Brasil
    cursor cr_crapcbb (pr_dtmvtolt in crapdat.dtmvtolt%type,
                       pr_cdcooper in crapcop.cdcooper%type,
                       pr_cdagenci in crapage.cdagenci%type) is
      SELECT crap.cdagenci,
             750 cdhistor,
             crap.valorpag
        from crapcbb crap
       where crap.dtmvtolt = pr_dtmvtolt
         and crap.cdcooper = pr_cdcooper
         and crap.flgrgatv = 1
         and crap.tpdocmto < 3
         and crap.cdagenci = decode(pr_cdagenci,0,crap.cdagenci,pr_cdagenci);


    -- Cursor para busca dos tipos de conta
    CURSOR cr_tipcta IS
      SELECT inpessoa
            ,cdtipo_conta cdtipcta
            ,cdmodalidade_tipo cdmodali
        FROM tbcc_tipo_conta;         
         
    -- Dados das tabela de trabalho por agência
    cursor cr_relwork_pac(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type
                         ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type
                         ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT cdagenci
            ,dschave  cdlanmto
            ,tpparcel tplancto
            ,nrdocmto qtlancto
            ,vlacumul vllancto
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper
         AND cdprograma  = pr_cdprograma
         AND dsrelatorio = 'CRAPACC_PAC'
         AND dtmvtolt    = pr_dtmvtolt
       ORDER BY cdagenci,dschave;

    -- Dados gerenciais das tabela de trabalho por agência
    cursor cr_relwork_pacger(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type
                            ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type
                            ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT cdagenci
            ,to_number(gene0002.fn_busca_entrada(1,dscritic,';'),'fm999g999g999g990') qtassoci
            ,to_number(gene0002.fn_busca_entrada(2,dscritic,';'),'fm999g999g999g990') qtctacor
            ,to_number(gene0002.fn_busca_entrada(3,dscritic,';'),'fm999g999g999g990') qtplanos
            ,to_number(gene0002.fn_busca_entrada(4,dscritic,';'),'fm999g999g999g999g990d00') vlcaptal
            ,to_number(gene0002.fn_busca_entrada(5,dscritic,';'),'fm999g999g999g999g990d00') vlplanos
            ,to_number(gene0002.fn_busca_entrada(6,dscritic,';'),'fm999g999g999g999g990d00') vlsmpmes
            ,to_number(gene0002.fn_busca_entrada(7,dscritic,';'),'fm999g999g999g990') qtassepr
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper
         AND cdprograma  = pr_cdprograma
         AND dsrelatorio = 'CRAPGER_PAC'
         AND dtmvtolt    = pr_dtmvtolt
       ORDER BY cdagenci;

    -- Dados das tabela de trabalho por empresa
    -- Obs: Registros por empresa precisam de Group By, pois para evitar concorrência
    --      da gravação de jobs gravamos os valores separados por cada PA em execução (JOB)
    --      e no centralizador (pr_cdagenci = 0) nós somamos
    cursor cr_relwork_emp(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type
                         ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type
                         ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT nrdconta cdempres
            ,dschave  cdlanmto
            ,tpparcel tplancto
            ,sum(nrdocmto) qtlancto
            ,SUM(vlacumul) vllancto
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper
         AND cdprograma  = pr_cdprograma
         AND dsrelatorio = 'CRAPACC_EMP'
         AND dtmvtolt    = pr_dtmvtolt
       GROUP BY nrdconta
               ,dschave
               ,tpparcel
       ORDER BY nrdconta,dschave;

    -- Dados gerenciais das tabela de trabalho por empresa
    -- Obs: Registros por empresa precisam de Group By, pois para evitar concorrência
    --      da gravação de jobs gravamos os valores separados por cada PA em execução (JOB)
    --      e no centralizador (pr_cdagenci = 0) nós somamos
    cursor cr_relwork_empger(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type
                            ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type
                            ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT cdempres
            ,sum(qtassoci) qtassoci
            ,sum(qtctacor) qtctacor
            ,sum(qtplanos) qtplanos
            ,sum(vlcaptal) vlcaptal
            ,sum(vlplanos) vlplanos
            ,sum(vlsmpmes) vlsmpmes
            ,sum(qtassepr) qtassepr
        FROM (SELECT nrdconta cdempres
                    ,to_number(gene0002.fn_busca_entrada(1,dscritic,';'),'fm999g999g999g990') qtassoci
                    ,to_number(gene0002.fn_busca_entrada(2,dscritic,';'),'fm999g999g999g990') qtctacor
                    ,to_number(gene0002.fn_busca_entrada(3,dscritic,';'),'fm999g999g999g990') qtplanos
                    ,to_number(gene0002.fn_busca_entrada(4,dscritic,';'),'fm999g999g999g999g990d00') vlcaptal
                    ,to_number(gene0002.fn_busca_entrada(5,dscritic,';'),'fm999g999g999g999g990d00') vlplanos
                    ,to_number(gene0002.fn_busca_entrada(6,dscritic,';'),'fm999g999g999g999g990d00') vlsmpmes
                    ,to_number(gene0002.fn_busca_entrada(7,dscritic,';'),'fm999g999g999g990') qtassepr
                FROM tbgen_batch_relatorio_wrk
               WHERE cdcooper    = pr_cdcooper
                 AND cdprograma  = pr_cdprograma
                 AND dsrelatorio = 'CRAPGER_EMP'
                 AND dtmvtolt    = pr_dtmvtolt
              )
       GROUP BY cdempres
       ORDER BY cdempres;

    --- ################################ SubRotinas ################################# ----
    function fn_cria_registro (pr_codigo    in number,
                               pr_tipo      in varchar2,
                               pr_historico in number) return varchar2 is
      -- Procedimento para inicialização dos registros da pl/table de valores
      -- Retorna o índice do registro criado
      vr_indice    varchar2(16) := pr_tipo||lpad(pr_codigo, 10, '0')||lpad(pr_historico, 5, '0');
    begin
      if not vr_tab_val.exists(vr_indice) then
        -- Cria registro na PL/Table com valores zerados
        vr_tab_val(vr_indice).vr_codigo   := pr_codigo;
        vr_tab_val(vr_indice).vr_tipo     := pr_tipo;
        vr_tab_val(vr_indice).vr_cdhistor := pr_historico;
        vr_tab_val(vr_indice).vr_qtlanmto := 0;
        vr_tab_val(vr_indice).vr_qteprlcr := 0;
        vr_tab_val(vr_indice).vr_qteprfin := 0;
        vr_tab_val(vr_indice).vr_qtsdvlcr := 0;
        vr_tab_val(vr_indice).vr_qtsdvfin := 0;
        vr_tab_val(vr_indice).vr_qtjurlcr := 0;
        vr_tab_val(vr_indice).vr_vllanmto := 0;
        vr_tab_val(vr_indice).vr_vleprlcr := 0;
        vr_tab_val(vr_indice).vr_vleprfin := 0;
        vr_tab_val(vr_indice).vr_vlsdvlcr := 0;
        vr_tab_val(vr_indice).vr_vlsdvfin := 0;
        vr_tab_val(vr_indice).vr_vljurlcr := 0;
      end if;
      return(vr_indice);
    end;

    -- Criar registro na tabela de Agências
    procedure pc_gera_registro_pac (pr_cdagenci in craplcm.cdagenci%type,
                                    pr_cdhistor in craplcm.cdhistor%type,
                                    pr_vllanmto in crapacc.vllanmto%type,
                                    pr_qtlanmto IN NUMBER DEFAULT 1) is
      -- Cria os registros para as tabelas que tem somente o pac, e cria a tabela de valores
      vr_indice_val   varchar2(16);
      vr_indice_pac   varchar2(11) := 'A'||lpad(pr_cdagenci, 10, '0');
    begin
      if not vr_tab_pac.exists(vr_indice_pac) then
        -- Cria registro na PL/Table com valores zerados
        vr_tab_pac(vr_indice_pac).vr_codigo := pr_cdagenci;
        vr_tab_pac(vr_indice_pac).vr_tipo := 'A';
        vr_tab_pac(vr_indice_pac).vr_qtassoci := 0;
        vr_tab_pac(vr_indice_pac).vr_qtctacor := 0;
        vr_tab_pac(vr_indice_pac).vr_qtplanos := 0;
        vr_tab_pac(vr_indice_pac).vr_qtassepr := 0;
        vr_tab_pac(vr_indice_pac).vr_vlsmpmes := 0;
        vr_tab_pac(vr_indice_pac).vr_vlcaptal := 0;
        vr_tab_pac(vr_indice_pac).vr_vlplanos := 0;
      end if;
      --
      vr_indice_val := fn_cria_registro(pr_cdagenci, 'A', 9999);
      vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + pr_qtlanmto;
      vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
      --
      vr_indice_val := fn_cria_registro(pr_cdagenci, 'A', pr_cdhistor);
      vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + pr_qtlanmto;
      vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
    end;

    -- Abrir informações dos vetores de Agência e Empresa
    procedure pc_gera_registro_conta (pr_cdagenci in crapass.cdagenci%type,
                                      pr_cdempres in crapemp.cdempres%type,
                                      pr_cdhistor in craplcm.cdhistor%type,
                                      pr_vllanmto in crapacc.vllanmto%type,
                                      pr_qtlanmto IN NUMBER DEFAULT 1) is
      -- Índices utilizados na manipulação das tabelas
      vr_indice_val   varchar2(16);
    begin
      -- AGENCIA --
      vr_indice_val := fn_cria_registro(pr_cdagenci, 'A', 9999);
      vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + pr_qtlanmto;
      vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
      --
      vr_indice_val := fn_cria_registro(pr_cdagenci, 'A', pr_cdhistor);
      vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + pr_qtlanmto;
      vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
      -- EMPRESA --      
      vr_indice_val := fn_cria_registro(pr_cdempres, 'E', 9999);
      vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + pr_qtlanmto;
      vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
      --
      vr_indice_val := fn_cria_registro(pr_cdempres, 'E', pr_cdhistor);
      vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + pr_qtlanmto;
      vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
    end;
    --

  begin

    --- ################################ Programa Principal ################################# ----
    EXECUTE IMMEDIATE 'Alter session set session_cached_cursors=200';
    vr_cdprogra := 'CRPS133';

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS133'
                              ,pr_action => null);

    -- Na execução principal
    if nvl(pr_idparale,0) = 0 then
      -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      vr_idlog_ini_ger := null;
      pc_log_programa(pr_dstiplog   => 'I',
                      pr_cdprograma => vr_cdprogra,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);
    end if;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_cdcritic => vr_cdcritic);
    -- Se retornou algum erro
    if vr_cdcritic <> 0 then
      -- Buscar descrição do erro
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      raise vr_exc_saida;
    end if;

    -- Buscar a data do movimento
    open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat
     into rw_crapdat;
    if btch0001.cr_crapdat%notfound then
      close btch0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(1);
      raise vr_exc_saida;
    end if;
    close btch0001.cr_crapdat;

    -- Buscar os dados da cooperativa
    open cr_crapcop(pr_cdcooper);
      fetch cr_crapcop into rw_crapcop;
      if cr_crapcop%notfound then
        close cr_crapcop;
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(651);
        raise vr_exc_saida;
      end if;
    close cr_crapcop;

    /*  Carrega tabela de tipos de conta  */
    FOR rw_tipcta IN cr_tipcta LOOP
      vr_tab_tipcta(rw_tipcta.inpessoa)(rw_tipcta.cdtipcta).cdmodali := rw_tipcta.cdmodali;
    END LOOP; /*  Fim do LOOP -- Carga da tabela de tipos de conta  */
          
    -- Buscar o saldo médio
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'SDMEDCTPPR'
                                             ,pr_tpregist => 001);
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_vlsldmed := 0;
    ELSE
      vr_vlsldmed := gene0002.fn_char_para_number(vr_dstextab);
    END IF;

    -- Variáveis de controle de data
    vr_flgmensa := trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm');
    vr_flganual := (to_char(rw_crapdat.dtmvtolt, 'mm') = '12');

    -- Tratar informações armazenadas em estruturas semestrais
    if to_char(rw_crapdat.dtmvtolt, 'mm') > '06' then
      vr_insldmes := to_number(to_char(rw_crapdat.dtmvtolt, 'mm')) - 6;
    else
      vr_insldmes := to_number(to_char(rw_crapdat.dtmvtolt, 'mm'));
    end if;

    -- Processo mensal só é executado na Central
    if pr_cdcooper <> 3 AND NOT vr_flgmensa THEN
      -- gerando exceção de final de programa
      raise vr_exc_fimprg;
    end IF;

    -- Garante que não existe sujeira na PL/Table de valores
    vr_tab_val.delete;

    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> Código da coopertiva
                                                 ,vr_cdprogra --> Código do programa
                                                 );

    /* Paralelismo visando performance Rodar Somente no processo Noturno */
    if rw_crapdat.inproces > 2 and vr_qtdjobs > 0 and pr_cdagenci  = 0 then
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;

      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exceção
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
         RAISE vr_exc_saida;
      END IF;

      -- Verifica se algum job paralelo executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdprogra    => vr_cdprogra
                                                   ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                   ,pr_tpagrupador => 1
                                                   ,pr_nrexecucao  => 1);

      -- Retorna todas as agências da Cooperativa
      for rw_crapage in cr_crapage (pr_cdcooper
                                   ,vr_cdprogra
                                   ,vr_qterro
                                   ,rw_crapdat.dtmvtolt) loop

        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$';

        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;

        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13)
                   || '  wpr_stprogra NUMBER;' || chr(13)
                   || '  wpr_infimsol NUMBER;' || chr(13)
                   || '  wpr_cdcritic NUMBER;' || chr(13)
                   || '  wpr_dscritic VARCHAR2(1500);' || chr(13)
                   || 'BEGIN' || chr(13)
                   || '  PC_CRPS133('|| pr_cdcooper
                   || '            ,'|| rw_crapage.cdagenci
                   || '            ,'|| vr_idparale
                   || '            ,wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);'
                   || chr(13)
                   || 'END;'; --

         -- Faz a chamada ao programa paralelo atraves de JOB
         gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                               ,pr_cdprogra => vr_cdprogra  --> Código do programa
                               ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                               ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                               ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                               ,pr_jobname  => vr_jobname   --> Nome randomico criado
                               ,pr_des_erro => vr_dscritic);

         -- Testar saida com erro
         if vr_dscritic is not null then
           -- Levantar exceçao
           raise vr_exc_saida;
         end if;

         -- Chama rotina que irá pausar este processo controlador
         -- caso tenhamos excedido a quantidade de JOBS em execuçao
         gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                     ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                     ,pr_des_erro => vr_dscritic);

         -- Testar saida com erro
         if  vr_dscritic is not null then
           -- Levantar exceçao
           raise vr_exc_saida;
         end if;

      end loop;
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if  vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Verifica se algum job executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdprogra    => vr_cdprogra
                                                   ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                   ,pr_tpagrupador => 1
                                                   ,pr_nrexecucao  => 1);
      if vr_qterro > 0 then
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_saida;
      end if;
    else

      if pr_cdagenci <> 0 then
        vr_tpexecucao := 2;
      else
        vr_tpexecucao := 1;
      end if;

      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                      ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                      ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic);
      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I'
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par);


      ---------------- Inicia o processamento, gerando os registros na conta ----------------

      -- Carregar titulares
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper,pr_cdagenci) LOOP
        vr_tab_crapttl(lpad(rw_crapttl.nrdconta, 10, '0')).cdempres := rw_crapttl.cdempres;
      END LOOP;

      -- Carregar Pessoas Juridicas
      FOR rw_crapjur IN cr_crapjur(pr_cdcooper,pr_cdagenci) LOOP
        vr_tab_crapjur(lpad(rw_crapjur.nrdconta, 10, '0')).cdempres := rw_crapjur.cdempres;
      END LOOP;
      
      -- Carregar borderos de desconto de titulos
      FOR rw_crapcdb in cr_crapcdb(rw_crapdat.dtmvtolt,
                                   pr_cdcooper,
                                   pr_cdagenci) LOOP 
        -- Criar registro na pltable
        vr_tab_crapcdb(rw_crapcdb.nrdconta).qtdregis := rw_crapcdb.qtdregis;
        vr_tab_crapcdb(rw_crapcdb.nrdconta).vlliquid := rw_crapcdb.vlliquid;
      END LOOP;
      
      -- Carregar custodia de cheques
      FOR rw_crapcst in cr_crapcst(rw_crapdat.dtmvtolt,
                                   pr_cdcooper,
                                   pr_cdagenci) LOOP 
        -- Criar registro na pltable
        vr_tab_crapcst(rw_crapcst.nrdconta).qtdregis := rw_crapcst.qtdregis;
        vr_tab_crapcst(rw_crapcst.nrdconta).vlcheque := rw_crapcst.vlcheque;
      END LOOP;
      
      -- Carregar dados das Cotas
      FOR rw_crapcot in cr_crapcot(pr_cdcooper,
                                   pr_cdagenci,
                                   to_number(to_char(rw_crapdat.dtmvtolt, 'mm'))) LOOP 
        -- Criar registro na pltable
        vr_tab_crapcot(rw_crapcot.nrdconta).vlcotant := rw_crapcot.vlcotant;
        vr_tab_crapcot(rw_crapcot.nrdconta).vlcapmes := rw_crapcot.vlcapmes;
      END LOOP;
      
      -- Somente na mensal
      IF vr_flgmensa THEN
        FOR rw_crapsld IN cr_crapsld(pr_cdcooper,
                                     pr_cdagenci, 
                                     vr_insldmes) LOOP  
          -- Criar registro na pltable
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsmstre := rw_crapsld.vlsmstre;
        END LOOP;
      END IF;
      
      -- Carregar dados de plano de capital
      FOR rw_crappla IN cr_crappla (pr_cdcooper,
                                    pr_cdagenci) LOOP
        vr_tab_crappla(rw_crappla.nrdconta).vlprepla := rw_crappla.vlprepla;
      END LOOP;
      
      -- Carregar juros de desconto de cheques
      for rw_gera_registro_conta in cr_crapljd (rw_crapdat.dtmvtolt,
                                                pr_cdcooper,
                                                pr_cdagenci) loop
        -- Se conta ainda não foi enviada ao vetor
        IF NOT vr_tab_ljdass.exists(rw_gera_registro_conta.nrdconta) THEN
          -- Reiniciar contador
          vr_id_interno := 1;
        ELSE
          -- Usar o count
          vr_id_interno := vr_tab_ljdass(rw_gera_registro_conta.nrdconta).vr_tab_crapljd.count()+1;
        END IF;
        
        -- Criar o registro dentro da pltable
        vr_tab_ljdass(rw_gera_registro_conta.nrdconta).vr_tab_crapljd(vr_id_interno).cdhistor := rw_gera_registro_conta.cdhistor;
        vr_tab_ljdass(rw_gera_registro_conta.nrdconta).vr_tab_crapljd(vr_id_interno).vlrestit := rw_gera_registro_conta.vlrestit;        
        
      end loop;
      
      -- Carregar contratos de empréstimo
      for rw_gera_registro_conta in cr_crapepr (pr_cdcooper,
                                                pr_cdagenci) loop
        -- Se conta ainda não foi enviada ao vetor
        IF NOT vr_tab_eprass.exists(rw_gera_registro_conta.nrdconta) THEN
          -- Reiniciar contador
          vr_id_interno := 1;
        ELSE
          -- Usar o count
          vr_id_interno := vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr.count()+1;
        END IF;
        -- Criar o registro dentro da pltable
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).dtmvtolt := rw_gera_registro_conta.dtmvtolt;
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst := rw_gera_registro_conta.vlemprst;  
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).inprejuz := rw_gera_registro_conta.inprejuz;        
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).dtprejuz := rw_gera_registro_conta.dtprejuz;        
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).vljurmes := rw_gera_registro_conta.vljurmes;        
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved := rw_gera_registro_conta.vlsdeved;        
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp := rw_gera_registro_conta.cdlcremp;        
        vr_tab_eprass(rw_gera_registro_conta.nrdconta).vr_tab_crapepr(vr_id_interno).cdfinemp := rw_gera_registro_conta.cdfinemp;          
      end loop;      
      
      -- Efetuar a busca diretamente da tabela de associados
      OPEN cr_crapass(pr_cdcooper,pr_cdagenci);
      LOOP
        FETCH cr_crapass BULK COLLECT INTO rw_crapass LIMIT 500;
        EXIT WHEN rw_crapass.COUNT = 0;            
        FOR idx IN rw_crapass.first..rw_crapass.last LOOP

          -- Limpar valor da variável
          vr_cdempres := 0;

          -- Identifica se é pessoa jurídica ou física
          IF rw_crapass(idx).inpessoa = 1 THEN
            -- Verifica se registro de pessoa física existe
            IF vr_tab_crapttl.exists(lpad(rw_crapass(idx).nrdconta, 10, '0')) THEN
              vr_cdempres := vr_tab_crapttl(lpad(rw_crapass(idx).nrdconta, 10, '0')).cdempres;
            END IF;
          ELSE
            -- Verifica se registro de pessoa jurídica existe
            IF vr_tab_crapjur.exists(lpad(rw_crapass(idx).nrdconta, 10, '0')) THEN
              vr_cdempres := vr_tab_crapjur(lpad(rw_crapass(idx).nrdconta, 10, '0')).cdempres;
            END IF;
          END IF;

          -- PAC
          vr_indice_pac := 'A'||lpad(rw_crapass(idx).cdagenci, 10, '0');
          if not vr_tab_pac.exists(vr_indice_pac) then
            vr_tab_pac(vr_indice_pac).vr_codigo := rw_crapass(idx).cdagenci;
            vr_tab_pac(vr_indice_pac).vr_tipo := 'A';
            vr_tab_pac(vr_indice_pac).vr_qtassoci := 0;
            vr_tab_pac(vr_indice_pac).vr_qtctacor := 0;
            vr_tab_pac(vr_indice_pac).vr_qtplanos := 0;
            vr_tab_pac(vr_indice_pac).vr_qtassepr := 0;
            vr_tab_pac(vr_indice_pac).vr_vlsmpmes := 0;
            vr_tab_pac(vr_indice_pac).vr_vlcaptal := 0;
            vr_tab_pac(vr_indice_pac).vr_vlplanos := 0;
          end if;
          -- Empresa
          vr_indice_emp := 'E'||lpad(vr_cdempres, 10, '0');
          if not vr_tab_emp.exists(vr_indice_emp) then
            vr_tab_emp(vr_indice_emp).vr_codigo := vr_cdempres;
            vr_tab_emp(vr_indice_emp).vr_tipo := 'E';
            vr_tab_emp(vr_indice_emp).vr_qtassoci := 0;
            vr_tab_emp(vr_indice_emp).vr_qtctacor := 0;
            vr_tab_emp(vr_indice_emp).vr_qtplanos := 0;
            vr_tab_emp(vr_indice_emp).vr_qtassepr := 0;
            vr_tab_emp(vr_indice_emp).vr_vlsmpmes := 0;
            vr_tab_emp(vr_indice_emp).vr_vlcaptal := 0;
            vr_tab_emp(vr_indice_emp).vr_vlplanos := 0;
          end if;

          -- Lançamentos em depósitos a vista
          for rw_gera_registro_conta in cr_craplcm (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Lançamentos em empréstimos
          for rw_gera_registro_conta in cr_craplem (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Lançamentos em cotas / capital
          for rw_gera_registro_conta in cr_craplct (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Lançamentos de aplicações RDCA
          for rw_gera_registro_conta in cr_craplap (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Lançamentos de aplicações de captação
          for rw_gera_registro_conta IN cr_craplac (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) LOOP
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          END LOOP;

          -- Lançamentos automáticos
          for rw_gera_registro_conta in cr_craplau (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanaut);
          end loop;

          -- Lançamentos de cobrança
          for rw_gera_registro_conta in cr_craplcb (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Lançamentos da conta de investimento
          for rw_gera_registro_conta in cr_craplci (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Lançamentos de aplicações de poupança
          for rw_gera_registro_conta in cr_craplpp (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          -- Transações nos caixas e auto-atendimento
          for rw_gera_registro_conta in cr_crapltr (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    rw_gera_registro_conta.cdhistor,
                                    rw_gera_registro_conta.vllanmto);
          end loop;

          --------- Processa as tabelas sem campo cdhistor. O campo cdhistor está fixo no cursor -------------

          -- Custódia de cheques
          IF vr_tab_crapcst.exists(rw_crapass(idx).nrdconta) THEN
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    997,
                                    vr_tab_crapcst(rw_crapass(idx).nrdconta).vlcheque,
                                    vr_tab_crapcst(rw_crapass(idx).nrdconta).qtdregis);
          END IF;

          -- Borderô de desconto de cheques
          IF vr_tab_crapcdb.exists(rw_crapass(idx).nrdconta) THEN
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    93,
                                    vr_tab_crapcdb(rw_crapass(idx).nrdconta).vlliquid,
                                    vr_tab_crapcdb(rw_crapass(idx).nrdconta).qtdregis);
          end IF;
          
          -- Cotas
          

          -- Bordero de desconto de títulos
          for rw_gera_registro_conta in cr_crapbdt (rw_crapdat.dtmvtolt,
                                                    pr_cdcooper,
                                                    rw_crapass(idx).nrdconta) loop
            -- Descto de titulos
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    992,
                                    rw_gera_registro_conta.vlliquid);
            -- Juros de descto
            pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                    vr_cdempres,
                                    993,
                                    rw_gera_registro_conta.vlliquid);
          end loop;

          -- Juros de descontos de cheques
          IF vr_tab_ljdass.exists(rw_crapass(idx).nrdconta) THEN
            IF vr_tab_ljdass(rw_crapass(idx).nrdconta).vr_tab_crapljd.count() > 0 THEN
              -- Iterar sob pltable interna
              FOR vr_id_interno IN 1..vr_tab_ljdass(rw_crapass(idx).nrdconta).vr_tab_crapljd.count() LOOP
                pc_gera_registro_conta (rw_crapass(idx).cdagenci,
                                        vr_cdempres,
                                        vr_tab_ljdass(rw_crapass(idx).nrdconta).vr_tab_crapljd(vr_id_interno).cdhistor,
                                        vr_tab_ljdass(rw_crapass(idx).nrdconta).vr_tab_crapljd(vr_id_interno).vlrestit);
              END LOOP;
            END IF;
          END IF;

          ----------------------- Mensal --------------------------------
          if vr_flgmensa then
            -- Verifica se possui informação do saldo médio mensal
            IF NOT vr_tab_crapsld.exists(rw_crapass(idx).nrdconta) THEN
              vr_cdcritic := 10;
              vr_dscritic := gene0001.fn_busca_critica(10)||' - Conta: '||rw_crapass(idx).nrdconta;
              -- tratando a exceção
              raise vr_exc_saida;
            end IF;
            -- Acumula os valores nas tabelas de PAC e empresa
            vr_tab_pac(vr_indice_pac).vr_vlsmpmes := vr_tab_pac(vr_indice_pac).vr_vlsmpmes + vr_tab_crapsld(rw_crapass(idx).nrdconta).vlsmstre;
            vr_tab_emp(vr_indice_emp).vr_vlsmpmes := vr_tab_emp(vr_indice_emp).vr_vlsmpmes + vr_tab_crapsld(rw_crapass(idx).nrdconta).vlsmstre;
            --
            if rw_crapass(idx).dtdemiss is null then
              if rw_crapass(idx).inmatric = 1 then
                vr_tab_pac(vr_indice_pac).vr_qtassoci := vr_tab_pac(vr_indice_pac).vr_qtassoci + 1;
                vr_tab_emp(vr_indice_emp).vr_qtassoci := vr_tab_emp(vr_indice_emp).vr_qtassoci + 1;
              end if;
              if vr_tab_tipcta(rw_crapass(idx).inpessoa)(rw_crapass(idx).cdtipcta).cdmodali not in (2, 3) then
                if rw_crapass(idx).cdsitdct = 6 then
                  if vr_tab_crapsld(rw_crapass(idx).nrdconta).vlsmstre >= vr_vlsldmed then
                    vr_tab_pac(vr_indice_pac).vr_qtctacor := vr_tab_pac(vr_indice_pac).vr_qtctacor + 1;
                    vr_tab_emp(vr_indice_emp).vr_qtctacor := vr_tab_emp(vr_indice_emp).vr_qtctacor + 1;
                  end if;
                else
                  vr_tab_pac(vr_indice_pac).vr_qtctacor := vr_tab_pac(vr_indice_pac).vr_qtctacor + 1;
                  vr_tab_emp(vr_indice_emp).vr_qtctacor := vr_tab_emp(vr_indice_emp).vr_qtctacor + 1;
                end if;
              end if;
            end if;
            
            -- Verifica se possui informações de cotas e recursos
            IF NOT vr_tab_crapcot.exists(rw_crapass(idx).nrdconta) THEN 
              vr_cdcritic := 169;
              vr_dscritic := gene0001.fn_busca_critica(169)||' - Conta: '||rw_crapass(idx).nrdconta;
              -- tratando a exceção
              raise vr_exc_saida;
            END IF;
            
            -- Acumula os valores de cotas e recursos gravados na coluna de valores do ano anterior
            if vr_flganual then
              vr_tab_pac(vr_indice_pac).vr_vlcaptal := vr_tab_pac(vr_indice_pac).vr_vlcaptal + vr_tab_crapcot(rw_crapass(idx).nrdconta).vlcotant;
              vr_tab_emp(vr_indice_emp).vr_vlcaptal := vr_tab_emp(vr_indice_emp).vr_vlcaptal + vr_tab_crapcot(rw_crapass(idx).nrdconta).vlcotant;
            else
              vr_tab_pac(vr_indice_pac).vr_vlcaptal := vr_tab_pac(vr_indice_pac).vr_vlcaptal + vr_tab_crapcot(rw_crapass(idx).nrdconta).vlcapmes;
              vr_tab_emp(vr_indice_emp).vr_vlcaptal := vr_tab_emp(vr_indice_emp).vr_vlcaptal + vr_tab_crapcot(rw_crapass(idx).nrdconta).vlcapmes;
            end if;
            
            -- Acumula o valor da prestação do plano de capitalização
            IF vr_tab_crappla.exists(rw_crapass(idx).nrdconta) THEN
              vr_tab_pac(vr_indice_pac).vr_qtplanos := vr_tab_pac(vr_indice_pac).vr_qtplanos + 1;
              vr_tab_emp(vr_indice_emp).vr_qtplanos := vr_tab_emp(vr_indice_emp).vr_qtplanos + 1;
              vr_tab_pac(vr_indice_pac).vr_vlplanos := vr_tab_pac(vr_indice_pac).vr_vlplanos + vr_tab_crappla(rw_crapass(idx).nrdconta).vlprepla;
              vr_tab_emp(vr_indice_emp).vr_vlplanos := vr_tab_emp(vr_indice_emp).vr_vlplanos + vr_tab_crappla(rw_crapass(idx).nrdconta).vlprepla;
            END IF;
            
            -- Loop para acumular valores de empréstimos
            vr_flghaepr := false;
            IF vr_tab_eprass.exists(rw_crapass(idx).nrdconta) THEN
              IF vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr.count() > 0 THEN
                -- Iterar sob pltable interna
                FOR vr_id_interno IN 1..vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr.count() LOOP
                  if to_char(vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).dtmvtolt, 'mmyyyy') = to_char(rw_crapdat.dtmvtolt, 'mmyyyy') and
                     vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).inprejuz = 0 then
                    --
                    vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', 9999);
                    vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
                    vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
                    vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    --
                    vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', 9999);
                    vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
                    vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
                    vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    --
                    vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp);
                    vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
                    vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    --
                    vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp);
                    vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
                    vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    --
                    vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdfinemp);
                    vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
                    vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                    --
                    vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdfinemp);
                    vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
                    vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlemprst;
                  end if;
                  --
                  if vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).inprejuz > 0 and
                     vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).dtprejuz < trunc(rw_crapdat.dtmvtolt, 'mm') then
                    continue;
                  end if;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', 9999);
                  vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vljurmes;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', 9999);
                  vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vljurmes;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp);
                  vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vljurmes;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp);
                  vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vljurmes;
                  --
                  if vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved = 0 then
                    continue;
                  end if;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', 9999);
                  vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', 9999);
                  vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp);
                  vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdlcremp);
                  vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdfinemp);
                  vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  --
                  vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).cdfinemp);
                  vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
                  vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + vr_tab_eprass(rw_crapass(idx).nrdconta).vr_tab_crapepr(vr_id_interno).vlsdeved;
                  --
                  vr_flghaepr := true;
                end loop; -- Fim do loop para acumular valores de empréstimos
              END IF;
            END IF;
            -- Se tinha algum empréstimo, acumula quantidade de associados para PAC e empresa.
            if vr_flghaepr then
              vr_tab_pac(vr_indice_pac).vr_qtassepr := vr_tab_pac(vr_indice_pac).vr_qtassepr + 1;
              vr_tab_emp(vr_indice_emp).vr_qtassepr := vr_tab_emp(vr_indice_emp).vr_qtassepr + 1;
            end if;

          end if;  -- aux_flgmensa

        END LOOP; -- Loop rw_crapass
      end loop;  -- Fim crapass
      CLOSE cr_crapass;
      rw_crapass.delete;
      

      -- Autenticações
      for rw_gera_registro_pac in cr_crapaut (rw_crapdat.dtmvtolt,
                                              pr_cdcooper,
                                              pr_cdagenci) loop
        pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                              rw_gera_registro_pac.cdhistor,
                              rw_gera_registro_pac.vldocmto);
      end loop;

      -- Lançamentos extra-sistema (boletim de caixa)
      for rw_gera_registro_pac in cr_craplcx (rw_crapdat.dtmvtolt,
                                              pr_cdcooper,
                                              pr_cdagenci) loop
        pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                              rw_gera_registro_pac.cdhistor,
                              rw_gera_registro_pac.vldocmto);
      end loop;

      -- Lançamentos de faturas
      for rw_gera_registro_pac in cr_craplft (rw_crapdat.dtmvtolt,
                                              pr_cdcooper,
                                              pr_cdagenci) loop
        pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                              rw_gera_registro_pac.cdhistor,
                              rw_gera_registro_pac.vllanmto);
      end loop;

      -- Títulos acolhidos
      for rw_gera_registro_pac in cr_craptit (rw_crapdat.dtmvtolt,
                                              pr_cdcooper,
                                              pr_cdagenci) loop
        pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                              rw_gera_registro_pac.cdhistor,
                              rw_gera_registro_pac.vldpagto);
      end loop;

      -- Movimento Correspondente Bancário - Banco do Brasil
      for rw_gera_registro_pac in cr_crapcbb (rw_crapdat.dtmvtolt,
                                              pr_cdcooper,
                                              pr_cdagenci) loop
        pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                              rw_gera_registro_pac.cdhistor,
                              rw_gera_registro_pac.valorpag);
      end loop;

      -- Ao final, devemos converter as informações das pltables de memória para tabela,
      -- pois os jobs paralelos irão inserir nas mesmas dentro de cada execução única
      -- Criacao dos registros crapacc por PAC
      vr_indice_pac := vr_tab_pac.first;
      while vr_indice_pac is not null loop
        IF vr_tab_pac(vr_indice_pac).vr_tipo = 'A' AND vr_tab_pac(vr_indice_pac).vr_codigo > 0 then
          for vr_contador in 1..9999 loop
            if vr_contador = 9999 then
              vr_cdlanmto := 0;
            else
              vr_cdlanmto := vr_contador;
            end if;
            -- Monta o índice da tabela por PAC e verifica se existe informação
            vr_indice_val := 'A'||lpad(vr_tab_pac(vr_indice_pac).vr_codigo, 10, '0')||lpad(vr_contador, 5, '0');
            if not vr_tab_val.exists(vr_indice_val) then
              continue;
            end if;

            -- Efetuar laço de 1 a 6 para gravar todas as opções de valor preenchido X tipo de registro
            for vr_tplancto in 1..6 loop
              -- Montar tipo, quantidade e valor conforme campo gravado
              if vr_tplancto = 1 and vr_tab_val(vr_indice_val).vr_qtlanmto > 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtlanmto;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vllanmto;
              elsif vr_tplancto = 2 and vr_tab_val(vr_indice_val).vr_qteprlcr > 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qteprlcr;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vleprlcr;
              elsif vr_tplancto = 4 and vr_tab_val(vr_indice_val).vr_qteprfin <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qteprfin;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vleprfin;
              elsif vr_tplancto = 3 and vr_tab_val(vr_indice_val).vr_qtsdvlcr <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtsdvlcr;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vlsdvlcr;
              elsif vr_tplancto = 5 and vr_tab_val(vr_indice_val).vr_qtsdvfin <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtsdvfin;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vlsdvfin;
              elsif vr_tplancto = 6 and vr_tab_val(vr_indice_val).vr_qtjurlcr <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtjurlcr;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vljurlcr;
              else
                continue;
              end if;
              -- Inserir
              begin
                insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci  -- Gravaremos PA
                         ,nrdconta  -- Gravaremos Empresa
                         ,dschave   -- Gravaremos histórico
                         ,tpparcel  -- Tipo Registro
                         ,nrdocmto  -- Quantidade Lançamento
                         ,vlacumul) -- Valor Lançamento
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'CRAPACC_PAC'
                         ,rw_crapdat.dtmvtolt
                         ,vr_tab_pac(vr_indice_pac).vr_codigo                       -- Gravaremos PA
                         ,0                                                         -- Gravaremos Empresa
                         ,vr_cdlanmto                                               -- Gravaremos histórico
                         ,vr_tplancto                                               -- Tipo Registro
                         ,vr_qtlancto                                               -- Quantidade Lançamento
                         ,vr_vllancto);                                             -- Valor Lançamento
              exception
                when others then
                  vr_dscritic := 'Erro ao gerar tbgen_batch_relatorio_wrk --> '||SQLERRM;
                  raise vr_exc_saida;
              end;
            end loop;
          end loop;
          -- Se processo mensal
          if vr_flgmensa then
            -- Montar informações gerenciais no dscritic
            vr_dscritic := to_char(nvl(vr_tab_pac(vr_indice_pac).vr_qtassoci, 0),'fm999g999g999g990')||';'||
                           to_char(nvl(vr_tab_pac(vr_indice_pac).vr_qtctacor, 0),'fm999g999g999g990')||';'||
                           to_char(nvl(vr_tab_pac(vr_indice_pac).vr_qtplanos, 0),'fm999g999g999g990')||';'||
                           to_char(nvl(vr_tab_pac(vr_indice_pac).vr_vlcaptal, 0),'fm999g999g999g999g990d00')||';'||
                           to_char(nvl(vr_tab_pac(vr_indice_pac).vr_vlplanos, 0),'fm999g999g999g999g990d00')||';'||
                           to_char(nvl(vr_tab_pac(vr_indice_pac).vr_vlsmpmes, 0),'fm999g999g999g999g990d00')||';'||
                           to_char(nvl(vr_tab_pac(vr_indice_pac).vr_qtassepr, 0),'fm999g999g999g990')||';';
            -- Gerar registro na tabela
            begin
              insert into tbgen_batch_relatorio_wrk
                       (cdcooper
                       ,cdprograma
                       ,dsrelatorio
                       ,dtmvtolt
                       ,cdagenci  -- Gravaremos PA da execução
                       ,nrdconta  -- Gravaremos Empresa
                       ,dschave   -- Gravaremos histórico
                       ,tpparcel  -- Tipo Registro
                       ,nrdocmto  -- Quantidade Lançamento
                       ,vltitulo  -- Valor Lançamento
                       ,dscritic)
                 values(pr_cdcooper
                       ,vr_cdprogra
                       ,'CRAPGER_PAC'
                       ,rw_crapdat.dtmvtolt
                       ,vr_tab_pac(vr_indice_pac).vr_codigo -- Gravaremos PA
                       ,0                                   -- Gravaremos Empresa
                       ,0                                   -- Gravaremos histórico
                       ,0                                   -- Tipo Registro
                       ,0                                   -- Quantidade Lançamento
                       ,0                                   -- Valor Lançamento
                       ,vr_dscritic);
            exception
              when others then
                vr_dscritic := 'Erro ao gerar tbgen_batch_relatorio_wrk --> '||SQLERRM;
                raise vr_exc_saida;
            end;
          end if;
        end if;
        vr_indice_pac := vr_tab_pac.next(vr_indice_pac);
      end loop;

      vr_indice_emp := vr_tab_emp.first;
      while vr_indice_emp is not null loop
        IF vr_tab_emp(vr_indice_emp).vr_tipo = 'E' AND vr_tab_emp(vr_indice_emp).vr_codigo > 0 then
          for vr_contador in 1..9999 loop
            if vr_contador = 9999 then
              vr_cdlanmto := 0;
            else
              vr_cdlanmto := vr_contador;
            end if;
            -- Monta o índice para tabela por empresa e verifica se existe informação
            vr_indice_val := 'E'||lpad(vr_tab_emp(vr_indice_emp).vr_codigo, 10, '0')||lpad(vr_contador, 5, '0');
            if not vr_tab_val.exists(vr_indice_val) then
              continue;
            end if;

            -- Efetuar laço de 1 a 6 para gravar todas as opções de valor preenchido X tipo de registro
            for vr_tplancto in 1..6 loop
              -- Montar tipo, quantidade e valor conforme campo gravado
              if vr_tplancto = 1 and vr_tab_val(vr_indice_val).vr_qtlanmto > 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtlanmto;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vllanmto;
              elsif vr_tplancto = 2 and vr_tab_val(vr_indice_val).vr_qteprlcr > 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qteprlcr;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vleprlcr;
              elsif vr_tplancto = 4 and vr_tab_val(vr_indice_val).vr_qteprfin <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qteprfin;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vleprfin;
              elsif vr_tplancto = 3 and vr_tab_val(vr_indice_val).vr_qtsdvlcr <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtsdvlcr;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vlsdvlcr;
              elsif vr_tplancto = 5 and vr_tab_val(vr_indice_val).vr_qtsdvfin <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtsdvfin;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vlsdvfin;
              elsif vr_tplancto = 6 and vr_tab_val(vr_indice_val).vr_qtjurlcr <> 0 then
                vr_qtlancto := vr_tab_val(vr_indice_val).vr_qtjurlcr;
                vr_vllancto := vr_tab_val(vr_indice_val).vr_vljurlcr;
              else
                continue;
              end if;
              -- Inserir
              begin
                insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci  -- Gravaremos PA da execução
                         ,nrdconta  -- Gravaremos Empresa
                         ,dschave   -- Gravaremos histórico
                         ,tpparcel  -- Tipo Registro
                         ,nrdocmto  -- Quantidade Lançamento
                         ,vlacumul)  -- Valor Lançamento
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'CRAPACC_EMP'
                         ,rw_crapdat.dtmvtolt
                         ,pr_cdagenci -- Gravaremos PA
                         ,vr_tab_emp(vr_indice_emp).vr_codigo -- Gravaremos Empresa
                         ,vr_cdlanmto                         -- Gravaremos histórico
                         ,vr_tplancto                         -- Tipo Registro
                         ,vr_qtlancto                         -- Quantidade Lançamento
                         ,vr_vllancto);                       -- Valor Lançamento  
              exception
                when others then
                  vr_dscritic := 'Erro ao gerar tbgen_batch_relatorio_wrk --> '||SQLERRM;
                  raise vr_exc_saida;
              end;
            end loop;
          end loop;
          -- Se processo mensal
          if vr_flgmensa then
            -- Montar informações gerenciais no dscritic
            vr_dscritic := to_char(nvl(vr_tab_emp(vr_indice_emp).vr_qtassoci, 0),'fm999g999g999g990')||';'||
                           to_char(nvl(vr_tab_emp(vr_indice_emp).vr_qtctacor, 0),'fm999g999g999g990')||';'||
                           to_char(nvl(vr_tab_emp(vr_indice_emp).vr_qtplanos, 0),'fm999g999g999g990')||';'||
                           to_char(nvl(vr_tab_emp(vr_indice_emp).vr_vlcaptal, 0),'fm999g999g999g999g990d00')||';'||
                           to_char(nvl(vr_tab_emp(vr_indice_emp).vr_vlplanos, 0),'fm999g999g999g999g990d00')||';'||
                           to_char(nvl(vr_tab_emp(vr_indice_emp).vr_vlsmpmes, 0),'fm999g999g999g999g990d00')||';'||
                           to_char(nvl(vr_tab_emp(vr_indice_emp).vr_qtassepr, 0),'fm999g999g999g990')||';';
            -- Gerar registro na tabela
            begin
              insert into tbgen_batch_relatorio_wrk
                       (cdcooper
                       ,cdprograma
                       ,dsrelatorio
                       ,dtmvtolt
                       ,cdagenci  -- Gravaremos PA da execução
                       ,nrdconta  -- Gravaremos Empresa
                       ,dschave   -- Gravaremos histórico
                       ,tpparcel  -- Tipo Registro
                       ,nrdocmto  -- Quantidade Lançamento
                       ,vltitulo  -- Valor Lançamento
                       ,dscritic)
                 values(pr_cdcooper
                       ,vr_cdprogra
                       ,'CRAPGER_EMP'
                       ,rw_crapdat.dtmvtolt
                       ,pr_cdagenci -- Gravaremos PA
                       ,vr_tab_emp(vr_indice_emp).vr_codigo -- Gravaremos Empresa
                       ,0                                   -- Gravaremos histórico
                       ,0                                   -- Tipo Registro
                       ,0                                   -- Quantidade Lançamento
                       ,0                                   -- Valor Lançamento
                       ,vr_dscritic);
            exception
              when others then
                vr_dscritic := 'Erro ao gerar tbgen_batch_relatorio_wrk --> '||SQLERRM;
                raise vr_exc_saida;
            end;
          end if;
        end if;
        vr_indice_emp := vr_tab_emp.next(vr_indice_emp);
      end loop;

      -- Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F'
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par
                     ,pr_flgsucesso => 1);

    end if;

    -- Se for o programa principal ou sem paralelismo
    if nvl(pr_idparale,0) = 0 then

      -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
      pc_log_programa(pr_dstiplog     => 'O'
                     ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper     => pr_cdcooper
                     ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia => 4
                     ,pr_dsmensagem   => 'Inicio - Alimentação das tabelas.'
                     ,pr_idprglog     => vr_idlog_ini_ger);

      -- Criacao dos registros crapacc por PAC
      for rw_wkpac in cr_relwork_pac(pr_cdcooper    => pr_cdcooper
                                    ,pr_cdprograma  => vr_cdprogra
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) loop
        -- Atualiza usando o código da agência
        begin
          update crapacc
             set crapacc.qtlanmto = crapacc.qtlanmto + rw_wkpac.qtlancto,
                 crapacc.vllanmto = crapacc.vllanmto + rw_wkpac.vllancto
           where crapacc.dtrefere = rw_crapdat.dtultdia
             and crapacc.cdagenci = rw_wkpac.cdagenci
             and crapacc.cdempres = 0
             and crapacc.tpregist = rw_wkpac.tplancto
             and crapacc.cdlanmto = rw_wkpac.cdlanmto
             and crapacc.cdcooper = pr_cdcooper;
          if sql%rowcount = 0 then
            begin
              insert into crapacc (dtrefere,
                                   cdagenci,
                                   cdempres,
                                   tpregist,
                                   cdlanmto,
                                   cdcooper,
                                   qtlanmto,
                                   vllanmto)
              values (rw_crapdat.dtultdia,
                      rw_wkpac.cdagenci,
                      0,
                      rw_wkpac.tplancto,
                      rw_wkpac.cdlanmto,
                      pr_cdcooper,
                      rw_wkpac.qtlancto,
                      rw_wkpac.vllancto);
            exception
              when others then
                vr_dscritic := 'Erro ao inserir vr_vllanmto para agência '||rw_wkpac.cdagenci||': '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
          when vr_exc_saida then
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao alterar vr_vllanmto para agência '||rw_wkpac.cdagenci||': '||sqlerrm;
            raise vr_exc_saida;
        end;
        
        -- Atualiza no registro centralizador
        begin
          update crapacc
             set crapacc.qtlanmto = crapacc.qtlanmto + rw_wkpac.qtlancto,
                 crapacc.vllanmto = crapacc.vllanmto + rw_wkpac.vllancto
           where crapacc.dtrefere = rw_crapdat.dtultdia
             and crapacc.cdagenci = 0
             and crapacc.cdempres = 0
             and crapacc.tpregist = rw_wkpac.tplancto
             and crapacc.cdlanmto = rw_wkpac.cdlanmto
             and crapacc.cdcooper = pr_cdcooper;
          if sql%rowcount = 0 then
            begin
              insert into crapacc (dtrefere,
                                   cdagenci,
                                   cdempres,
                                   tpregist,
                                   cdlanmto,
                                   cdcooper,
                                   qtlanmto,
                                   vllanmto)
              values (rw_crapdat.dtultdia,
                      0,
                      0,
                      rw_wkpac.tplancto,
                      rw_wkpac.cdlanmto,
                      pr_cdcooper,
                      rw_wkpac.qtlancto,
                      rw_wkpac.vllancto);
            exception
              when others then
                vr_dscritic := 'Erro ao inserir vr_vllanmto por agência (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
                when vr_exc_saida then
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao alterar vr_vllanmto por agência (acumulado): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end loop;

      -- Geração das informações gerenciais
      for rw_wkpac in cr_relwork_pacger(pr_cdcooper    => pr_cdcooper
                                       ,pr_cdprograma  => vr_cdprogra
                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) loop
        -- Atualiza informações gerenciais
        begin
          update crapger
             set crapger.qtassoci = rw_wkpac.qtassoci,
                 crapger.qtautent = 0,
                 crapger.qtctacor = rw_wkpac.qtctacor,
                 crapger.qtplanos = rw_wkpac.qtplanos,
                 crapger.vlcaptal = rw_wkpac.vlcaptal,
                 crapger.vlplanos = rw_wkpac.vlplanos,
                 crapger.vlsmpmes = rw_wkpac.vlsmpmes,
                 crapger.qtassepr = rw_wkpac.qtassepr
           where crapger.dtrefere = rw_crapdat.dtultdia
             and crapger.cdagenci = rw_wkpac.cdagenci
             and crapger.cdempres = 0
             and crapger.cdcooper = pr_cdcooper;
          if sql%rowcount = 0 then
            begin
              insert into crapger (dtrefere,
                                   cdagenci,
                                   cdempres,
                                   cdcooper,
                                   qtassoci,
                                   qtautent,
                                   qtctacor,
                                   qtplanos,
                                   vlcaptal,
                                   vlplanos,
                                   vlsmpmes,
                                   qtassepr,
                                   qtaplrdc,
                                   vlaplrdc,
                                   qtaplrda,
                                   vlaplrda,
                                   qtaplrpp,
                                   vlaplrpp,
                                   qtctrrpp,
                                   vlctrrpp,
                                   qtassapl,
                                   qtrettal,
                                   qtsoltal,
                                   qtrttlct,
                                   qtrttlbc,
                                   qtsltlct,
                                   qtsltlbc)
              values (rw_crapdat.dtultdia,
                      rw_wkpac.cdagenci,
                      0,
                      pr_cdcooper,
                      rw_wkpac.qtassoci,
                      0,
                      rw_wkpac.qtctacor,
                      rw_wkpac.qtplanos,
                      rw_wkpac.vlcaptal,
                      rw_wkpac.vlplanos,
                      rw_wkpac.vlsmpmes,
                      rw_wkpac.qtassepr,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0);
            exception
              when others then
                vr_dscritic := 'Erro ao inserir informações gerenciais (crapger): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
            when vr_exc_saida then
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao alterar informações gerenciais (crapger): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end loop;

      -- Criacao dos registros crapacc por EMPRESA
      for rw_wkemp in cr_relwork_emp(pr_cdcooper    => pr_cdcooper
                                    ,pr_cdprograma  => vr_cdprogra
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) loop

        -- Atualiza usando o código da empresa
        begin
          update crapacc
             set crapacc.qtlanmto = crapacc.qtlanmto + rw_wkemp.qtlancto,
                 crapacc.vllanmto = crapacc.vllanmto + rw_wkemp.vllancto
           where crapacc.dtrefere = rw_crapdat.dtultdia
             and crapacc.cdagenci = 0
             and crapacc.cdempres = rw_wkemp.cdempres
             and crapacc.tpregist = rw_wkemp.tplancto
             and crapacc.cdlanmto = rw_wkemp.cdlanmto
             and crapacc.cdcooper = pr_cdcooper;
          if sql%rowcount = 0 then
            begin
              insert into crapacc (dtrefere,
                                   cdagenci,
                                   cdempres,
                                   tpregist,
                                   cdlanmto,
                                   cdcooper,
                                   qtlanmto,
                                   vllanmto)
              values (rw_crapdat.dtultdia,
                      0,
                      rw_wkemp.cdempres,
                      rw_wkemp.tplancto,
                      rw_wkemp.cdlanmto,
                      pr_cdcooper,
                      rw_wkemp.qtlancto,
                      rw_wkemp.vllancto);
            exception
              when others then
                vr_dscritic := 'Erro ao inserir vr_vllanmto para empresa '||rw_wkemp.cdempres||': '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
            when vr_exc_saida then
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao alterar vr_vllanmto para empresa '||rw_wkemp.cdempres||': '||sqlerrm;
            raise vr_exc_saida;
        end;

        -- Atualiza no registro centralizador
        begin
          update crapacc
             set crapacc.qtlanmto = crapacc.qtlanmto + rw_wkemp.qtlancto,
                 crapacc.vllanmto = crapacc.vllanmto + rw_wkemp.vllancto
           where crapacc.dtrefere = rw_crapdat.dtultdia
             and crapacc.cdagenci = 0
             and crapacc.cdempres = 9999
             and crapacc.tpregist = rw_wkemp.tplancto
             and crapacc.cdlanmto = rw_wkemp.cdlanmto
             and crapacc.cdcooper = pr_cdcooper;
          if sql%rowcount = 0 then
            begin
              insert into crapacc (dtrefere,
                                   cdagenci,
                                   cdempres,
                                   tpregist,
                                   cdlanmto,
                                   cdcooper,
                                   qtlanmto,
                                   vllanmto)
              values (rw_crapdat.dtultdia,
                      0,
                      9999,
                      rw_wkemp.tplancto,
                      rw_wkemp.cdlanmto,
                      pr_cdcooper,
                      rw_wkemp.qtlancto,
                      rw_wkemp.vllancto);
            exception
              when others then
                vr_dscritic := 'Erro ao inserir vr_vllanmto por empresa (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
            when vr_exc_saida then
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao alterar vr_vllanmto por empresa (acumulado): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end loop;

      -- Geração das informações gerenciais
      for rw_wkemp in cr_relwork_empger(pr_cdcooper    => pr_cdcooper
                                       ,pr_cdprograma  => vr_cdprogra
                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) loop
        -- Atualiza informações gerenciais
        begin
          update crapger
             set crapger.qtassoci = rw_wkemp.qtassoci,
                 crapger.qtautent = 0,
                 qtctacor = rw_wkemp.qtctacor,
                 qtplanos = rw_wkemp.qtplanos,
                 vlcaptal = rw_wkemp.vlcaptal,
                 vlplanos = rw_wkemp.vlplanos,
                 vlsmpmes = rw_wkemp.vlsmpmes,
                 qtassepr = rw_wkemp.qtassepr
           where crapger.dtrefere = rw_crapdat.dtultdia
             and crapger.cdagenci = 0
             and crapger.cdempres = rw_wkemp.cdempres
             and crapger.cdcooper = pr_cdcooper;
          if sql%rowcount = 0 then
            begin
              insert into crapger (dtrefere,
                                   cdagenci,
                                   cdempres,
                                   cdcooper,
                                   qtassoci,
                                   qtautent,
                                   qtctacor,
                                   qtplanos,
                                   vlcaptal,
                                   vlplanos,
                                   vlsmpmes,
                                   qtassepr,
                                   qtaplrdc,
                                   vlaplrdc,
                                   qtaplrda,
                                   vlaplrda,
                                   qtaplrpp,
                                   vlaplrpp,
                                   qtctrrpp,
                                   vlctrrpp,
                                   qtassapl,
                                   qtrettal,
                                   qtsoltal,
                                   qtrttlct,
                                   qtrttlbc,
                                   qtsltlct,
                                   qtsltlbc)
              values (rw_crapdat.dtultdia,
                      0,
                      rw_wkemp.cdempres,
                      pr_cdcooper,
                      rw_wkemp.qtassoci,
                      0,
                      rw_wkemp.qtctacor,
                      rw_wkemp.qtplanos,
                      rw_wkemp.vlcaptal,
                      rw_wkemp.vlplanos,
                      rw_wkemp.vlsmpmes,
                      rw_wkemp.qtassepr,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0);
            exception
              when others then
                vr_dscritic := 'Erro ao inserir informações gerenciais (crapger): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
          when vr_exc_saida then
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao alterar informações gerenciais (crapger): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end loop;

      -- Limpa os registros da tabela de trabalho
      begin
        delete from tbgen_batch_relatorio_wrk
         where cdcooper    = pr_cdcooper
           and cdprograma  = vr_cdprogra
           AND dsrelatorio IN('CRAPACC_PAC','CRAPGER_PAC','CRAPACC_EMP','CRAPGER_EMP')
           and dtmvtolt    = rw_crapdat.dtmvtolt;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
          raise vr_exc_saida;
      end;

      -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
      pc_log_programa(PR_DSTIPLOG           => 'O'
                     ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper           => pr_cdcooper
                     ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia       => 4
                     ,pr_dsmensagem         => 'Fim - Alimentação das tabelas.'
                     ,PR_IDPRGLOG           => vr_idlog_ini_ger);

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Caso seja o controlador
      if vr_idcontrole <> 0 then
        -- Atualiza finalização do batch na tabela de controle
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);
        -- Testar saida com erro
        if  vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;
      end if;

      -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F'
                     ,pr_cdprograma => vr_cdprogra
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 1);
      -- Efetuar commit
      COMMIT;
    ELSE
      -- Atualiza finalização do batch na tabela de controle
      gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                         ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                         ,pr_dscritic     --pr_dscritic  OUT crapcri.dscritic%TYPE
                                         );

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);

      -- Salvar informacoes no banco de dados
      COMMIT;
    END IF;

  exception
    when vr_exc_fimprg then
      -- chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- efetuar commit pois gravaremos o que foi processo até então
      commit;

    when vr_exc_saida then
      -- se foi retornado apenas código
      if vr_cdcritic > 0 and vr_dscritic is null then
        -- buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      end if;
      -- devolvemos código e critica encontradas
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      -- Na execução paralela
      IF nvl(pr_idparale,0) <> 0 THEN
        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);                                     
        -- Grava LOG de erro com as críticas retornadas                           
        pc_log_programa(pr_dstiplog      => 'E', 
                        pr_cdprograma    => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper      => pr_cdcooper,
                        pr_tpexecucao    => vr_tpexecucao,
                        pr_tpocorrencia  => 3,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => pr_cdcritic,
                        pr_dsmensagem    => pr_dscritic,
                        pr_flgsucesso    => 0,
                        pr_idprglog      => vr_idlog_ini_par);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);                        
      END IF;
      -- efetuar rollback
      rollback;
  when others then
      -- efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;    
      
      -- Na execução paralela
      if nvl(pr_idparale,0) <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par); 
                        
        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if; 
      -- efetuar rollback
      rollback;
  END;
end PC_CRPS133;
/
