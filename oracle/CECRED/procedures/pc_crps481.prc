CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS481 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_nmtelant IN VARCHAR2                --> Nome tela anterior
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS481                      Antigo: Fontes/CRPS481.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007                      Ultima atualizacao: 05/04/2017
   
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Solicitacao: 005. Ordem = 40
               Finalizar as aplicacoes RDCPRE e RDCPOS, colocando o saldo na
               conta investimento.
               Emite relatorio 456.

   Alteracoes: 05/10/2007 - Trabalhar com 4 casas na provisao RDCPOS e
                            RDCPRE (Magui).

               05/11/2007 - Dtfimper da provisao_pre com erro (Magui).
               
               12/11/2007 - Substituir histor 477 por 490 na CI (Magui).
               
               10/12/2007 - Crapass nao cadastrado (Magui).

               11/03/2008 - Melhorar leitura do craplap para taxas (Magui).
               
               03/04/2008 - Deixar finalizar aplicacoes bloqueadas (Magui).

               11/04/2008 - Zerar vlslfmes quando insaqtot = 1 (Magui).
               
               28/04/2008 - Corrigir atualizacao do lote (Magui);
                          - Mostrar aplicacao bloqueada so 1 vez (Evandro).
                          
               03/08/2009 - Paulo - Precise. Incluir quebra por PAC, campo DIAS 
                            de aplica�ao entre campos "aplicacao" e "creditado"
                            geral um arquivo geral e um para cada pac.
              
               06/08/2009 - Utilizar o numero da aplicacao finalizada como o
                            numero do documento ao gerar os lancamentos na conta
                            investimento  - craplci.nrdocmto = craprda.nraplica
                            (Fernando).

               11/11/2009 - Alterado o FIND da CRAPAGE para que utilizasse o
                            campo cdcooper. (Guilherme/Precise).
                            
               04/03/2010 - Alterado formato do campo "CREDITADO" para valores 
                            negativos (Gabriel).              

               25/08/2011 - Nao zerar vlslfmes quando ultimo dia do mes.
                            Campos sera zerado no crps249 (Magui).
                            
               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao inv�s da crapass (James).   
                            
               12/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
                         
               03/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               30/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).       
                            
               04/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                            

               27/01/2013 - Conversao Progress -> Oracle (Alisson - Amcom)
               
               08/09/2014 - Alterado para quando n�o possuir BLQRGT resgatar o valor
                            da aplica��o da conta investimento para a conta corrente.
                            (Douglas - Projeto Capta��o Internet 2014/2)
               
               01/10/2014 - Adicionado valida��o do historico de lan�amento na conta
                            investimento para quando for 490 (Credito) somar o valor e
                            quando for 484 (Debito) subtrai o valor do saldo.
                            (Douglas - Projeto Capta��o Internet 2014/2)

               18/11/2014 - Alterado para gerar lan�amentos apenas quando a aplica��o 
                            possuir valor maior que zero. (Douglas - Chamado 191418)

               03/12/2014 - Ajustes referente a criacao de lancamentos e utilizacao 
                            de lotes (Jean Michel).
                            
               26/08/2015 - Ajustado para quando tiver bloqueio judicial, tratar da mesma
                            forma como bloqueio de aplicacacao, deixando o dinheiro na
                            conta investimento e nao jogando pra conta corrente.
                            (Jorge/Gielow).             

               10/06/2016 - Ajustado para utilizar a procedure padrao TABE0001.pc_carrega_ctablq
                            para carregar as contas que estao bloqueadas (Douglas - Chamado 454248)
                            
               05/04/2017 - #455742 Ajuste de passagem dos par�metros inpessoa e nrcpfcgc para n�o
                            consultar novamente o associado no pkg apli0001 (Carlos)
     ............................................................................. */

     DECLARE

     /* Tipos de Registro para Tabelas de Memoria */
     TYPE typ_reg_aplicacao IS RECORD
       (cdagenci craprda.cdageass%TYPE
       ,nrdconta craprda.nrdconta%TYPE
       ,nraplica craprda.nraplica%TYPE
       ,vlsldrdc craprda.vlsdrdca%TYPE
       ,qtdiaapl craprda.qtdiaapl%TYPE
       ,nmextage crapage.nmextage%TYPE
       ,dsobserv VARCHAR2(1000));

     /* Tipos de Dados para vetores e tabelas de memoria */
     TYPE typ_tab_aplicacao  IS TABLE OF typ_reg_aplicacao INDEX BY VARCHAR2(30);
     TYPE typ_tab_crapage    IS TABLE OF crapage.nmextage%TYPE INDEX BY PLS_INTEGER;
     TYPE typ_tab_lancto     IS TABLE OF craprda.vlsdrdca%TYPE INDEX BY PLS_INTEGER;
     -- Defini��o de tipo e inicializa��o com valores
     TYPE vr_typ_ctrdocmt IS VARRAY(9) OF VARCHAR2(1);

     /* Vetores de Memoria */
     vr_tab_aplicacao typ_tab_aplicacao;
     vr_tab_crapage   typ_tab_crapage;
     vr_tab_craptab   APLI0001.typ_tab_ctablq;
     vr_tab_lancto    typ_tab_lancto;
     vr_ctrdocmt      vr_typ_ctrdocmt := vr_typ_ctrdocmt('1','2','3','4','5','6','7','8','9');

	 -- Definicao do tipo para a tabela de aplica��es
     vr_craprda apli0001.typ_tab_craprda;

     /* Cursores da rotina CRPS481 */

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT crapcop.cdcooper
             ,crapcop.nmrescop
             ,crapcop.nrtelura
             ,crapcop.cdbcoctl
             ,crapcop.cdagectl
             ,crapcop.dsdircop
             ,crapcop.nrctactl
             ,crapcop.cdagedbb
             ,crapcop.cdageitg
             ,crapcop.nrdocnpj
       FROM crapcop crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     --Selecionar associados
     CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT crapass.nmprimtl
             ,crapass.inpessoa
             ,crapass.nrcpfcgc
             ,crapass.cdagenci
             ,crapass.nrdconta
       FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND   crapass.nrdconta = pr_nrdconta;  
     rw_crapass cr_crapass%ROWTYPE;

     --Selecionar Desconto Titulos
     CURSOR cr_crapdtc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT crapdtc.tpaplica
             ,crapdtc.tpaplrdc
       FROM crapdtc 
       WHERE crapdtc.cdcooper = pr_cdcooper     
       AND   crapdtc.tpaplrdc IN (1,2)
       ORDER BY cdcooper, tpaplica;
     --Selecionar Aplicacoes
     CURSOR cr_craprda (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_tpaplica IN craprda.tpaplica%TYPE
                       ,pr_dtvencto IN crapdat.dtmvtopr%TYPE) IS
       SELECT craprda.cdageass
             ,craprda.nrdconta
             ,craprda.nraplica
             ,craprda.qtdiaapl
             ,craprda.dtmvtolt 
             ,craprda.vlsdrdca
             ,craprda.dtfimper
             ,craprda.dtvencto
             ,craprda.vlsltxmx
             ,craprda.dtsdfmes
             ,craprda.cdcooper
             ,craprda.inaniver
             ,craprda.insaqtot
             ,craprda.incalmes
             ,craprda.vlsltxmm
             ,craprda.vlrgtacu
             ,craprda.vlslfmes
             ,craprda.qtdiauti
             ,craprda.dtatslmm
             ,craprda.dtatslmx
             ,craprda.tpaplica
             ,craplap.txaplica
             ,craplap.txaplmes
             ,craplap.vllanmto             
             ,craprda.rowid rowid_rda
             ,craplap.rowid rowid_lap
             ,ass.inpessoa
             ,ass.nrcpfcgc
       FROM craprda
           ,craplap
           ,crapass ass
       WHERE craprda.cdcooper = pr_cdcooper
       AND   craprda.tpaplica = pr_tpaplica 
       AND   craprda.insaqtot = 0
       AND   craprda.dtvencto <= pr_dtvencto
         AND craplap.cdcooper = craprda.cdcooper 
         AND craplap.dtmvtolt = craprda.dtmvtolt
         AND craplap.cdagenci = craprda.cdagenci
         AND craplap.cdbccxlt = craprda.cdbccxlt
         AND craplap.nrdolote = craprda.nrdolote
         AND craplap.nrdconta = craprda.nrdconta 
         AND craplap.nrdocmto = craprda.nraplica
         AND ass.cdcooper = craprda.cdcooper
         AND ass.nrdconta = craprda.nrdconta
       ORDER BY cdcooper, tpaplica, insaqtot, cdageass, nrdconta, nraplica, vlsdrdca;

     TYPE typ_rec_craprda IS TABLE OF cr_craprda%ROWTYPE
          INDEX BY PLS_INTEGER;
     vr_tab_craprda typ_rec_craprda;

     --Selecionar Agencias
     CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE) IS
       SELECT crapage.cdagenci
             ,crapage.nmextage
       FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper;

       
      
     --Selecionar Lotes
     CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
       SELECT craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdbccxlt
             ,craplot.nrdolote
             ,craplot.tplotmov
             ,craplot.cdcooper
             ,craplot.nrseqdig
             ,craplot.vlinfodb
             ,craplot.vlcompdb
             ,craplot.qtinfoln
             ,craplot.qtcompln
             ,craplot.vlinfocr
             ,craplot.vlcompcr
             ,craplot.rowid
             ,count(1) over() retorno
       FROM craplot 
       WHERE craplot.cdcooper = pr_cdcooper 
       AND   craplot.dtmvtolt = pr_dtmvtolt 
       AND   craplot.cdagenci = pr_cdagenci           
       AND   craplot.cdbccxlt = pr_cdbccxlt          
       AND   craplot.nrdolote = pr_nrdolote;
     rw_craplot cr_craplot%ROWTYPE;
     rw_crablot cr_craplot%ROWTYPE;
     rw_crablot_10111 cr_craplot%ROWTYPE;
     rw_crablot_10112 cr_craplot%ROWTYPE;
     rw_craxlot cr_craplot%ROWTYPE; --Usado somente no insert dos lotes
           
     --Selecionar lancamentos historico 529 e 531
     CURSOR cr_crablap (pr_cdcooper IN craplap.cdcooper%TYPE
                       ,pr_nrdconta IN craplap.nrdconta%TYPE
                       ,pr_nraplica IN craplap.nraplica%TYPE) IS
       SELECT SUM(decode(craplap.cdhistor,529,nvl(craplap.vllanmto,0),nvl(craplap.vllanmto,0)*-1)) vllanmto
       FROM craplap 
       WHERE craplap.cdcooper = pr_cdcooper
       AND   craplap.nrdconta = pr_nrdconta
       AND   craplap.nraplica = pr_nraplica
       AND   craplap.cdhistor IN (529,531);
     rw_crablap cr_crablap%ROWTYPE;
          
     --Listar Telefones
     CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%type
                      ,pr_nrdconta IN craptfc.nrdconta%type
                      ,pr_tptelefo IN craptfc.idseqttl%type) IS
       SELECT craptfc.nrdddtfc
             ,craptfc.nrtelefo
       FROM craptfc
       WHERE craptfc.cdcooper = pr_cdcooper
       AND   craptfc.nrdconta = pr_nrdconta
       AND   craptfc.tptelefo = pr_tptelefo
       ORDER BY craptfc.progress_recid ASC;
     rw_craptfc cr_craptfc%ROWTYPE;
          
     -- Lan�amentos de dep�sitos a vista
     CURSOR cr_craplcm (pr_cdcooper   IN craplrg.cdcooper%TYPE     --> C�digo cooperativa
                       ,pr_dtmvtolt   IN craplot.dtmvtolt%TYPE     --> Data movimento atual
                       ,pr_cdagenci   IN craplot.cdagenci%TYPE     --> C�digo agencia
                       ,pr_cdbccxlt   IN craplot.cdbccxlt%TYPE     --> C�digo caixa/banco
                       ,pr_nrdolote   IN craplot.nrdolote%TYPE     --> N�mero de lote
                       ,pr_nrdconta   IN craprda.nrdconta%TYPE     --> N�mero de conta
                       ,pr_nraplica   IN craplrg.nraplica%TYPE) IS --> N�mero de aplica��o
       SELECT cm.ROWID
             ,cm.nrseqdig
             ,count(1) over() retorno
       FROM craplcm cm
       WHERE cm.cdcooper = pr_cdcooper
         AND cm.dtmvtolt = pr_dtmvtolt
         AND cm.cdagenci = pr_cdagenci
         AND cm.cdbccxlt = pr_cdbccxlt
         AND cm.nrdolote = pr_nrdolote
         AND cm.nrdctabb = pr_nrdconta
         AND cm.nrdocmto = gene0002.fn_char_para_number(pr_nraplica);
     rw_craplcm cr_craplcm%rowtype;

     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     --Constantes
     vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS481';

     --Variaveis Locais
     vr_index      INTEGER;
     vr_cdhistor   INTEGER;
     vr_tptelefo   INTEGER;
     vr_nrdolote   INTEGER;
     vr_tplotmov   INTEGER;
     vr_nom_direto VARCHAR2(100);
     vr_nrramfon   VARCHAR2(100);
     vr_regexist   BOOLEAN:= FALSE;
     vr_flgaplic   BOOLEAN:= FALSE;
     vr_crapass    BOOLEAN:= FALSE;
     vr_nomearq    VARCHAR2(100);
     vr_txaplmes   craplap.txaplmes%TYPE;
     vr_txaplica   craplap.txaplica%TYPE;
     vr_dtrefere   craplap.dtrefere%TYPE;
     vr_nrdocmto   craplap.nrdocmto%TYPE;
     vr_dtiniper   craprda.dtiniper%TYPE;
     vr_dtfimper   craprda.dtfimper%TYPE;
     vr_vlrentot   craprda.vlsdrdca%TYPE;
     vr_vllctprv   craplap.vllanmto%TYPE;
     vr_vllanmto   craplap.vllanmto%TYPE;
     vr_vlsldrdc   craprda.vlsdrdca%TYPE;
     vr_vlrdirrf   craplap.vllanmto%TYPE;
     vr_vlrenacu   craplap.vllanmto%TYPE;
     vr_vlsldapl   craplap.vllanmto%TYPE;
     vr_vlrendmm   craplap.vlrendmm%TYPE;
     vr_vlrnttmm   craplap.vlrendmm%TYPE;
     vr_vlslfmes   craprda.vlslfmes%TYPE;
     vr_dtsdfmes   craprda.dtsdfmes%TYPE;
     vr_perirrgt   NUMBER(25,2);
     vr_vlrenrgt   craplap.vllanmto%TYPE;
     vr_txapllap   craplap.txaplica%TYPE;
     vr_vlajtfim   NUMBER;
     vr_vlsltxmx   NUMBER;
     vr_nmprimtl   crapass.nmprimtl%TYPE;
     vr_taxa       NUMBER;
     vr_vlblqjud   NUMBER;
     vr_vlresblq   NUMBER;
     vr_flgimune   BOOLEAN;
     vr_dtinitax   DATE;
     vr_dtfimtax   DATE;
     vr_dstextab   craptab.dstextab%TYPE;
     vr_nraplica   VARCHAR2(2000);        --> N�mero da aplica��o
     vr_nraplfun   VARCHAR2(2000);        --> N�mero da aplica��o corrente
     vr_vlresgat   NUMBER(10,2);          --> Valor resgate
     vr_cdhistorc  craplcm.cdhistor%TYPE; --> C�digo hist�rico de controle
     vr_contapli   NUMBER;                --> Conta aplica��o
     vr_inaplblq   NUMBER := 0;           --> Indice de bloqueio 
     
     --Variaveis dos Indices
     vr_index_craptab   VARCHAR2(30);
     vr_index_aplicacao VARCHAR2(30);
     --Tabela Extrato
     vr_tab_extr_rdc   apli0001.typ_tab_extr_rdc;
     --Tabela de Erros
     vr_tab_erro       gene0001.typ_tab_erro;

     --Variaveis para retorno de erro
     vr_des_erro        VARCHAR2(3);
     vr_cdcritic        INTEGER:= 0;
     vr_dscritic        VARCHAR2(4000);

     --Variaveis de Excecao
     vr_exc_final       EXCEPTION;
     vr_exc_saida       EXCEPTION;
     vr_exc_fimprg      EXCEPTION;

     -- Variavel para armazenar as informacoes em XML
     vr_des_xml        CLOB;
     vr_des_xml999     CLOB;
     vr_des_xml_sem    CLOB;


     --Procedure para Inicializar os CLOBs
     PROCEDURE pc_inicializa_clob (pr_tipo IN INTEGER) IS
     BEGIN
       IF pr_tipo = 1 THEN
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       ELSIF pr_tipo = 2 THEN
         dbms_lob.createtemporary(vr_des_xml999, TRUE);
         dbms_lob.open(vr_des_xml999, dbms_lob.lob_readwrite);
       ELSE
         dbms_lob.createtemporary(vr_des_xml_sem, TRUE);
         dbms_lob.open(vr_des_xml_sem, dbms_lob.lob_readwrite);
       END IF;    
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao inicializar CLOB. Rotina pc_crps481.pc_inicializa_clob. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END pc_inicializa_clob;

     --Procedure para Finalizar os CLOBs
     PROCEDURE pc_finaliza_clob (pr_tipo IN INTEGER) IS
     BEGIN
       IF pr_tipo = 1 THEN
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);            
       ELSIF pr_tipo = 2 THEN
         dbms_lob.close(vr_des_xml999);
         dbms_lob.freetemporary(vr_des_xml999);            
       ELSE
         dbms_lob.close(vr_des_xml_sem);  
         dbms_lob.freetemporary(vr_des_xml_sem);            
       END IF;    
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao finalizar CLOB. Rotina pc_crps481.pc_finaliza_clob. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END pc_finaliza_clob;

     --Procedure para limpar os dados das tabelas de memoria
     PROCEDURE pc_limpa_tabela IS
     BEGIN
       vr_tab_aplicacao.DELETE;
       vr_tab_crapage.DELETE;
       vr_tab_craptab.DELETE;
       vr_tab_lancto.DELETE;
       vr_tab_extr_rdc.DELETE;
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_crps481.pc_limpa_tabela. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END pc_limpa_tabela;

     --Escrever no arquivo CLOB
     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                             ,pr_tipo      IN INTEGER) IS
     BEGIN
       --Se foi passada infomacao
       IF pr_des_dados IS NOT NULL THEN
         --Escrever no Clob
         IF pr_tipo = 1 THEN
           dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
         ELSIF pr_tipo = 2 THEN
           dbms_lob.writeappend(vr_des_xml999,length(pr_des_dados),pr_des_dados);
         ELSE
           dbms_lob.writeappend(vr_des_xml_sem,length(pr_des_dados),pr_des_dados);  
         END IF;    
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
         --Levantar Excecao
         RAISE vr_exc_saida;
     END pc_escreve_xml;

     -- Gerar lancamentos lci
     PROCEDURE pc_gera_lancto_lci (pr_cdcooper   IN crapcop.cdcooper%TYPE  --Cooperativa
                                  ,pr_nrdconta   IN craprda.nrdconta%TYPE  --Numero Conta
                                  ,pr_nraplica   IN craprda.nraplica%TYPE  --Numero Aplicacao
                                  ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE  --Proximo Dia util
                                  ,pr_vlsldapl   IN craprda.vlsdrdca%TYPE  --Saldo Aplicacao
                                  ,pr_cdhistor_lci IN craplci.cdhistor%TYPE -- Hist�rico do Lan�amento na conta invertimento (490-CREDITO/484-DEBITO)
                                  ,pr_rw_crablot IN OUT cr_craplot%ROWTYPE --Registro do Lote
                                  ,pr_cdcritic   OUT INTEGER               --Codigo Erro
                                  ,pr_dscritic   OUT VARCHAR2) IS          --Descricao Erro
     BEGIN
       DECLARE
         --Tipo de Registro
         rw_craplci craplci%ROWTYPE;
         --Variaveis Erro
         vr_cdcritic INTEGER;
         vr_dscritic VARCHAR2(4000);
         --Variaveis Excecao
         vr_exc_erro EXCEPTION;
         --Saldo da conta investimento
         vr_vlsldapl craprda.vlsdrdca%TYPE;
       BEGIN
         --Inicializar variaveis erro
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;
         
         /*** Gera lancamentos Credito Saldo Conta Investimento ***/
         BEGIN
           INSERT INTO craplci
             (craplci.dtmvtolt
             ,craplci.cdagenci
             ,craplci.cdbccxlt
             ,craplci.nrdolote
             ,craplci.nrdconta
             ,craplci.nrdocmto
             ,craplci.cdhistor
             ,craplci.vllanmto
             ,craplci.nrseqdig
             ,craplci.cdcooper)
           VALUES
             (pr_rw_crablot.dtmvtolt
             ,pr_rw_crablot.cdagenci
             ,pr_rw_crablot.cdbccxlt
             ,pr_rw_crablot.nrdolote
             ,pr_nrdconta
             ,pr_nraplica
             ,pr_cdhistor_lci
             ,nvl(pr_vlsldapl,0)
             ,nvl(pr_rw_crablot.nrseqdig,0) + 1
             ,pr_cdcooper)
           RETURNING craplci.nrseqdig
           INTO rw_craplci.nrseqdig;  
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao inserir craplci na crps481.pc_gera_lancto_lci. '||SQLERRM;
             --Levantar Excecao
             RAISE vr_exc_erro;
         END;      
         
         IF pr_cdhistor_lci IN(489,490) THEN
           --Atualizar Lote
           BEGIN
             UPDATE craplot SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                               ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                               ,craplot.vlinfocr = nvl(craplot.vlinfocr,0) + nvl(pr_vlsldapl,0)
                               ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + nvl(pr_vlsldapl,0)
                               ,craplot.nrseqdig = nvl(rw_craplci.nrseqdig,0)
             WHERE craplot.rowid = pr_rw_crablot.rowid                  
             RETURNING 
                  craplot.qtinfoln
                 ,craplot.qtcompln
                 ,craplot.vlinfocr
                 ,craplot.vlcompcr
                 ,craplot.nrseqdig
             INTO pr_rw_crablot.qtinfoln
                 ,pr_rw_crablot.qtcompln
                 ,pr_rw_crablot.vlinfocr
                 ,pr_rw_crablot.vlcompcr
                 ,pr_rw_crablot.nrseqdig;         
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar craplot na crps481.pc_gera_lancto_lci. '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;

         ELSIF  pr_cdhistor_lci IN(477,534) THEN
           --Atualizar Lote
           BEGIN
             UPDATE craplot SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                               ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                               ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(pr_vlsldapl,0)
                               ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(pr_vlsldapl,0)
                               ,craplot.nrseqdig = nvl(rw_craplci.nrseqdig,0)
             WHERE craplot.rowid = pr_rw_crablot.rowid                  
             RETURNING 
                  craplot.qtinfoln
                 ,craplot.qtcompln
                 ,craplot.vlinfodb
                 ,craplot.vlcompdb
                 ,craplot.nrseqdig
             INTO pr_rw_crablot.qtinfoln
                 ,pr_rw_crablot.qtcompln
                 ,pr_rw_crablot.vlinfodb
                 ,pr_rw_crablot.vlcompdb
                 ,pr_rw_crablot.nrseqdig;         
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar craplot na crps481.pc_gera_lancto_lci. '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;
         END IF;      

         /*** Atualizar Saldo Conta Investimento ***/
         BEGIN
           /* Validar o hist�rico do lancamento na conta de investimento */
           IF pr_cdhistor_lci = 490 THEN
             /* Se for 490-CREDITO, soma o valor do saldo */
             vr_vlsldapl := nvl(pr_vlsldapl,0);

             UPDATE crapsli SET crapsli.vlsddisp = nvl(crapsli.vlsddisp,0) + vr_vlsldapl
             WHERE crapsli.cdcooper = pr_cdcooper
             AND   crapsli.nrdconta = pr_nrdconta
             AND   to_char(crapsli.dtrefere,'MMYYYY') = to_char(pr_dtmvtopr,'MMYYYY');
               --Se nao atualizou
               IF SQL%ROWCOUNT = 0 THEN
                 --Inserir saldo conta investimento
                 BEGIN
                   INSERT INTO crapsli
                     (crapsli.dtrefere
                     ,crapsli.nrdconta
                     ,crapsli.cdcooper
                     ,crapsli.vlsddisp)
                   VALUES
                     (last_day(pr_dtmvtopr)
                     ,pr_nrdconta
                     ,pr_cdcooper
                     ,vr_vlsldapl);  
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdcritic:= 0;
                     vr_dscritic:= 'Erro ao inserir crapsli na crps481.pc_gera_lancto_lci. '||SQLERRM;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;       
               END IF;  
            
           END IF;

         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao atualizar crapsli na crps481.pc_gera_lancto_lci. '||SQLERRM;
             --Levantar Excecao
             RAISE vr_exc_erro;
         END;       
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_cdcritic:= vr_cdcritic;
           pr_dscritic:= vr_dscritic;
         WHEN OTHERS THEN    
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina crps481.pc_gera_lancto_lci. '||SQLERRM;
       END;    
     END pc_gera_lancto_lci;                               

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS481
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;
              
       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida; 
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar Agencias
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapage(rw_crapage.cdagenci):= rw_crapage.nmextage;
       END LOOP;  

       --Carregar aplicacoes disponiveis para saque
       TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                 ,pr_tab_cta_bloq => vr_tab_craptab);

       -- Data de fim e inicio da utilizacao da taxa de poupanca.
       -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
       --  a poupanca, a cooperativa opta por usar ou nao.
       -- Buscar a descricao das faixas contido na craptab
       vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'MXRENDIPOS'
                                               ,pr_tpregist => 1);
       
       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         -- Utilizar datas padr�o
         vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
         vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
       ELSE
         -- Utilizar datas da tabela
         vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
         vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
       END IF;

       --Verificar se os lotes 8479 e 10113 existem
       FOR idx IN 1..4 LOOP
         CASE idx 
           WHEN 1 THEN 
             vr_nrdolote:= 8479;
             vr_tplotmov:= 9;
           WHEN 2 THEN 
             vr_nrdolote:= 10113;
             vr_tplotmov:= 29;
           WHEN 3 THEN 
             vr_nrdolote:= 10111;
             vr_tplotmov:= 29;
           WHEN 4 THEN 
             vr_nrdolote:= 10112;
             vr_tplotmov:= 29;
         END CASE;

         --Selecionar Lote
         OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => vr_nrdolote);  
         --Executar o fetch de acordo com o registro
         FETCH cr_craplot INTO rw_craxlot;                
         --Se nao encontrou
         IF cr_craplot%NOTFOUND THEN
           --Criar Lote
           BEGIN
             INSERT INTO craplot 
               (craplot.dtmvtolt
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.tplotmov
               ,craplot.cdcooper
               ,craplot.nrseqdig)
             VALUES
             (rw_crapdat.dtmvtopr
             ,1
             ,100
             ,vr_nrdolote
             ,vr_tplotmov
             ,pr_cdcooper
             ,0)
           RETURNING 
                craplot.dtmvtolt
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.tplotmov
               ,craplot.cdcooper
               ,craplot.nrseqdig    
               ,craplot.rowid
             INTO 
                rw_craxlot.dtmvtolt
               ,rw_craxlot.cdagenci
               ,rw_craxlot.cdbccxlt
               ,rw_craxlot.nrdolote
               ,rw_craxlot.tplotmov
               ,rw_craxlot.cdcooper
               ,rw_craxlot.nrseqdig         
               ,rw_craxlot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               --Fechar Cursor
               CLOSE cr_craplot;
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao inserir craplot. '||SQLERRM;
               RAISE vr_exc_saida;
           END;      
         END IF;
         --Fechar Cursor
         CLOSE cr_craplot;
         --Atribuir o registro encontrado/inserido para o registro correspondente
         CASE idx 
           WHEN 1 THEN rw_craplot:= rw_craxlot;
           WHEN 2 THEN rw_crablot:= rw_craxlot;
           WHEN 3 THEN rw_crablot_10111:= rw_craxlot;
           WHEN 4 THEN rw_crablot_10112:= rw_craxlot;
         END CASE;
       END LOOP;

       --Tipo Aplicacoes
       FOR rw_crapdtc IN cr_crapdtc (pr_cdcooper => pr_cdcooper) LOOP

         --Selecionar Aplicacoes
         -- Carregar PL Table com dados da tabela CRAPRDA
         OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                        ,pr_tpaplica => rw_crapdtc.tpaplica
                        ,pr_dtvencto => rw_crapdat.dtmvtopr);
         LOOP
           FETCH cr_craprda BULK COLLECT INTO vr_tab_craprda LIMIT 100000;
                 
           EXIT WHEN vr_tab_craprda.COUNT = 0;

           FOR idx IN vr_tab_craprda.first..vr_tab_craprda.last LOOP
                   
             --Limpa a tabela
             vr_craprda.delete;
                   
             --Alimenta PLTABLE com as informa��es da aplica��o
             vr_craprda(1).dtvencto:= vr_tab_craprda(idx).dtvencto;
             vr_craprda(1).dtmvtolt:= vr_tab_craprda(idx).dtmvtolt;
             vr_craprda(1).vlsdrdca:= vr_tab_craprda(idx).vlsdrdca;
             vr_craprda(1).qtdiauti:= vr_tab_craprda(idx).qtdiauti;
             vr_craprda(1).vlsltxmm:= vr_tab_craprda(idx).vlsltxmm;
             vr_craprda(1).dtatslmm:= vr_tab_craprda(idx).dtatslmm;
             vr_craprda(1).vlsltxmx:= vr_tab_craprda(idx).vlsltxmx;
             vr_craprda(1).dtatslmx:= vr_tab_craprda(idx).dtatslmx;
             vr_craprda(1).tpaplica:= vr_tab_craprda(idx).tpaplica;             
             vr_craprda(1).txaplica:= vr_tab_craprda(idx).txaplica;
             vr_craprda(1).txaplmes:= vr_tab_craprda(idx).txaplmes;
             vr_craprda(1).inpessoa:= vr_tab_craprda(idx).inpessoa;
             vr_craprda(1).nrcpfcgc:= vr_tab_craprda(idx).nrcpfcgc;
                                                 
           --Inicializar Variaveis
           vr_vlsldrdc:= 0;
           vr_vlrentot:= 0;    
           vr_vlsldapl:= 0;
           vr_vlrendmm:= 0;
           vr_inaplblq:= 0;
           
           /*** Testa se aplicacao esta disponivel para saque ***/
             vr_index_craptab:= lpad(vr_tab_craprda(idx).nrdconta,12,'0')||lpad(substr(vr_tab_craprda(idx).nraplica,1,7),8,'0');
            
           IF vr_tab_craptab.EXISTS(vr_index_craptab) THEN
             --Se nao existe aplicacao
               vr_index_aplicacao:= lpad(vr_tab_craprda(idx).cdageass,10,'0')||
                                    lpad(vr_tab_craprda(idx).nrdconta,10,'0')||
                                    lpad(substr(vr_tab_craprda(idx).nraplica,1,7),10,'0');
             IF NOT vr_tab_aplicacao.EXISTS(vr_index_aplicacao) THEN
               --Inserir Aplicacao
                 vr_tab_aplicacao(vr_index_aplicacao).nrdconta:= vr_tab_craprda(idx).nrdconta;
                 vr_tab_aplicacao(vr_index_aplicacao).nraplica:= vr_tab_craprda(idx).nraplica;
                 vr_tab_aplicacao(vr_index_aplicacao).qtdiaapl:= vr_tab_craprda(idx).qtdiaapl;
                 vr_tab_aplicacao(vr_index_aplicacao).cdagenci:= vr_tab_craprda(idx).cdageass;
                 vr_tab_aplicacao(vr_index_aplicacao).nmextage:= vr_tab_crapage(vr_tab_craprda(idx).cdageass);
               --Marcar que existe aplicacao    
               vr_flgaplic:= TRUE;
             END IF;  
             vr_tab_aplicacao(vr_index_aplicacao).vlsldrdc:= 0;
             vr_tab_aplicacao(vr_index_aplicacao).dsobserv:= 'Aplicacao Bloqueada';
             -- Aplicacao bloqueada
             vr_inaplblq := 1;
           END IF; 
           --Zerar valores bloqueios
           vr_vlblqjud:= 0;
           vr_vlresblq:= 0;
           /*** Busca Saldo Bloqueio Judicial ***/
           gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper         --Cooperativa 
                                             ,pr_nrdconta => vr_tab_craprda(idx).nrdconta --Conta
                                           ,pr_nrcpfcgc => 0 /*fixo*/          --Cpf/cnpj
                                           ,pr_cdtipmov => 1 /*bloqueio*/      --Tipo Movimento
                                           ,pr_cdmodali => 2 /*aplicacao*/     --Modalidade
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Atual
                                           ,pr_vlbloque => vr_vlblqjud         --Valor Bloqueado
                                           ,pr_vlresblq => vr_vlresblq         --Valor Residual
                                           ,pr_dscritic => vr_dscritic);       --Critica
           --Se ocorreu erro
           IF vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           --Se possuir valor bloqueado
           IF nvl(vr_vlblqjud,0) > 0 THEN 
             --Montar indice Aplicacao
               vr_index_aplicacao:= lpad(vr_tab_craprda(idx).cdageass,10,'0')||
                                    lpad(vr_tab_craprda(idx).nrdconta,10,'0')||
                                    lpad(substr(vr_tab_craprda(idx).nraplica,1,7),10,'0');
             --Se nao existe aplicacao                                 
             IF NOT vr_tab_aplicacao.EXISTS(vr_index_aplicacao) THEN
               --Inserir Aplicacao
                 vr_tab_aplicacao(vr_index_aplicacao).nrdconta:= vr_tab_craprda(idx).nrdconta;
                 vr_tab_aplicacao(vr_index_aplicacao).nraplica:= vr_tab_craprda(idx).nraplica;
                 vr_tab_aplicacao(vr_index_aplicacao).qtdiaapl:= vr_tab_craprda(idx).qtdiaapl;
                 vr_tab_aplicacao(vr_index_aplicacao).cdagenci:= vr_tab_craprda(idx).cdageass;
                 vr_tab_aplicacao(vr_index_aplicacao).nmextage:= vr_tab_crapage(vr_tab_craprda(idx).cdageass);
               --Marcar que existe aplicacao    
               vr_flgaplic:= TRUE;
             END IF;
             vr_tab_aplicacao(vr_index_aplicacao).vlsldrdc:= 0;
             vr_tab_aplicacao(vr_index_aplicacao).dsobserv:= 'Apl. Bloq. Judicialmente';
             -- Aplicacao bloqueada
             vr_inaplblq := 2;
           END IF; 
             
           --Atribuir Taxas Encontradas
             vr_txaplica:= vr_tab_craprda(idx).txaplica;
             vr_txaplmes:= vr_tab_craprda(idx).txaplmes;

           --Limpar tabela erros
           vr_tab_erro.DELETE;
           
           --RDC_PRE
           IF rw_crapdtc.tpaplrdc = 1 THEN
             --Consultar saldo rdc pre
             APLI0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper          --> Cooperativa
                                        ,pr_nrdconta => vr_tab_craprda(idx).nrdconta  --> Nro da conta da aplica��o RDCA
                                        ,pr_nraplica => vr_tab_craprda(idx).nraplica  --> Nro da aplica��o RDCA
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data do processo (N�o necessariamente da CRAPDAT)
                                      ,pr_dtiniper => NULL                 --> Data de in�cio da aplica��o
                                      ,pr_dtfimper => NULL                 --> Data de t�rmino da aplica��o
                                      ,pr_txaplica => 0                    --> Taxa aplicada
                                      ,pr_tab_crapdat => rw_crapdat        --> Controle de Datas
                                      ,pr_inpessoa => vr_tab_craprda(idx).inpessoa
                                      ,pr_nrcpfcgc => vr_tab_craprda(idx).nrcpfcgc
                                      ,pr_vlsdrdca => vr_vlsldrdc          --> Saldo da aplica��o p�s c�lculo
                                      ,pr_vlrdirrf => vr_vlrdirrf          --> Valor de IR
                                      ,pr_perirrgt => vr_perirrgt          --> Percentual de IR resgatado
                                      ,pr_des_reto => vr_des_erro          --> OK ou NOK
                                      ,pr_tab_erro => vr_tab_erro);        --> Tabela com erros

             --Se retornou erro
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                 ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                 ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
               ELSE
                 vr_cdcritic:= 0;
                   vr_dscritic:= 'Retorno "NOK" na apli0001.pc_saldo_rdc_pre e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
               END IF;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             --Valores Acumulados
               vr_vlrenacu:= nvl(vr_vlsldrdc,0) - nvl(vr_tab_craprda(idx).vlsdrdca,0);
             vr_vlsldapl:= nvl(vr_vlsldrdc,0) - nvl(vr_vlrdirrf,0);
             --Valor Acumulado maior zero
             IF nvl(vr_vlrenacu,0) > 0 THEN
               /*** Lancar rendimento no craplap.cdhistor = 475 ***/
               vr_cdhistor:= 475;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vlrenacu;
               vr_txapllap:= vr_txaplica;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
               --Gerar Lancamento Rdc Credito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'C'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap  --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;
                                           
               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF; 
             --Valor IR maior zero
             IF nvl(vr_vlrdirrf,0) > 0 THEN
               /*** lancar irrf no craplap.cdhistor = 476 ***/
               vr_cdhistor:= 476;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vlrdirrf;
               vr_txapllap:= vr_perirrgt;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
               --Gerar Lancamento Rdc Debito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'D'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;
               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF;
             --Inicio e Fim Periodo
             vr_dtiniper:= trunc(rw_crapdat.dtmvtolt,'MM');
               vr_dtfimper:= vr_tab_craprda(idx).dtfimper;  
             --Consultar o saldo da aplicacao rdcpre
             apli0001.pc_provisao_rdc_pre (pr_cdcooper => pr_cdcooper               --> Cooperativa
                                            ,pr_nrdconta => vr_tab_craprda(idx).nrdconta       --> Nro da conta da aplicacao RDCA
                                            ,pr_nraplica => vr_tab_craprda(idx).nraplica       --> Nro da aplicacao RDCA
                                          ,pr_dtiniper => vr_dtiniper               --> Data base inicial
                                          ,pr_dtfimper => vr_dtfimper               --> Data base final
                                          ,pr_vlsdrdca => vr_vlsldrdc               --> Valor do saldo RDCA
                                          ,pr_vlrentot => vr_vllanmto               --> Valor do rendimento total
                                          ,pr_vllctprv => vr_vllctprv               --> Valor dos ajustes RDC
                                          ,pr_des_reto => vr_des_erro               --> OK ou NOK
                                          ,pr_tab_erro => vr_tab_erro);             --> Tabela com erros

             --Se retornou erro
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta)||' Aplica: '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
               ELSE
                   vr_dscritic:= 'Retorno "NOK" na apli0001.pc_provisao_rdc_pre e sem informacao na pr_tab_erro, Conta: '||vr_tab_craprda(idx).nrdconta||' Aplica: '||vr_tab_craprda(idx).nraplica;
               END IF;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             --Se possui valor de ajuste
             IF nvl(vr_vllctprv,0) > 0 THEN
               /*** lancar estorno da provisao craplap.cdhistor = 463 ***/
               vr_cdhistor:= 463;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vllctprv;
               vr_txapllap:= vr_txaplica;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
               --Gerar Lancamento Rdc Debito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'D'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;
               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF;  
           ELSIF rw_crapdtc.tpaplrdc = 2 THEN 
             -- Rotina de calculo do saldo das aplicacoes RDC POS
             apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Proximo dia util
                                      ,pr_nrdconta => vr_tab_craprda(idx).nrdconta --> Nro da conta da aplicacao RDC
                                      ,pr_craprda  => vr_craprda          --> Informa��es da aplica��o
                                      ,pr_dtmvtpap => rw_crapdat.dtmvtolt --> Data do movimento atual passado
                                      ,pr_dtcalsld => vr_tab_craprda(idx).dtvencto --> Data do movimento atual passado
                                      ,pr_flantven => FALSE               --> Flag antecede vencimento
                                      ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                      ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                      ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                      ,pr_cdprogra => vr_cdprogra         --> C�digo do programa
                                      ,pr_inpessoa => vr_tab_craprda(idx).inpessoa
                                      ,pr_nrcpfcgc => vr_tab_craprda(idx).nrcpfcgc
                                      ,pr_vlsdrdca => vr_vlsldrdc         --> Saldo da aplicacao pos calculo
                                      ,pr_vlrentot => vr_vlrentot         --> Saldo da aplicacao pos calculo
                                      ,pr_vlrdirrf => vr_vlrdirrf         --> Valor de IR
                                      ,pr_perirrgt => vr_perirrgt         --> Percentual de IR resgatado
                                      ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
             -- Se retornar erro
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                 ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                 ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
               ELSE
                 vr_cdcritic:= 0;
                   vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
               END IF;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF; 
             /*** Busca todos os rendimentos que foram calculados
              quando houve um lancamento 529 a taxa minima e as reversoes.***/
             vr_vlrendmm:= nvl(vr_vlrentot,0);
             /* no caso de resgate total, o rendimento calculado
                         acima e so da ultima provisao ate a data do resgate */
             vr_vlrnttmm:= nvl(vr_vlrentot,0);
             --Selecionar lancamentos historico 529 e 531
             OPEN cr_crablap (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_tab_craprda(idx).nrdconta
                               ,pr_nraplica => vr_tab_craprda(idx).nraplica);
             FETCH cr_crablap INTO rw_crablap;
             --Fechar Cursor
             CLOSE cr_crablap;
             --Acumular valor encontrado
             vr_vlrnttmm:= nvl(vr_vlrnttmm,0) + nvl(rw_crablap.vllanmto,0);
             --Valor Rendimento
             vr_vlrenrgt:= vr_vlrnttmm; 
             --Verificar Imunidade Tributaria
             IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper  => pr_cdcooper          --> Codigo Cooperativa
                                                  ,pr_nrdconta  => vr_tab_craprda(idx).nrdconta  --> Numero da Conta
                                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data movimento
                                                ,pr_flgrvvlr  => TRUE                 --> Identificador se deve gravar valor
                                                ,pr_cdinsenc  => 5                    --> Codigo da isen��o
                                                ,pr_vlinsenc  => TRUNC((vr_vlrenrgt * vr_perirrgt / 100),2)--> Valor insento
                                                ,pr_inpessoa  => vr_tab_craprda(idx).inpessoa
                                                ,pr_nrcpfcgc  => vr_tab_craprda(idx).nrcpfcgc
                                                ,pr_flgimune  => vr_flgimune          --> Identificador se � imune
                                                ,pr_dsreturn  => vr_des_erro          --> Descricao Critica
                                                ,pr_tab_erro  => vr_tab_erro);        --> Tabela erros

             -- Caso retornou com erro, levantar exce��o
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                 ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                 ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
               ELSE
                 vr_cdcritic:= 0;
                   vr_dscritic:= 'Retorno "NOK" na IMUT0001.pc_verifica_imunidade_trib e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
               END IF;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;

             --Se Estiver Imune
             IF vr_flgimune THEN
               --Saldo Aplicacao
               vr_vlsldapl:= apli0001.fn_round(vr_vlsldrdc,2);
               --Zerar valor IR
               vr_vlrdirrf:= 0;
             ELSE
               --Saldo Aplicacao 
               vr_taxa:= vr_vlrenrgt * vr_perirrgt;
               vr_taxa:= TRUNC(vr_taxa / 100,2);
               
               vr_vlsldapl:= apli0001.fn_round(vr_vlsldrdc - vr_taxa,2);
               --Valor IR
               vr_vlrdirrf:= vr_taxa;
             END IF;  
             --Armazenar valor lancamento 534
             vr_tab_lancto(534):= vr_vlsldapl;
             --Valor Resgate
             IF nvl(vr_vlrenrgt,0) > 0 THEN
               /*** lancar rendimento no craplap.cdhistor = 532 ***/
               vr_cdhistor:= 532;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vlrenrgt;
               vr_txapllap:= vr_txaplica;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
               --Gerar Lancamento Rdc Credito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'C'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;

               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF;  
             --Valor IR
             IF nvl(vr_vlrdirrf,0) > 0 THEN
               /*** lancar irrf no craplap.cdhistor = 533 ***/
               vr_cdhistor:= 533;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vlrdirrf;
               vr_txapllap:= vr_perirrgt;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
               --Gerar Lancamento Rdc Debito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'D'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;
               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF;  
             --Rendimento Aplicacao
             IF nvl(vr_vlrentot,0) > 0 THEN
               /*** lancar provisao ate data do vencto ***/
               vr_cdhistor:= 529;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vlrentot;
               vr_txapllap:= vr_txaplica;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
               --Atualizar Rendimento Aplicacao
               BEGIN
                 UPDATE craprda SET craprda.vlsltxmx = nvl(craprda.vlsltxmx,0) + nvl(vr_vllanmto,0)
                   WHERE craprda.rowid = vr_tab_craprda(idx).rowid_rda
                 RETURNING craprda.vlsltxmx
                   INTO vr_tab_craprda(idx).vlsltxmx;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar craprda. '||SQLERRM;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;    
               --Gerar Lancamento Rdc Credito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'C'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;

               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF;  
             --Valor Resgate
             IF nvl(vr_vlrenrgt,0) > 0 THEN
               
               vr_cdhistor:= 531;
                 vr_dtrefere:= vr_tab_craprda(idx).dtfimper;
               vr_vllanmto:= vr_vlrenrgt;
               vr_tab_lancto(531):= vr_vlrenrgt;
               vr_txapllap:= vr_txaplica;
               vr_nrdocmto:= nvl(rw_craplot.nrseqdig,0) + 1;
  
               --Gerar Lancamento Rdc Debito
               APLI0001.pc_gera_craplap_rdc(pr_cdcooper   => pr_cdcooper              --> Cooperativa
                                           ,pr_dtmvtolt   => rw_craplot.dtmvtolt      --> Data do movimento
                                           ,pr_cdagenci   => rw_craplot.cdagenci      --> Numero agencia
                                           ,pr_nrdcaixa   => NULL                     --> Numero do caixa
                                           ,pr_cdbccxlt   => rw_craplot.cdbccxlt      --> Caixa/Agencia
                                           ,pr_nrdolote   => rw_craplot.nrdolote      --> Numero lote
                                             ,pr_nrdconta   => vr_tab_craprda(idx).nrdconta      --> Numero da conta
                                             ,pr_nraplica   => vr_tab_craprda(idx).nraplica      --> Numero da aplicacao
                                           ,pr_nrdocmto   => vr_nrdocmto              --> Numero do documento
                                           ,pr_txapllap   => vr_txapllap              --> Taxa aplicada
                                           ,pr_cdhistor   => vr_cdhistor              --> Historico
                                           ,pr_nrseqdig   => rw_craplot.nrseqdig      --> Digito de sequencia
                                           ,pr_vllanmto   => vr_vllanmto              --> Valor de lancamento
                                           ,pr_dtrefere   => vr_dtrefere              --> Data de referencia
                                           ,pr_vlrendmm   => vr_vlrendmm              --> Valor Rendimento
                                           ,pr_tipodrdb   => 'D'                      --> Indicador de debito ou credito
                                           ,pr_rowidlot   => rw_craplot.rowid         --> Identificador de registro CRAPLOT
                                             ,pr_rowidlap   => vr_tab_craprda(idx).rowid_lap --> Identificador de registro CRAPLAP
                                           ,pr_vlinfodb   => rw_craplot.vlinfodb      --> Total a debito
                                           ,pr_vlcompdb   => rw_craplot.vlcompdb      --> Total a debito comp.
                                           ,pr_qtinfoln   => rw_craplot.qtinfoln      --> Total de lancamentos
                                           ,pr_qtcompln   => rw_craplot.qtcompln      --> Total de lancamentos comp.
                                           ,pr_vlinfocr   => rw_craplot.vlinfocr      --> Total a credtio
                                           ,pr_vlcompcr   => rw_craplot.vlcompcr      --> Total a credtio comp.
                                           ,pr_des_reto   => vr_des_erro              --> Retorno da execucao da procedure
                                           ,pr_tab_erro   => vr_tab_erro);            --> Tabela de erros;

               --Se retornou erro
               IF vr_des_erro = 'NOK' THEN
                 -- Tenta buscar o erro no vetor de erro
                 IF vr_tab_erro.COUNT > 0 THEN
                   vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                   vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                   ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                   ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
                 ELSE
                   vr_cdcritic:= 0;
                     vr_dscritic:= 'Retorno "NOK" na apli0001.pc_gera_craplap_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
                 END IF;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;                            
             END IF;  
           END IF; --tpaplrdc = 2

           --Se possuir Saldo na Aplicacao, apenas maior que zero
           --Saldo negativo n�o ser� gerado lan�amento
           IF nvl(vr_vlsldapl,0) > 0 THEN
             /*** Conferencia do saldo a ser resgatado para nao haver sobras.
             Pelo motivo que as provisoes sao calculadas com 4 casas mais
             no extrato sao mostradas so duas */
             apli0001.pc_extrato_rdc (pr_cdcooper         => vr_tab_craprda(idx).cdcooper   --> Codigo cooperativa
                                     ,pr_cdagenci         => 1                     --> Codigo da agencia
                                     ,pr_nrdcaixa         => 999                   --> Numero do caixa
                                     ,pr_nrctaapl         => vr_tab_craprda(idx).nrdconta   --> Numero de conta
                                     ,pr_nraplres         => vr_tab_craprda(idx).nraplica   --> Numero da aplicacao
                                     ,pr_dtiniper         => NULL                  --> Data inicial do periodo
                                     ,pr_dtfimper         => NULL                  --> Data final do periodo
                                     ,pr_inpessoa         => vr_tab_craprda(idx).inpessoa
                                     ,pr_nrcpfcgc         => vr_tab_craprda(idx).nrcpfcgc
                                     ,pr_typ_tab_extr_rdc => vr_tab_extr_rdc       --> TEMP TABLE de extrato
                                     ,pr_des_reto         => vr_des_erro           --> Indicador de saida com erro (OK/NOK)
                                     ,pr_tab_erro         => vr_tab_erro);         --> Tabela com erros

             /* Verifica se houve erro */
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| 
                                 ' '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta) ||
                                 ' '||to_char(vr_tab_craprda(idx).nraplica,'fm999g990');
               ELSE
                 vr_cdcritic:= 0;
                   vr_dscritic:= 'Retorno "NOK" na apli0001.pc_extrato_rdc e sem informa��o na pr_tab_erro, Conta: '||gene0002.fn_mask_conta(vr_tab_craprda(idx).nrdconta);
               END IF;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             --Encontrar ultimo registro na tabela extrato
             vr_index:= vr_tab_extr_rdc.LAST;
             IF vr_index IS NOT NULL THEN
               --Zerar ajuste Final
               vr_vlajtfim:= 0;
               --Valor Saldo Aplicacao
               IF nvl(vr_tab_extr_rdc(vr_index).vlsdlsap,0) > nvl(vr_vlsldapl,0) THEN
                 --Valor Ajustar recebe saldo menos anterior
                 vr_vlajtfim:= nvl(vr_tab_extr_rdc(vr_index).vlsdlsap,0) - nvl(vr_vlsldapl,0);
                 --Saldo Aplicacao recebe anterior mais ajustado
                 vr_vlsldapl:= nvl(vr_vlsldapl,0) + nvl(vr_vlajtfim,0);
               ELSIF nvl(vr_tab_extr_rdc(vr_index).vlsdlsap,0) < nvl(vr_vlsldapl,0) THEN  
                 --Valor Ajustar recebe anterior - saldo aplicacao
                 vr_vlajtfim:= nvl(vr_vlsldapl,0) - nvl(vr_tab_extr_rdc(vr_index).vlsdlsap,0);
                 --Saldo Aplicacao recebe anterior menos ajustado
                 vr_vlsldapl:= nvl(vr_vlsldapl,0) - nvl(vr_vlajtfim,0);
               END IF;  
             END IF; 
             --Existe registro
             vr_regexist:= TRUE;   
             BEGIN
               IF rw_crapdtc.tpaplrdc = 1 THEN --Pre
                 vr_cdhistor:= 477;
                 --Zerar Taxa maxima
                 vr_vlsltxmx:= 0;
               ELSE --Pos
                 vr_cdhistor:= 534;
                 --Taxa Maxima recebe saldo taxa maxima - saldo aplicacao
                   vr_vlsltxmx:= nvl(vr_tab_craprda(idx).vlsltxmx,0) - nvl(vr_vlsldapl,0);
               END IF;    
               --Inserir Lancamento Aplicacao
               INSERT INTO craplap
                 (craplap.dtmvtolt
                 ,craplap.cdagenci
                 ,craplap.cdbccxlt
                 ,craplap.nrdolote
                 ,craplap.nrdconta
                 ,craplap.nraplica
                 ,craplap.nrdocmto
                 ,craplap.txaplmes
                 ,craplap.txaplica
                 ,craplap.cdhistor
                 ,craplap.nrseqdig
                 ,craplap.dtrefere
                 ,craplap.cdcooper
                 ,craplap.vllanmto)
               VALUES
                 (rw_craplot.dtmvtolt
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                   ,vr_tab_craprda(idx).nrdconta
                   ,vr_tab_craprda(idx).nraplica
                 ,nvl(rw_craplot.nrseqdig,0) + 1
                 ,vr_txaplica
                 ,vr_txaplica
                 ,vr_cdhistor
                 ,nvl(rw_craplot.nrseqdig,0) + 1
                   ,vr_tab_craprda(idx).dtfimper
                 ,pr_cdcooper
                 ,nvl(vr_vlsldapl,0))
                 RETURNING craplap.vllanmto INTO vr_tab_craprda(idx).vllanmto;  
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir craplap. '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
             --Atualizar Saldo Taxa maxima
             BEGIN
               UPDATE craprda SET craprda.vlsltxmx = nvl(vr_vlsltxmx,0)
                 WHERE craprda.rowid = vr_tab_craprda(idx).rowid_rda
                 RETURNING craprda.vlsltxmx INTO vr_tab_craprda(idx).vlsltxmx;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar craprda. '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
             --Atualizar Lote
             BEGIN  
                UPDATE craplot SET craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_tab_craprda(idx).vllanmto,0)
                                   ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_tab_craprda(idx).vllanmto,0)
                                 ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                 ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                 ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
               WHERE craplot.rowid = rw_craplot.rowid
               RETURNING 
                    craplot.vlinfodb
                   ,craplot.vlcompdb
                   ,craplot.qtinfoln
                   ,craplot.qtcompln
                   ,craplot.nrseqdig
               INTO rw_craplot.vlinfodb
                   ,rw_craplot.vlcompdb
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.nrseqdig;        
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar craplot. '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
           END IF;
           
           -- Ap�s processar as informa��es da aplica��o para a conta de investimento
           -- Testar se a n�o aplica��o possui bloqueio de resgate (BLQRGT)
             vr_index_craptab:= lpad(vr_tab_craprda(idx).nrdconta,12,'0')||lpad(substr(vr_tab_craprda(idx).nraplica,1,7),8,'0');
    
           IF vr_tab_craptab.EXISTS(vr_index_craptab) OR vr_inaplblq > 0 THEN

             --Atualizar Saldo Conta Investimento
             pc_gera_lancto_lci (pr_cdcooper     => pr_cdcooper          --Cooperativa
                                  ,pr_nrdconta     => vr_tab_craprda(idx).nrdconta  --Numero Conta
                                  ,pr_nraplica     => vr_tab_craprda(idx).nraplica  --Numero Aplicacao
                                ,pr_dtmvtopr     => rw_crapdat.dtmvtopr  --Proximo Dia util
                                ,pr_vlsldapl     => vr_vlsldapl          --Saldo Aplicacao
                                ,pr_cdhistor_lci => 490                  --Historico 490 - CREDITO C/I
                                ,pr_rw_crablot   => rw_crablot           --Registro do Lote
                                ,pr_cdcritic     => vr_cdcritic          --Codigo Erro
                                ,pr_dscritic     => vr_dscritic);        --Descricao Erro

             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;

           ELSE -- Se a aplicacao nao tem bloqueio 

             --Atualizar Saldo Conta Investimento
             pc_gera_lancto_lci (pr_cdcooper     => pr_cdcooper          --Cooperativa
                                  ,pr_nrdconta     => vr_tab_craprda(idx).nrdconta  --Numero Conta
                                  ,pr_nraplica     => vr_tab_craprda(idx).nraplica  --Numero Aplicacao
                                ,pr_dtmvtopr     => rw_crapdat.dtmvtopr  --Proximo Dia util
                                ,pr_vlsldapl     => vr_vlsldapl          --Saldo Aplicacao
                                ,pr_cdhistor_lci => 489                  --Historico 489
                                ,pr_rw_crablot   => rw_crablot_10112     --Registro do Lote
                                ,pr_cdcritic     => vr_cdcritic          --Codigo Erro
                                ,pr_dscritic     => vr_dscritic);        --Descricao Erro

             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;

             IF rw_crapdtc.tpaplrdc = 1 THEN -- RDC PRE
               
               --Atualizar Saldo Conta Investimento
               pc_gera_lancto_lci (pr_cdcooper     => pr_cdcooper          --Cooperativa
                                    ,pr_nrdconta     => vr_tab_craprda(idx).nrdconta  --Numero Conta
                                    ,pr_nraplica     => vr_tab_craprda(idx).nraplica  --Numero Aplicacao
                                  ,pr_dtmvtopr     => rw_crapdat.dtmvtopr  --Proximo Dia util
                                  ,pr_vlsldapl     => vr_vlsldapl          --Saldo Aplicacao
                                  ,pr_cdhistor_lci => 477                  --Historico 489
                                  ,pr_rw_crablot   => rw_crablot_10111     --Registro do Lote
                                  ,pr_cdcritic     => vr_cdcritic          --Codigo Erro
                                  ,pr_dscritic     => vr_dscritic);        --Descricao Erro

               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;

             ELSE -- RDC POS
               
               --Atualizar Saldo Conta Investimento
               pc_gera_lancto_lci (pr_cdcooper     => pr_cdcooper          --Cooperativa
                                    ,pr_nrdconta     => vr_tab_craprda(idx).nrdconta  --Numero Conta
                                    ,pr_nraplica     => vr_tab_craprda(idx).nraplica  --Numero Aplicacao
                                  ,pr_dtmvtopr     => rw_crapdat.dtmvtopr  --Proximo Dia util
                                  ,pr_vlsldapl     => vr_vlsldapl          --Saldo Aplicacao
                                  ,pr_cdhistor_lci => 534                  --Historico 489
                                  ,pr_rw_crablot   => rw_crablot_10111     --Registro do Lote
                                  ,pr_cdcritic     => vr_cdcritic          --Codigo Erro
                                  ,pr_dscritic     => vr_dscritic);        --Descricao Erro

               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;

             END IF;

             
             -- Executar o processo para resgatar o valor da conta investimento 
             -- e credit�-lo na conta corrente 
             -- CASO NAO HAJA BLOQUEIO
             --IF vr_inaplblq = 0 THEN 
             
             -- Testa se cursor j� est� aberto
             IF cr_craplot%isopen THEN
               CLOSE cr_craplot;
             END IF;
             
             -- Gera lancamento no conta-corrente
             OPEN cr_craplot(pr_cdcooper, rw_crapdat.dtmvtopr, 1, 100, 8478);
             FETCH cr_craplot INTO rw_craplot;

             -- Verifica se encontrou registros.
             -- Se n�o tiver encontrado insere na tabela CRAPLOT.
             IF cr_craplot%notfound OR rw_craplot.retorno > 1 THEN
               CLOSE cr_craplot;
               BEGIN
                 -- Envio centralizado de log de erro
                 INSERT INTO craplot(dtmvtolt
                                    ,cdagenci
                                    ,cdbccxlt
                                    ,nrdolote
                                    ,tplotmov
                                    ,cdcooper)
                   VALUES(rw_crapdat.dtmvtopr
                         ,1
                         ,100
                         ,8478
                         ,1
                         ,pr_cdcooper)
                 RETURNING cdagenci, dtmvtolt, cdbccxlt, nrdolote, tplotmov, rowid, nrseqdig
                      INTO rw_craplot.cdagenci,
                           rw_craplot.dtmvtolt,
                           rw_craplot.cdbccxlt,
                           rw_craplot.nrdolote,
                           rw_craplot.tplotmov,
                           rw_craplot.rowid,
                           rw_craplot.nrseqdig;
               EXCEPTION
                 WHEN others THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Erro ao inserir em CRAPLOT. ' || sqlerrm;
                   RAISE vr_exc_saida;
               END;
             ELSE
               CLOSE cr_craplot;
             END IF;

             -- Atribui valores
               vr_nraplica := vr_tab_craprda(idx).nraplica;
               vr_nraplfun := vr_tab_craprda(idx).nraplica;
             vr_vlresgat := vr_vlsldapl;
             vr_contapli := 9;

             LOOP
               -- Busca registros dos lan�amentos
               OPEN cr_craplcm(pr_cdcooper
                              ,rw_craplot.dtmvtolt
                              ,rw_craplot.cdagenci
                              ,rw_craplot.cdbccxlt
                              ,rw_craplot.nrdolote
                                ,vr_tab_craprda(idx).nrdconta
                              ,vr_nraplica);
               FETCH cr_craplcm INTO rw_craplcm;

               -- Verifica se foram encontrados registros.
               -- Se n�o encontrar insere registro na tabela CRAPLCM e atualiza tabela CRAPLOT.
               -- Se encontrar, gera um novo n�mero de aplica��o e repete a busca.
               IF cr_craplcm%NOTFOUND OR rw_craplcm.retorno > 1 THEN
                 CLOSE cr_craplcm;

                 IF rw_crapdtc.tpaplrdc = 1 THEN
                   vr_cdhistorc := 478;
                 ELSE
                   vr_cdhistorc := 530;
                 END IF;

                 BEGIN
                   UPDATE craplot cl
                   SET cl.qtinfoln = cl.qtinfoln + 1
                      ,cl.qtcompln = cl.qtcompln + 1
                      ,cl.vlinfocr = cl.vlinfocr + vr_vlresgat
                      ,cl.vlcompcr = cl.vlcompcr + vr_vlresgat
                      ,cl.nrseqdig = nvl(rw_craplot.nrseqdig, 0) + 1
                   WHERE cl.ROWID = rw_craplot.ROWID
                   RETURNING cl.qtinfoln, cl.qtcompln, cl.vlinfocr, cl.vlcompcr, cl.nrseqdig
                   INTO rw_craplot.qtinfoln, rw_craplot.qtcompln, rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.nrseqdig;
                 EXCEPTION
                   WHEN others THEN
                     vr_cdcritic := 0;
                     vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
                     RAISE vr_exc_saida;
                 END;

                 BEGIN
                   INSERT INTO craplcm(dtmvtolt
                                      ,dtrefere
                                      ,cdagenci
                                      ,cdbccxlt
                                      ,nrdolote
                                      ,nrdconta
                                      ,nrdctabb
                                      ,nrdctitg
                                      ,nrdocmto
                                      ,cdcooper
                                      ,cdhistor
                                      ,vllanmto
                                      ,nrseqdig
                                      ,cdcoptfn)      --> adicionado somente para resolver consist�ncia do Oracle, n�o existe no Progress.
                     VALUES(rw_craplot.dtmvtolt
                             ,vr_tab_craprda(idx).dtmvtolt
                           ,rw_craplot.cdagenci
                           ,rw_craplot.cdbccxlt
                           ,rw_craplot.nrdolote
                             ,vr_tab_craprda(idx).nrdconta
                             ,vr_tab_craprda(idx).nrdconta
                             ,gene0002.fn_mask(vr_tab_craprda(idx).nrdconta, '99999999')
                           ,gene0002.fn_char_para_number(vr_nraplica)
                           ,pr_cdcooper
                           ,vr_cdhistorc
                           ,vr_vlresgat
                           ,rw_craplot.nrseqdig
                           ,0);
                 EXCEPTION
                   WHEN others THEN
                     vr_cdcritic := 0;
                     vr_dscritic := 'Erro ao inserir  CRAPLCM. ' || sqlerrm;
                     RAISE vr_exc_saida;
                 END;
                 -- Sai do loop
                 EXIT;
               ELSE
                 CLOSE cr_craplcm;
                 -- Modifica o nraplica para buscar novamente e encontrar um nrdocmto vazio na craplcm
                 BEGIN
                   vr_nraplica := vr_ctrdocmt(vr_contapli) + vr_nraplica;
                 EXCEPTION
                   WHEN others THEN
                     IF gene0002.fn_numerico(vr_nraplica) = FALSE THEN
                       vr_contapli := vr_contapli - 1;
                       vr_nraplica := vr_ctrdocmt(vr_contapli) + vr_nraplfun;
                     END IF;
                 END;
                 -- Volta ao in�cio do loop para fazer nova busca na craplcm
                 CONTINUE;
               END IF;
             END LOOP; -- Fim do loop da craplcm
             
           END IF; -- Fim do resgate da aplica��o para a conta corrente
           
           --Montar Indice Aplicacao
             vr_index_aplicacao:= lpad(vr_tab_craprda(idx).cdageass,10,'0')||
                                  lpad(vr_tab_craprda(idx).nrdconta,10,'0')||
                                  lpad(substr(vr_tab_craprda(idx).nraplica,1,7),10,'0');
           --Verificar se Existe aplicacao
           IF NOT vr_tab_aplicacao.EXISTS(vr_index_aplicacao) THEN
             --Inserir Aplicacao
               vr_tab_aplicacao(vr_index_aplicacao).nrdconta:= vr_tab_craprda(idx).nrdconta;
               vr_tab_aplicacao(vr_index_aplicacao).nraplica:= vr_tab_craprda(idx).nraplica;
               vr_tab_aplicacao(vr_index_aplicacao).qtdiaapl:= vr_tab_craprda(idx).qtdiaapl;
               vr_tab_aplicacao(vr_index_aplicacao).cdagenci:= vr_tab_craprda(idx).cdageass;
               vr_tab_aplicacao(vr_index_aplicacao).nmextage:= vr_tab_crapage(vr_tab_craprda(idx).cdageass);
             --Marcar flag aplicacao
             vr_flgaplic:= TRUE;
           END IF;      
           /* Se nao estiver bloqueada, coloca uma linha para observacoes */
           IF nvl(vr_tab_aplicacao(vr_index_aplicacao).dsobserv,'#') <> 'Aplicacao Bloqueada'      AND
              nvl(vr_tab_aplicacao(vr_index_aplicacao).dsobserv,'#') <> 'Apl. Bloq. Judicialmente' THEN
             vr_tab_aplicacao(vr_index_aplicacao).dsobserv:= Rpad('_',25,'_');
           END IF;  
           --Atualizar Saldo Rendimento
           vr_tab_aplicacao(vr_index_aplicacao).vlsldrdc:= nvl(vr_vlsldapl,0);
           
           /*** Magui, quando ultimo dia do mes, esses campos nao podem zera-
           dos aqui, precisa ser no crps249, senao da erro no gerencial por PA ***/    
             IF vr_tab_craprda(idx).dtsdfmes <> rw_crapdat.dtmvtolt THEN 
             vr_vlslfmes:= 0;
             vr_dtsdfmes:= NULL;
           ELSE
               vr_vlslfmes:= nvl(vr_tab_craprda(idx).vlslfmes,0);
               vr_dtsdfmes:= vr_tab_craprda(idx).dtsdfmes;
           END IF;  
           --Atualizar Rendimento
           BEGIN
             UPDATE craprda SET craprda.inaniver = 1
                               ,craprda.insaqtot = 1
                               ,craprda.incalmes = 1
                               ,craprda.vlsdrdca = 0
                               ,craprda.vlsltxmx = 0
                               ,craprda.vlsltxmm = 0
                               ,craprda.vlrgtacu = nvl(craprda.vlrgtacu,0) + nvl(vr_vlsldapl,0)
                               ,craprda.vlslfmes = vr_vlslfmes
                               ,craprda.dtsdfmes = vr_dtsdfmes
               WHERE craprda.rowid = vr_tab_craprda(idx).rowid_rda
             RETURNING 
                  craprda.inaniver
                 ,craprda.insaqtot
                 ,craprda.incalmes
                 ,craprda.vlsdrdca
                 ,craprda.vlsltxmx
                 ,craprda.vlsltxmm
                 ,craprda.vlrgtacu
                 ,craprda.vlslfmes
                 ,craprda.dtsdfmes
               INTO vr_tab_craprda(idx).inaniver
                   ,vr_tab_craprda(idx).insaqtot
                   ,vr_tab_craprda(idx).incalmes
                   ,vr_tab_craprda(idx).vlsdrdca
                   ,vr_tab_craprda(idx).vlsltxmx
                   ,vr_tab_craprda(idx).vlsltxmm
                   ,vr_tab_craprda(idx).vlrgtacu                                   
                   ,vr_tab_craprda(idx).vlslfmes
                   ,vr_tab_craprda(idx).dtsdfmes;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar craprda. '||SQLERRM;  
               --Levantar Excecao
               RAISE vr_exc_saida;
           END;
         END LOOP;
           
       END LOOP;

         CLOSE cr_craprda;
         
	     END LOOP;
            
       vr_tab_craprda.delete; -- limpa dados do bulk ja armazenado em outra pl table   

       --Criar Clob para totalizador
       pc_inicializa_clob(2);
       
       --Criar tag xml do totalizador
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl456>',2);
       
       -- Busca do diret�rio base da cooperativa
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl 
       
       --Buscar primeiro registro do vetor
       vr_index_aplicacao:= vr_tab_aplicacao.FIRST;
       
       /*** Percorrer todas as aplicacoes ***/        
       WHILE vr_index_aplicacao IS NOT NULL LOOP
         --Primeiro Registro da Agencia
         IF vr_index_aplicacao = vr_tab_aplicacao.FIRST  OR
            vr_tab_aplicacao(vr_index_aplicacao).cdagenci <> vr_tab_aplicacao(vr_tab_aplicacao.PRIOR(vr_index_aplicacao)).cdagenci THEN
            
           --Inicializar Clob das agnecias
           pc_inicializa_clob(1);
           
           --Criar tag xml por agencia
           pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl456>',1);
           
           -- Inicilizar as informa��es do XML por agencia
           FOR idx IN 1..2 LOOP
             pc_escreve_xml('<agencia dtmvtolt="'||
                          to_char(rw_craplot.dtmvtolt,'DD/MM/YYYY')||'" cdagenci="'||rw_craplot.cdagenci||
                          '" cdbccxlt="'||rw_craplot.cdbccxlt||'" nrdolote="'|| to_char(rw_craplot.nrdolote,'fm999g990')||
                          '" tplotmov="'||to_char(rw_craplot.tplotmov,'fm00')||'" apli_cdagenci="'||
                          vr_tab_aplicacao(vr_index_aplicacao).cdagenci||'" nmextage="'||
                          vr_tab_aplicacao(vr_index_aplicacao).nmextage||'">',idx);
           END LOOP;               
           --Nome Arquivo
           vr_nomearq:= 'crrl456_'||gene0002.fn_mask(vr_tab_aplicacao(vr_index_aplicacao).cdagenci,'999')||'.lst';             
         END IF;
         
         --Primeiro Registro da Conta
         IF vr_index_aplicacao = vr_tab_aplicacao.FIRST  OR
            vr_tab_aplicacao(vr_index_aplicacao).nrdconta <> vr_tab_aplicacao(vr_tab_aplicacao.PRIOR(vr_index_aplicacao)).nrdconta THEN

           --Verificar a Conta do Associado
           OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_tab_aplicacao(vr_index_aplicacao).nrdconta);
           --Posicionar no primeiro registro                
           FETCH cr_crapass INTO rw_crapass;
           --Marcar que encontrou
           vr_crapass:= cr_crapass%FOUND;
           --Fechar Cursor
           CLOSE cr_crapass;
            
           --Se a conta nao existe escreve no log e pula registro
           IF NOT vr_crapass THEN
             --Montar Critica
             vr_dscritic:= ' Conta/dv: '||gene0002.fn_mask_conta(vr_tab_aplicacao(vr_index_aplicacao).nrdconta)||
                           ' Nr.Aplicacao: '||to_char(vr_tab_aplicacao(vr_index_aplicacao).nraplica,'fm999g990');
             --Escrever Mensagem Log
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
             --Proximo Registro
             GOTO PROXIMO;
           END IF;
           --Nome Titular
           vr_nmprimtl:= rw_crapass.nmprimtl;
           --Ramal
           vr_nrramfon:= NULL;
           --Tipo Telefone
           --IF vr_tab_crapass(vr_tab_aplicacao(vr_index_aplicacao).nrdconta).inpessoa = 1 THEN
           IF rw_crapass.inpessoa = 1 THEN
             vr_tptelefo:= 1;  --Residencial
           ELSE
             vr_tptelefo:= 3;  --Comercial
           END IF; 
           --Selecionar Telefone
           OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                          ,pr_tptelefo => vr_tptelefo);
           FETCH cr_craptfc INTO rw_craptfc;
           --Se encontrou
           IF cr_craptfc%FOUND THEN
             --Numero Ramal
             vr_nrramfon:= rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;
           END IF;
           --Fechar Cursor
           CLOSE cr_craptfc;
           --Selecionar Telefone Celular
           OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                          ,pr_tptelefo => 2);
           FETCH cr_craptfc INTO rw_craptfc;
           --Se encontrou
           IF cr_craptfc%FOUND THEN
             --Ramal possui informacoes
             IF vr_nrramfon IS NOT NULL THEN
               --Numero Ramal
               vr_nrramfon:= vr_nrramfon || '/';
             ELSE
               --Recebe DDD
               vr_nrramfon:= rw_craptfc.nrdddtfc;
             END IF;    
             --Concatenar Telefone
             vr_nrramfon:= vr_nrramfon ||rw_craptfc.nrtelefo;
           END IF;
           --Fechar Cursor
           CLOSE cr_craptfc; 
           --Se Ramal eh nulo
           IF vr_nrramfon IS NULL THEN                
             --Pessoa Fisica
             IF rw_crapass.inpessoa = 1 THEN
               vr_tptelefo:= 3;  --Comercial
             ELSE
               vr_tptelefo:= 1;  --Residencial
             END IF; 
             --Selecionar Telefone
             OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapass.nrdconta
                            ,pr_tptelefo => vr_tptelefo);
             FETCH cr_craptfc INTO rw_craptfc;
             --Se encontrou
             IF cr_craptfc%FOUND THEN
               --Numero Ramal
               vr_nrramfon:= rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;
             ELSE
               vr_nrramfon:= NULL;  
             END IF;
             --Fechar Cursor
             CLOSE cr_craptfc;
           END IF;
         END IF;
         --Escrever as contas no XML da agencia e do 999
         FOR idx IN 1..2 LOOP
           pc_escreve_xml
             ('<conta>
                <nmprimtl>'||SUBSTR(vr_nmprimtl,1,35)||'</nmprimtl>
                <nrdconta>'||GENE0002.fn_mask_conta(rw_crapass.nrdconta)||'</nrdconta>
                <nraplica>'||to_char(vr_tab_aplicacao(vr_index_aplicacao).nraplica,'fm999g999g990')||'</nraplica>
                <qtdiaapl>'||to_char(vr_tab_aplicacao(vr_index_aplicacao).qtdiaapl,'fm9990')||'</qtdiaapl>
                <vlsldrdc>'||To_Char(vr_tab_aplicacao(vr_index_aplicacao).vlsldrdc,'fm999999g990d00')||'</vlsldrdc>
                <nrramfon>'||substr(vr_nrramfon,1,24)||'</nrramfon>
                <dsobserv>'||substr(vr_tab_aplicacao(vr_index_aplicacao).dsobserv,1,25)||'</dsobserv>
             </conta>',idx);
         END LOOP;           
         --Ultimo Registro Agencia
         IF vr_index_aplicacao = vr_tab_aplicacao.LAST  OR
            vr_tab_aplicacao(vr_index_aplicacao).cdagenci <> vr_tab_aplicacao(vr_tab_aplicacao.NEXT(vr_index_aplicacao)).cdagenci THEN

           --Finaliza TAG agencia nos 2 Clobs
           FOR idx IN 1..2 LOOP
             pc_escreve_xml('</agencia>',idx);
           END LOOP;
                   
           --Finalizar tag relatorio agencia
           pc_escreve_xml('</crrl456>',1); 
                      
           --Solicitar geracao do arquivo por agencia
           gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl456/agencia/conta'  --> N� base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl456.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Titulo do relat�rio
                                      ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nomearq --> Arquivo final
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impress�o (Imprim.p)
                                      ,pr_nmformul  => NULL                --> Nome do formul�rio para impress�o
                                      ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                      ,pr_flg_gerar => 'N'                 --> gerar PDF
                                      ,pr_des_erro  => vr_dscritic);       --> Sa�da com erro
                                      
           --Se ocorreu erro
           IF vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;
           
           -- Liberando a mem�ria alocada pro CLOB por agencia
           pc_finaliza_clob(1);
         END IF;
         
         <<PROXIMO>>
         --Proximo Registro da Aplicacao
         vr_index_aplicacao:= vr_tab_aplicacao.NEXT(vr_index_aplicacao);
       END LOOP;
         
       --Se existiram aplicacoes
       IF vr_flgaplic THEN
         
         --Finalizar tag no Clob Totalizador
         pc_escreve_xml('</crrl456>',2);
         
         --Nome do Arquivo
         vr_nomearq:= 'crrl456_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst';
          
         --Solicitar geracao do arquivo
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml999       --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl456/agencia/conta'  --> N� base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl456.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Titulo do relat�rio
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nomearq --> Arquivo final
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impress�o (Imprim.p)
                                    ,pr_nmformul  => NULL                --> Nome do formul�rio para impress�o
                                    ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_dscritic);       --> Sa�da com erro
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         --Finalizar Clob Totalizador
         pc_finaliza_clob(2);
       ELSE
         --Inicializar Clob 
         pc_inicializa_clob(3);   
         --Escrever no Clob
         pc_escreve_xml('*** NENHUMA APLICACAO EM ANIVERSARIO ***'||chr(13),3);
         --Nome do Arquivo
         vr_nomearq:= 'crrl456_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst';
         --Solicitar geracao do arquivo
         gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                            ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                            ,pr_dsxml     => vr_des_xml_sem      --> Arquivo XML de dados
                                            ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nomearq --> Arquivo final
                                            ,pr_flg_impri => 'S'                 --> Chamar a impress�o (Imprim.p)
                                            ,pr_flg_gerar => 'S'                 --> gerar PDF
                                            ,pr_nmformul  => '132col'            --> Nome do formul�rio para impress�o
                                            ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                            ,pr_des_erro  => vr_dscritic);       --> Sa�da com erro
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         -- Liberando a mem�ria alocada pelos CLOBs
         pc_finaliza_clob(3);
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);


       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_fimprg THEN

         -- Buscar a descricao da critica
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

         -- Se foi gerada critica para envio ao log
         IF vr_dscritic IS NOT NULL THEN
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
         --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
         -- Efetuar commit pois gravaremos o que foi processado ate entao
         COMMIT;
       WHEN vr_exc_saida THEN

         -- Buscar a descricao
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;
         
       WHEN OTHERS THEN

         cecred.pc_internal_exception(pr_cdcooper);

         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;
     END;
   END PC_CRPS481;
/
