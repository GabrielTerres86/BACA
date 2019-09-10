CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS008(pr_cdcooper  IN NUMBER                --> Cooperativa
                                             ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo Agencia 
                                             ,pr_idparale  IN crappar.idparale%TYPE --> Indicador de processoparalelo
                                             ,pr_stprogra  OUT PLS_INTEGER          --> Saída de termino da execução
                                             ,pr_infimsol  OUT PLS_INTEGER          --> Saída de termino da solicitação
                                             ,pr_cdcritic  OUT NUMBER               --> Código crítica
                                             ,pr_dscritic  OUT VARCHAR2) IS         --> Descrição crítica
  BEGIN

  /* .............................................................................

   Programa: pc_crps008                      Antigo: Fontes/crps008.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 23/04/2019

   Dados referentes ao programa:

   Frequencia: Mensal (Batch)
   Objetivo  : Atualizar mensalmente os saldos (anterior e extrato) e cobrar
               os juros sobre os saldos medios negativos. Atende a solicita-
               cao 003 (Mensal de atualizacao).

   Alteracoes: 08/08/94 - Alterado para somar na base do ipmf o valor do lanca-
                          mento para os casos onde o valor do ipmf seja zerado
                          (Edson).

               14/11/94 - Alterado para  gerar lancamento de juros de saque s/
                          bloqueado (Deborah).

               16/12/94 - Alterado para nao cobrar IPMF depois de 31/12/94
                          (Deborah).

               17/02/95 - Alterado para nao calcular juros para as contas que
                          tenham inpessoa = 3.

               10/03/95 - Alterado para utilizar a moeda fixa do proximo
                          movimento (Odair).

               14/01/97 - Alterado para tratar CPMF (Deborah).

               09/07/97 - Tratar extrato quinzenal (Odair)

               16/02/98 - Alterar a data final da CPMF (Odair)

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/01/99 - Alteracao para cobranca do IOF (Deborah).

               01/02/99 - Deve atualizar a base do IOF, mesmo quando o valor
                          do IOF eh zero. (Deborah).

               12/03/1999 - Alterado para calcular mas nao debitar IOF no
                            ultimo dia do mes (Deborah).

               07/06/1999 - Tratar CPMF (Deborah).

               07/10/1999 - Aumentado o numero de casas decimais nas taxas
                            (Edson).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               26/08/2003 - Mudanca no calculo do bloqueado (Deborah).

               11/02/2004 - Atualizar campo crapsld.dtrefext (Edson).

               23/06/2004 - Tratar novos campos no crapsld (Edson).

               23/09/2004 - Efetuar virada mensal cad.crapsli(Mirtes).

               10/05/2005 - Ajustar o saldo diario historico (crapsda) (Edson).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, crapipm, crapneg e crapsli (Diego).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               08/06/2006 - Atualizacao no tratamento do campo crapper.dtfimper
                            , esta data pode ser um feriado ou fim de semana
                            (Julio)

               23/10/2006 - FOR EACH crapper, reparo no tratamentos do dtfimper
                            para quando nao cair em dia util (Julio)

               12/02/2007 - Efetuada modificacao para nova estrutura crapneg
                            (Diego).

               24/04/2007 - Substituir craptab "JUROSESPEC" pelo craplrt (Ze).

               31/10/2007 - Melhorada mensagem de taxa nao cadastrada (Magui).

               15/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).

               28/01/2008 - Alterar logica para cobranca de IOF (David).

               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela craphis(Guilherme).

               29/01/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               09/08/2013 - Inclusão de teste na pr_flgresta antes de
                            controlar o restart (Marcos-Supero)

               14/10/2013 - Ajuste no controle de criticas (Gabriel)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart
                           (Marcos-Supero)

               21/01/2014 - Ajustes no povoamento da pltable vr_tab_crapsld
                            para gravar o campo nrdconta, pois antes não estava sendo
                            gravado e isto fazia com que o update dentro da forall
                            desta pltable não atualizasse nenhum registro (Marcos-Supero)
                            
               02/05/2014 - Ajuste na lógica para uasar a fn_sequence na criação da crapneg
                            pois estávamos perdendo o sequenciamento correto na crapsqu
                            (Marcos-Supero)

               21/10/2014 - Retirado a cobranca de jutos de limite de credito e colocado
                            no crps0001 (Jean Michel).            

               02/06/2015 - Ajuste na gravacao do crapsld.dtrisclq. (James)

               28/08/2015 - Retirada de registros de memória e tratamentos no processamento para  
                            sanar o problema de estouro de memória na execução do programa na 
                            mensal. ( Renato - Supero )

               29/10/2015 - Inclusao do pr_cdcooper na pc_informa_acesso.
                            (Jaison/Andrino - PRJ Estado de Crise)

               21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                            (Carlos Rafael Tanholi).   
                            
               05/07/2016 - Tratamento na rotina de validação do limite de credito, removendo
                            o raise e gerando apenas erro no log, conforme solicitacao do Daniel
                            (Carlos Rafael Tanholi).             
                            
               01/03/2017 - Incluir criação de craplau caso cooperado nao tenha saldo para 
                            efetuar lançamentos para o historico 37 (Lucas Ranghetti M338.1)
                            
               03/04/2017 - Ajuste no calculo do IOF, incluir calculo da taxa adicional do IOF.
                            (Odirlei-AMcom)

               26/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel.
                            Heitor (Mouts) - Melhoria 440

               05/06/2017 - Ajustes para incrementar/zerar variaveis quando craplau também
                            (Lucas Ranghetti/Thiago Rodrigues)
                            
               21/11/2017 - Adequar a cobranca de IOF para a nova legislacao. (James)   
                                                 
               19/01/2018 - Corrigido cálculo de saldo bloqueado (Luis Fernando-Gft)                                 

               19/03/2018 - Consistencia para considerar dias úteis ou corridos na 
                            atualização do saldo - Daniel(AMcom)		

               28/06/2018 - Projeto Revitalização Sistemas - Transformação do programa
			                em paralelo por Agência - Andreatta (MOUTs)
                            
               06/08/2018 - Inclusao de maiores detalhes nos logs de erros - Andreatta (MOUTs) 

               05/11/2018 - Correção de erro na composição do saldo após débito do histórico 37 (Reginaldo/AMcom/P450)
                            
               23/04/2019 - Inclusão da chamada a TIOF0001.pc_insere_iof ao incrementar o valor do IOF no campo vliofmes
                            (PRJ410 - SM - Douglas Pagel / AMcom)
                            
     ............................................................................. */

     DECLARE
       
       --- ################################ Variáveis ################################# ----
       
       --Variaveis das taxas de juros
       vr_txjurneg  NUMBER:= 0;
       vr_txjursaq  NUMBER:= 0;
       vr_txipmneg  NUMBER:= 0;
       vr_txipmsaq  NUMBER:= 0;

       --Variaveis do iof
       vr_vlbasiof  NUMBER:= 0;
       vr_dtinifis  DATE;
       vr_dtfimfis  DATE;

       vr_dtrisclq_aux DATE;
	     vr_dtcorte_prm  DATE;

       vr_qtddsdev_aux  NUMBER:= 0;
       
       -- Variáveis acumulo lote 8450
       vr_vlinfocr craplot.vlinfocr%type := 0;
       vr_vlcompcr craplot.vlcompcr%type := 0; 
       vr_vlinfodb craplot.vlinfodb%type := 0;
       vr_vlcompdb craplot.vlcompcr%type := 0;     
       vr_qtinfoln craplot.vlcompdb%type := 0;
       vr_qtcompln craplot.qtcompln%type := 0;  
       
       
       -- Variáveis acumulo lote 8476
       vr_vlinfocr_ajt craplot.vlinfocr%type := 0;
       vr_vlcompcr_ajt craplot.vlcompcr%type := 0; 
       vr_vlinfodb_ajt craplot.vlinfodb%type := 0;
       vr_vlcompdb_ajt craplot.vlcompcr%type := 0;     
       vr_qtinfoln_ajt craplot.vlcompdb%type := 0;
       vr_qtcompln_ajt craplot.qtcompln%type := 0; 

       --Variaveis do ipmf
       vr_vlbasipm  NUMBER:= 0;
       vr_vldoipmf  NUMBER:= 0;
       vr_vldjuros  NUMBER:= 0;
       vr_vlajulcm  NUMBER:= 0;
       vr_vlajuipm  NUMBER:= 0;
       vr_txcpmfcc  NUMBER:= 0;
       vr_txrdcpmf  NUMBER:= 0;
       vr_indabono  NUMBER:= 0;
       vr_dtinipmf  DATE;
       vr_dtfimpmf  DATE;
       vr_dtiniabo  DATE;

       --Totalizadores
       vr_tot_vlsldant  NUMBER:= 0;
       vr_tot_vlsldatu  NUMBER:= 0;

       --Variaveis para calculo saldo
       vr_vlsldant  NUMBER:= 0;
       vr_vlsldatu  NUMBER:= 0;
       vr_qtddsdev  NUMBER:= 0;
       vr_nrseqneg  NUMBER:= 0;
       vr_mesmovto  NUMBER:= 0;
       vr_vlsldolt  NUMBER:= 0;
       vr_vlsldoan  NUMBER:= 0;
       vr_crapcot   ROWID;

       --Variaveis de controle do programa
       vr_flgencer   BOOLEAN;
       vr_flghaneg   BOOLEAN;
       vr_flgajust   BOOLEAN;
       vr_flgdcpmf   BOOLEAN;
       vr_cdprogra   VARCHAR2(10);
       vr_cdcritic   NUMBER:= 0;
       vr_dscritic   VARCHAR2(2000);
       vr_idx        PLS_INTEGER := 0;

       --Variavel para cálculo juros
       vr_qtjurmfx  crapcot.qtjurmfx%TYPE;

       --Variaveis de Excecao
       vr_exc_fim     EXCEPTION;
       vr_exc_saida   EXCEPTION;

       -- Guardar registro dstextab
       vr_dstextab craptab.dstextab%TYPE;       

       vr_des_erro  VARCHAR2(100);
       vr_nrseqdig NUMBER:= 0;
       vr_idlancto NUMBER;
       vr_vlsddisp NUMBER;
       vr_qtdiacor NUMBER;
       vr_vliofpri NUMBER := 0; --> valor do IOF principal
       vr_vliofadi NUMBER := 0; --> valor do IOF adicional
       vr_vliofcpl NUMBER := 0; --> valor do IOF complementar
       vr_flgimune PLS_INTEGER;
       vr_vltaxa_iof_principal NUMBER := 0;
       vr_natjurid crapjur.natjurid%TYPE;
       vr_tpregtrb crapjur.tpregtrb%TYPE;
       
       -- Dados de lote
       vr_cdagenci craplot.cdagenci%TYPE := 1;
       vr_cdbccxlt craplot.cdbccxlt%TYPE := 100;
       vr_nrdolote craplot.nrdolote%TYPE := 8450;       
       vr_nrdolote_ajt craplot.nrdolote%TYPE := 8476;
       
       --- ################################ Tipos e Registros de memória ################################# ----
       
       -- Definicao do tipo de registro de lançamentos
       TYPE typ_reg_craplcm IS
       RECORD (dtmvtolt craplcm.dtmvtolt%TYPE
              ,cdagenci craplcm.cdagenci%TYPE
              ,cdbccxlt craplcm.cdbccxlt%TYPE
              ,nrdolote craplcm.nrdolote%TYPE
              ,vllanmto craplcm.vllanmto%TYPE
              ,vrrowid  rowid);

       -- Definicao do tipo de registro de associado juridico
       TYPE typ_reg_crapjur IS
       RECORD (natjurid crapjur.natjurid%TYPE
              ,tpregtrb crapjur.tpregtrb%TYPE);    
             
       -- Definicao do tipo de tabela de linhas credito
       TYPE typ_tab_craplrt IS
         TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

       -- Definicao do tipo de tabela de lançamentos
       TYPE typ_tab_craplcm IS
         TABLE OF typ_reg_craplcm
         INDEX BY PLS_INTEGER;

       -- Definição do tipo de registro de saldos
       TYPE typ_tab_crapsld IS
         TABLE OF crapsld%ROWTYPE
       INDEX BY PLS_INTEGER;
       
       -- Definicao do tipo de tabela de associados juridicos
       TYPE typ_tab_crapjur IS
         TABLE OF typ_reg_crapjur
       INDEX BY BINARY_INTEGER;  

       -- Definicao do vetor de memoria
       vr_tab_craplrt  typ_tab_craplrt;
       vr_tab_craplcm  typ_tab_craplcm;
       vr_tab_crapsld  typ_tab_crapsld;
       vr_tab_crapjur  typ_tab_crapjur;
       
       --Tipo da tabela de saldos
       vr_tab_saldo EXTR0001.typ_tab_saldos;
       vr_tab_erro  GENE0001.typ_tab_erro;
    
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

       -- variaveis para rotina de debito
       vr_tab_retorno   lanc0001.typ_reg_retorno;
       vr_incrineg      INTEGER;      -- Indicador de crítica do negócio

       --- ################################ CURSORES ################################# ----

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       
       -- Cursor genérico de calendário
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
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

       -- Selecionar dados da tabela de historicos
       CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE
                         ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
         SELECT craphis.cdhistor
               ,craphis.inhistor
               ,craphis.indebcre
               ,craphis.indoipmf
         FROM craphis craphis
         WHERE craphis.cdcooper = pr_cdcooper
         AND   craphis.cdhistor = pr_cdhistor;
       rw_craphis cr_craphis%ROWTYPE;

       -- Selecionar informacoes dos periodos
       CURSOR cr_crapper (pr_cdcooper IN crapper.cdcooper%TYPE
                         ,pr_dtiniper IN crapper.dtfimper%TYPE
                         ,pr_dtfimper IN crapper.dtfimper%TYPE
                         ,pr_infimper IN crapper.infimper%TYPE) IS
         SELECT crapper.ROWID
               ,crapper.dtdebito
         FROM crapper crapper
         WHERE crapper.cdcooper = pr_cdcooper
         AND   crapper.dtfimper > pr_dtiniper
         AND   crapper.dtfimper < pr_dtfimper
         AND   crapper.infimper = pr_infimper;
       rw_crapper cr_crapper%ROWTYPE;

       -- Selecionar informacoes da moeda
       CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                         ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
         SELECT crapmfx.ROWID
               ,crapmfx.vlmoefix
         FROM crapmfx crapmfx
         WHERE crapmfx.cdcooper = pr_cdcooper
         AND   crapmfx.dtmvtolt = pr_dtmvtolt
         AND   crapmfx.tpmoefix = pr_tpmoefix;
       rw_crapmfx cr_crapmfx%ROWTYPE;

       -- Selecionar informacoes dos saldos dos associados
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE
                         ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE
                         ,pr_dtmvtoan IN crapsda.dtmvtolt%TYPE) IS
         SELECT /*+ NOPARALLEL */
                crapsld.nrdconta     nrdconta
              , crapsld.vljuresp     vljuresp
              , crapsld.vljurmes     vljurmes
              , crapsld.vljursaq     vljursaq
              , crapsld.vlsmnesp     vlsmnesp
              , crapsld.vlsddisp     vlsddisp
              , crapsld.vlsdchsl     vlsdchsl
              , crapsld.qtjramfx     qtjramfx
              , crapsld.vlsmnmes     vlsmnmes
              , crapsld.vlsmnblq     vlsmnblq
              , crapsld.vlsdbloq     vlsdbloq
              , crapsld.vlsdblpr     vlsdblpr
              , crapsld.vlsdblfp     vlsdblfp
              , crapsld.qtlanmes     qtlanmes
              , crapsld.vlipmfpg     vlipmfpg
              , crapsld.vlipmfap     vlipmfap
              , crapsld.vlbasipm     vlbasipm
              , crapsld.qtddsdev     qtddsdev
              , crapsld.qtddtdev     qtddtdev
              , crapsld.qtdriclq     qtdriclq
              , crapsld.dtrisclq     dtrisclq
              , crapsld.dtdsdclq     dtdsdclq
              , crapsld.vldisext     vldisext
              , crapsld.vlblqext     vlblqext
              , crapsld.vlblpext     vlblpext
              , crapsld.vlblfext     vlblfext
              , crapsld.vlchsext     vlchsext
              , crapsld.vlindext     vlindext
              , crapsld.vldisant     vldisant
              , crapsld.vlblqant     vlblqant
              , crapsld.vlblpant     vlblpant
              , crapsld.vlblfant     vlblfant
              , crapsld.vlchsant     vlchsant
              , crapsld.vlindant     vlindant
              , crapsld.vlsdextr     vlsdextr
              , crapsld.vltsalan     vltsalan
              , crapsld.vlsdmesa     vlsdmesa
              , crapsld.dtrefext     dtrefext
              , crapsld.dtsdexes     dtsdexes
              , crapsld.dtsdanes     dtsdanes
              , crapsld.vlsdexes     vlsdexes
              , crapsld.vlsdanes     vlsdanes
              , crapsld.qtsmamfx     qtsmamfx
              , crapsld.vlsdindi     vlsdindi
              , crapsld.vltsallq     vltsallq
              , crapsld.vlsmpmes     vlsmpmes
              , crapsld.qtlanano     qtlanano
              , crapsld.vlbasiof     vlbasiof
              , crapsld.vliofmes     vliofmes
              , crapsld.vlsmstre##1  vlsmstre##1
              , crapsld.vlsmstre##2  vlsmstre##2
              , crapsld.vlsmstre##3  vlsmstre##3
              , crapsld.vlsmstre##4  vlsmstre##4
              , crapsld.vlsmstre##5  vlsmstre##5
              , crapsld.vlsmstre##6  vlsmstre##6
              , crapsld.smposano##1  smposano##1
              , crapsld.smposano##2  smposano##2
              , crapsld.smposano##3  smposano##3
              , crapsld.smposano##4  smposano##4
              , crapsld.smposano##5  smposano##5
              , crapsld.smposano##6  smposano##6
              , crapsld.smposano##7  smposano##7
              , crapsld.smposano##8  smposano##8
              , crapsld.smposano##9  smposano##9
              , crapsld.smposano##10 smposano##10
              , crapsld.smposano##11 smposano##11
              , crapsld.smposano##12 smposano##12
              , crapsld.smnegano##1  smnegano##1
              , crapsld.smnegano##2  smnegano##2
              , crapsld.smnegano##3  smnegano##3
              , crapsld.smnegano##4  smnegano##4
              , crapsld.smnegano##5  smnegano##5
              , crapsld.smnegano##6  smnegano##6
              , crapsld.smnegano##7  smnegano##7
              , crapsld.smnegano##8  smnegano##8
              , crapsld.smnegano##9  smnegano##9
              , crapsld.smnegano##10 smnegano##10
              , crapsld.smnegano##11 smnegano##11
              , crapsld.smnegano##12 smnegano##12
              , crapsld.smblqano##1  smblqano##1
              , crapsld.smblqano##2  smblqano##2
              , crapsld.smblqano##3  smblqano##3
              , crapsld.smblqano##4  smblqano##4
              , crapsld.smblqano##5  smblqano##5
              , crapsld.smblqano##6  smblqano##6
              , crapsld.smblqano##7  smblqano##7
              , crapsld.smblqano##8  smblqano##8
              , crapsld.smblqano##9  smblqano##9
              , crapsld.smblqano##10 smblqano##10
              , crapsld.smblqano##11 smblqano##11
              , crapsld.smblqano##12 smblqano##12
              , crapsld.smespano##1  smespano##1
              , crapsld.smespano##2  smespano##2
              , crapsld.smespano##3  smespano##3
              , crapsld.smespano##4  smespano##4
              , crapsld.smespano##5  smespano##5
              , crapsld.smespano##6  smespano##6
              , crapsld.smespano##7  smespano##7
              , crapsld.smespano##8  smespano##8
              , crapsld.smespano##9  smespano##9
              , crapsld.smespano##10 smespano##10
              , crapsld.smespano##11 smespano##11
              , crapsld.smespano##12 smespano##12
              , crapsld.rowid
               -- CAMPOS DA CRAPASS
              , crapass.nrdconta     ass_nrdconta
              , crapass.vllimcre     ass_vllimcre
              , crapass.tpextcta     ass_tpextcta
              , crapass.inpessoa     ass_inpessoa
              , crapass.inprejuz     ass_inprejuz
               -- CAMPOS DE INFORMAÇÃO DO SALDO DIÁRIO DOS ASSOCIADOS
              , sda_oan.vlsddisp     vlsldoan
              , sda_olt.vlsddisp     vlsldolt 
               -- CAMPOS COM INFORMAÇÕES DE COTAS E RECURSOS
              , crapcot.ROWID        rowidcot
           FROM crapcot    crapcot
              , crapsda    sda_oan -- Saldos baseados na data anterior
              , crapsda    sda_olt -- Saldos baseados na data atual
              , crapass    crapass
              , crapsld    crapsld
          WHERE crapcot.nrdconta(+) = crapsld.nrdconta
            AND crapcot.cdcooper(+) = crapsld.cdcooper
            AND sda_oan.dtmvtolt(+) = pr_dtmvtoan
            AND sda_olt.dtmvtolt(+) = pr_dtmvtolt
            AND sda_oan.nrdconta(+) = crapsld.nrdconta
            AND sda_oan.cdcooper(+) = crapsld.cdcooper
            AND sda_olt.nrdconta(+) = crapsld.nrdconta 
            AND sda_olt.cdcooper(+) = crapsld.cdcooper
            AND crapass.cdcooper(+) = crapsld.cdcooper
            AND crapass.nrdconta(+) = crapsld.nrdconta   
            AND crapass.cdcooper(+) = crapsld.cdcooper   
            AND crapass.cdagenci    = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
            AND crapsld.cdcooper    = pr_cdcooper;  
       -- PLTABLE para fazer bulk collect e acelerar as leituras  
       TYPE typ_CRAPSLD IS TABLE OF cr_crapsld%ROWTYPE INDEX BY PLS_INTEGER;
       rw_crapsld typ_CRAPSLD;              

       -- Selecionar contratos de limites de creditos
       CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE
                         ,pr_nrdconta IN craplim.nrdconta%TYPE
                         ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                         ,pr_insitlim IN craplim.insitlim%TYPE) IS
         SELECT *
           FROM (SELECT craplim.nrdconta
                       ,craplim.cddlinha
                       ,craplim.dtinivig
                       ,craplim.vllimite
                       ,rownum nrlinha
                 FROM craplim craplim
                 WHERE  craplim.cdcooper = pr_cdcooper
                 AND    craplim.nrdconta = pr_nrdconta
                 AND    craplim.tpctrlim = pr_tpctrlim
                 AND    craplim.insitlim = pr_insitlim
                 ORDER BY craplim.cdcooper
                        , craplim.nrdconta
                        , craplim.dtinivig
                        , craplim.tpctrlim
                        , craplim.nrctrlim)
          ORDER BY nrlinha DESC;  -- Order by realizado para simular o FIND LAST do progress
       rw_craplim cr_craplim%ROWTYPE;
 
       -- Selecionar Cadastro de linhas de credito rotativos
       CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE) IS
         SELECT craplrt.ROWID
               ,craplrt.cddlinha
               ,craplrt.qtdiavig
               ,craplrt.txmensal
         FROM craplrt  craplrt
         WHERE  craplrt.cdcooper = pr_cdcooper;
       rw_craplrt cr_craplrt%ROWTYPE;

       -- Selecionar informacoes dos lançamentos da conta
       CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE
                         ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                         ,pr_cdhistor IN craplcm.cdhistor%TYPE) IS
         SELECT /*+ INDEX (craplcm craplcm##craplcm4) */
                craplcm.cdhistor
               ,craplcm.vllanmto
               ,craplcm.nrdconta
               ,craplcm.nrdocmto
               ,craplcm.dtmvtolt
               ,craplcm.nrdctabb
               ,craplcm.cdbanchq
               ,craplcm.cdagechq
               ,craplcm.nrctachq
               ,craplcm.nrdctitg
               ,craplcm.cdpesqbb
               ,craplcm.cdoperad
               ,craplcm.vldoipmf
               ,craplcm.cdcooper
               ,craplcm.cdagenci
               ,craplcm.cdbccxlt
               ,craplcm.nrdolote
               ,craplcm.ROWID
         FROM craplcm craplcm
             ,crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = craplcm.nrdconta
           AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
           AND craplcm.cdcooper = pr_cdcooper
           AND craplcm.dtmvtolt = pr_dtmvtolt
           AND craplcm.cdhistor = pr_cdhistor;
       rw_craplcm cr_craplcm%ROWTYPE;

       -- Selecionar saldos negativos
       CURSOR cr_crapneg2 (pr_cdcooper  IN crapneg.cdcooper%TYPE
                          ,pr_nrdconta  IN crapneg.nrdconta%TYPE
                          ,pr_cdhisest  IN crapneg.cdhisest%TYPE
                          ,pr_vlestour  IN crapneg.vlestour%TYPE) IS
         SELECT crapneg.ROWID
               ,crapneg.nrseqdig
         FROM crapneg crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
         AND   crapneg.nrdconta = pr_nrdconta
         AND   crapneg.cdhisest = pr_cdhisest
         AND   crapneg.vlestour = pr_vlestour
       ORDER BY cdcooper, nrdconta, nrseqdig DESC;
       rw_crapneg2 cr_crapneg2%ROWTYPE;

      -- Controle de cobranca de lancamentos futuros em conta corrente
      CURSOR cr_tbcc_lautom_controle(pr_idlancto IN NUMBER) IS
        SELECT 1
          FROM tbcc_lautom_controle tbcc
         WHERE tbcc.idlautom = pr_idlancto;
        rw_tbcc_lautom_controle cr_tbcc_lautom_controle%ROWTYPE;
        
      -- Selecionar informacoes dos associados juridico
      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                        ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT jur.natjurid
              ,jur.tpregtrb
              ,jur.nrdconta
          FROM crapjur jur
              ,crapass ass
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.cdcooper = ass.cdcooper
           AND jur.nrdconta = ass.nrdconta
           AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci); 
     
      -- Cursor para buscar valores e atualizar a capa do lote na tabela l            
      cursor cr_work_lot(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
        select sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) vlinfocr,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vlcompcr,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) vlinfodb,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vlcompdb,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))) qtinfoln,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,6)+1,instr(a.dscritic,';',1,7)-instr(a.dscritic,';',1,6)-1))) qtcompln
          from tbgen_batch_relatorio_wrk a
         where a.cdcooper    = pr_cdcooper
           and a.cdprograma  = pr_cdprograma
           and a.dsrelatorio = pr_dsrelatorio
           and a.dtmvtolt    = pr_dtmvtolt;    
      vr_tab_work_lot cr_work_lot%rowtype; 
     
     ---------------------------------------
     -- Inicio Bloco Principal pc_crps008
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS008';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS008'
                                 ,pr_action => pr_cdcooper);
                                 
       -- Na execução principal
       if nvl(pr_idparale,0) = 0 then
         -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
         vr_idlog_ini_ger := null;
         pc_log_programa(pr_dstiplog   => 'I'    
                        ,pr_cdprograma => vr_cdprogra          
                        ,pr_cdcooper   => pr_cdcooper
                        ,pr_tpexecucao => 1    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        ,pr_idprglog   => vr_idlog_ini_ger);
       end if;                                 

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada para a cooperativa
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE btch0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE btch0001.cr_crapdat;
       END IF;

       -- Calcular ultimo dia do mes anterior conforme versão anterior
       rw_crapdat.dtultdia := Last_Day(Add_Months(rw_crapdat.dtmvtopr,-1));

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;
       
       -- Buscar quantidade parametrizada de Jobs
       vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper   --> Código da coopertiva
                                                    ,vr_cdprogra); --> Código do programa
       
       /* Paralelismo visando performance Rodar Somente no processo Noturno */
       if rw_crapdat.inproces > 2 AND vr_qtdjobs > 0 and pr_cdagenci = 0 then  
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
         for rw_age in cr_crapage (pr_cdcooper
                                  ,vr_cdprogra
                                  ,vr_qterro
                                  ,rw_crapdat.dtmvtolt) loop
                                               
           -- Montar o prefixo do código do programa para o jobname
           vr_jobname := vr_cdprogra ||'_'|| rw_age.cdagenci || '$';  
         
           -- Cadastra o programa paralelo
           gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                     ,pr_idprogra => LPAD(rw_age.cdagenci,3,'0') --> Utiliza a agência como id programa
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
                      || '  PC_CRPS008('|| pr_cdcooper 
                      || '            ,'|| rw_age.cdagenci 
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
         
         EXECUTE IMMEDIATE 'alter session set sort_area_size = 1048576000';
       
         if pr_cdagenci <> 0 then
           vr_tpexecucao := 2;
         else
           vr_tpexecucao := 1;
         end if;    
         
         -- Grava controle de batch por agência
         gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper      -- Codigo da Cooperativa
                                         ,pr_cdprogra    => vr_cdprogra      -- Codigo do Programa
                                         ,pr_dtmvtolt    => rw_crapdat.dtmvtolt  -- Data de Movimento
                                         ,pr_tpagrupador => 1                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                         ,pr_cdagrupador => pr_cdagenci      -- Codigo do agrupador conforme (tpagrupador)
                                         ,pr_cdrestart   => null             -- Controle do registro de restart em caso de erro na execucao
                                         ,pr_nrexecucao  => 1                -- Numero de identificacao da execucao do programa
                                         ,pr_idcontrole  => vr_idcontrole    -- ID de Controle
                                         ,pr_cdcritic    => pr_cdcritic      -- Codigo da critica
                                         ,pr_dscritic    => vr_dscritic);    -- Descricao da critica
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
       
       
         -- Procedimento padrão de busca de informações de CPMF
         gene0005.pc_busca_cpmf(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_dtinipmf => vr_dtinipmf
                               ,pr_dtfimpmf => vr_dtfimpmf
                               ,pr_txcpmfcc => vr_txcpmfcc
                               ,pr_txrdcpmf => vr_txrdcpmf
                               ,pr_indabono => vr_indabono
                               ,pr_dtiniabo => vr_dtiniabo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
         -- Se retornou erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar raise
           RAISE vr_exc_saida;
         END IF;
         
         -- Buscar data parametro de referencia para calculo de juros
         BEGIN  
           vr_dtcorte_prm := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                               ,pr_nmsistem => 'CRED'
                                                               ,pr_cdacesso => 'DT_CORTE_REGCRE')
                                                               ,'DD/MM/RRRR');
        
         EXCEPTION
           WHEN OTHERS THEN
             vr_dtcorte_prm := rw_crapdat.dtmvtolt;
         END; 

         --Carregar tabela memoria com as linhas de credito
         FOR rw_craplrt IN cr_craplrt (pr_cdcooper => pr_cdcooper) LOOP
           vr_tab_craplrt(rw_craplrt.cddlinha):= rw_craplrt.txmensal;
         END LOOP;
         
         --Carregar tabela memoria de associados
         FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci) LOOP
           vr_tab_crapjur(rw_crapjur.nrdconta).natjurid := rw_crapjur.natjurid;
           vr_tab_crapjur(rw_crapjur.nrdconta).tpregtrb := rw_crapjur.tpregtrb;
         END LOOP;

         --Se a data do movimento estiver entre a data de inicio e fim da cpmf
         IF rw_crapdat.dtmvtolt BETWEEN vr_dtinipmf AND vr_dtfimpmf THEN
           -- flag cpmf recebe true
           vr_flgdcpmf:= TRUE;
         ELSE
           -- flag cpmf recebe false
           vr_flgdcpmf:= FALSE;
         END IF;

         -- Carrega a taxa da CPMF para os juros do cheque especial
         OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                         ,pr_cdhistor => 38) ;
         -- Posicionar no proximo registro
         FETCH cr_craphis INTO rw_craphis;
         -- Se nao encontrar
         IF cr_craphis%NOTFOUND THEN
           -- Buscar mensagem de erro da critica
           vr_cdcritic := 93;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' HST 38';
           -- Fechar Cursor
           CLOSE cr_craphis;
           -- Sair do programa
           RAISE vr_exc_saida;
         END IF;
         -- Fechar Cursor
         CLOSE cr_craphis;

         -- Carrega a taxa da CPMF para a multa sobre o conta corrente
         OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                         ,pr_cdhistor => 37) ;
         -- Posicionar no proximo registro
         FETCH cr_craphis INTO rw_craphis;
         -- Se nao encontrar
         IF cr_craphis%NOTFOUND THEN
           -- Buscar mensagem de erro da critica
           vr_cdcritic := 93;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' HST 37';
           -- Fechar Cursor
           CLOSE cr_craphis;
           -- Sair do programa
           RAISE vr_exc_saida;
         ELSE
           -- taxa cpmf conta corrente recebe taxa cpmf conta corrente
           vr_txipmneg:= vr_txcpmfcc;
         END IF;
         -- Fechar Cursor
         CLOSE cr_craphis;

         -- Carrega a taxa da CPMF para a multa sobre o saque bloqueado
         OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                         ,pr_cdhistor => 57) ;
         -- Posicionar no proximo registro
         FETCH cr_craphis INTO rw_craphis;
         -- Se nao encontrar
         IF cr_craphis%NOTFOUND THEN
           -- Buscar mensagem de erro da critica
           vr_cdcritic := 93;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' HST 57';
           -- Fechar Cursor
           CLOSE cr_craphis;
           -- Sair do programa
           RAISE vr_exc_saida;
         ELSE
           -- taxa cpmf saque recebe taxa cpmf conta corrente
           vr_txipmsaq:= vr_txcpmfcc;
         END IF;
         -- Fechar Cursor
         CLOSE cr_craphis;

         -- Buscar configuração na tabela
         vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 0
                                                  ,pr_cdacesso => 'DIASCREDLQ'
                                                  ,pr_tpregist => 0);
         
         -- Se nao encontrou entao
         IF TRIM(vr_dstextab) IS NULL THEN
           -- Buscar mensagem de erro da critica
           vr_cdcritic:= 210;
           -- Sair do programa
           RAISE vr_exc_saida;
         ELSE
           -- Atribuir quantidade de dias devedor
           vr_qtddsdev:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));
         END IF;

         -- Verificar se é dia de encerramento
         OPEN cr_crapper (pr_cdcooper => pr_cdcooper
                         ,pr_dtiniper => rw_crapdat.dtmvtoan
                         ,pr_dtfimper => rw_crapdat.dtmvtopr
                         ,pr_infimper => 2);
         -- Posicionar no proximo registro
         FETCH cr_crapper INTO rw_crapper;
         -- Se nao encontrar
         IF cr_crapper%FOUND THEN
           -- Atribuir true para encerramento
           vr_flgencer:= TRUE;
         ELSE
           -- Atribuir false para encerramento
           vr_flgencer:= FALSE;
         END IF;
         -- Fechar Cursor
         CLOSE cr_crapper;

         -- Buscar configuração na tabela
         vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                         ,pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'USUARI'
                         ,pr_cdempres => 11
                         ,pr_cdacesso => 'JUROSNEGAT'
                         ,pr_tpregist => 1);
         
         --Se nao encontrou entao
         IF TRIM(vr_dstextab) IS NULL THEN
           --Montar mensagem de erro com base na critica
           vr_cdcritic:= 162;
           --Sair do programa
           RAISE vr_exc_saida;
         ELSE
           --Atribuir Taxa Juros conta negativa
           vr_txjurneg:= GENE0002.fn_char_para_number(SubStr(vr_dstextab,1,10)) / 100;
         END IF;

         -- Buscar configuração na tabela
         vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                         ,pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'USUARI'
                         ,pr_cdempres => 11
                         ,pr_cdacesso => 'JUROSSAQUE'
                         ,pr_tpregist => 1);
         
         --Se nao encontrou entao
         IF TRIM(vr_dstextab) IS NULL THEN
           --Montar mensagem de erro com base na critica
           vr_cdcritic:= 162;
           --Sair do programa
           RAISE vr_exc_saida;
         ELSE
           --Atribuir Taxa Juros conta negativa
           vr_txjursaq:= GENE0002.fn_char_para_number(SubStr(vr_dstextab,1,10)) / 100;

         END IF;

         --Selecionar informacoes da moeda
         OPEN cr_crapmfx (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                         ,pr_tpmoefix => 2);
         --Posicionar no proximo registro
         FETCH cr_crapmfx INTO rw_crapmfx;
         --Se nao encontrar
         IF cr_crapmfx%NOTFOUND THEN
           --Montar mensagem de erro com base na critica
           vr_cdcritic:= 140;
           --Fechar Cursor
           CLOSE cr_crapmfx;
           --Sair do programa
           RAISE vr_exc_saida;
         END IF;
         --Fechar Cursor
         CLOSE cr_crapmfx;

         -- Buscar dias corridos para a cobrança de juros
         vr_qtdiacor:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PARLIM_QTDIACOR');

         -- Retornar todos os registros de saldos dos Cooperados
         OPEN cr_crapsld (pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_dtmvtoan => rw_crapdat.dtmvtoan);
         LOOP
           FETCH cr_crapsld BULK COLLECT INTO rw_crapsld LIMIT 50;
           EXIT WHEN rw_crapsld.COUNT = 0;            
           FOR idx IN rw_crapsld.first..rw_crapsld.last LOOP 
             --Se não encontrou o associado
             IF rw_crapsld(idx).ass_nrdconta IS NULL THEN
               --Montar mensagem de erro com base na critica
               vr_cdcritic:= 251;
             vr_dscritic := 'Idx '||idx||' --> '||gene0001.fn_busca_critica(vr_cdcritic);
               --Sair do programa
               RAISE vr_exc_saida;
             END IF;

             --Zerar valor juros cheque especial
             rw_crapsld(idx).vljuresp:= 0;
             --Zerar valor juros mes
             rw_crapsld(idx).vljurmes:= 0;
             --Zerar valor juros saque
             rw_crapsld(idx).vljursaq:= 0;

             --Zerar valor do impf
             vr_vldoipmf:= 0;
             --Zerar valor da base do impf
             vr_vlbasipm:= 0;
             --Zerar valor dos juros
             vr_vldjuros:= 0;
             --Zerar valor dos juros acumulados
             vr_vlajulcm:= 0;
             --Zerar valor ajustado do impf
             vr_vlajuipm:= 0;
             --Zerar valor base do iof
             vr_vlbasiof:= 0;
             --Flag ajuste recebe false
             vr_flgajust:= FALSE;
               
             -- Condicao para verificar se a empresa existe
             IF vr_tab_crapjur.EXISTS(rw_crapsld(idx).nrdconta) THEN
               -- Natureza Juridica
               vr_natjurid := vr_tab_crapjur(rw_crapsld(idx).nrdconta).natjurid;
               -- Regime de Tributacao
               vr_tpregtrb := vr_tab_crapjur(rw_crapsld(idx).nrdconta).tpregtrb;
             ELSE
               -- Natureza Juridica             
               vr_natjurid := 0;
               -- Regime de Tributacao
               vr_tpregtrb := 0;
             END IF;

             --Se for primeiro dia util e tiver IOF a cobrar
             IF rw_crapsld(idx).vlsmnesp < 0 THEN

               -- Selecionar informacoes dos limites(1-em estudo) de credito do associado
               OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapsld(idx).nrdconta
                               ,pr_tpctrlim => 1
                               ,pr_insitlim => 2);
               --Posicionar no proximo registro
               FETCH cr_craplim INTO rw_craplim;
               --Se nao encontrar
               IF cr_craplim%NOTFOUND THEN
                 --Fechar cursor
                 CLOSE cr_craplim;
                 --Selecionar informacoes dos limites(3-cancelado) de credito do associado
                 OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapsld(idx).nrdconta
                                 ,pr_tpctrlim => 1
                                 ,pr_insitlim => 3);
                 --Posicionar no proximo registro
                 FETCH cr_craplim INTO rw_craplim;
                 --Se nao encontrou
                 IF cr_craplim%NOTFOUND THEN
                   --Montar mensagem de erro com base na critica
                   vr_cdcritic:= 105;
                   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                     
                   -- Envio centralizado de log de erro
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                             ,pr_ind_tipo_log => 2 -- Erro tratato
                                             ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE')
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                                || vr_cdprogra || ' --> '
                                                                                || vr_dscritic );                 
                 END IF;
               END IF;
               --Fechar Cursor
               CLOSE cr_craplim;

               IF vr_cdcritic = 105 THEN             
                     
                 -- zerar variaveis para o processo continuar normalmente                                                                          
                 vr_cdcritic := 0;
                 vr_dscritic := '';   
                     
               ELSE  --Selecionar Cadastro de linhas de credito rotativos

                 --Se nao encontrar mostra erro e aborta programa
                 IF NOT vr_tab_craplrt.EXISTS(rw_craplim.cddlinha) THEN
                   --Buscar mensagem de erro da critica
                   vr_cdcritic := 363;
                   vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)|| ' --> '||gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   --Sair do programa
                   RAISE vr_exc_saida;
                 END IF;

                 --Valor juros cheque especial recebe valor juros * txmensal /100 * -1
                 IF (rw_crapsld(idx).ass_inprejuz = 0) THEN
                 rw_crapsld(idx).vljuresp:= (rw_crapsld(idx).vlsmnesp * (vr_tab_craplrt(rw_craplim.cddlinha) / 100)) * -1;
                 ELSE
                   rw_crapsld(idx).vljuresp := 0;
               END IF;
                
               END IF;

             END IF;

             --Se valor negativo no mes menor zero
             IF rw_crapsld(idx).vlsmnmes < 0 THEN
               --valor juros do saldo devedor recebe valor negativo no mes * taxa juros negativo * -1.
               IF (rw_crapsld(idx).ass_inprejuz = 0) THEN
               rw_crapsld(idx).vljurmes:= (rw_crapsld(idx).vlsmnmes * vr_txjurneg) * -1;
               ELSE
                 rw_crapsld(idx).vljurmes:= 0;
             END IF;
             END IF;

             --Se valor media saque s/ bloqueado menor zero
             IF rw_crapsld(idx).vlsmnblq < 0   THEN
               --Valor juro saque recebe valor media saque s/ bloqueado * taxa juros saque * -1.
               IF (rw_crapsld(idx).ass_inprejuz = 0) THEN
               rw_crapsld(idx).vljursaq:= (rw_crapsld(idx).vlsmnblq * vr_txjursaq) * -1;
               ELSE
                 rw_crapsld(idx).vljursaq:= 0;
             END IF;
             END IF;

             --Valor saldo anterior recebe valor saldo disponivel + valor saldo cheque salario
             vr_vlsldant:= Nvl(rw_crapsld(idx).vlsddisp,0) + Nvl(rw_crapsld(idx).vlsdchsl,0);
             --Valor saldo atual recebe valor saldo anterior - valor juros cheque especial - juros mes - juros de saque
             vr_vlsldatu:= vr_vlsldant - Nvl(rw_crapsld(idx).vljurmes,0) - Nvl(rw_crapsld(idx).vljursaq,0);

             --Verificar se existe cota para o associado
             IF rw_crapsld(idx).rowidcot IS NULL THEN
               --Buscar mensagem de erro da critica
               vr_cdcritic := 169;
               vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ;

               --Sair do programa
               RAISE vr_exc_saida;
             ELSE
               --Atribuir o rowid da tabela de memoria para o registro
               vr_crapcot := rw_crapsld(idx).rowidcot; 
             END IF;

             --Se os juros cheque especial ou juros do mes ou juros de saque for maior zero e for pessoa fisica ou juridica
             IF (rw_crapsld(idx).vljuresp > 0  OR rw_crapsld(idx).vljurmes > 0  OR rw_crapsld(idx).vljursaq > 0)  AND
                (rw_crapsld(idx).ass_inpessoa < 3)                THEN 

               --Acumular em quantidade juros em MFX os juros do cheque especial + juros no mes + juros saque dividido pelo valor moeda

               --Quantidade juros recebe juros ch. especial + juros mes + juros saque dividido valor moeda
               vr_qtjurmfx:= Round(((Round(Nvl(rw_crapsld(idx).vljuresp,0),2)  +
                                     Round(Nvl(rw_crapsld(idx).vljurmes,0),2)  +
                                     Round(Nvl(rw_crapsld(idx).vljursaq,0),2)
                                    ) / Nvl(rw_crapmfx.vlmoefix,0)),4); 
                        
               --Acumular a quantidade de juros calculada
               rw_crapsld(idx).qtjramfx:= Nvl(rw_crapsld(idx).qtjramfx,0) + Nvl(vr_qtjurmfx,0);


               --Valor total saldo anterior recebe:
               --vlsdblfp = valor do saldo bloqueado fora da praca
               --vlsdbloq = valor saldo bloqueado
               --vlsdblpr = valor do saldo bloqueado praca
               --vlsdchsl = valor do saldo cheque salario
               --vlsddisp = valor do saldo disponivel
               --vllimcre = valor do limite de credito do associado
               vr_tot_vlsldant:= Nvl(rw_crapsld(idx).vlsddisp,0) + Nvl(rw_crapsld(idx).vlsdchsl,0) +
                                 Nvl(rw_crapsld(idx).vlsdbloq,0) + Nvl(rw_crapsld(idx).vlsdblpr,0) +
                                 Nvl(rw_crapsld(idx).vlsdblfp,0) + Nvl(rw_crapsld(idx).ass_vllimcre,0);

               --Zerar Numero sequencial tabela
               vr_nrseqneg:= 0;
               --Atribuir false para flag existe saldo negativo
               vr_flghaneg:= FALSE;
               --Se a data do movimento estiver entre inicio e fim de iof  ou calcula cpmf
               IF (rw_crapdat.dtmvtolt BETWEEN vr_dtinifis AND vr_dtfimfis) OR vr_flgdcpmf THEN
                 --Flag ajuste recebe false
                 vr_flgajust:= FALSE;
               ELSE
                 --Flag ajuste recebe true
                 vr_flgajust:= TRUE;
               END IF;

               --Se tem saldo negativo no crapneg
               IF vr_tot_vlsldant < 0 THEN
                 --Flag saldo negativo recebe true
                 vr_flghaneg:= TRUE;

                 --Selecionar informacoes de saldos negativos e controles de cheque
                 OPEN cr_crapneg2 (pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => rw_crapsld(idx).nrdconta
                                  ,pr_cdhisest => 5
                                  ,pr_vlestour => (vr_tot_vlsldant * -1));
                 --Posicionar no proximo registro
                 FETCH cr_crapneg2  INTO rw_crapneg2;
                 --Se nao encontrar
                 IF cr_crapneg2%NOTFOUND  THEN
                   --Buscar mensagem de erro da critica
                   vr_cdcritic := 419;
                   vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   -- Fechar Cursor
                   CLOSE cr_crapneg2;
                   --Sair do programa
                   RAISE vr_exc_saida;
                 ELSE
                   --Inicializar numero sequencial lancamento com o já existente
                   vr_nrseqneg:= Nvl(rw_crapneg2.nrseqdig,0);
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_crapneg2;
               ELSE
                 -- Usar cadastro sequenciador para geração da crapneg
                 vr_nrseqneg := fn_sequence('CRAPNEG','NRSEQDIG',pr_cdcooper||';'||rw_crapsld(idx).nrdconta);
               END IF;

               --Atualizar os juros pagos no registro de cotas
               BEGIN
                 --Quantidade juros recebe juros ch. especial + juros mes + juros saque dividido valor moeda
                 vr_qtjurmfx:= Round(((Round(Nvl(rw_crapsld(idx).vljuresp,0),2)  +
                                       Round(Nvl(rw_crapsld(idx).vljurmes,0),2)  +
                                       Round(Nvl(rw_crapsld(idx).vljursaq,0),2)
                                      ) / Nvl(rw_crapmfx.vlmoefix,0)),4);
                         
                 --Atualizar quantidade juros na tabela cotas
                 UPDATE crapcot SET crapcot.qtjurmfx = Nvl(crapcot.qtjurmfx,0) + Nvl(vr_qtjurmfx,0)
                  WHERE crapcot.ROWID = vr_crapcot;
               EXCEPTION
                 WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao Atualizar tabela crapcot Rowid '||vr_crapcot||' --> '||SQLERRM;
                   --Sair do programa
                   RAISE vr_exc_saida;
               END;

               --Se a multa sobre o saldo devedor for maior zero
               IF rw_crapsld(idx).vljurmes > 0 THEN
                 
                  -- Verificar Saldo do cooperado
                  extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper, 
                                              pr_rw_crapdat => rw_crapdat, 
                                              pr_cdagenci => 1, 
                                              pr_nrdcaixa => 0, 
                                              pr_cdoperad => '1', 
                                              pr_nrdconta => rw_crapsld(idx).nrdconta, 
                                              pr_vllimcre => rw_crapsld(idx).ass_vllimcre, 
                                              pr_dtrefere => rw_crapdat.dtmvtolt, 
                                              pr_flgcrass => FALSE, 
                                              pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                              pr_des_reto => vr_des_erro, 
                                              pr_tab_sald => vr_tab_saldo, 
                                              pr_tab_erro => vr_tab_erro);
                                                                    
                  --Se ocorreu erro
                  IF vr_des_erro = 'NOK' THEN
                    -- Tenta buscar o erro no vetor de erro
                    IF vr_tab_erro.COUNT > 0 THEN
                      vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                      vr_dscritic:= ' Conta: '||rw_crapsld(idx).nrdconta || ' --> '||vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    ELSE
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Conta: '||rw_crapsld(idx).nrdconta||' --> Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro';
                    END IF;
                                      
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                  ELSE
                    vr_dscritic:= NULL;
                  END IF;
                  --Verificar o saldo retornado
                  IF vr_tab_saldo.Count = 0 THEN
                    --Montar mensagem erro
                    vr_cdcritic:= 0;
                  vr_dscritic:= ' Conta: '||rw_crapsld(idx).nrdconta || ' --> Nao foi possivel consultar o saldo para a operacao.';                                              
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                  ELSE
                    vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                   nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
                  END IF; 

                 -- Se saldo do cooperado não suprir o lançamento e qtd dias corridos for > 0 
                 -- vamos agendar o lançamento na LAUTOM
                 IF rw_crapsld(idx).vljurmes > vr_vlsddisp AND vr_qtdiacor > 0 THEN                   
                        
                   vr_nrseqdig:= fn_sequence('CRAPLAU','NRSEQDIG',''||pr_cdcooper||';'||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||'');
                       
                   BEGIN
                    INSERT INTO craplau
                                (craplau.cdcooper
                                ,craplau.dtmvtopg
                                ,craplau.cdagenci
                                ,craplau.cdbccxlt
                                ,craplau.cdhistor
                                ,craplau.dtmvtolt
                                ,craplau.insitlau
                                ,craplau.nrdconta
                                ,craplau.nrdctabb
                                ,craplau.nrdolote
                                ,craplau.nrseqdig
                                ,craplau.tpdvalor
                                ,craplau.vllanaut
                                ,craplau.nrdocmto
                                ,craplau.dttransa
                                ,craplau.hrtransa
                                ,craplau.dsorigem)
                         VALUES (pr_cdcooper            -- craplau.cdcooper
                                ,rw_crapdat.dtmvtolt    -- craplau.dtmvtopg
                                ,vr_cdagenci            -- craplau.cdagenci
                                ,vr_cdbccxlt            -- craplau.cdbccxlt
                                ,37                     -- craplau.cdhistor
                                ,rw_crapdat.dtmvtolt    -- craplau.dtmvtolt
                                ,1                      -- craplau.insitlau
                                ,rw_crapsld(idx).nrdconta    -- craplau.nrdconta
                                ,rw_crapsld(idx).nrdconta    -- craplau.nrdctabb
                                ,vr_nrdolote            -- craplau.nrdolote
                                ,nvl(vr_nrseqdig,0) + 1 -- craplau.nrseqdig
                                ,1                      -- craplau.tpdvalor
                                ,rw_crapsld(idx).vljurmes    -- craplau.vllanaut
                                ,99999937               -- craplau.nrdocmto
                                ,rw_crapdat.dtmvtolt            -- craplau.dttransa
                                ,gene0002.fn_busca_time -- craplau.hrtransa
                                ,'ADIOFJUROS')          -- craplau.dsorigem
                      RETURNING idlancto 
                           INTO vr_idlancto; 
                    EXCEPTION
                      WHEN OTHERS THEN
                      vr_dscritic := ' Conta: '||rw_crapsld(idx).nrdconta || ' --> Erro ao inserir craplau: '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                         
                   -- Para cada craplau vamos criar um registro de controle
                   OPEN cr_tbcc_lautom_controle(pr_idlancto => vr_idlancto);
                   FETCH cr_tbcc_lautom_controle INTO rw_tbcc_lautom_controle;
                         
                   IF cr_tbcc_lautom_controle%NOTFOUND THEN
                     CLOSE cr_tbcc_lautom_controle;
                           
                     BEGIN
                       INSERT INTO tbcc_lautom_controle(cdcooper, 
                                                        nrdconta, 
                                                        dtmvtolt, 
                                                        vloriginal, 
                                                        idlautom, 
                                                        insit_lancto, 
                                                        cdhistor) 
                                                 VALUES(pr_cdcooper
                                                       ,rw_crapsld(idx).nrdconta
                                                       ,rw_crapdat.dtmvtolt
                                                       ,rw_crapsld(idx).vljurmes
                                                       ,vr_idlancto
                                                       ,1
                                                       ,37);
                       EXCEPTION  
                         WHEN OTHERS THEN
                        vr_dscritic := ' Conta: '||rw_crapsld(idx).nrdconta || ' --> Erro ao inserir cr_tbcc_lautom_controle: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                           
                   ELSE
                     CLOSE cr_tbcc_lautom_controle;
                   END IF;
                     
                   --Diminuir o valor do lancamento nos juros
                   vr_vldjuros:= Nvl(vr_vldjuros,0) + Nvl(rw_crapsld(idx).vljurmes,0);
                 ELSE -- Caso contrario segue criando registro na conta corrente  
                 
                   -- Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
                   BEGIN
                     LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => vr_cdagenci
                                                       , pr_cdbccxlt => vr_cdbccxlt
                                                       , pr_nrdolote => vr_nrdolote
                                                       , pr_cdhistor => 37
                                                       , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                       , pr_nrdconta => rw_crapsld(idx).nrdconta
                                                       , pr_nrdctabb => rw_crapsld(idx).nrdconta
                                                       , pr_nrdctitg => GENE0002.FN_MASK(rw_crapsld(idx).nrdconta, '99999999')
                                                       , pr_nrdocmto => 99999937
                                                       , pr_nrseqdig => CRAPLOT_8450_SEQ.NEXTVAL
                                                       , pr_vllanmto => rw_crapsld(idx).vljurmes
                                                       , pr_cdcooper => pr_cdcooper
                                                       , pr_vldoipmf => TRUNC(rw_crapsld(idx).vljurmes * vr_txipmneg,2)
                                                       , pr_cdcoptfn => 0
                                                       , pr_tab_retorno => vr_tab_retorno
	                                                     , pr_incrineg => vr_incrineg
                                                       , pr_cdcritic => vr_cdcritic
                                                       , pr_dscritic => vr_dscritic
                                                       );

                     IF vr_dscritic IS NOT NULL
                        AND vr_incrineg = 0 THEN -- Erro de sistema/BD
                       RAISE vr_exc_saida;
                     END IF;
                     -- guarda dados par serem utilizados mais a frente
                     rw_craplcm.vllanmto := rw_crapsld(idx).vljurmes;
                     rw_craplcm.vldoipmf := TRUNC(rw_crapsld(idx).vljurmes * vr_txcpmfcc,2);
                     rw_craplcm.rowid    := vr_tab_retorno.rowidlct;

                   EXCEPTION
                     WHEN vr_exc_saida THEN
                       RAISE vr_exc_saida;
                     WHEN OTHERS THEN
                   vr_dscritic := ' Conta: '||rw_crapsld(idx).nrdconta || ' --> Erro ao inserir na tabela craplcm. '||SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;

                   -- Incrementar o total a debito
                   vr_vlinfodb:= Nvl(vr_vlinfodb,0) + Nvl(rw_craplcm.vllanmto,0);
                   --Incrementar o total a debito compensado
                   vr_vlcompdb:= Nvl(vr_vlcompdb,0) + Nvl(rw_craplcm.vllanmto,0);
                   --Incrementar a quantidade total de lancamentos
                   vr_qtinfoln:= Nvl(vr_qtinfoln,0) + 1;
                   --Incrementar a quantidade total de lancamentos compensados
                   vr_qtcompln:= Nvl(vr_qtcompln,0) + 1;
                   
                   --Incrementar a quantidade de lancamentos no mes
                   rw_crapsld(idx).qtlanmes:= Nvl(rw_crapsld(idx).qtlanmes,0) + 1;
                   --Diminuir do saldo disponivel o valor do lancamento
                   rw_crapsld(idx).vlsddisp:= Nvl(rw_crapsld(idx).vlsddisp,0) - Nvl(rw_craplcm.vllanmto,0);
                   --Diminuir o valor do lancamento nos juros
                   vr_vldjuros:= Nvl(vr_vldjuros,0) + Nvl(rw_craplcm.vllanmto,0);

                   --Se cobrar cpmf
                   IF vr_flgdcpmf THEN
                     --Acumular o valor do lancamento no valor base ipmf
                     vr_vlbasipm:= vr_vlbasipm + Nvl(rw_craplcm.vllanmto,0);
                     --Acumular no valor do ipmf o valor do ipmf existente no lancamento
                     vr_vldoipmf:= vr_vldoipmf + Nvl(rw_craplcm.vldoipmf,0);
                   END IF;

                 END IF;

               END IF;

               --Se o juros sobre o saque bloqueado for maior zero
               IF rw_crapsld(idx).vljursaq > 0 THEN
                 --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
                 BEGIN
                   LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => vr_cdagenci
                                                     , pr_cdbccxlt => vr_cdbccxlt
                                                     , pr_nrdolote => vr_nrdolote
                                                     , pr_cdhistor => 57
                                                     , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                     , pr_nrdconta => rw_crapsld(idx).nrdconta
                                                     , pr_nrdctabb => rw_crapsld(idx).nrdconta
                                                     , pr_nrdctitg => GENE0002.FN_MASK(rw_crapsld(idx).nrdconta, '99999999')
                                                     , pr_nrdocmto => 99999957
                                                     , pr_nrseqdig => CRAPLOT_8450_SEQ.NEXTVAL
                                                     , pr_vllanmto => rw_crapsld(idx).vljursaq
                                                     , pr_cdcooper => pr_cdcooper
                                                     , pr_vldoipmf => TRUNC(rw_crapsld(idx).vljursaq * vr_txipmsaq,2)
                                                     , pr_cdcoptfn => 0
                                                     , pr_tab_retorno => vr_tab_retorno
	                                                   , pr_incrineg => vr_incrineg                                                   
                                                     , pr_cdcritic => vr_cdcritic
                                                     , pr_dscritic => vr_dscritic);

                   IF TRIM(vr_dscritic) IS NOT NULL OR
                      vr_cdcritic > 0 THEN
                     RAISE vr_exc_saida;
                   END IF; 
                   
                   -- guarda dados par serem utilizados mais a frente
                   rw_craplcm.vllanmto := rw_crapsld(idx).vljursaq;
                   rw_craplcm.vldoipmf := TRUNC(rw_crapsld(idx).vljursaq * vr_txipmsaq,2);
                   rw_craplcm.rowid    := vr_tab_retorno.rowidlct;
                 

                 EXCEPTION
                   WHEN vr_exc_saida THEN
                     RAISE vr_exc_saida;
                   WHEN OTHERS THEN
                   vr_dscritic := ' Conta: '||rw_crapsld(idx).nrdconta || ' --> Erro ao inserir na tabela craplcm. '||SQLERRM;
                     --Sair do programa
                     RAISE vr_exc_saida;
                 END;

                 -- Incrementar o total a debito
                 vr_vlinfodb:= Nvl(vr_vlinfodb,0) + Nvl(rw_craplcm.vllanmto,0);
                 --Incrementar o total a debito compensado
                 vr_vlcompdb:= Nvl(vr_vlcompdb,0) + Nvl(rw_craplcm.vllanmto,0);
                 --Incrementar a quantidade total de lancamentos
                 vr_qtinfoln:= Nvl(vr_qtinfoln,0) + 1;
                 --Incrementar a quantidade total de lancamentos compensados
                 vr_qtcompln:= Nvl(vr_qtcompln,0) + 1;

                 --Incrementar a quantidade de lancamentos no mes
                 rw_crapsld(idx).qtlanmes:= Nvl(rw_crapsld(idx).qtlanmes,0) + 1;
                 --Diminuir do saldo disponivel o valor do lancamento
                 rw_crapsld(idx).vlsddisp:= Nvl(rw_crapsld(idx).vlsddisp,0) - Nvl(rw_craplcm.vllanmto,0);
                 --Diminuir o valor do lancamento nos juros
                 vr_vldjuros:= Nvl(vr_vldjuros,0) + Nvl(rw_craplcm.vllanmto,0);

                 --Se cobrar cpmf
                 IF vr_flgdcpmf THEN
                   --Acumular o valor do lancamento no valor base ipmf
                   vr_vlbasipm:= Nvl(vr_vlbasipm,0) + Nvl(rw_craplcm.vllanmto,0);
                   --Acumular no valor do ipmf o valor do ipmf existente no lancamento
                   vr_vldoipmf:= Nvl(vr_vldoipmf,0) + Nvl(rw_craplcm.vldoipmf,0);
                 END IF;
               END IF;

               --Se cobrar cpmf
               IF vr_flgdcpmf THEN
                 --Se valor base ipmf > 0
                 IF vr_vlbasipm > 0 THEN
                   --Se for encerramento
                   IF vr_flgencer THEN

                     --Atualizar informacoes debitos de cpmf
                     BEGIN

                       --Acumula valor do ipmf no valor do ipmf a pagar
                       rw_crapsld(idx).vlipmfpg:= Nvl(rw_crapsld(idx).vlipmfpg,0) + Nvl(vr_vldoipmf,0);

                       --Atualizar informacoes de debitos de ipmf
                       UPDATE crapipm SET crapipm.vlbasipm = Nvl(crapipm.vlbasipm,0) + Nvl(vr_vlbasipm,0)
                                         ,crapipm.vldoipmf = Nvl(crapipm.vldoipmf,0) + Nvl(vr_vldoipmf,0)
                       WHERE crapipm.cdcooper = pr_cdcooper
                       AND   crapipm.nrdconta = rw_craplcm.nrdconta
                       AND   crapipm.dtdebito = rw_crapper.dtdebito
                       AND   crapipm.indebito = 1;

                       --Se não atualizou nada entao cria registro
                       IF SQL%ROWCOUNT = 0 THEN
                         BEGIN
                           INSERT INTO crapipm (crapipm.dtdebito
                                               ,crapipm.indebito
                                               ,crapipm.nrdconta
                                               ,crapipm.vlbasipm
                                               ,crapipm.vldoipmf
                                               ,crapipm.cdcooper)
                                       VALUES  (rw_crapper.dtdebito
                                               ,1
                                               ,rw_craplcm.nrdconta
                                               ,vr_vlbasipm
                                               ,vr_vldoipmf
                                               ,pr_cdcooper);
                         EXCEPTION
                           WHEN OTHERS THEN
                         vr_dscritic := ' Conta: '||rw_craplcm.nrdconta || ' --> Erro ao inserir na tabela crapipm. '||SQLERRM;
                           --Sair do programa
                           RAISE vr_exc_saida;
                         END;
                       END IF;

                     EXCEPTION
                     WHEN vr_exc_saida THEN
                       RAISE vr_exc_saida;
                       WHEN OTHERS THEN
                       vr_dscritic := ' Conta: '||rw_craplcm.nrdconta || ' --> Erro ao atualizar tabela crapipm. '||SQLERRM;
                         --Sair do programa
                         RAISE vr_exc_saida;
                     END;
                   ELSE
                     --Acumular no Valor ipmf a pagar o valor do ipmf
                     rw_crapsld(idx).vlipmfap:= Nvl(rw_crapsld(idx).vlipmfap,0) + Nvl(vr_vldoipmf,0);
                     --Acumular no valor base do ipmf o valor base do ipmf
                     rw_crapsld(idx).vlbasipm:= Nvl(rw_crapsld(idx).vlbasipm,0) + Nvl(vr_vlbasipm,0);

                   END IF; --vr_flgencer
                 END IF; --vr_vlbasipm > 0
               END IF; --vr_flgdcpmf

               --Valor total atual recebe total saldo anterior - juros mes - juros cheque especial - juros saque
               vr_tot_vlsldatu:= Nvl(vr_tot_vlsldant,0) -
                                 Nvl(rw_crapsld(idx).vljurmes,0) -
                                 Nvl(rw_crapsld(idx).vljursaq,0);

               --Se o valor total saldo atual for negativo e diferente do valor total saldo anterior
               IF vr_tot_vlsldatu < 0 AND vr_tot_vlsldatu <> vr_tot_vlsldant THEN
                 --Se for negativo
                 IF vr_flghaneg THEN

                   --Atualizar informacoes  de saldos negativos e controles de cheque
                   BEGIN
                     UPDATE crapneg SET crapneg.vlestour = (vr_tot_vlsldatu * -1)
                     WHERE crapneg.cdcooper = pr_cdcooper
                     AND   crapneg.nrdconta = rw_crapsld(idx).nrdconta
                     AND   crapneg.nrseqdig = vr_nrseqneg;

                     --Se nao atualizou nada
                     IF SQL%ROWCOUNT = 0 THEN
                       --Buscar mensagem de erro da critica
                       vr_cdcritic := 419;
                       vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                       --Sair do programa
                       RAISE vr_exc_saida;
                     END IF;
                   EXCEPTION
                   WHEN vr_exc_saida THEN
                     RAISE vr_Exc_saida;
                     WHEN OTHERS THEN
                     vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> Erro ao atualizar tabela crapneg. '||SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;
                 ELSE
                   --Inserir saldos e cheques
                   BEGIN
                     INSERT INTO crapneg (crapneg.nrdconta
                                         ,crapneg.nrseqdig
                                         ,crapneg.cdhisest
                                         ,crapneg.cdobserv
                                         ,crapneg.dtiniest
                                         ,crapneg.nrdctabb
                                         ,crapneg.nrdocmto
                                         ,crapneg.qtdiaest
                                         ,crapneg.vlestour
                                         ,crapneg.vllimcre
                                         ,crapneg.cdtctant
                                         ,crapneg.cdtctatu
                                         ,crapneg.dtfimest
                                         ,crapneg.cdbanchq
                                         ,crapneg.cdagechq
                                         ,crapneg.nrctachq
                                         ,crapneg.cdcooper)
                                VALUES   (rw_crapsld(idx).ass_nrdconta 
                                         ,vr_nrseqneg
                                         ,5
                                         ,0
                                         ,rw_crapdat.dtmvtolt
                                         ,0
                                         ,0
                                         ,1
                                         ,(vr_tot_vlsldatu * -1)
                                         ,rw_crapsld(idx).ass_vllimcre
                                         ,0
                                         ,0
                                         ,rw_crapdat.dtmvtolt
                                         ,0
                                         ,0
                                         ,0
                                         ,pr_cdcooper);
                   EXCEPTION
                     WHEN OTHERS THEN
                   vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).ass_nrdconta)||' --> Erro ao  inserir na tabela crapneg. Cdhisest=5 '||SQLERRM;
                     --Levantar Exceção
                     RAISE vr_exc_saida;
                   END;
                     
                   -- Regra para cálculo de dias úteis ou dias corridos - Daniel(AMcom)
                   vr_dtrisclq_aux := nvl(rw_crapsld(idx).dtrisclq, rw_crapdat.dtmvtolt);
                  --
                  IF vr_dtrisclq_aux <= vr_dtcorte_prm 
                     -- Se estiver em prejuízo, deve efetuar a contagem em dias corridos                 
                     AND rw_crapsld(idx).ass_inprejuz = 0 /*não está em Prejuízo*/ THEN  
                     -- Considerar dias úteis -- Regra atual
                   --Incrementar quantidade dias devedor
                   rw_crapsld(idx).qtddsdev:= Nvl(rw_crapsld(idx).qtddsdev,0) + 1;
                   --Incrementar quantidade total dias conta devedora
                   rw_crapsld(idx).qtddtdev:= Nvl(rw_crapsld(idx).qtddtdev,0) + 1;
                   --Incrementar quantidade dias saldo negativo risco
                   rw_crapsld(idx).qtdriclq:= Nvl(rw_crapsld(idx).qtdriclq,0) + 1;
                   ELSE
                     -- Considerar dias corridos -- Daniel(AMcom)
                     -- Guardar posição inicial de quantidade de dias SLD
                     vr_qtddsdev_aux     := nvl(rw_crapsld(idx).qtddsdev,0);
                     --
                     IF rw_crapdat.dtmvtolt = vr_dtrisclq_aux THEN
                       -- Incrementar quantidade dias corridos devedor 
                       rw_crapsld(idx).qtddsdev := 1;
                       -- Incrementar quantidade total dias corridos conta devedora
                       rw_crapsld(idx).qtddtdev := nvl(rw_crapsld(idx).qtddtdev,0)+1;
                       -- Incrementar quantidade dias corridos saldo negativo risco
                       rw_crapsld(idx).qtdriclq := 1;
                     ELSE 
                       IF rw_crapsld(idx).ass_inprejuz = 0 THEN
                       -- Incrementar quantidade dias corridos devedor 
                       rw_crapsld(idx).qtddsdev := (rw_crapdat.dtmvtolt-vr_dtrisclq_aux);
                       -- Incrementar quantidade dias corridos saldo negativo risco
                       rw_crapsld(idx).qtdriclq := (rw_crapdat.dtmvtolt-vr_dtrisclq_aux);                   
                       ELSE
                         rw_crapsld(idx).qtddsdev := PREJ0003.fn_calc_dias_atraso_cc_prej(pr_cdcooper, rw_crapsld(idx).nrdconta, rw_crapdat.dtmvtopr);
                         rw_crapsld(idx).qtdriclq := rw_crapsld(idx).qtddsdev;
                       END IF;
                       
                       -- Incrementar quantidade total dias corridos conta devedora
                       rw_crapsld(idx).qtddtdev := nvl(rw_crapsld(idx).qtddtdev,0)+(rw_crapsld(idx).qtddsdev-vr_qtddsdev_aux);
                                       
                     END IF;
                   END IF;

                   --Se quantidade dias saldo negativo risco > quantidade dias risco
                   IF rw_crapsld(idx).qtdriclq >= 1 THEN
                     --quantidade dias saldo negativo risco recebe a data do movimento
                      rw_crapsld(idx).dtrisclq:= rw_crapdat.dtmvtolt;
                   END IF;

                   --Se a quantidade existente na saldo de dias devedor maior ou igual a qdade dias devedor calculado
                   IF rw_crapsld(idx).qtddsdev >= vr_qtddsdev THEN
                     --data saldo devedor liquida recebe a data do movimento
                     rw_crapsld(idx).dtdsdclq:= rw_crapdat.dtmvtolt;

                     -- Usar cadastro sequenciador para geração da crapneg
                     vr_nrseqneg := fn_sequence('CRAPNEG','NRSEQDIG',pr_cdcooper||';'||rw_crapsld(idx).nrdconta);

                     --Inserir saldos e cheques
                     BEGIN
                       INSERT INTO crapneg (crapneg.nrdconta
                                           ,crapneg.nrseqdig
                                           ,crapneg.cdhisest
                                           ,crapneg.cdobserv
                                           ,crapneg.dtiniest
                                           ,crapneg.nrdctabb
                                           ,crapneg.nrdocmto
                                           ,crapneg.qtdiaest
                                           ,crapneg.vlestour
                                           ,crapneg.vllimcre
                                           ,crapneg.cdtctant
                                           ,crapneg.cdtctatu
                                           ,crapneg.dtfimest
                                           ,crapneg.cdbanchq
                                           ,crapneg.cdagechq
                                           ,crapneg.nrctachq
                                           ,crapneg.cdcooper)
                                  VALUES   (rw_crapsld(idx).ass_nrdconta 
                                           ,vr_nrseqneg
                                           ,4
                                           ,0
                                           ,rw_crapdat.dtmvtolt
                                           ,0
                                           ,0
                                           ,0
                                           ,0
                                           ,rw_crapsld(idx).ass_vllimcre 
                                           ,0
                                           ,0
                                           ,NULL
                                           ,0
                                           ,0
                                           ,0
                                           ,pr_cdcooper);
                     EXCEPTION
                       WHEN OTHERS THEN
                     vr_dscritic := 'Conta '||rw_crapsld(idx).ass_nrdconta ||' --> Erro ao  inserir na tabela crapneg. Cdhisest=4 '||SQLERRM;
                       --Levantar Exceção
                       RAISE vr_exc_saida;
                     END;

                   END IF;
                 END IF;
               END IF;
             END IF;

             /*  Atualiza os saldos mensais  */

             --Valor saldo disponivel extrato recebe saldo disponivel anterior
             rw_crapsld(idx).vldisext:= Nvl(rw_crapsld(idx).vldisant,0);
             --Valor saldo bloqueado extrato recebe saldo bloqueado anterior
             rw_crapsld(idx).vlblqext:= Nvl(rw_crapsld(idx).vlblqant,0);
             --Valor saldo bloqueado na praca extrato recebe bloqueado praca anterior
             rw_crapsld(idx).vlblpext:= Nvl(rw_crapsld(idx).vlblpant,0);
             --Valor saldo bloqueado fora praca recebe valor bloqueado fora praca anterior
             rw_crapsld(idx).vlblfext:= Nvl(rw_crapsld(idx).vlblfant,0);
             --Valor saldo cheque salario extrato recebe valor cheque salario anterior
             rw_crapsld(idx).vlchsext:= Nvl(rw_crapsld(idx).vlchsant,0);
             --Valor saldo bloqueado praca recebe saldo bloqueado praca anterior
             rw_crapsld(idx).vlindext:= Nvl(rw_crapsld(idx).vlindant,0);
             --Saldo disponivel mes anterior recebe valor saldo disponivel
             rw_crapsld(idx).vldisant:= Nvl(rw_crapsld(idx).vlsddisp,0);
             --Saldo bloqueado no mes anterior recebe valor saldo bloqueado
             rw_crapsld(idx).vlblqant:= Nvl(rw_crapsld(idx).vlsdbloq,0);
             --Saldo bloquaedo praca mes anterior recebe valor bloqueado praca
             rw_crapsld(idx).vlblpant:= Nvl(rw_crapsld(idx).vlsdblpr,0);
             --Saldo bloqueado fora praca mes anterior recebe valor bloqueado fora praca
             rw_crapsld(idx).vlblfant:= Nvl(rw_crapsld(idx).vlsdblfp,0);
             --Saldo cheque salario mes anterior recebe valor saldo cheque salario
             rw_crapsld(idx).vlchsant:= Nvl(rw_crapsld(idx).vlsdchsl,0);
             --Saldo indisponivel do mes anterior recebe valor saldo indisponivel
             rw_crapsld(idx).vlindant:= Nvl(rw_crapsld(idx).vlsdindi,0);
             --Saldo inicio do mes anterior recebe saldo final do mes anterior
             rw_crapsld(idx).vlsdextr:= Nvl(rw_crapsld(idx).vlsdmesa,0);
             --Salario liquido mes anterior recebe salario liquido
             rw_crapsld(idx).vltsalan:= Nvl(rw_crapsld(idx).vltsallq,0);
             --saldo final do mes anterior recebe valor disponivel + bloqueado + salario liquido + bloqueado praca + bloqueado fora praca
             rw_crapsld(idx).vlsdmesa:= Nvl(rw_crapsld(idx).vlsddisp,0) + Nvl(rw_crapsld(idx).vlsdbloq,0) +
                                   Nvl(rw_crapsld(idx).vlsdchsl,0) + Nvl(rw_crapsld(idx).vlsdblpr,0) +
                                   Nvl(rw_crapsld(idx).vlsdblfp,0);
             --Data referencia extrato recebe o ultimo dia do mes
             rw_crapsld(idx).dtrefext:= rw_crapdat.dtultdia;         /* Para uso do sist. CASH  */
             --Referencia do saldo para extrato recebe a data referencia saldo anterior
             rw_crapsld(idx).dtsdexes:= rw_crapsld(idx).dtsdanes;
             --data referencia saldo anterior recebe o ultimo dia util
             rw_crapsld(idx).dtsdanes:= rw_crapdat.dtultdia;
             --Saldo para extrato especial recebe o saldo anterior para extrato
             rw_crapsld(idx).vlsdexes:= Nvl(rw_crapsld(idx).vlsdanes,0);
             --saldo anterior para extrato recebe saldo final do mes anterior
             rw_crapsld(idx).vlsdanes:= Nvl(rw_crapsld(idx).vlsdmesa,0);
             --Acumular anual mfx com saldo medio no mes / valor da moeda
             rw_crapsld(idx).qtsmamfx:= Nvl(rw_crapsld(idx).qtsmamfx,0) + Round((Round(Nvl(rw_crapsld(idx).vlsmpmes,0),2)
                                                                       / Nvl(rw_crapmfx.vlmoefix,0)),4);

             /*  Faz ajuste no valor do lcm289  */

             --Executar loop enquanto flag ajuste estiver verdadeiro
             WHILE vr_flgajust LOOP
               -- Se o vetor estiver vazio entao popula
               IF vr_tab_craplcm.Count = 0 THEN
                 --Selecionar informacoes de lancamento historico 289 e montar tabela memoria
                 FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                              ,pr_cdagenci => pr_cdagenci
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdhistor => 289) LOOP
                   vr_tab_craplcm(rw_craplcm.nrdconta).dtmvtolt:= rw_craplcm.dtmvtolt;
                   vr_tab_craplcm(rw_craplcm.nrdconta).cdagenci:= rw_craplcm.cdagenci;
                   vr_tab_craplcm(rw_craplcm.nrdconta).cdbccxlt:= rw_craplcm.cdbccxlt;
                   vr_tab_craplcm(rw_craplcm.nrdconta).nrdolote:= rw_craplcm.nrdolote;
                   vr_tab_craplcm(rw_craplcm.nrdconta).vllanmto:= rw_craplcm.vllanmto;
                   vr_tab_craplcm(rw_craplcm.nrdconta).vrrowid := rw_craplcm.rowid;
                 END LOOP;
               END IF;

               BEGIN
                 --Selecionar informacoes dos lancamentos da conta do saldo
                 IF NOT vr_tab_craplcm.EXISTS(rw_crapsld(idx).nrdconta) THEN
                   RAISE vr_exc_fim;
                 ELSE
                   --Atribuir valores do vetor para o registro
                   rw_craplcm.dtmvtolt:= vr_tab_craplcm(rw_crapsld(idx).nrdconta).dtmvtolt;
                   rw_craplcm.cdagenci:= vr_tab_craplcm(rw_crapsld(idx).nrdconta).cdagenci;
                   rw_craplcm.cdbccxlt:= vr_tab_craplcm(rw_crapsld(idx).nrdconta).cdbccxlt;
                   rw_craplcm.nrdolote:= vr_tab_craplcm(rw_crapsld(idx).nrdconta).nrdolote;
                   rw_craplcm.vllanmto:= vr_tab_craplcm(rw_crapsld(idx).nrdconta).vllanmto;
                   rw_craplcm.rowid   := vr_tab_craplcm(rw_crapsld(idx).nrdconta).vrrowid;

                   -- Se o valor do saldo mes anterior for negativo
                   IF rw_crapsld(idx).vlsdmesa < 0 THEN
                     -- Se o valor do saldo mes anterior + valor dos juros >= 0
                     IF (rw_crapsld(idx).vlsdmesa + vr_vldjuros) >= 0   THEN
                       --Valor ajuste lancamento recebe valor saldo mes anterior * -1
                       vr_vlajulcm:= rw_crapsld(idx).vlsdmesa * -1;
                     ELSE
                       --Valor ajuste lancamento recebe valor dos juros
                       vr_vlajulcm:= vr_vldjuros;
                     END IF;

                     -- Se o valor do lancamento menos o valor ajuste lancamento for > 0
                     IF (rw_craplcm.vllanmto - vr_vlajulcm) > 0 THEN
                       --Diminuir do valor do lancamento o valor do ajuste calculado
                       BEGIN
                         UPDATE craplcm SET craplcm.vllanmto = craplcm.vllanmto - Nvl(vr_vlajulcm,0)
                         WHERE craplcm.ROWID = rw_craplcm.ROWID;
                       EXCEPTION
                         WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao atualizar tabela craplcm Rowid '||rw_craplcm.ROWID||' --> '||SQLERRM;
                           --Sair do programa
                           RAISE vr_exc_saida;
                       END;
                       
                       -- Atualizar lote
                       vr_vlcompcr_ajt := nvl(vr_vlcompcr_ajt,0) - Nvl(vr_vlajulcm,0);
                       vr_vlinfocr_ajt := nvl(vr_vlinfocr_ajt,0) - Nvl(vr_vlajulcm,0);
                       
                       --Se cobrar cpmf
                       IF vr_flgdcpmf THEN
                         --Valor ajuste ipmf recebe valor do ipmf - (valor lancamento * taxa cpmf)
                         vr_vlajuipm:= rw_craplcm.vldoipmf - TRUNC(rw_craplcm.vllanmto * vr_txcpmfcc,2);

                         BEGIN
                           UPDATE craplcm SET craplcm.vldoipmf = craplcm.vldoipmf - Nvl(vr_vlajuipm,0)
                           WHERE craplcm.ROWID = rw_craplcm.ROWID;
                         EXCEPTION
                           WHEN OTHERS THEN
                           vr_dscritic :=  'Erro ao atualizar tabela craplcm Rowid '||rw_craplcm.ROWID||' --> '||SQLERRM;
                             --Sair do programa
                             RAISE vr_exc_saida;
                         END;
                       END IF;
                     ELSE
                       
                       -- Atualizar lote
                       vr_vlcompcr_ajt := nvl(vr_vlcompcr_ajt,0) - Nvl(vr_vlajulcm,0);
                       vr_vlinfocr_ajt := nvl(vr_vlinfocr_ajt,0) - Nvl(vr_vlajulcm,0);
                       vr_qtcompln_ajt := nvl(vr_qtcompln_ajt,0) - 1;
                       vr_qtinfoln_ajt := nvl(vr_qtinfoln_ajt,0) - 1;
                       
                       --Se cobrar cpmf
                       IF vr_flgdcpmf THEN
                         --Valor ajuste lancamento recebe valor do lancamento
                         vr_vlajulcm:= Nvl(rw_craplcm.vllanmto,0);
                         --Valor ajuste do ipmf recebe valor do ipmf
                         vr_vlajuipm:= Nvl(rw_craplcm.vldoipmf,0);
                       END IF;

                       --Excluir o lancamento
                       BEGIN
                         DELETE craplcm
                         WHERE craplcm.ROWID = rw_craplcm.ROWID;
                       EXCEPTION
                         WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao excluir lancamento Rowid '||rw_craplcm.ROWID||' --> '||SQLERRM;
                           --Sair do programa
                           RAISE vr_exc_saida;
                       END;
                     END IF;

                     --Se cobrar cpmf
                     IF vr_flgdcpmf THEN
                       --Se for encerramento
                       IF vr_flgencer THEN
                         BEGIN

                           --Valor do ipmf a pagar recebe valor ipmf a pagar menos juros ipmf
                           rw_crapsld(idx).vlipmfpg:= Nvl(rw_crapsld(idx).vlipmfpg,0) - Nvl(vr_vlajuipm,0);

                           --Atualizar informacoes de debitos de ipmf
                           UPDATE crapipm SET crapipm.vlbasipm = Nvl(crapipm.vlbasipm,0) - Nvl(vr_vlajulcm,0)
                                             ,crapipm.vldoipmf = Nvl(crapipm.vldoipmf,0) - Nvl(vr_vlajuipm,0)
                           WHERE crapipm.cdcooper = pr_cdcooper
                           AND   crapipm.nrdconta = rw_crapsld(idx).nrdconta
                           AND   crapipm.dtdebito = rw_crapper.dtdebito
                           AND   crapipm.indebito = 1;

                           --Se não atualizou nada
                           IF SQL%ROWCOUNT = 0 THEN
                             --Buscar mensagem de erro da critica
                           vr_dscritic :=  ' CONTA: '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||
                                           ' PERIODO: '||To_Char(rw_crapper.dtdebito,'DD/MM/YYYY')||
                                           ' --> ERRO! - CRAPIPM NAO ENCONTRADO -';
                             --Sair do programa
                             RAISE vr_exc_saida;
                           END IF;
                         EXCEPTION
                         WHEN vr_exc_saida THEN
                           RAISE vr_Exc_saida;
                           WHEN OTHERS THEN
                           vr_dscritic := ' CONTA: '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> Erro ao atualizar crapipm. '||SQLERRM;
                             --Sair do programa
                             RAISE vr_exc_saida;
                         END;
                       ELSE --nao for encerramento
                         --Valor base ipmf recebe valor base ipmf - valor ajuste do lancamento
                         rw_crapsld(idx).vlbasipm:= Nvl(rw_crapsld(idx).vlbasipm,0) - Nvl(vr_vlajulcm,0);
                         --Valor ipmf apurado recebe valor ipmf apurado menos valor ajuste ipmf
                         rw_crapsld(idx).vlipmfap:= Nvl(rw_crapsld(idx).vlipmfap,0) - Nvl(vr_vlajuipm,0);
                       END IF;
                     END IF;
                   END IF;
                 END IF;
                 --Sair do while
                 EXIT;
               EXCEPTION
                 WHEN vr_exc_fim THEN
                   --Atribuir false para flag fazendo sair do loop
                   vr_flgajust:= FALSE;
               END;
             END LOOP; --While

             --Variavel recebe o mes do movimento 1..12
             vr_mesmovto:= to_number(To_Char(rw_crapdat.dtmvtolt,'MM'));
             --Se passou da metade do ano
             IF vr_mesmovto > 6 THEN
               --Diminuir 6 do mes encontrado
               vr_mesmovto:= vr_mesmovto-6;
             END IF;

             --Valor do saldo medio mensal recebe o valor positivo no mes
             CASE vr_mesmovto
               WHEN 1 THEN
                 rw_crapsld(idx).vlsmstre##1:= Nvl(rw_crapsld(idx).vlsmpmes,0);
               WHEN 2 THEN
                 rw_crapsld(idx).vlsmstre##2:= Nvl(rw_crapsld(idx).vlsmpmes,0);
               WHEN 3 THEN
                 rw_crapsld(idx).vlsmstre##3:= Nvl(rw_crapsld(idx).vlsmpmes,0);
               WHEN 4 THEN
                 rw_crapsld(idx).vlsmstre##4:= Nvl(rw_crapsld(idx).vlsmpmes,0);
               WHEN 5 THEN
                 rw_crapsld(idx).vlsmstre##5:= Nvl(rw_crapsld(idx).vlsmpmes,0);
               WHEN 6 THEN
                 rw_crapsld(idx).vlsmstre##6:= Nvl(rw_crapsld(idx).vlsmpmes,0);
             END CASE;

             --Variavel recebe o mes do movimento 1..12
             vr_mesmovto:= to_number(To_Char(rw_crapdat.dtmvtolt,'MM'));

             --Atualizar informacoes na tabela de saldo para cada mes
             --smposano = Valor do saldo medio positivo no ano recebe o valor positivo no mes
             --smnegano = Valor do saldo medio negativo no ano recebe o valor negativo no mes
             --smblqano = Valor do saldo medio bloqueado no ano recebe o valor media saque
             --smespano = Valor do saldo medio ch. especial no ano recebe valor negativo especial no mes
             CASE vr_mesmovto
               WHEN 1 THEN
                 rw_crapsld(idx).smposano##1:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##1:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##1:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##1:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 2 THEN
                 rw_crapsld(idx).smposano##2:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##2:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##2:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##2:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 3 THEN
                 rw_crapsld(idx).smposano##3:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##3:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##3:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##3:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 4 THEN
                 rw_crapsld(idx).smposano##4:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##4:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##4:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##4:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 5 THEN
                 rw_crapsld(idx).smposano##5:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##5:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##5:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##5:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 6 THEN
                 rw_crapsld(idx).smposano##6:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##6:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##6:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##6:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 7 THEN
                 rw_crapsld(idx).smposano##7:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##7:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##7:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##7:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 8 THEN
                 rw_crapsld(idx).smposano##8:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##8:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##8:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##8:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 9 THEN
                 rw_crapsld(idx).smposano##9:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##9:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##9:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##9:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 10 THEN
                 rw_crapsld(idx).smposano##10:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##10:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##10:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##10:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 11 THEN
                 rw_crapsld(idx).smposano##11:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##11:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##11:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##11:= Nvl(rw_crapsld(idx).vlsmnesp,0);
               WHEN 12 THEN
                 rw_crapsld(idx).smposano##12:= Nvl(rw_crapsld(idx).vlsmpmes,0);
                 rw_crapsld(idx).smnegano##12:= Nvl(rw_crapsld(idx).vlsmnmes,0);
                 rw_crapsld(idx).smblqano##12:= Nvl(rw_crapsld(idx).vlsmnblq,0);
                 rw_crapsld(idx).smespano##12:= Nvl(rw_crapsld(idx).vlsmnesp,0);
             END CASE;


             --Incrementar a quantidade de lancamentos no ano com os lancamentos do mes
             rw_crapsld(idx).qtlanano:= Nvl(rw_crapsld(idx).qtlanano,0) + Nvl(rw_crapsld(idx).qtlanmes,0);
             --Zerar quantidade de lancamentos do mes
             rw_crapsld(idx).qtlanmes:= 0;
             --Zerar valor negativo especial no mes
             rw_crapsld(idx).vlsmnesp:= 0;
             --Zerar valor negativo no mes
             rw_crapsld(idx).vlsmnmes:= 0;
             --Zerar media saque s/ bloqueado
             rw_crapsld(idx).vlsmnblq:= 0;
             --Zerar valor positivo no mes
             rw_crapsld(idx).vlsmpmes:= 0;
             --Zerar valor salario liquido
             rw_crapsld(idx).vltsallq:= 0;

             /*--- Calculo do IOF ---*/
             --Se taxa IOF > 0 e valor saldo disponivel < 0
             IF rw_crapsld(idx).vlsddisp < 0  THEN
               --Zerar valor base iof
               vr_vlbasiof:= 0;

               --Selecionar informacoes do saldo da conta dos associados (usando dtmvtoan)
               IF rw_crapsld(idx).vlsldoan IS NOT NULL THEN
                 vr_vlsldoan := rw_crapsld(idx).vlsldoan;
               ELSE
                 --Buscar mensagem de erro da critica
                 vr_cdcritic:= 10;
                 vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                 --Sair do programa
                 RAISE vr_exc_saida;
               END IF;

               --Selecionar informacoes do saldo da conta dos associados (usando dtmvtolt)
               IF rw_crapsld(idx).vlsldolt IS NOT NULL THEN
                 vr_vlsldolt := rw_crapsld(idx).vlsldolt;
               ELSE
                 --Buscar mensagem de erro da critica
                 vr_cdcritic := 10;
                 vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                 --Sair do programa
                 RAISE vr_exc_saida;
               END IF;

               --Se o valor disponivel maior igual a zero
               IF vr_vlsldolt >= 0 THEN
                 --Se valor disponivel maior ou igual a zero
                 IF vr_vlsldoan >= 0  THEN
                   --Valor base iof recebe valor disponivel * -1
                   vr_vlbasiof:= rw_crapsld(idx).vlsddisp * -1;
                 ELSIF  rw_crapsld(idx).vlsddisp < vr_vlsldoan  THEN
                   --Valor base iof recebe valor disponivel na data do movimento menos o disponivel na anterior
                   vr_vlbasiof:= Nvl(vr_vlsldoan,0) - Nvl(rw_crapsld(idx).vlsddisp,0);
                 END IF;
               ELSE
                 --Se valor disponivel na saldo for menor que o saldo disponivel do associado no movto atual
                 --   valor disponivel na saldo for menor que o saldo disponivel do associado no movto anterior
                 IF rw_crapsld(idx).vlsddisp < vr_vlsldolt  AND
                    rw_crapsld(idx).vlsddisp < vr_vlsldoan  THEN
                   --Se saldo disponivel do associado no movto atual maior saldo disponivel no movto anterior
                   IF vr_vlsldolt > vr_vlsldoan THEN
                     --Valor base iof recebe saldo disponivel do associado no movimento anterior menos saldo disponivel
                     vr_vlbasiof:= Nvl(vr_vlsldoan,0) - Nvl(rw_crapsld(idx).vlsddisp,0);
                   ELSE
                     --Valor base iof recebe saldo disponivel do associado no movimento atual menos saldo disponivel
                     vr_vlbasiof:= Nvl(vr_vlsldolt,0) - Nvl(rw_crapsld(idx).vlsddisp,0);
                   END IF;
                 END IF;
               END IF;
                 
               --Se valor base iof for maior zero
               IF vr_vlbasiof > 0 THEN
                 --Atualizar valor base iof na tabela saldo
                 rw_crapsld(idx).vlbasiof := Nvl(rw_crapsld(idx).vlbasiof,0) + Nvl(vr_vlbasiof,0);
                 -----------------------------------------------------------------------------------------------
                 -- Calcula o Valor do IOF Adicional
                 -----------------------------------------------------------------------------------------------
                 TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 5           --> Adiantamento a Depositante
                                              ,pr_tpoperacao => 1           --> Calculo de Inclusao/Atraso
                                              ,pr_cdcooper   => pr_cdcooper
                                              ,pr_nrdconta   => rw_crapsld(idx).nrdconta
                                              ,pr_inpessoa   => rw_crapsld(idx).ass_inpessoa
                                              ,pr_natjurid   => vr_natjurid
                                              ,pr_tpregtrb   => vr_tpregtrb
                                              ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                                              ,pr_qtdiaiof   => 1
                                              ,pr_vloperacao => ROUND(vr_vlbasiof,2)
                                              ,pr_vltotalope => NVL(ABS(rw_crapsld(idx).vlsddisp),0) + NVL(rw_crapsld(idx).ass_vllimcre,0)
                                              ,pr_vliofpri   => vr_vliofpri
                                              ,pr_vliofadi   => vr_vliofadi
                                              ,pr_vliofcpl   => vr_vliofcpl
                                              ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                              ,pr_flgimune   => vr_flgimune
                                              ,pr_dscritic   => vr_dscritic);
                     
                 -- Condicao para verificar se houve critica                             
                 IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||vr_dscritic;
                   RAISE vr_exc_saida;
                 END IF;
                 
                 -----------------------------------------------------------------------------------------------
                 -- Efetuar a gravacao do IOF
                 -----------------------------------------------------------------------------------------------
                 TIOF0001.pc_insere_iof(pr_cdcooper   => pr_cdcooper
                                       ,pr_nrdconta   => rw_crapsld(idx).nrdconta
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                                       ,pr_tpproduto  => 5   --> Adiantamento a Depositante
                                       ,pr_nrcontrato => 0
                                       ,pr_vliofpri   => vr_vliofpri
                                       ,pr_vliofadi   => vr_vliofadi
                                       ,pr_flgimune   => vr_flgimune
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
                                       
                 -- Condicao para verificar se houve critica                             
                 IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld(idx).nrdconta)||' --> '||vr_dscritic;
                   RAISE vr_exc_saida;
                 END IF;                                       
                   
                 -- Atualizar valor do iof no mes na tabela de saldo
                 IF vr_flgimune = 0 THEN
                 rw_crapsld(idx).vliofmes:= Nvl(rw_crapsld(idx).vliofmes,0) + ROUND(NVL(vr_vliofadi,0),2) + ROUND(NVL(vr_vliofpri,0),2);
                 ELSE
                    rw_crapsld(idx).vliofmes:= Nvl(rw_crapsld(idx).vliofmes,0);
                 END IF;
               END IF;
                 
             END IF;

             --Atualizar tabela de cotas
             BEGIN
               --Atualizar valor base Conta Corrente IOF e valor IOF sobre a Conta Corrente
               UPDATE crapcot SET crapcot.vlbsicct = Nvl(crapcot.vlbsicct,0) + Nvl(rw_crapsld(idx).vlbasiof,0)
                                 ,crapcot.vliofcct = Nvl(crapcot.vliofcct,0) + Nvl(rw_crapsld(idx).vliofmes,0)
                WHERE crapcot.ROWID = vr_crapcot;
             EXCEPTION
               WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar tabela crapcot Rowid '||vr_crapcot||' --> '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
             END;

             --Atualizar valor disponivel na tabela de saldos
             BEGIN
               UPDATE crapsda SET crapsda.vlsddisp = Nvl(rw_crapsld(idx).vlsddisp,0)
               WHERE crapsda.cdcooper = pr_cdcooper
               AND   crapsda.nrdconta = rw_crapsld(idx).nrdconta
               AND   crapsda.dtmvtolt = rw_crapdat.dtmvtolt;
             EXCEPTION
               WHEN OTHERS THEN
             vr_dscritic := 'Conta '||rw_crapsld(idx).nrdconta||' --> Erro ao atualizar tabela crapsda: '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
             END;

             --Atualizar a tabela Saldos
             vr_idx := vr_idx + 1;
             vr_tab_crapsld(vr_idx).nrdconta := rw_crapsld(idx).nrdconta;
             vr_tab_crapsld(vr_idx).vljuresp := rw_crapsld(idx).vljuresp;
             vr_tab_crapsld(vr_idx).vljurmes := rw_crapsld(idx).vljurmes;
             vr_tab_crapsld(vr_idx).vljursaq := rw_crapsld(idx).vljursaq;
             vr_tab_crapsld(vr_idx).qtjramfx := rw_crapsld(idx).qtjramfx;
             vr_tab_crapsld(vr_idx).qtlanmes := rw_crapsld(idx).qtlanmes;
             vr_tab_crapsld(vr_idx).vlsddisp := rw_crapsld(idx).vlsddisp;
             vr_tab_crapsld(vr_idx).vlipmfpg := rw_crapsld(idx).vlipmfpg;
             vr_tab_crapsld(vr_idx).vlipmfap := rw_crapsld(idx).vlipmfap;
             vr_tab_crapsld(vr_idx).vlbasipm := rw_crapsld(idx).vlbasipm;
             vr_tab_crapsld(vr_idx).qtddsdev := rw_crapsld(idx).qtddsdev;
             vr_tab_crapsld(vr_idx).qtddtdev := rw_crapsld(idx).qtddtdev;
             vr_tab_crapsld(vr_idx).qtdriclq := rw_crapsld(idx).qtdriclq;
             vr_tab_crapsld(vr_idx).dtrisclq := rw_crapsld(idx).dtrisclq;
             vr_tab_crapsld(vr_idx).dtdsdclq := rw_crapsld(idx).dtdsdclq;
             vr_tab_crapsld(vr_idx).vldisext := rw_crapsld(idx).vldisext;
             vr_tab_crapsld(vr_idx).vlblqext := rw_crapsld(idx).vlblqext;
             vr_tab_crapsld(vr_idx).vlblpext := rw_crapsld(idx).vlblpext;
             vr_tab_crapsld(vr_idx).vlblfext := rw_crapsld(idx).vlblfext;
             vr_tab_crapsld(vr_idx).vlchsext := rw_crapsld(idx).vlchsext;
             vr_tab_crapsld(vr_idx).vlindext := rw_crapsld(idx).vlindext;
             vr_tab_crapsld(vr_idx).vldisant := rw_crapsld(idx).vldisant;
             vr_tab_crapsld(vr_idx).vlblqant := rw_crapsld(idx).vlblqant;
             vr_tab_crapsld(vr_idx).vlblpant := rw_crapsld(idx).vlblpant;
             vr_tab_crapsld(vr_idx).vlblfant := rw_crapsld(idx).vlblfant;
             vr_tab_crapsld(vr_idx).vlchsant := rw_crapsld(idx).vlchsant;
             vr_tab_crapsld(vr_idx).vlindant := rw_crapsld(idx).vlindant;
             vr_tab_crapsld(vr_idx).vlsdextr := rw_crapsld(idx).vlsdextr;
             vr_tab_crapsld(vr_idx).vltsalan := rw_crapsld(idx).vltsalan;
             vr_tab_crapsld(vr_idx).vlsdmesa := rw_crapsld(idx).vlsdmesa;
             vr_tab_crapsld(vr_idx).dtrefext := rw_crapsld(idx).dtrefext;
             vr_tab_crapsld(vr_idx).dtsdexes := rw_crapsld(idx).dtsdexes;
             vr_tab_crapsld(vr_idx).dtsdanes := rw_crapsld(idx).dtsdanes;
             vr_tab_crapsld(vr_idx).vlsdexes := rw_crapsld(idx).vlsdexes;
             vr_tab_crapsld(vr_idx).vlsdanes := rw_crapsld(idx).vlsdanes;
             vr_tab_crapsld(vr_idx).qtsmamfx := rw_crapsld(idx).qtsmamfx;
             vr_tab_crapsld(vr_idx).qtlanano := rw_crapsld(idx).qtlanano;
             vr_tab_crapsld(vr_idx).vlsmnesp := rw_crapsld(idx).vlsmnesp;
             vr_tab_crapsld(vr_idx).vlsmnmes := rw_crapsld(idx).vlsmnmes;
             vr_tab_crapsld(vr_idx).vlsmnblq := rw_crapsld(idx).vlsmnblq;
             vr_tab_crapsld(vr_idx).vlsmpmes := rw_crapsld(idx).vlsmpmes;
             vr_tab_crapsld(vr_idx).vltsallq := rw_crapsld(idx).vltsallq;
             vr_tab_crapsld(vr_idx).vlbasiof := rw_crapsld(idx).vlbasiof;
             vr_tab_crapsld(vr_idx).vliofmes := rw_crapsld(idx).vliofmes;
             vr_tab_crapsld(vr_idx).vlsmstre##1  := rw_crapsld(idx).vlsmstre##1;
             vr_tab_crapsld(vr_idx).vlsmstre##2  := rw_crapsld(idx).vlsmstre##2;
             vr_tab_crapsld(vr_idx).vlsmstre##3  := rw_crapsld(idx).vlsmstre##3;
             vr_tab_crapsld(vr_idx).vlsmstre##4  := rw_crapsld(idx).vlsmstre##4;
             vr_tab_crapsld(vr_idx).vlsmstre##5  := rw_crapsld(idx).vlsmstre##5;
             vr_tab_crapsld(vr_idx).vlsmstre##6  := rw_crapsld(idx).vlsmstre##6;
             vr_tab_crapsld(vr_idx).smposano##1  := rw_crapsld(idx).smposano##1;
             vr_tab_crapsld(vr_idx).smposano##2  := rw_crapsld(idx).smposano##2;
             vr_tab_crapsld(vr_idx).smposano##3  := rw_crapsld(idx).smposano##3;
             vr_tab_crapsld(vr_idx).smposano##4  := rw_crapsld(idx).smposano##4;
             vr_tab_crapsld(vr_idx).smposano##5  := rw_crapsld(idx).smposano##5;
             vr_tab_crapsld(vr_idx).smposano##6  := rw_crapsld(idx).smposano##6;
             vr_tab_crapsld(vr_idx).smposano##7  := rw_crapsld(idx).smposano##7;
             vr_tab_crapsld(vr_idx).smposano##8  := rw_crapsld(idx).smposano##8;
             vr_tab_crapsld(vr_idx).smposano##9  := rw_crapsld(idx).smposano##9;
             vr_tab_crapsld(vr_idx).smposano##10 := rw_crapsld(idx).smposano##10;
             vr_tab_crapsld(vr_idx).smposano##11 := rw_crapsld(idx).smposano##11;
             vr_tab_crapsld(vr_idx).smposano##12 := rw_crapsld(idx).smposano##12;
             vr_tab_crapsld(vr_idx).smnegano##1  := rw_crapsld(idx).smnegano##1;
             vr_tab_crapsld(vr_idx).smnegano##2  := rw_crapsld(idx).smnegano##2;
             vr_tab_crapsld(vr_idx).smnegano##3  := rw_crapsld(idx).smnegano##3;
             vr_tab_crapsld(vr_idx).smnegano##4  := rw_crapsld(idx).smnegano##4;
             vr_tab_crapsld(vr_idx).smnegano##5  := rw_crapsld(idx).smnegano##5;
             vr_tab_crapsld(vr_idx).smnegano##6  := rw_crapsld(idx).smnegano##6;
             vr_tab_crapsld(vr_idx).smnegano##7  := rw_crapsld(idx).smnegano##7;
             vr_tab_crapsld(vr_idx).smnegano##8  := rw_crapsld(idx).smnegano##8;
             vr_tab_crapsld(vr_idx).smnegano##9  := rw_crapsld(idx).smnegano##9;
             vr_tab_crapsld(vr_idx).smnegano##10 := rw_crapsld(idx).smnegano##10;
             vr_tab_crapsld(vr_idx).smnegano##11 := rw_crapsld(idx).smnegano##11;
             vr_tab_crapsld(vr_idx).smnegano##12 := rw_crapsld(idx).smnegano##12;
             vr_tab_crapsld(vr_idx).smblqano##1  := rw_crapsld(idx).smblqano##1;
             vr_tab_crapsld(vr_idx).smblqano##2  := rw_crapsld(idx).smblqano##2;
             vr_tab_crapsld(vr_idx).smblqano##3  := rw_crapsld(idx).smblqano##3;
             vr_tab_crapsld(vr_idx).smblqano##4  := rw_crapsld(idx).smblqano##4;
             vr_tab_crapsld(vr_idx).smblqano##5  := rw_crapsld(idx).smblqano##5;
             vr_tab_crapsld(vr_idx).smblqano##6  := rw_crapsld(idx).smblqano##6;
             vr_tab_crapsld(vr_idx).smblqano##7  := rw_crapsld(idx).smblqano##7;
             vr_tab_crapsld(vr_idx).smblqano##8  := rw_crapsld(idx).smblqano##8;
             vr_tab_crapsld(vr_idx).smblqano##9  := rw_crapsld(idx).smblqano##9;
             vr_tab_crapsld(vr_idx).smblqano##10 := rw_crapsld(idx).smblqano##10;
             vr_tab_crapsld(vr_idx).smblqano##11 := rw_crapsld(idx).smblqano##11;
             vr_tab_crapsld(vr_idx).smblqano##12 := rw_crapsld(idx).smblqano##12;
             vr_tab_crapsld(vr_idx).smespano##1  := rw_crapsld(idx).smespano##1;
             vr_tab_crapsld(vr_idx).smespano##2  := rw_crapsld(idx).smespano##2;
             vr_tab_crapsld(vr_idx).smespano##3  := rw_crapsld(idx).smespano##3;
             vr_tab_crapsld(vr_idx).smespano##4  := rw_crapsld(idx).smespano##4;
             vr_tab_crapsld(vr_idx).smespano##5  := rw_crapsld(idx).smespano##5;
             vr_tab_crapsld(vr_idx).smespano##6  := rw_crapsld(idx).smespano##6;
             vr_tab_crapsld(vr_idx).smespano##7  := rw_crapsld(idx).smespano##7;
             vr_tab_crapsld(vr_idx).smespano##8  := rw_crapsld(idx).smespano##8;
             vr_tab_crapsld(vr_idx).smespano##9  := rw_crapsld(idx).smespano##9;
             vr_tab_crapsld(vr_idx).smespano##10 := rw_crapsld(idx).smespano##10;
             vr_tab_crapsld(vr_idx).smespano##11 := rw_crapsld(idx).smespano##11;
             vr_tab_crapsld(vr_idx).smespano##12 := rw_crapsld(idx).smespano##12;
           END LOOP; -- Bulk
         END LOOP; --rw_crapsld(idx)
         CLOSE cr_crapsld;
         
         -- Atualiza a tabela de saldos com os registros restantes ainda não gravados
         BEGIN
           FORALL idx IN INDICES OF vr_tab_crapsld SAVE EXCEPTIONS
             UPDATE crapsld SET  crapsld.vljuresp = vr_tab_crapsld(idx).vljuresp
                                ,crapsld.vljurmes = vr_tab_crapsld(idx).vljurmes
                                ,crapsld.vljursaq = vr_tab_crapsld(idx).vljursaq
                                ,crapsld.qtjramfx = vr_tab_crapsld(idx).qtjramfx
                                ,crapsld.qtlanmes = vr_tab_crapsld(idx).qtlanmes
                                ,crapsld.vlsddisp = vr_tab_crapsld(idx).vlsddisp
                                ,crapsld.vlipmfpg = vr_tab_crapsld(idx).vlipmfpg
                                ,crapsld.vlipmfap = vr_tab_crapsld(idx).vlipmfap
                                ,crapsld.vlbasipm = vr_tab_crapsld(idx).vlbasipm
                                ,crapsld.qtddsdev = vr_tab_crapsld(idx).qtddsdev
                                ,crapsld.qtddtdev = vr_tab_crapsld(idx).qtddtdev
                                ,crapsld.qtdriclq = vr_tab_crapsld(idx).qtdriclq
                                ,crapsld.dtrisclq = vr_tab_crapsld(idx).dtrisclq
                                ,crapsld.dtdsdclq = vr_tab_crapsld(idx).dtdsdclq
                                ,crapsld.vldisext = vr_tab_crapsld(idx).vldisext
                                ,crapsld.vlblqext = vr_tab_crapsld(idx).vlblqext
                                ,crapsld.vlblpext = vr_tab_crapsld(idx).vlblpext
                                ,crapsld.vlblfext = vr_tab_crapsld(idx).vlblfext
                                ,crapsld.vlchsext = vr_tab_crapsld(idx).vlchsext
                                ,crapsld.vlindext = vr_tab_crapsld(idx).vlindext
                                ,crapsld.vldisant = vr_tab_crapsld(idx).vldisant
                                ,crapsld.vlblqant = vr_tab_crapsld(idx).vlblqant
                                ,crapsld.vlblpant = vr_tab_crapsld(idx).vlblpant
                                ,crapsld.vlblfant = vr_tab_crapsld(idx).vlblfant
                                ,crapsld.vlchsant = vr_tab_crapsld(idx).vlchsant
                                ,crapsld.vlindant = vr_tab_crapsld(idx).vlindant
                                ,crapsld.vlsdextr = vr_tab_crapsld(idx).vlsdextr
                                ,crapsld.vltsalan = vr_tab_crapsld(idx).vltsalan
                                ,crapsld.vlsdmesa = vr_tab_crapsld(idx).vlsdmesa
                                ,crapsld.dtrefext = vr_tab_crapsld(idx).dtrefext
                                ,crapsld.dtsdexes = vr_tab_crapsld(idx).dtsdexes
                                ,crapsld.dtsdanes = vr_tab_crapsld(idx).dtsdanes
                                ,crapsld.vlsdexes = vr_tab_crapsld(idx).vlsdexes
                                ,crapsld.vlsdanes = vr_tab_crapsld(idx).vlsdanes
                                ,crapsld.qtsmamfx = vr_tab_crapsld(idx).qtsmamfx
                                ,crapsld.qtlanano = vr_tab_crapsld(idx).qtlanano
                                ,crapsld.vlsmnesp = vr_tab_crapsld(idx).vlsmnesp
                                ,crapsld.vlsmnmes = vr_tab_crapsld(idx).vlsmnmes
                                ,crapsld.vlsmnblq = vr_tab_crapsld(idx).vlsmnblq
                                ,crapsld.vlsmpmes = vr_tab_crapsld(idx).vlsmpmes
                                ,crapsld.vltsallq = vr_tab_crapsld(idx).vltsallq
                                ,crapsld.vlbasiof = vr_tab_crapsld(idx).vlbasiof
                                ,crapsld.vliofmes = vr_tab_crapsld(idx).vliofmes
                                ,crapsld.vlsmstre##1  = vr_tab_crapsld(idx).vlsmstre##1
                                ,crapsld.vlsmstre##2  = vr_tab_crapsld(idx).vlsmstre##2
                                ,crapsld.vlsmstre##3  = vr_tab_crapsld(idx).vlsmstre##3
                                ,crapsld.vlsmstre##4  = vr_tab_crapsld(idx).vlsmstre##4
                                ,crapsld.vlsmstre##5  = vr_tab_crapsld(idx).vlsmstre##5
                                ,crapsld.vlsmstre##6  = vr_tab_crapsld(idx).vlsmstre##6
                                ,crapsld.smposano##1  = vr_tab_crapsld(idx).smposano##1
                                ,crapsld.smposano##2  = vr_tab_crapsld(idx).smposano##2
                                ,crapsld.smposano##3  = vr_tab_crapsld(idx).smposano##3
                                ,crapsld.smposano##4  = vr_tab_crapsld(idx).smposano##4
                                ,crapsld.smposano##5  = vr_tab_crapsld(idx).smposano##5
                                ,crapsld.smposano##6  = vr_tab_crapsld(idx).smposano##6
                                ,crapsld.smposano##7  = vr_tab_crapsld(idx).smposano##7
                                ,crapsld.smposano##8  = vr_tab_crapsld(idx).smposano##8
                                ,crapsld.smposano##9  = vr_tab_crapsld(idx).smposano##9
                                ,crapsld.smposano##10 = vr_tab_crapsld(idx).smposano##10
                                ,crapsld.smposano##11 = vr_tab_crapsld(idx).smposano##11
                                ,crapsld.smposano##12 = vr_tab_crapsld(idx).smposano##12
                                ,crapsld.smnegano##1  = vr_tab_crapsld(idx).smnegano##1
                                ,crapsld.smnegano##2  = vr_tab_crapsld(idx).smnegano##2
                                ,crapsld.smnegano##3  = vr_tab_crapsld(idx).smnegano##3
                                ,crapsld.smnegano##4  = vr_tab_crapsld(idx).smnegano##4
                                ,crapsld.smnegano##5  = vr_tab_crapsld(idx).smnegano##5
                                ,crapsld.smnegano##6  = vr_tab_crapsld(idx).smnegano##6
                                ,crapsld.smnegano##7  = vr_tab_crapsld(idx).smnegano##7
                                ,crapsld.smnegano##8  = vr_tab_crapsld(idx).smnegano##8
                                ,crapsld.smnegano##9  = vr_tab_crapsld(idx).smnegano##9
                                ,crapsld.smnegano##10 = vr_tab_crapsld(idx).smnegano##10
                                ,crapsld.smnegano##11 = vr_tab_crapsld(idx).smnegano##11
                                ,crapsld.smnegano##12 = vr_tab_crapsld(idx).smnegano##12
                                ,crapsld.smblqano##1  = vr_tab_crapsld(idx).smblqano##1
                                ,crapsld.smblqano##2  = vr_tab_crapsld(idx).smblqano##2
                                ,crapsld.smblqano##3  = vr_tab_crapsld(idx).smblqano##3
                                ,crapsld.smblqano##4  = vr_tab_crapsld(idx).smblqano##4
                                ,crapsld.smblqano##5  = vr_tab_crapsld(idx).smblqano##5
                                ,crapsld.smblqano##6  = vr_tab_crapsld(idx).smblqano##6
                                ,crapsld.smblqano##7  = vr_tab_crapsld(idx).smblqano##7
                                ,crapsld.smblqano##8  = vr_tab_crapsld(idx).smblqano##8
                                ,crapsld.smblqano##9  = vr_tab_crapsld(idx).smblqano##9
                                ,crapsld.smblqano##10 = vr_tab_crapsld(idx).smblqano##10
                                ,crapsld.smblqano##11 = vr_tab_crapsld(idx).smblqano##11
                                ,crapsld.smblqano##12 = vr_tab_crapsld(idx).smblqano##12
                                ,crapsld.smespano##1  = vr_tab_crapsld(idx).smespano##1
                                ,crapsld.smespano##2  = vr_tab_crapsld(idx).smespano##2
                                ,crapsld.smespano##3  = vr_tab_crapsld(idx).smespano##3
                                ,crapsld.smespano##4  = vr_tab_crapsld(idx).smespano##4
                                ,crapsld.smespano##5  = vr_tab_crapsld(idx).smespano##5
                                ,crapsld.smespano##6  = vr_tab_crapsld(idx).smespano##6
                                ,crapsld.smespano##7  = vr_tab_crapsld(idx).smespano##7
                                ,crapsld.smespano##8  = vr_tab_crapsld(idx).smespano##8
                                ,crapsld.smespano##9  = vr_tab_crapsld(idx).smespano##9
                                ,crapsld.smespano##10 = vr_tab_crapsld(idx).smespano##10
                                ,crapsld.smespano##11 = vr_tab_crapsld(idx).smespano##11
                                ,crapsld.smespano##12 = vr_tab_crapsld(idx).smespano##12
             WHERE crapsld.cdcooper = pr_cdcooper
               AND crapsld.nrdconta = vr_tab_crapsld(idx).nrdconta;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar tabela crapsld. '||
                              SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
              -- Sair do programa
              RAISE vr_exc_saida;
         END;
         
         -- Para execuções paralelas
         IF pr_cdagenci > 0 THEN 
         
           -- Gravar informações do lote 8450
           IF vr_vlinfocr > 0 OR vr_vlcompcr > 0 
           OR vr_vlinfodb > 0 OR vr_vlcompdb > 0 
           OR vr_qtinfoln > 0 OR vr_qtcompln > 0 THEN  
             -- Rotina para inserir em tabela de trabalho para atualização da crplot no CRPS148
             BEGIN
               insert into tbgen_batch_relatorio_wrk(cdcooper
                                                    ,cdprograma
                                                    ,dsrelatorio
                                                    ,dtmvtolt
                                                    ,dschave
                                                    ,cdagenci
                                                    ,dscritic)
                                              values(pr_cdcooper
                                                    ,vr_cdprogra
                                                    ,'CRAPLOT_8450'
                                                    ,rw_crapdat.dtmvtolt
                                                    ,pr_cdagenci
                                                    ,pr_cdagenci
                                                    ,';'||vr_vlinfocr||';'||     
                                                          vr_vlcompcr||';'||
                                                          vr_vlinfodb||';'||
                                                          vr_vlcompdb||';'||
                                                          vr_qtinfoln||';'||
                                                          vr_qtcompln||';');
             
             EXCEPTION
               WHEN OTHERS THEN 
                 vr_dscritic := 'Erro ao inserir tbgen_batch_relatorio_wrk 8450: '||sqlerrm;  
                 raise vr_exc_saida; 
             END;
           END IF;
           
           -- Gravar informações do lote 8476
           IF vr_vlinfocr_ajt > 0 OR vr_vlcompcr_ajt > 0 
           OR vr_vlinfodb_ajt > 0 OR vr_vlcompdb_ajt > 0 
           OR vr_qtinfoln_ajt > 0 OR vr_qtcompln_ajt > 0 THEN  
             -- Rotina para inserir em tabela de trabalho para atualização da crplot no CRPS148
             BEGIN
               insert into tbgen_batch_relatorio_wrk(cdcooper
                                                    ,cdprograma
                                                    ,dsrelatorio
                                                    ,dtmvtolt
                                                    ,dschave
                                                    ,cdagenci
                                                    ,dscritic)
                                              values(pr_cdcooper
                                                    ,vr_cdprogra
                                                    ,'CRAPLOT_8476'
                                                    ,rw_crapdat.dtmvtolt
                                                    ,pr_cdagenci
                                                    ,pr_cdagenci
                                                    ,';'||vr_vlinfocr_ajt||';'||     
                                                          vr_vlcompcr_ajt||';'||
                                                          vr_vlinfodb_ajt||';'||
                                                          vr_vlcompdb_ajt||';'||
                                                          vr_qtinfoln_ajt||';'||
                                                          vr_qtcompln_ajt||';');
             
             EXCEPTION
               WHEN OTHERS THEN 
                 vr_dscritic := 'Erro ao inserir tbgen_batch_relatorio_wrk 8476: '||sqlerrm;  
                 raise vr_exc_saida; 
             END;
           END IF;
         END IF;
         
         -- Grava data fim para o JOB na tabela de LOG 
         pc_log_programa(pr_dstiplog   => 'F'  
                        ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci           
                        ,pr_cdcooper   => pr_cdcooper
                        ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        ,pr_idprglog   => vr_idlog_ini_par
                        ,pr_flgsucesso => 1); 
         
       END IF;
         
       -- Verificar se ocorreram críticas
       IF vr_cdcritic > 0 THEN
         RAISE vr_exc_saida;
       END IF;

       -- Se for o programa principal ou sem paralelismo
       if nvl(pr_idparale,0) = 0 then
         
         -- Caso execução paralela
         IF vr_idparale > 0 THEN
                 
           -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
           pc_log_programa(pr_dstiplog     => 'O'
                          ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                          ,pr_cdcooper     => pr_cdcooper
                          ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          ,pr_tpocorrencia => 4
                          ,pr_dsmensagem   => 'Inicio - Restauração valores das execuções anteriores.'
                          ,pr_idprglog     => vr_idlog_ini_ger); 
           
           -- Restaurar dados do lote 8450
           open cr_work_lot(pr_cdcooper    => pr_cdcooper
                           ,pr_cdprograma  => vr_cdprogra
                           ,pr_dsrelatorio => 'CRAPLOT_8450' 
                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt);
           -- Realiza fetch no cursor
           fetch cr_work_lot into vr_tab_work_lot;
           -- Verifica se existem registros
           if cr_work_lot%found then
             -- Fecha cursor
             close cr_work_lot;  
             -- Gravar para as varíaveis os valores do cursor
             vr_vlinfocr := vr_tab_work_lot.vlinfocr;
             vr_vlcompcr := vr_tab_work_lot.vlcompcr;
             vr_qtinfoln := vr_tab_work_lot.qtinfoln;
             vr_qtcompln := vr_tab_work_lot.qtcompln;
             vr_vlinfodb := vr_tab_work_lot.vlinfodb;
             vr_vlcompdb := vr_tab_work_lot.vlcompdb;
           ELSE
             --Fecha cursor
             close cr_work_lot;  
           end if;   
           
           -- Restaurar dados do lote 8476
           open cr_work_lot(pr_cdcooper    => pr_cdcooper
                           ,pr_cdprograma  => vr_cdprogra
                           ,pr_dsrelatorio => 'CRAPLOT_8476' 
                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt);
           -- Realiza fetch no cursor
           fetch cr_work_lot into vr_tab_work_lot;
           -- Verifica se existem registros
           if cr_work_lot%found then
             -- Fecha cursor
             close cr_work_lot;  
             -- Gravar para as varíaveis os valores do cursor
             vr_vlinfocr_ajt := vr_tab_work_lot.vlinfocr;
             vr_vlcompcr_ajt := vr_tab_work_lot.vlcompcr;
             vr_qtinfoln_ajt := vr_tab_work_lot.qtinfoln;
             vr_qtcompln_ajt := vr_tab_work_lot.qtcompln;
             vr_vlinfodb_ajt := vr_tab_work_lot.vlinfodb;
             vr_vlcompdb_ajt := vr_tab_work_lot.vlcompdb;
           ELSE
             --Fecha cursor
             close cr_work_lot;  
           end if; 
         
           -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
           pc_log_programa(PR_DSTIPLOG           => 'O'
                          ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                          ,pr_cdcooper           => pr_cdcooper
                          ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          ,pr_tpocorrencia       => 4
                          ,pr_dsmensagem         => 'Fim - Restauração valores das execuções anteriores.'
                          ,PR_IDPRGLOG           => vr_idlog_ini_ger);         
         END IF;
       
         -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
         pc_log_programa(pr_dstiplog     => 'O'
                        ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                        ,pr_cdcooper     => pr_cdcooper
                        ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        ,pr_tpocorrencia => 4
                        ,pr_dsmensagem   => 'Inicio - Geração Saldo Conta Investimento e gravação Lotes'
                        ,pr_idprglog     => vr_idlog_ini_ger); 
       
         -- Executar virada dos saldos das contas investimento
         BEGIN
           INSERT INTO crapsli (crapsli.dtrefere
                               ,crapsli.nrdconta
                               ,crapsli.vlsddisp
                               ,crapsli.cdcooper)
                         SELECT Last_Day(rw_crapdat.dtmvtopr) -- Data do ultimo dia do mes baseado no proximo dia util
                               ,crapsli.nrdconta
                               ,crapsli.vlsddisp
                               ,pr_cdcooper
                          FROM crapsli  crapsli
                         WHERE crapsli.cdcooper = pr_cdcooper
                           AND trunc(crapsli.dtrefere,'MM') = trunc(rw_crapdat.dtmvtolt,'MM');
         EXCEPTION
           WHEN dup_val_on_index THEN
             NULL; -- Ignorar pois a virada da SLI já foi feita.
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir na tabela crapsli. '||SQLERRM;
             -- Sair do programa
             RAISE vr_exc_saida;
         END;
         
         -- Se há informações para gravação do lote 8450
         IF vr_vlinfocr > 0 OR vr_vlcompcr > 0 
         OR vr_vlinfodb > 0 OR vr_vlcompdb > 0 
         OR vr_qtinfoln > 0 OR vr_qtcompln > 0 THEN 
           BEGIN
             update craplot
                set craplot.vlinfocr = nvl(craplot.vlinfocr,0) + nvl(vr_vlinfocr,0)
                   ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + nvl(vr_vlcompcr,0)
                   ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + nvl(vr_qtinfoln,0)
                   ,craplot.qtcompln = nvl(craplot.qtcompln,0) + nvl(vr_qtcompln,0)
                   ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_vlinfodb,0)
                   ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_vlcompdb,0)
                   ,craplot.nrseqdig = CRAPLOT_8450_SEQ.NEXTVAL
              where craplot.dtmvtolt = rw_crapdat.dtmvtolt
                and craplot.cdagenci = vr_cdagenci
                and craplot.cdbccxlt = vr_cdbccxlt
                and craplot.nrdolote = vr_nrdolote
                and craplot.cdcooper = pr_cdcooper;     
             -- Não encontrou nenhum registro
             IF sql%rowcount = 0 THEN   
               insert into craplot (dtmvtolt
                                   ,cdagenci
                                   ,cdbccxlt
                                   ,nrdolote
                                   ,tplotmov
                                   ,cdcooper
                                   ,nrseqdig
                                   ,vlinfocr
                                   ,vlcompcr
                                   ,qtinfoln
                                   ,qtcompln
                                   ,vlinfodb
                                   ,vlcompdb)
               values (rw_crapdat.dtmvtolt
                      ,vr_cdagenci
                      ,vr_cdbccxlt
                      ,vr_nrdolote
                      ,1
                      ,pr_cdcooper
                      ,CRAPLOT_8450_SEQ.NEXTVAL
                      ,nvl(vr_vlinfocr,0)
                      ,nvl(vr_vlcompcr,0)
                      ,nvl(vr_qtinfoln,0)
                      ,nvl(vr_qtcompln,0)
                      ,nvl(vr_vlinfodb,0)
                      ,nvl(vr_vlcompdb,0));           
             END IF;
           exception
             when others then
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao gerar/atualizar tabela craplot 8450: '||sqlerrm;
               raise vr_exc_saida;            
           END;
         END IF;
         
         -- Se há informações para gravação do lote 8476
         IF vr_vlinfocr_ajt > 0 OR vr_vlcompcr_ajt > 0 
         OR vr_vlinfodb_ajt > 0 OR vr_vlcompdb_ajt > 0 
         OR vr_qtinfoln_ajt > 0 OR vr_qtcompln_ajt > 0 THEN 
           BEGIN
             update craplot
                set craplot.vlinfocr = nvl(craplot.vlinfocr,0) + nvl(vr_vlinfocr_ajt,0)
                   ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + nvl(vr_vlcompcr_ajt,0)
                   ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + nvl(vr_qtinfoln_ajt,0)
                   ,craplot.qtcompln = nvl(craplot.qtcompln,0) + nvl(vr_qtcompln_ajt,0)
                   ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_vlinfodb_ajt,0)
                   ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_vlcompdb_ajt,0)
                   ,craplot.nrseqdig = CRAPLOT_8476_SEQ.NEXTVAL
              where craplot.dtmvtolt = rw_crapdat.dtmvtolt
                and craplot.cdagenci = vr_cdagenci
                and craplot.cdbccxlt = vr_cdbccxlt
                and craplot.nrdolote = vr_nrdolote_ajt
                and craplot.cdcooper = pr_cdcooper;             
             -- Não encontrou nenhum registro
             IF sql%rowcount = 0 THEN   
               insert into craplot (dtmvtolt
                                   ,cdagenci
                                   ,cdbccxlt
                                   ,nrdolote
                                   ,tplotmov
                                   ,cdcooper
                                   ,nrseqdig
                                   ,vlinfocr
                                   ,vlcompcr
                                   ,qtinfoln
                                   ,qtcompln
                                   ,vlinfodb
                                   ,vlcompdb)
               values (rw_crapdat.dtmvtolt
                      ,vr_cdagenci
                      ,vr_cdbccxlt
                      ,vr_nrdolote_ajt
                      ,1
                      ,pr_cdcooper
                      ,CRAPLOT_8476_SEQ.NEXTVAL
                      ,nvl(vr_vlinfocr_ajt,0)
                      ,nvl(vr_vlcompcr_ajt,0)
                      ,nvl(vr_qtinfoln_ajt,0)
                      ,nvl(vr_qtcompln_ajt,0)
                      ,nvl(vr_vlinfodb_ajt,0)
                      ,nvl(vr_vlcompdb_ajt,0));           
             END IF;
           exception
             when others then
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao gerar/atualizar tabela craplot 8476: '||sqlerrm;
               raise vr_exc_saida;            
           END;
         END IF;
           
         -- Grava LOG de ocorrência final
         pc_log_programa(PR_DSTIPLOG           => 'O'
                        ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                        ,pr_cdcooper           => pr_cdcooper
                        ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        ,pr_tpocorrencia       => 4
                        ,pr_dsmensagem         => 'Fim - Geração Saldo Conta Investimento e gravação Lotes.'
                        ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
       
         -- Processo OK, devemos chamar a fimprg
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
       
         --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
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
                                            ,pr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE
       
         -- Encerrar o job do processamento paralelo dessa agência
         gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                     ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                     ,pr_des_erro => vr_dscritic);  
       
         -- Salvar informacoes no banco de dados
         COMMIT;
       END IF; 
       
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
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
        
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
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
        
        -- Efetuar rollback
        ROLLBACK;
     END;
   END pc_crps008;
/
