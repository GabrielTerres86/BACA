CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS133(pr_cdcooper  IN craptab.cdcooper%TYPE
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                             ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o                                                     pr_stprogra OUT PLS_INTEGER,            --> Sa�da de termino da execu��o
                                             ,pr_cdcritic out crapcri.cdcritic%TYPE
                                             ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps133 (Antigo Fontes/crps133.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/95                      Ultima atualizacao: 28/05/2015

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

               11/02/2013 - Convers�o Progress >> Oracle PL/SQL (Daniel - Supero)

               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas)

               09/10/2013 - Modificado o padr�o das exce��es para utilizar a rotina
                            pc_valida_fimprg (Edison - AMcom)

               25/11/2013 - Ajustes na passagem dos par�metros para restart (Marcos-Supero)

               06/12/2013 - Ajustes em problemas do programa. (Marcos-Supero)

							 19/09/2014 - Acrescentado leitura da tabela craplac. (Reinert)
               
               24/04/2015 - Ajustar para gerar a critica de Associado n�o cadastrado no 
                            LOG de mensagens, ao inv�s de gerar no LOG do processo.
                            (DOuglas - Chamado 273546)

               28/05/2015 - Realizando a retirada dos tratamentos de restart, pois o programa
                            apresentou erros no processo batch. Os c�digos foram comentados e 
                            podem ser removidos em futuras altera��es do fonte. (Renato - Supero)

               05/03/2018 - Substitu�da verificacao do tipo de conta "NOT IN (5,6,7,17,18)" para a 
                            modalidade do tipo de conta diferente de "2" e "3". PRJ366. (Lombardi)
                            
............................................................................. */
  -- Busca o saldo m�dio
  cursor cr_craptab is
    select craptab.dstextab
      from craptab
     where craptab.cdcooper = pr_cdcooper
       and upper(craptab.nmsistem) = 'CRED'
       and craptab.cdempres = 11
       and upper(craptab.tptabela) = 'USUARI'
       and upper(craptab.cdacesso) = 'SDMEDCTPPR'
       and craptab.tpregist = 001;
  rw_craptab    cr_craptab%rowtype;
  -- Data do movimento
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  -- Dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select 1
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%rowtype;
  -- Busca informa��es do associado
  cursor cr_crapass (pr_cdcooper in crapcop.cdcooper%type) is
    select cdagenci,
           nrdconta,
           cdtipcta,
           cdsitdct,
           inpessoa,
           dtdemiss,
           inmatric
      from crapass
     where cdcooper = pr_cdcooper;
  -- Busca informa��es do titular da conta
  cursor cr_crapttl (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type) is
    select cdempres
      from crapttl
     where crapttl.cdcooper = pr_cdcooper
       and crapttl.nrdconta = pr_nrdconta
       and crapttl.idseqttl = 1;
  -- Busca informa��es da conta PJ
  cursor cr_crapjur (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type) is
    select cdempres
      from crapjur
     where crapjur.cdcooper = pr_cdcooper
       and crapjur.nrdconta = pr_nrdconta;
  -- Busca o saldo m�dio mensal do associado
  cursor cr_crapsld (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type,
                     pr_insldmes in number) is
    select decode(pr_insldmes,
                  1, crapsld.vlsmstre##1,
                  2, crapsld.vlsmstre##2,
                  3, crapsld.vlsmstre##3,
                  4, crapsld.vlsmstre##4,
                  5, crapsld.vlsmstre##5,
                  6, crapsld.vlsmstre##6,
                  0) vlsmstre
      from crapsld
     where crapsld.cdcooper = pr_cdcooper
       and crapsld.nrdconta = pr_nrdconta;
  rw_crapsld      cr_crapsld%rowtype;
  -- Busca o valor capital do m�s (cotas e recursos)
  cursor cr_crapcot (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type,
                     pr_mes in number) is
    select vlcotant,
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
     where crapcot.cdcooper = pr_cdcooper
       and crapcot.nrdconta = pr_nrdconta;
  rw_crapcot      cr_crapcot%rowtype;
  -- Busca o valor da presta��o do plano de capitaliza��o
  cursor cr_crappla (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type) is
    select /*+ index (crappla crappla3)*/
           crappla.vlprepla
      from crappla
     where crappla.cdcooper = pr_cdcooper
       and crappla.nrdconta = pr_nrdconta
       and crappla.cdsitpla = 1
       and crappla.tpdplano = 1
       and rownum = 1;
  rw_crappla     cr_crappla%rowtype;
  -- Busca informa��es referentes a empr�stimos
  cursor cr_crapepr (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type) is
    select /*+ index (crappla crapepr2)*/
           crapepr.dtmvtolt,
           crapepr.vlemprst,
           crapepr.inprejuz,
           crapepr.dtprejuz,
           crapepr.vljurmes,
           crapepr.vlsdeved,
           crapepr.cdlcremp,
           crapepr.cdfinemp
      from crapepr
     where crapepr.cdcooper = pr_cdcooper
       and crapepr.nrdconta = pr_nrdconta;
  rw_crapepr     cr_crapepr%rowtype;
  --
  -- Cursores para buscar os valores a serem registrados
  --
  -- Lan�amentos em dep�sitos a vista
  cursor cr_craplcm (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplcm4)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplcm crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos em empr�stimos
  cursor cr_craplem (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplem4)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplem crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos em cotas / capital
  cursor cr_craplct (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplct4)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplct crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos de aplica��es RDCA
  cursor cr_craplap (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplap4)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplap crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos de aplica��es de capta��o			 
  CURSOR cr_craplac (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
	                  ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		SELECT lac.nrdconta
		      ,lac.cdhistor
					,lac.vllanmto
			FROM craplac lac
		 WHERE lac.dtmvtolt = pr_dtmvtolt
		   AND lac.cdcooper = pr_cdcooper;
  -- Lan�amentos autom�ticos
  cursor cr_craplau (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplau3)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanaut
      from craplau crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos de cobran�a
  cursor cr_craplcb (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplcb3)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplcb crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos da conta de investimento
  cursor cr_craplci (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplci1)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplci crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos de aplica��es de poupan�a
  cursor cr_craplpp (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplpp4)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from craplpp crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Transa��es nos caixas e auto-atendimento
  cursor cr_crapltr (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap crapltr1)*/
           crap.nrdconta,
           crap.cdhistor,
           crap.vllanmto
      from crapltr crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper
       and crap.cdhistor not in (316, 375, 376, 377, 767, 918, 920)
       and crap.nrdconta > 0;
  -- Cust�dia de cheques
  cursor cr_crapcst (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap crapcst4)*/
           crap.nrdconta,
           997 cdhistor,
           crap.vlcheque
      from crapcst crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Border� de desconto de cheques
  cursor cr_crapcdb (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap crapcdb4)*/
           crap.nrdconta,
           996 cdhistor,
           crap.vlliquid
      from crapcdb crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Juros de descontos de cheques
  cursor cr_crapljd (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap crapljd1)*/
           crap.nrdconta,
           998 cdhistor,
           crap.vlrestit
      from crapljd crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Registro para receber o resultado dos cursores acima, por conta
  rw_gera_registro_conta    cr_craplcm%rowtype;
  -- Border� de descontos de t�tulos
  cursor cr_crapbdt (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select crap.nrdconta,
           crap.nrborder
      from crapbdt crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- T�tulos do border� de descontos
  cursor cr_craptdb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in crapbdt.nrdconta%type,
                     pr_nrborder in crapbdt.nrborder%type) is
    select crap.nrdconta,
           crap.vlliquid
      from craptdb crap
     where crap.cdcooper = pr_cdcooper
       and crap.nrdconta = pr_nrdconta
       and crap.nrborder = pr_nrborder;
  --
  -- Tabelas que contam somente por PAC
  --
  -- Autentica��es
  cursor cr_crapaut (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap crapaut2)*/
           crap.cdagenci,
           995 cdhistor,
           crap.vldocmto
      from crapaut crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos extra-sistema (boletim de caixa)
  cursor cr_craplcx (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplcx2)*/
           crap.cdagenci,
           crap.cdhistor,
           crap.vldocmto
      from craplcx crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Lan�amentos de faturas
  cursor cr_craplft (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craplft1)*/
           crap.cdagenci,
           crap.cdhistor,
           (crap.vllanmto + nvl(crap.vlrmulta, 0) + nvl(crap.vlrjuros, 0)) vllanmto
      from craplft crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- T�tulos acolhidos
  cursor cr_craptit (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap craptit1)*/
           crap.cdagenci,
           994 cdhistor,
           crap.vldpagto
      from craptit crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper;
  -- Movimento Correspondente Banc�rio - Banco do Brasil
  cursor cr_crapcbb (pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdcooper in crapcop.cdcooper%type) is
    select /*+ index (crap crapcbb1)*/
           crap.cdagenci,
           750 cdhistor,
           crap.valorpag
      from crapcbb crap
     where crap.dtmvtolt = pr_dtmvtolt
       and crap.cdcooper = pr_cdcooper
       and crap.flgrgatv = 1
       and crap.tpdocmto < 3;
  -- Registro para receber o resultado dos cursores acima, por ag�ncia
  rw_gera_registro_pac      cr_crapaut%rowtype;
  -- Cursor para busca dos tipos de conta
  CURSOR cr_tipcta IS
    SELECT inpessoa
          ,cdtipo_conta cdtipcta
          ,cdmodalidade_tipo cdmodali
      FROM tbcc_tipo_conta;

  -- Registro para armazenar os dados gerais (PAC e empresa)
  type tab_geral is record (vr_codigo    number(10),
                            vr_tipo      varchar2(1), -- "A"g�ncia ou "E"mpresa
                            vr_qtassoci  crapger.qtassoci%type,
                            vr_qtctacor  crapger.qtctacor%type,
                            vr_qtplanos  crapger.qtplanos%type,
                            vr_qtassepr  crapger.qtassepr%type,
                            vr_vlsmpmes  crapger.vlsmpmes%type,
                            vr_vlcaptal  crapger.vlcaptal%type,
                            vr_vlplanos  crapger.vlplanos%type);
  -- Defini��o da tabela para armazenar os registros de dados gerais
  type typ_tab_geral is table of tab_geral index by varchar2(11);
  -- Inst�ncias das tabelas. O �ndice ser� o tipo concatenado com o c�digo.
  vr_tab_pac       typ_tab_geral;
  vr_tab_emp       typ_tab_geral;
  -- Vari�veis utilizadas para indexar as PL/Tables
  vr_indice_pac    varchar2(11);
  vr_indice_emp    varchar2(11);

  -- Registro para armazenar os valores
  type tab_valores is record (vr_codigo    number(10),
                              vr_tipo      varchar2(1), -- "A"g�ncia ou "E"mpresa
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
  -- Defini��o da tabela para armazenar os registros de valores
  type typ_tab_valores is table of tab_valores index by varchar2(16);
  -- Inst�ncia da tabela. O �ndice ser� a concatena��o de tipo, c�digo e hist�rico.
  vr_tab_val       typ_tab_valores;
  -- Vari�vel utilizada para indexar a PL/Table
  vr_indice_val    varchar2(16);

  -- Definicao do tipo de tabela para os tipos de conta
  TYPE typ_reg_tipcta   IS RECORD(cdmodali tbcc_tipo_conta.cdmodalidade_tipo%TYPE);        
  TYPE typ_tab_tipcta_2 IS TABLE OF typ_reg_tipcta   INDEX BY PLS_INTEGER;        
  TYPE typ_tab_tipcta   IS TABLE OF typ_tab_tipcta_2 INDEX BY PLS_INTEGER;          
  -- Vetor para armazenar os dados para o processo definitivo
  vr_tab_tipcta typ_tab_tipcta;
  
  -- C�digo do programa
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

  -- Vari�vel para armazenar o saldo m�dio
  vr_vlsldmed      crapsld.vlsmstre##1%type;
  -- C�digo da empresa do associado (PF ou PJ)
  vr_cdempres      crapttl.cdempres%type;
  --
  vr_flghaepr      boolean;
  -- Vari�vel para armazenar o c�digo do lan�amento
  vr_cdlanmto      crapacc.cdlanmto%type;
  -- Vari�veis para controle de reprocesso
  vr_dsrestar      crapres.dsrestar%type;
  vr_nrctares      crapres.nrdconta%type;
  vr_inrestar      number(1);
  --
  -- Procedimentos internos para manipula��o das pl/tables
  --
  function fn_cria_registro (pr_codigo    in number,
                             pr_tipo      in varchar2,
                             pr_historico in number) return varchar2 is
    -- Procedimento para inicializa��o dos registros da pl/table de valores
    -- Retorna o �ndice do registro criado
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
  --
  procedure pc_gera_registro_pac (pr_cdagenci in craplcm.cdagenci%type,
                                  pr_cdhistor in craplcm.cdhistor%type,
                                  pr_vllanmto in crapacc.vllanmto%type) is
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
    vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + 1;
    vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
    --
    vr_indice_val := fn_cria_registro(pr_cdagenci, 'A', pr_cdhistor);
    vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + 1;
    vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
  end;
  --
  procedure pc_gera_registro_conta (pr_nrdconta in crapass.nrdconta%type,
                                    pr_cdhistor in craplcm.cdhistor%type,
                                    pr_vllanmto in crapacc.vllanmto%type) is
  -- Cria os registros para as tabelas que tem numero da conta, e cria a tabela de valores
    -- Busca informa��es do associado
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select crapass.inpessoa,
             crapass.cdagenci
        from crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.nrdconta = pr_nrdconta;
    rw_crapass    cr_crapass%rowtype;
    -- Busca informa��es do titular da conta
    cursor cr_crapttl (pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select cdempres
        from crapttl
       where crapttl.cdcooper = pr_cdcooper
         and crapttl.nrdconta = pr_nrdconta
         and crapttl.idseqttl = 1;
    -- Busca informa��es da conta PJ
    cursor cr_crapjur (pr_cdcooper in crapcop.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      select cdempres
        from crapjur
       where crapjur.cdcooper = pr_cdcooper
         and crapjur.nrdconta = pr_nrdconta;
    -- �ndices utilizados na manipula��o das tabelas
    vr_indice_val   varchar2(16);
    vr_indice_pac   varchar2(11);
    vr_indice_emp   varchar2(11);
    -- C�digo da empresa
    vr_cdempres     crapttl.cdempres%type := 0;
  begin
    -- Busca informa��es do associado
    open cr_crapass (pr_cdcooper,
                     pr_nrdconta);
      fetch cr_crapass into rw_crapass;
      if cr_crapass%notfound then
        close cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(9)||' - Conta: '||pr_nrdconta;
        -- Gera a mensagem de erro no log e n�o prossegue a rotina.

        -- envio centralizado de log de erro
        -- Ajustar para gerar o LOG no arquivo de mensagens em vez do LOG do processo noturno
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- erro tratado
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR') || ' - ' ||
                                                      to_char(sysdate,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);                                                      
        return;
      end if;
    close cr_crapass;
    -- Busca o c�digo da empresa para PF ou PJ
    if rw_crapass.inpessoa = 1 then
      open cr_crapttl (pr_cdcooper,
                       pr_nrdconta);
        fetch cr_crapttl into vr_cdempres;
      close cr_crapttl;
    else
      open cr_crapjur (pr_cdcooper,
                       pr_nrdconta);
        fetch cr_crapjur into vr_cdempres;
      close cr_crapjur;
    end if;
    --
    -- PAC
    --
    -- Gera registros na tabela de PAC e na de valores
    vr_indice_pac := 'A'||lpad(rw_crapass.cdagenci, 10, '0');
    if not vr_tab_pac.exists(vr_indice_pac) then
      -- Cria registro na PL/Table com valores zerados
      vr_tab_pac(vr_indice_pac).vr_codigo := rw_crapass.cdagenci;
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
    vr_indice_val := fn_cria_registro(rw_crapass.cdagenci, 'A', 9999);
    vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + 1;
    vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
    --
    vr_indice_val := fn_cria_registro(rw_crapass.cdagenci, 'A', pr_cdhistor);
    vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + 1;
    vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
    --
    -- EMPRESA
    --
    -- Gera registros na tabela de empresa e na de valores
    vr_indice_emp := 'E'||lpad(vr_cdempres, 10, '0');
    if not vr_tab_emp.exists(vr_indice_emp) then
      -- Cria registro na PL/Table com valores zerados
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
    --
    vr_indice_val := fn_cria_registro(vr_cdempres, 'E', 9999);
    vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + 1;
    vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
    --
    vr_indice_val := fn_cria_registro(vr_cdempres, 'E', pr_cdhistor);
    vr_tab_val(vr_indice_val).vr_qtlanmto := vr_tab_val(vr_indice_val).vr_qtlanmto + 1;
    vr_tab_val(vr_indice_val).vr_vllanmto := vr_tab_val(vr_indice_val).vr_vllanmto + pr_vllanmto;
  end;
  --
begin
  --
  vr_cdprogra := 'CRPS133';

  -- Incluir nome do m�dulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS133'
                            ,pr_action => null);

  -- Valida��es iniciais do programa
  BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                            ,pr_flgbatch => 1
                            ,pr_infimsol => pr_infimsol
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_cdcritic => vr_cdcritic);
  -- Se retornou algum erro
  if vr_cdcritic <> 0 then
    -- Buscar descri��o do erro
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;

  -- Buscar informa��es de reprocesso
  --   Caso vr_dsrestar seja nulo, processa os loops por ag�ncia e por empresa
  --   Caso seja PAC, processa o loop por ag�ncia a partir de "vr_nrctares" e todo o loop por empresa
  --   Caso seja EMPRESA, processa o loop por empresa a partir de "vr_nrctares" e descarta o loop por ag�ncia
  btch0001.pc_valida_restart (pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_nrctares,
                              vr_dsrestar,
                              vr_inrestar,
                              vr_cdcritic,
                              vr_dscritic);

  if vr_dscritic is not null then
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
        
  -- Buscar o saldo m�dio
  open cr_craptab;
    fetch cr_craptab into rw_craptab;
    if cr_craptab%notfound then
      vr_vlsldmed := 0;
    else
      vr_vlsldmed := gene0002.fn_char_para_number(rw_craptab.dstextab);
    end if;
  close cr_craptab;

  -- Vari�veis de controle de data
  vr_flgmensa := trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm');
  vr_flganual := (to_char(rw_crapdat.dtmvtolt, 'mm') = '12');

  if to_char(rw_crapdat.dtmvtolt, 'mm') > '06' then
    vr_insldmes := to_number(to_char(rw_crapdat.dtmvtolt, 'mm')) - 6;
  else
    vr_insldmes := to_number(to_char(rw_crapdat.dtmvtolt, 'mm'));
  end if;
  -- Caso n�o seja a cooperativa 3 e n�o seja processo mensal, abandona a execu��o
  if pr_cdcooper <> 3 then
    if not vr_flgmensa then
      --return;
      -- gerando exce��o de final de programa
      raise vr_exc_fimprg;
    end if;
  end if;
  -- Garante que n�o existe sujeira na PL/Table de valores
  vr_tab_val.delete;
  -- Inicia o processamento, gerando os registros na conta
  -- Lan�amentos em dep�sitos a vista
  for rw_gera_registro_conta in cr_craplcm (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  -- Lan�amentos em empr�stimos
  for rw_gera_registro_conta in cr_craplem (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  -- Lan�amentos em cotas / capital
  for rw_gera_registro_conta in cr_craplct (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  -- Lan�amentos de aplica��es RDCA
  for rw_gera_registro_conta in cr_craplap (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
	-- Lan�amentos de aplica��es de capta��o
	for rw_gera_registro_conta IN cr_craplac (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) LOOP
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
	END LOOP;
  -- Lan�amentos autom�ticos
  for rw_gera_registro_conta in cr_craplau (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanaut);
  end loop;
  -- Lan�amentos de cobran�a
  for rw_gera_registro_conta in cr_craplcb (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  -- Lan�amentos da conta de investimento
  for rw_gera_registro_conta in cr_craplci (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  -- Lan�amentos de aplica��es de poupan�a
  for rw_gera_registro_conta in cr_craplpp (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  -- Transa��es nos caixas e auto-atendimento
  for rw_gera_registro_conta in cr_crapltr (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vllanmto);
  end loop;
  --
  -- Processa as tabelas sem campo cdhistor. O campo cdhistor est� fixo no cursor
  --
  -- Cust�dia de cheques
  for rw_gera_registro_conta in cr_crapcst (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vlcheque);
  end loop;
  -- Border� de desconto de cheques
  for rw_gera_registro_conta in cr_crapcdb (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vlliquid);
  end loop;
  --
  for rw_crapbdt in cr_crapbdt (rw_crapdat.dtmvtolt,
                                pr_cdcooper) loop
    for rw_gera_registro_conta in cr_craptdb (pr_cdcooper,
                                              rw_crapbdt.nrdconta,
                                              rw_crapbdt.nrborder) loop
      -- Descto de titulos
      pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                              992,
                              rw_gera_registro_conta.vlliquid);
      -- Juros de descto
      pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                              993,
                              rw_gera_registro_conta.vlliquid);
    end loop;
  end loop;
  -- Juros de descontos de cheques
  for rw_gera_registro_conta in cr_crapljd (rw_crapdat.dtmvtolt,
                                            pr_cdcooper) loop
    pc_gera_registro_conta (rw_gera_registro_conta.nrdconta,
                            rw_gera_registro_conta.cdhistor,
                            rw_gera_registro_conta.vlrestit);
  end loop;
  -- Autentica��es
  for rw_gera_registro_pac in cr_crapaut (rw_crapdat.dtmvtolt,
                                          pr_cdcooper) loop
    pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                          rw_gera_registro_pac.cdhistor,
                          rw_gera_registro_pac.vldocmto);
  end loop;
  -- Lan�amentos extra-sistema (boletim de caixa)
  for rw_gera_registro_pac in cr_craplcx (rw_crapdat.dtmvtolt,
                                          pr_cdcooper) loop
    pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                          rw_gera_registro_pac.cdhistor,
                          rw_gera_registro_pac.vldocmto);
  end loop;
  -- Lan�amentos de faturas
  for rw_gera_registro_pac in cr_craplft (rw_crapdat.dtmvtolt,
                                          pr_cdcooper) loop
    pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                          rw_gera_registro_pac.cdhistor,
                          rw_gera_registro_pac.vllanmto);
  end loop;
  -- T�tulos acolhidos
  for rw_gera_registro_pac in cr_craptit (rw_crapdat.dtmvtolt,
                                          pr_cdcooper) loop
    pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                          rw_gera_registro_pac.cdhistor,
                          rw_gera_registro_pac.vldpagto);
  end loop;
  -- Movimento Correspondente Banc�rio - Banco do Brasil
  for rw_gera_registro_pac in cr_crapcbb (rw_crapdat.dtmvtolt,
                                          pr_cdcooper) loop
    pc_gera_registro_pac (rw_gera_registro_pac.cdagenci,
                          rw_gera_registro_pac.cdhistor,
                          rw_gera_registro_pac.valorpag);
  end loop;
  --
  -- Mensal
  --
  if vr_flgmensa then
    for rw_crapass in cr_crapass (pr_cdcooper) loop
      -- Recuperar o nome do titular da conta
      if rw_crapass.inpessoa = 1 then
        -- Pessoa f�sica
        open cr_crapttl (pr_cdcooper,
                         rw_crapass.nrdconta);
          fetch cr_crapttl into vr_cdempres;
        close cr_crapttl;
      else
        -- Pessoa juridica
        open cr_crapjur (pr_cdcooper,
                         rw_crapass.nrdconta);
          fetch cr_crapjur into vr_cdempres;
        close cr_crapjur;
      end if;
      -- Criar PL/Tables
      -- PAC
      vr_indice_pac := 'A'||lpad(rw_crapass.cdagenci, 10, '0');
      if not vr_tab_pac.exists(vr_indice_pac) then
        vr_tab_pac(vr_indice_pac).vr_codigo := rw_crapass.cdagenci;
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
      -- Verifica se possui informa��o do saldo m�dio mensal
      open cr_crapsld (pr_cdcooper,
                       rw_crapass.nrdconta,
                       vr_insldmes);
        fetch cr_crapsld into rw_crapsld;
        if cr_crapsld%notfound then
          close cr_crapsld;
          vr_cdcritic := 10;
          vr_dscritic := gene0001.fn_busca_critica(10)||' - Conta: '||rw_crapass.nrdconta;
          -- tratando a exce��o
          raise vr_exc_saida;
        end if;
      close cr_crapsld;
      -- Acumula os valores nas tabelas de PAC e empresa
      vr_tab_pac(vr_indice_pac).vr_vlsmpmes := vr_tab_pac(vr_indice_pac).vr_vlsmpmes + rw_crapsld.vlsmstre;
      vr_tab_emp(vr_indice_emp).vr_vlsmpmes := vr_tab_emp(vr_indice_emp).vr_vlsmpmes + rw_crapsld.vlsmstre;
      --
      if rw_crapass.dtdemiss is null then
        if rw_crapass.inmatric = 1 then
          vr_tab_pac(vr_indice_pac).vr_qtassoci := vr_tab_pac(vr_indice_pac).vr_qtassoci + 1;
          vr_tab_emp(vr_indice_emp).vr_qtassoci := vr_tab_emp(vr_indice_emp).vr_qtassoci + 1;
        end if;
        if vr_tab_tipcta(rw_crapass.inpessoa)(rw_crapass.cdtipcta).cdmodali not in (2, 3) then
          if rw_crapass.cdsitdct = 6 then
            if rw_crapsld.vlsmstre >= vr_vlsldmed then
              vr_tab_pac(vr_indice_pac).vr_qtctacor := vr_tab_pac(vr_indice_pac).vr_qtctacor + 1;
              vr_tab_emp(vr_indice_emp).vr_qtctacor := vr_tab_emp(vr_indice_emp).vr_qtctacor + 1;
            end if;
          else
            vr_tab_pac(vr_indice_pac).vr_qtctacor := vr_tab_pac(vr_indice_pac).vr_qtctacor + 1;
            vr_tab_emp(vr_indice_emp).vr_qtctacor := vr_tab_emp(vr_indice_emp).vr_qtctacor + 1;
          end if;
        end if;
      end if;
      -- Verifica se possui informa��es de cotas e recursos
      open cr_crapcot (pr_cdcooper,
                       rw_crapass.nrdconta,
                       to_number(to_char(rw_crapdat.dtmvtolt, 'mm')));
        fetch cr_crapcot into rw_crapcot;
        if cr_crapcot%notfound then
          close cr_crapcot;
          vr_cdcritic := 169;
          vr_dscritic := gene0001.fn_busca_critica(169)||' - Conta: '||rw_crapass.nrdconta;
          -- tratando a exce��o
          raise vr_exc_saida;
        end if;
      close cr_crapcot;
      -- Acumula os valores de cotas e recursos
      if vr_flganual then
        vr_tab_pac(vr_indice_pac).vr_vlcaptal := vr_tab_pac(vr_indice_pac).vr_vlcaptal + rw_crapcot.vlcotant;
        vr_tab_emp(vr_indice_emp).vr_vlcaptal := vr_tab_emp(vr_indice_emp).vr_vlcaptal + rw_crapcot.vlcotant;
      else
        vr_tab_pac(vr_indice_pac).vr_vlcaptal := vr_tab_pac(vr_indice_pac).vr_vlcaptal + rw_crapcot.vlcapmes;
        vr_tab_emp(vr_indice_emp).vr_vlcaptal := vr_tab_emp(vr_indice_emp).vr_vlcaptal + rw_crapcot.vlcapmes;
      end if;
      -- Acumula o valor da presta��o do plano de capitaliza��o
      open cr_crappla (pr_cdcooper,
                       rw_crapass.nrdconta);
        fetch cr_crappla into rw_crappla;
        if cr_crappla%found then
          vr_tab_pac(vr_indice_pac).vr_qtplanos := vr_tab_pac(vr_indice_pac).vr_qtplanos + 1;
          vr_tab_emp(vr_indice_emp).vr_qtplanos := vr_tab_emp(vr_indice_emp).vr_qtplanos + 1;
          vr_tab_pac(vr_indice_pac).vr_vlplanos := vr_tab_pac(vr_indice_pac).vr_vlplanos + rw_crappla.vlprepla;
          vr_tab_emp(vr_indice_emp).vr_vlplanos := vr_tab_emp(vr_indice_emp).vr_vlplanos + rw_crappla.vlprepla;
        end if;
      close cr_crappla;
      -- Loop para acumular valores de empr�stimos
      vr_flghaepr := false;
      for rw_crapepr in cr_crapepr (pr_cdcooper,
                                    rw_crapass.nrdconta) loop
        if to_char(rw_crapepr.dtmvtolt, 'mmyyyy') = to_char(rw_crapdat.dtmvtolt, 'mmyyyy') and
           rw_crapepr.inprejuz = 0 then
          --
          vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', 9999);
          vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
          vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + rw_crapepr.vlemprst;
          vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
          vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + rw_crapepr.vlemprst;
          --
          vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', 9999);
          vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
          vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + rw_crapepr.vlemprst;
          vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
          vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + rw_crapepr.vlemprst;
          --
          vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', rw_crapepr.cdlcremp);
          vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
          vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + rw_crapepr.vlemprst;
          --
          vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', rw_crapepr.cdlcremp);
          vr_tab_val(vr_indice_val).vr_qteprlcr := vr_tab_val(vr_indice_val).vr_qteprlcr + 1;
          vr_tab_val(vr_indice_val).vr_vleprlcr := vr_tab_val(vr_indice_val).vr_vleprlcr + rw_crapepr.vlemprst;
          --
          vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', rw_crapepr.cdfinemp);
          vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
          vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + rw_crapepr.vlemprst;
          --
          vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', rw_crapepr.cdfinemp);
          vr_tab_val(vr_indice_val).vr_qteprfin := vr_tab_val(vr_indice_val).vr_qteprfin + 1;
          vr_tab_val(vr_indice_val).vr_vleprfin := vr_tab_val(vr_indice_val).vr_vleprfin + rw_crapepr.vlemprst;
        end if;
        --
        if rw_crapepr.inprejuz > 0 and
           rw_crapepr.dtprejuz < trunc(rw_crapdat.dtmvtolt, 'mm') then
          continue;
        end if;
        --
        vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', 9999);
        vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
        vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + rw_crapepr.vljurmes;
        --
        vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', 9999);
        vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
        vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + rw_crapepr.vljurmes;
        --
        vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', rw_crapepr.cdlcremp);
        vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
        vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + rw_crapepr.vljurmes;
        --
        vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', rw_crapepr.cdlcremp);
        vr_tab_val(vr_indice_val).vr_qtjurlcr := vr_tab_val(vr_indice_val).vr_qtjurlcr + 1;
        vr_tab_val(vr_indice_val).vr_vljurlcr := vr_tab_val(vr_indice_val).vr_vljurlcr + rw_crapepr.vljurmes;
        --
        if rw_crapepr.vlsdeved = 0 then
          continue;
        end if;
        --
        vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', 9999);
        vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + rw_crapepr.vlsdeved;
        vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + rw_crapepr.vlsdeved;
        --
        vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', 9999);
        vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + rw_crapepr.vlsdeved;
        vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + rw_crapepr.vlsdeved;
        --
        vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', rw_crapepr.cdlcremp);
        vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + rw_crapepr.vlsdeved;
        --
        vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', rw_crapepr.cdlcremp);
        vr_tab_val(vr_indice_val).vr_qtsdvlcr := vr_tab_val(vr_indice_val).vr_qtsdvlcr + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvlcr := vr_tab_val(vr_indice_val).vr_vlsdvlcr + rw_crapepr.vlsdeved;
        --
        vr_indice_val := fn_cria_registro(vr_tab_pac(vr_indice_pac).vr_codigo, 'A', rw_crapepr.cdfinemp);
        vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + rw_crapepr.vlsdeved;
        --
        vr_indice_val := fn_cria_registro(vr_tab_emp(vr_indice_emp).vr_codigo, 'E', rw_crapepr.cdfinemp);
        vr_tab_val(vr_indice_val).vr_qtsdvfin := vr_tab_val(vr_indice_val).vr_qtsdvfin + 1;
        vr_tab_val(vr_indice_val).vr_vlsdvfin := vr_tab_val(vr_indice_val).vr_vlsdvfin + rw_crapepr.vlsdeved;
        --
        vr_flghaepr := true;
      end loop; -- Fim do loop para acumular valores de empr�stimos
      -- Se tinha algum empr�stimo, acumula quantidade de associados para PAC e empresa.
      if vr_flghaepr then
        vr_tab_pac(vr_indice_pac).vr_qtassepr := vr_tab_pac(vr_indice_pac).vr_qtassepr + 1;
        vr_tab_emp(vr_indice_emp).vr_qtassepr := vr_tab_emp(vr_indice_emp).vr_qtassepr + 1;
      end if;
    end loop;  -- Fim crapass
  end if;  -- aux_flgmensa
  -- Criacao dos registros crapacc por PAC
  if nvl(vr_dsrestar, 'x') <> 'EMPRESA' then
    vr_indice_pac := vr_tab_pac.first;
    while vr_indice_pac is not null loop
      if vr_tab_pac(vr_indice_pac).vr_codigo > vr_nrctares and
         vr_tab_pac(vr_indice_pac).vr_tipo   = 'A' then
        for vr_contador in 1..9999 loop
          if vr_contador = 9999 then
            vr_cdlanmto := 0;
          else
            vr_cdlanmto := vr_contador;
          end if;
          -- Monta o �ndice da tabela por PAC e verifica se existe informa��o
          vr_indice_val := 'A'||lpad(vr_tab_pac(vr_indice_pac).vr_codigo, 10, '0')||lpad(vr_contador, 5, '0');
          if not vr_tab_val.exists(vr_indice_val) then
            continue;
          end if;
          -- Verifica se existe lan�amento da tabela de valores
          if vr_tab_val(vr_indice_val).vr_qtlanmto > 0 then
            -- Atualiza usando o c�digo da ag�ncia
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtlanmto,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vllanmto
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
                 and crapacc.cdempres = 0
                 and crapacc.tpregist = 1
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          vr_tab_pac(vr_indice_pac).vr_codigo,
                          0,
                          1,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtlanmto,
                          vr_tab_val(vr_indice_val).vr_vllanmto);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vllanmto para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vllanmto para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                raise vr_exc_saida;
            end;
            -- Atualiza com c�digo da ag�ncia igual a zero
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtlanmto,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vllanmto
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = 0
                 and crapacc.tpregist = 1
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          1,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtlanmto,
                          vr_tab_val(vr_indice_val).vr_vllanmto);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vllanmto por ag�ncia (acumulado): '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vllanmto por ag�ncia (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
          -- Verifica se � execu��o mensal da rotina
          if vr_flgmensa then
            if vr_tab_val(vr_indice_val).vr_qteprlcr > 0 then
              -- Atualiza usando o c�digo da ag�ncia
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprlcr,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprlcr
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 2
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            vr_tab_pac(vr_indice_pac).vr_codigo,
                            0,
                            2,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qteprlcr,
                            vr_tab_val(vr_indice_val).vr_vleprlcr);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vleprlcr para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vleprlcr para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                  raise vr_exc_saida;
              end;
              -- Atualiza com c�digo da ag�ncia igual a zero
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprlcr,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprlcr
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = 0
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 2
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            2,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qteprlcr,
                            vr_tab_val(vr_indice_val).vr_vleprlcr);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vleprlcr por ag�ncia (acumulado): '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vleprlcr por ag�ncia (acumulado): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
            -- Verifica se existe valor de empr�stimo ou financiamento
            if vr_tab_val(vr_indice_val).vr_qteprfin <> 0 then
              -- Atualiza usando o c�digo da ag�ncia
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprfin,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprfin
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 4
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            vr_tab_pac(vr_indice_pac).vr_codigo,
                            0,
                            4,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qteprfin,
                            vr_tab_val(vr_indice_val).vr_vleprfin);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vleprfin para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vleprfin para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                  raise vr_exc_saida;
              end;
              -- Atualiza com c�digo da ag�ncia igual a zero
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprfin,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprfin
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = 0
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 4
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            4,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qteprfin,
                            vr_tab_val(vr_indice_val).vr_vleprfin);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vleprfin por ag�ncia (acumulado): '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vleprfin por ag�ncia (acumulado): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
            -- Verifica se existe saldo devedor
            if vr_tab_val(vr_indice_val).vr_qtsdvlcr <> 0 then
              -- Atualiza usando o c�digo da ag�ncia
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvlcr
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 3
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            vr_tab_pac(vr_indice_pac).vr_codigo,
                            0,
                            3,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                            vr_tab_val(vr_indice_val).vr_vlsdvlcr);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vlsdvlcr para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vlsdvlcr para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                  raise vr_exc_saida;
              end;
              -- Atualiza com c�digo da ag�ncia igual a zero
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvlcr
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = 0
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 3
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            3,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                            vr_tab_val(vr_indice_val).vr_vlsdvlcr);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vlsdvlcr por ag�ncia (acumulado): '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vlsdvlcr por ag�ncia (acumulado): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
            -- Verifica se existe saldo devedor
            if vr_tab_val(vr_indice_val).vr_qtsdvfin <> 0 then
              -- Atualiza usando o c�digo da ag�ncia
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvfin,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvfin
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 5
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            vr_tab_pac(vr_indice_pac).vr_codigo,
                            0,
                            5,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qtsdvfin,
                            vr_tab_val(vr_indice_val).vr_vlsdvfin);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vlsdvfin para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vlsdvfin para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                  raise vr_exc_saida;
              end;
              -- Atualiza com c�digo da ag�ncia igual a zero
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvfin,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvfin
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = 0
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 5
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            5,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qtsdvfin,
                            vr_tab_val(vr_indice_val).vr_vlsdvfin);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vlsdvfin por ag�ncia (acumulado): '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vlsdvfin por ag�ncia (acumulado): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
            -- Verifica se existem valores de juros
            if vr_tab_val(vr_indice_val).vr_qtjurlcr <> 0 then
              -- Atualiza usando o c�digo da ag�ncia
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtjurlcr,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vljurlcr
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 6
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            vr_tab_pac(vr_indice_pac).vr_codigo,
                            0,
                            6,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qtjurlcr,
                            vr_tab_val(vr_indice_val).vr_vljurlcr);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vljurlcr para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vljurlcr para ag�ncia '||vr_tab_pac(vr_indice_pac).vr_codigo||': '||sqlerrm;
                  raise vr_exc_saida;
              end;
              -- Atualiza com c�digo da ag�ncia igual a zero
              begin
                update crapacc
                   set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtjurlcr,
                       crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vljurlcr
                 where crapacc.dtrefere = rw_crapdat.dtultdia
                   and crapacc.cdagenci = 0
                   and crapacc.cdempres = 0
                   and crapacc.tpregist = 6
                   and crapacc.cdlanmto = vr_cdlanmto
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
                            6,
                            vr_cdlanmto,
                            pr_cdcooper,
                            vr_tab_val(vr_indice_val).vr_qtjurlcr,
                            vr_tab_val(vr_indice_val).vr_vljurlcr);
                  exception
                    when others then
                      vr_dscritic := 'Erro ao inserir vr_vljurlcr por ag�ncia (acumulado): '||sqlerrm;
                      raise vr_exc_saida;
                  end;
                end if;
              exception
                when others then
                  vr_dscritic := 'Erro ao alterar vr_vljurlcr por ag�ncia (acumulado): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
          end if;  -- Fim do vr_flgmensa
        end loop;  -- Fim do FOR 1..9999
        -- Caso seja execu��o mensal
        if vr_flgmensa then
          -- Atualiza informa��es gerenciais
          begin
            update crapger
               set crapger.qtassoci = nvl(vr_tab_pac(vr_indice_pac).vr_qtassoci, 0),
                   crapger.qtautent = 0,
                   crapger.qtctacor = nvl(vr_tab_pac(vr_indice_pac).vr_qtctacor, 0),
                   crapger.qtplanos = nvl(vr_tab_pac(vr_indice_pac).vr_qtplanos, 0),
                   crapger.vlcaptal = nvl(vr_tab_pac(vr_indice_pac).vr_vlcaptal, 0),
                   crapger.vlplanos = nvl(vr_tab_pac(vr_indice_pac).vr_vlplanos, 0),
                   crapger.vlsmpmes = nvl(vr_tab_pac(vr_indice_pac).vr_vlsmpmes, 0),
                   crapger.qtassepr = nvl(vr_tab_pac(vr_indice_pac).vr_qtassepr, 0)
             where crapger.dtrefere = rw_crapdat.dtultdia
               and crapger.cdagenci = vr_tab_pac(vr_indice_pac).vr_codigo
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
                        vr_tab_pac(vr_indice_pac).vr_codigo,
                        0,
                        pr_cdcooper,
                        nvl(vr_tab_pac(vr_indice_pac).vr_qtassoci, 0),
                        0,
                        nvl(vr_tab_pac(vr_indice_pac).vr_qtctacor, 0),
                        nvl(vr_tab_pac(vr_indice_pac).vr_qtplanos, 0),
                        nvl(vr_tab_pac(vr_indice_pac).vr_vlcaptal, 0),
                        nvl(vr_tab_pac(vr_indice_pac).vr_vlplanos, 0),
                        nvl(vr_tab_pac(vr_indice_pac).vr_vlsmpmes, 0),
                        nvl(vr_tab_pac(vr_indice_pac).vr_qtassepr, 0),
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
                  vr_dscritic := 'Erro ao inserir informa��es gerenciais (crapger): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
          exception
            when others then
              vr_dscritic := 'Erro ao alterar informa��es gerenciais (crapger): '||sqlerrm;
              raise vr_exc_saida;
          end;
        end if;
        -- Atualiza controle de reprocesso
       /* begin
          update crapres
             set crapres.nrdconta = vr_tab_pac(vr_indice_pac).vr_codigo,
                 crapres.dsrestar = 'PAC'
           where crapres.cdprogra = vr_cdprogra
             and crapres.cdcooper = pr_cdcooper;
        exception
          when others then
            vr_dscritic := 'Erro ao atualizar controle de reprocesso: '||sqlerrm;
            raise vr_exc_saida;
        end;
        if sql%rowcount = 0 then
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(151);
          raise vr_exc_saida;
        end if;*/
      end if;

      --commit;

      vr_indice_pac := vr_tab_pac.next(vr_indice_pac);
    end loop;
  end if;
  -- Criacao dos registros crapacc por EMPRESA
  vr_indice_emp := vr_tab_emp.first;
  while vr_indice_emp is not null loop
    if (vr_tab_emp(vr_indice_emp).vr_codigo > vr_nrctares or
        nvl(vr_dsrestar, 'x') = 'PAC') and
       vr_tab_emp(vr_indice_emp).vr_tipo = 'E' then
      for vr_contador in 1..9999 loop
        if vr_contador = 9999 then
          vr_cdlanmto := 0;
        else
          vr_cdlanmto := vr_contador;
        end if;
        -- Monta o �ndice para tabela por empresa e verifica se existe informa��o
        vr_indice_val := 'E'||lpad(vr_tab_emp(vr_indice_emp).vr_codigo, 10, '0')||lpad(vr_contador, 5, '0');
        if not vr_tab_val.exists(vr_indice_val) then
          continue;
        end if;
        -- Verifica se existe lan�amento
        if vr_tab_val(vr_indice_val).vr_qtlanmto > 0 then
          -- Atualiza usando o c�digo da empresa
          begin
            update crapacc
               set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtlanmto,
                   crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vllanmto
             where crapacc.dtrefere = rw_crapdat.dtultdia
               and crapacc.cdagenci = 0
               and crapacc.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
               and crapacc.tpregist = 1
               and crapacc.cdlanmto = vr_cdlanmto
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
                        vr_tab_emp(vr_indice_emp).vr_codigo,
                        1,
                        vr_cdlanmto,
                        pr_cdcooper,
                        vr_tab_val(vr_indice_val).vr_qtlanmto,
                        vr_tab_val(vr_indice_val).vr_vllanmto);
              exception
                when others then
                  vr_dscritic := 'Erro ao inserir vr_vllanmto para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
          exception
            when others then
              vr_dscritic := 'Erro ao alterar vr_vllanmto para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
              raise vr_exc_saida;
          end;
          -- Atualiza com c�digo da empresa igual a 9999
          begin
            update crapacc
               set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtlanmto,
                   crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vllanmto
             where crapacc.dtrefere = rw_crapdat.dtultdia
               and crapacc.cdagenci = 0
               and crapacc.cdempres = 9999
               and crapacc.tpregist = 1
               and crapacc.cdlanmto = vr_cdlanmto
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
                        1,
                        vr_cdlanmto,
                        pr_cdcooper,
                        vr_tab_val(vr_indice_val).vr_qtlanmto,
                        vr_tab_val(vr_indice_val).vr_vllanmto);
              exception
                when others then
                  vr_dscritic := 'Erro ao inserir vr_vllanmto por empresa (acumulado): '||sqlerrm;
                  raise vr_exc_saida;
              end;
            end if;
          exception
            when others then
              vr_dscritic := 'Erro ao alterar vr_vllanmto por empresa (acumulado): '||sqlerrm;
              raise vr_exc_saida;
          end;
        end if;
        -- Caso seja execu��o mensal
        if vr_flgmensa then
          if vr_tab_val(vr_indice_val).vr_qteprlcr > 0 then
            -- Atualiza usando o c�digo da empresa
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprlcr,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprlcr
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
                 and crapacc.tpregist = 2
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          vr_tab_emp(vr_indice_emp).vr_codigo,
                          2,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qteprlcr,
                          vr_tab_val(vr_indice_val).vr_vleprlcr);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vleprlcr para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vleprlcr para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                raise vr_exc_saida;
            end;
            -- Atualiza com c�digo da empresa igual a 9999
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprlcr,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprlcr
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = 9999
                 and crapacc.tpregist = 2
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          2,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qteprlcr,
                          vr_tab_val(vr_indice_val).vr_vleprlcr);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vleprlcr por empresa (acumulado): '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vleprlcr por empresa (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
          -- Verifica se existe valor de empr�stimo ou financiamento
          if vr_tab_val(vr_indice_val).vr_qteprfin <> 0 then
            -- Atualiza usando o c�digo da empresa
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprfin,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprfin
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
                 and crapacc.tpregist = 4
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          vr_tab_emp(vr_indice_emp).vr_codigo,
                          4,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qteprfin,
                          vr_tab_val(vr_indice_val).vr_vleprfin);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vleprfin para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vleprfin para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                raise vr_exc_saida;
            end;
            -- Atualiza com c�digo da empresa igual a 9999
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qteprfin,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vleprfin
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = 9999
                 and crapacc.tpregist = 4
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          4,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qteprfin,
                          vr_tab_val(vr_indice_val).vr_vleprfin);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vleprfin por empresa (acumulado): '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vleprfin por empresa (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
          -- Verifica se existe valor de saldo devedor
          if vr_tab_val(vr_indice_val).vr_qtsdvlcr <> 0 then
            -- Atualiza usando o c�digo da empresa
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvlcr
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
                 and crapacc.tpregist = 3
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          vr_tab_emp(vr_indice_emp).vr_codigo,
                          3,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                          vr_tab_val(vr_indice_val).vr_vlsdvlcr);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vlsdvlcr para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vlsdvlcr para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                raise vr_exc_saida;
            end;
            -- Atualiza com c�digo da empresa igual a 9999
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvlcr
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = 9999
                 and crapacc.tpregist = 3
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          3,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtsdvlcr,
                          vr_tab_val(vr_indice_val).vr_vlsdvlcr);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vlsdvlcr por empresa (acumulado): '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vlsdvlcr por empresa (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
          -- Verifica se existe saldo devedor de financiamento
          if vr_tab_val(vr_indice_val).vr_qtsdvfin <> 0 then
            -- Atualiza usando o c�digo da empresa
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvfin,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvfin
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
                 and crapacc.tpregist = 5
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          vr_tab_emp(vr_indice_emp).vr_codigo,
                          5,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtsdvfin,
                          vr_tab_val(vr_indice_val).vr_vlsdvfin);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vlsdvfin para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vlsdvfin para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                raise vr_exc_saida;
            end;
            -- Atualiza com c�digo da empresa igual a 9999
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtsdvfin,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vlsdvfin
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = 9999
                 and crapacc.tpregist = 5
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          5,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtsdvfin,
                          vr_tab_val(vr_indice_val).vr_vlsdvfin);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vlsdvfin por empresa (acumulado): '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vlsdvfin por empresa (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
          -- Verifica se existem juros
          if vr_tab_val(vr_indice_val).vr_qtjurlcr <> 0 then
            -- Atualiza usando o c�digo da empresa
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtjurlcr,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vljurlcr
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
                 and crapacc.tpregist = 6
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          vr_tab_emp(vr_indice_emp).vr_codigo,
                          6,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtjurlcr,
                          vr_tab_val(vr_indice_val).vr_vljurlcr);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vljurlcr para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vljurlcr para empresa '||vr_tab_emp(vr_indice_emp).vr_codigo||': '||sqlerrm;
                raise vr_exc_saida;
            end;
            -- Atualiza com c�digo da empresa igual a 9999
            begin
              update crapacc
                 set crapacc.qtlanmto = crapacc.qtlanmto + vr_tab_val(vr_indice_val).vr_qtjurlcr,
                     crapacc.vllanmto = crapacc.vllanmto + vr_tab_val(vr_indice_val).vr_vljurlcr
               where crapacc.dtrefere = rw_crapdat.dtultdia
                 and crapacc.cdagenci = 0
                 and crapacc.cdempres = 9999
                 and crapacc.tpregist = 6
                 and crapacc.cdlanmto = vr_cdlanmto
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
                          6,
                          vr_cdlanmto,
                          pr_cdcooper,
                          vr_tab_val(vr_indice_val).vr_qtjurlcr,
                          vr_tab_val(vr_indice_val).vr_vljurlcr);
                exception
                  when others then
                    vr_dscritic := 'Erro ao inserir vr_vljurlcr por empresa (acumulado): '||sqlerrm;
                    raise vr_exc_saida;
                end;
              end if;
            exception
              when others then
                vr_dscritic := 'Erro ao alterar vr_vljurlcr por empresa (acumulado): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        end if;  -- Fim do vr_flgmensa
      end loop;  -- Fim do FOR 1..9999
      -- Caso seja execu��o mensal
      if vr_flgmensa then
        -- Atualiza informa��es gerenciais
        begin
          update crapger
             set crapger.qtassoci = nvl(vr_tab_emp(vr_indice_emp).vr_qtassoci, 0),
                 crapger.qtautent = 0,
                 crapger.qtctacor = nvl(vr_tab_emp(vr_indice_emp).vr_qtctacor, 0),
                 crapger.qtplanos = nvl(vr_tab_emp(vr_indice_emp).vr_qtplanos, 0),
                 crapger.vlcaptal = nvl(vr_tab_emp(vr_indice_emp).vr_vlcaptal, 0),
                 crapger.vlplanos = nvl(vr_tab_emp(vr_indice_emp).vr_vlplanos, 0),
                 crapger.vlsmpmes = nvl(vr_tab_emp(vr_indice_emp).vr_vlsmpmes, 0),
                 crapger.qtassepr = nvl(vr_tab_emp(vr_indice_emp).vr_qtassepr, 0)
           where crapger.dtrefere = rw_crapdat.dtultdia
             and crapger.cdagenci = 0
             and crapger.cdempres = vr_tab_emp(vr_indice_emp).vr_codigo
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
                      vr_tab_emp(vr_indice_emp).vr_codigo,
                      pr_cdcooper,
                      nvl(vr_tab_emp(vr_indice_emp).vr_qtassoci, 0),
                      0,
                      nvl(vr_tab_emp(vr_indice_emp).vr_qtctacor, 0),
                      nvl(vr_tab_emp(vr_indice_emp).vr_qtplanos, 0),
                      nvl(vr_tab_emp(vr_indice_emp).vr_vlcaptal, 0),
                      nvl(vr_tab_emp(vr_indice_emp).vr_vlplanos, 0),
                      nvl(vr_tab_emp(vr_indice_emp).vr_vlsmpmes, 0),
                      nvl(vr_tab_emp(vr_indice_emp).vr_qtassepr, 0),
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
                vr_dscritic := 'Erro ao inserir informa��es gerenciais (crapger): '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
        exception
          when others then
            vr_dscritic := 'Erro ao alterar informa��es gerenciais (crapger): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end if;
      -- Atualiza o controle de reprocesso
      /*begin
        update crapres
           set crapres.nrdconta = vr_tab_emp(vr_indice_emp).vr_codigo,
               crapres.dsrestar = 'EMPRESA'
         where crapres.cdprogra = vr_cdprogra
           and crapres.cdcooper = pr_cdcooper;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar controle de reprocesso: '||sqlerrm;
          raise vr_exc_saida;
      end;
      if sql%rowcount = 0 then
        vr_cdcritic := 151;
        vr_dscritic := gene0001.fn_busca_critica(151);
        raise vr_exc_saida;
      end if;*/
    end if;

    --commit;

    vr_indice_emp := vr_tab_emp.next(vr_indice_emp);
  end loop;
  -- Procedimento para eliminar o controle de reprocesso, pois o programa chegou ao fim
  btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_dscritic);
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;

  -- chamamos a fimprg para encerrarmos o processo sem parar a cadeia
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Gravar as informa��es
  commit;

exception
  when vr_exc_fimprg then
    -- se foi retornado apenas c�digo
    if nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
      -- buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- efetuar commit pois gravaremos o que foi processo at� ent�o
    commit;

  when vr_exc_saida then
    -- se foi retornado apenas c�digo
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- devolvemos c�digo e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- efetuar rollback
    rollback;
  when others then
    -- efetuar retorno do erro n�o tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- efetuar rollback
    rollback;
end pc_crps133;
/

