CREATE OR REPLACE PROCEDURE CECRED.pc_crps156 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Numero da conta (para processo da cadeia passar zeros)
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps156      (Fontes/crps156.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Abril/96.                       Ultima atualizacao: 01/12/2017

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Solicitacao: 005 (Finalizacao do processo).
                 Efetuar o resgate das poupancas programas e credita-los em conta-
                 corrente.
                 Emite relatorio 125.

     Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                 21/05/1999 - Consistir se a aplicacao esta bloqueada (Deborah).

                 04/01/2000 - Nao gerar pedido de impressao (Deborah).

                 11/02/2000 - Gerar pedido de impressao (Deborah).  
                   
                 01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
                   
                 21/08/2001 - Tratamento do saldo antecipado. (Ze Eduardo).

                 09/02/2004 - Se resgate total zerar vlabcpmf (Margarete).
                   
                 12/05/2004 - Quando resgate parcial e tiver vlabcpmf deixar
                              saldo para pagto do IR no aniversario (Margarete).
                                
                 13/08/2004 - Se tem vlabcpmf nao deixar resgatar a parte
                              do abono (Margarete). 

                 15/09/2004 - Tratamento Conta Investimento(Mirtes)
                   
                 09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                              para 7 posicoes, na leitura da tabela (Evandro).
                                
                 29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                              craplcm, craplpp, craprej, craplci, crapsli e do
                              buffer crablot (Diego).

                 10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
                   
                 15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                   
                 29/04/2008 - Apos gerar lancamento na conta investimento passar
                              a situacao da rpp para 5 (resgate por vencimento)
                              (Guilherme).
                   
                 12/02/2010 - Quando o resgate da poupança for por vencimento da 
                              mesma e estiver bloqueada, dar a critica 828 e 
                              fazer o resgate da poupança(Guilherme).

                 14/06/2011 - Tratar poupanca inexistente.
                   
                 09/10/2013 - Tratamento para Imunidade Tributaria (Ze).
                   
                 05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                              (Lucas R.)
                                
                 16/01/2014 - Inclusao de VALIDATE craplot, craplcm, craplpp, 
                              craprej, crablot, craplci e crapsli (Carlos)
                                
                 11/03/2014 - Incluido ordenacao por craplrg.tpresgat no for each
                              craplrg. (Reinert)
                   
                 27/04/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
                   
                 20/04/2016 - Adicionado validacao rw_craplrg.tpresgat = 2
                              para correção do chamado 414286. (Kelvin)
                              
                 13/06/2016 - Ajustado cursor da craptab para remover o NLV e o order by
                              pois o parametro sempre eh passado e nao precisa ordernar
                              (Douglas - Chamado 454248)

                 26/07/2016 - Finalizacao da conversao (Jonata-Rkam)
                   
                 29/11/2016 - Efetuar o resgate no dia quando passado uma conta especifica
                              Utilizado pela rotina BLQJ0002 (Andrino-Mouts)
                              
                 01/12/2017 - Inclusao da validação de bloqueis de aplic.
                              PRJ404 - Garantia(Odirlei-AMcom) 
                              
                 18/04/2018 - Tratamento se existe valor bloqueado como garantia de operação com poupança programa
                              PRJ404 - Garantia(Oscar-AMcom)              
                              
								 18/05/2018 - Validar bloqueio de poupança programada (SM404)            
                 03/07/2018 - PRJ450 - Regulatorios de Credito - Centralizacao do lancamento em conta corrente (Fabiano B. Dias - AMcom).
                              
                 17/01/2019 - INC0030960 - Tratamento para evitar locks nos cursores que contém FOR UPDATE NOWAIT.
                              Incluido verificacao na abertura do cursor por N...vezes antes de abortar o processo.
                              Rubens Lima (Mouts)              
                              
				 16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

				 20/04/2019 - P411.2 - Alteração para incluir geração de protocolo no resgate
                     CIS Corporate
					 ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS156';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_tpcritic crapcri.cdcritic%TYPE;

    vr_vlsdappr       NUMBER;
    vr_vlrgappr       NUMBER;    
    vr_tpresgate_apl   INTEGER := 0;
    vr_vlrtotresgate_apl   NUMBER := 0;
    vr_vlresgat_apl   NUMBER := 0;
    vr_vlresgat_acu   NUMBER := 0;
    vr_nrseqrgt INTEGER := 0;
    vr_flgfimresga    BOOLEAN := FALSE;

    -- VARIÁVEIS GLOBAIS
    vr_gbl_tentativa      NUMBER:=0;
    vr_gbl_total_vezes    NUMBER:=15; --Quantidade de vezes que irá tentar abrir o cursor antes de abortar a execução (Tratamento para lock)
    vr_gbl_achou_registro NUMBER:=0;   

    rw_craplot_rvt lote0001.cr_craplot_sem_lock%rowtype;
    vr_nrseqdig    craplot.nrseqdig%type;

    vr_perirapl NUMBER := 0;
    vr_valortir  NUMBER := 0;
    vr_vlsdtoap NUMBER := 0;
    vr_dsperirapl VARCHAR2(1000);      
      
    vr_geraprotocolo PLS_INTEGER:=0;

    vr_dsinfor1 VARCHAR2(1000);
    vr_dsinfor2 VARCHAR2(1000);
    vr_dsinfor3 VARCHAR2(1000);
    vr_nrdconta VARCHAR2(1000);
    vr_nmextttl VARCHAR2(1000);      
    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_nmcidade crapage.nmcidade%TYPE;
    vr_des_erro VARCHAR2(1000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
          ,cop.dsdircop
          ,cop.cdbcoctl
          ,cop.cdagectl
          ,cop.vlinimon
          ,cop.vllmonip
          ,cop.nrdocnpj
          ,cop.nrtelura
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        
    -- Buscar lancamentos de resgates solicitados.
    CURSOR cr_craplrg (pr_cdcooper craplrg.cdcooper%TYPE,
                       pr_nrdconta craplrg.nrdconta%TYPE,
                       pr_dtmvtopr craplrg.dtresgat%TYPE) IS
      SELECT craplrg.nrdconta
            ,craplrg.nraplica
            ,craplrg.cdcooper
            ,craplrg.tpresgat
            ,craplrg.vllanmto
            ,craplrg.flgcreci
            ,craplrg.dtmvtolt
            ,craplrg.rowid
            ,craplrg.hrtransa
		    ,craplrg.idautblq
        FROM craplrg
       WHERE craplrg.cdcooper  = pr_cdcooper
         AND craplrg.nrdconta  = decode(pr_nrdconta, 0, craplrg.nrdconta, pr_nrdconta)
         AND craplrg.dtresgat <= pr_dtmvtopr
         AND craplrg.inresgat  = 0
         AND craplrg.tpaplica  = 4
		 AND craplrg.hrtransa >= 0
         AND craplrg.tpresgat IN (1,2,3)
       ORDER BY craplrg.tpresgat;
       
    -- Buscar cadastro da poupanca programada.
    CURSOR cr_craprpp (pr_cdcooper craplrg.cdcooper%TYPE,
                       pr_nrdconta craprpp.nrdconta%TYPE,
                       pr_nraplica craprpp.nrctrrpp%TYPE) IS
      SELECT /*+ index (craprpp craprpp#craprpp1)*/
             craprpp.nrdconta
            ,craprpp.nrctrrpp
            ,craprpp.dtvctopp
            ,craprpp.vlabcpmf
            ,craprpp.flgctain
            ,craprpp.dtfimper
            ,craprpp.cdprodut
            ,craprpp.rowid            
        FROM craprpp
       WHERE craprpp.cdcooper = pr_cdcooper
         AND craprpp.nrdconta = pr_nrdconta
         AND craprpp.nrctrrpp = pr_nraplica
         FOR UPDATE NOWAIT;
    rw_craprpp cr_craprpp%ROWTYPE;   
    
          -- Selecionar dados de aplicacao
      CURSOR cr_craprac (pr_cdcooper craplrg.cdcooper%TYPE,
                       pr_nrdconta craprac.nrdconta%TYPE,
                       pr_nrctrrpp craprac.nrctrrpp%TYPE) IS
        SELECT
        rac.cdcooper, rac.nrdconta,
        rac.nraplica, rac.cdprodut,
        rac.cdnomenc, rac.dtmvtolt,
        rac.dtvencto, rac.dtatlsld,
        rac.vlaplica, rac.vlbasapl,
        rac.vlsldatl, rac.vlslfmes,
        rac.vlsldacu, rac.qtdiacar,
        rac.qtdiaprz, rac.qtdiaapl,
        rac.txaplica, rac.idsaqtot,
        rac.idblqrgt, rac.idcalorc,
        rac.cdoperad, rac.progress_recid,
        rac.iddebcti, rac.vlbasant,
        rac.vlsldant, rac.dtsldant,
        rac.rowid,
        cpc.nmprodut, cpc.idsitpro,
        cpc.cddindex, cpc.idtippro,
        cpc.idtxfixa, cpc.idacumul,
        cpc.cdhscacc, cpc.cdhsvrcc,
        cpc.cdhsraap, cpc.cdhsnrap, 
        cpc.cdhsprap, cpc.cdhsrvap,
        cpc.cdhsrdap, cpc.cdhsirap,
        cpc.cdhsrgap, cpc.cdhsvtap
        FROM 
        craprac rac,
        crapcpc cpc 
        WHERE
        rac.cdcooper = pr_cdcooper  AND
        rac.nrdconta = pr_nrdconta AND
        rac.nrctrrpp = pr_nrctrrpp AND
        cpc.cdprodut = rac.cdprodut AND
        rac.idsaqtot = 0
        ORDER BY 
        rac.nraplica;
        
        rw_craprac     cr_craprac%rowtype;
    
    -- Buscar dados do lote
    -- Buscar rejeitados
    CURSOR cr_craprej (pr_cdcooper craplot.cdcooper%TYPE,
                       pr_dtmvtopr craplot.dtmvtolt%TYPE) IS
    SELECT craprej.cdcritic,
           craprej.nrdconta,
           craprej.nraplica,
           craprej.dtdaviso,
           craprej.vldaviso,
           craprej.vlsdapli, 
           craprej.vllanmto
      FROM craprej
     WHERE craprej.cdcooper = pr_cdcooper
       AND craprej.dtmvtolt = pr_dtmvtopr
       AND craprej.cdagenci = 156
       AND craprej.cdbccxlt = 156
       AND craprej.nrdolote = 156
       AND craprej.tpintegr = 156
     ORDER BY craprej.dtmvtolt, craprej.cdagenci, craprej.cdbccxlt,
              craprej.nrdolote, craprej.nrdconta, craprej.nraplica;
    
    /* Cursor genérico e padrão para busca da craptab */
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE
                     ,pr_dstextab IN craptab.dstextab%TYPE) IS
      SELECT tab.dstextab
            ,tab.tpregist
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
         AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
         AND tab.cdempres = pr_cdempres
         AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso)
         AND to_number(SUBSTR(tab.dstextab,1,7)) = pr_dstextab;
    rw_craptab cr_craptab%ROWTYPE;

    -- Cursor para encontrar o associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.nmprimtl
          ,ass.vllimcre
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ass.cdcooper
          ,ass.cdagenci
          ,ass.idastcjt
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;   

    --Selecionar informacoes do titular
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
    SELECT ttl.nmextttl
          ,ttl.nrcpfcgc
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    -- Cursosr para encontrar a cidade do PA do associado
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                     ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT age.nmcidade
      FROM crapage age
     WHERE age.cdcooper = pr_cdcooper 
       AND age.cdagenci = pr_cdagenci;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
    vr_dstextab_apli  craptab.dstextab%TYPE;
    vr_fcraprpp       BOOLEAN;
    -- valores de taxa na rotina original progress
    -- sempre retorna zerado para esse programa
    vr_rpp_txaplmes   NUMBER := 0;
    vr_rpp_txaplica   NUMBER := 0;
    
    vr_percenir       NUMBER;
    vr_vlresgat       NUMBER;
    vr_saldorpp       NUMBER;
    vr_vlirabap       NUMBER;	
    vr_vlsdrdppe      NUMBER;
    vr_des_reto       VARCHAR2(5);
    vr_tab_erro       GENE0001.typ_tab_erro;
    vr_flgresga       BOOLEAN;
    vr_flgimune       BOOLEAN;
    vr_regexist       BOOLEAN;
    vr_rel_qtdrejln   INTEGER := 0;
    vr_rel_vldrejdb   NUMBER := 0;
    vr_rel_vldrejcr   NUMBER := 0;

    vr_vlultren NUMBER(20,8) := 0; --> Valor de ultimo rendimento
    vr_vlrentot NUMBER(20,8) := 0; --> Valor de rendimento total
    vr_vlrevers NUMBER(20,8) := 0; --> Valor de reversao
    vr_vlrdirrf NUMBER(20,8) := 0; --> Valor de IRRF
    vr_percirrf NUMBER(20,8) := 0; --> Valor percentual de IRRF
    vr_vlsldttr NUMBER(20,8) := 0; --> Valor Saldo Total de Resgate
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(100);
    
    -- Tabela de retorno LANC0001 (PRJ450 03/07/2018).
    vr_tab_retorno     lanc0001.typ_reg_retorno;
    vr_incrineg        number;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
      
    PROCEDURE pc_gera_resgate_app_prog(pr_cdcooper crapcop.cdcooper%TYPE,
                                          pr_tpresgat craplrg.flgcreci%TYPE,
                                          pr_flgcreci craplrg.flgcreci%TYPE,
                                          pr_vlresgat NUMBER) IS

      ------------------------------- VARIAVEIS -------------------------------
    vr_cdcritic_app   PLS_INTEGER := 0;
    vr_dscritic_app   VARCHAR2(4000) := NULL;
    vr_tpcritic_app crapcri.cdcritic%TYPE;
    BEGIN

        vr_nrseqrgt := 0;
        vr_vlrtotresgate_apl := 0;
        vr_vlresgat_acu := 0;
        vr_flgfimresga := FALSE;        
       BEGIN
        -- Buscar aplicações para os resgates solicitados.
        FOR rw_craprac IN cr_craprac (pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => rw_craprpp.nrdconta,
                                      pr_nrctrrpp => rw_craprpp.nrctrrpp) LOOP
                vr_vlrgappr := 0;
                vr_vlsdappr := 0;
                vr_vlsldttr := 0;
         	
         	vr_tpresgate_apl := pr_tpresgat;
         	vr_nrseqrgt := vr_nrseqrgt + 1;

                APLI0008.pc_calc_saldo_resgate (pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_vlresgat => vr_vlresgat - vr_vlresgat_acu
                                                   ,pr_idtiprgt => vr_tpresgate_apl
                                                   ,pr_dtresgat => rw_crapdat.dtmvtopr
                                                   ,pr_nrseqrgt => 0
                                                   ,pr_idrgtcti => 0
                                                   ,pr_vlsldtot => vr_vlsdappr 
                                                   ,pr_vlsldrgt => vr_vlrgappr
                                                   ,pr_vlultren => vr_vlultren 
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers 
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_vlsldttr => vr_vlsldttr
                                                   ,pr_tpcritic => vr_tpcritic_app
                                                   ,pr_cdcritic => vr_cdcritic_app
                                                   ,pr_dscritic => vr_dscritic_app);

                -- Se encontrar erros na execucão
                IF vr_dscritic_app is not null THEN
                   RAISE vr_exc_saida;
                END IF;

                IF (vr_nrseqrgt > 1) THEN
                  vr_perirapl := -1;
                ELSE
                  vr_perirapl := vr_percirrf;
                END IF;
                      
                vr_valortir := vr_valortir + vr_vlrdirrf;

                vr_vlrtotresgate_apl := vr_vlrtotresgate_apl + vr_vlrgappr;
                vr_vlresgat_apl := vr_vlrgappr;
                vr_tpresgate_apl := 1;
                IF (pr_tpresgat = 1) THEN
                   IF (vr_vlresgat > vr_vlrtotresgate_apl) THEN
                       vr_tpresgate_apl := 2;
                   ELSIF (vr_vlresgat = vr_vlrtotresgate_apl) THEN
                        IF (vr_vlrgappr = vr_vlsldttr) THEN
                           vr_tpresgate_apl := 2;
                        ELSE
                           vr_tpresgate_apl := 1;
                        END IF;
                          vr_flgfimresga := TRUE;
                   ELSE
                       vr_vlresgat_apl := vr_vlresgat - vr_vlresgat_acu;    
                       vr_flgfimresga := TRUE;
                   END IF;
                 ELSE
                   vr_tpresgate_apl := 2;
                 END IF;
                 
                 APLI0005.pc_efetua_resgate(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_craprac.nrdconta
                                      ,pr_nraplica => rw_craprac.nraplica
                                      ,pr_vlresgat => vr_vlresgat_apl
                                      ,pr_idtiprgt => vr_tpresgate_apl
                                      ,pr_dtresgat => rw_crapdat.dtmvtopr
                                      ,pr_nrseqrgt => vr_nrseqrgt
                                      ,pr_idrgtcti => pr_flgcreci
                                      ,pr_tpcritic => vr_tpcritic_app
                                      ,pr_cdcritic => vr_cdcritic_app
                                      ,pr_dscritic => vr_dscritic_app);
                
                vr_vlresgat_acu := vr_vlresgat_acu + vr_vlresgat_apl;
                -- Se encontrar erros na execuc?o
                IF vr_dscritic_app is not null THEN
                  RAISE vr_exc_saida;
                END IF;

                IF (vr_flgfimresga) THEN
                    EXIT;
                END IF;
          END LOOP; -- fim loop rac
         EXCEPTION
           WHEN vr_exc_saida THEN
             vr_cdcritic := vr_cdcritic_app;
             vr_dscritic := vr_dscritic_app;
           WHEN OTHERS THEN
             vr_dscritic := 'Não foi possivel inserir craplot(8383): '||SQLERRM;
             RAISE vr_exc_saida;
         END;
    END pc_gera_resgate_app_prog;


    PROCEDURE pc_gera_resgate_poup_prog(pr_cdcooper crapcop.cdcooper%TYPE,
                                          pr_flgcreci craplrg.flgcreci%TYPE,
                                          pr_vlresgat NUMBER) IS
    /* Gerar  lançamento na conta investimento*/
    PROCEDURE pc_gera_lancamentos_craplci(pr_cdcooper crapcop.cdcooper%TYPE,
                                          pr_flgctain craprpp.flgctain%TYPE,
                                          pr_flgcreci craplrg.flgcreci%TYPE,
                                          pr_nrdconta craprpp.nrdconta%TYPE,
                                          pr_vlresgat NUMBER) IS
                                          
      ------------------------------- VARIAVEIS -------------------------------
      vr_qtdsli PLS_INTEGER;
      
    BEGIN
      IF pr_flgctain = 1 /* True */ AND  /* Nova aplicacao  */    
         pr_flgcreci = 0 /* False*/ THEN  /* Somente Transferencia */
        
        /*  Gera lancamentos Conta Investimento  - Debito Transf */
        /* Projeto Revitalizacao - Remocao de lote */
        lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                  , pr_dtmvtolt => rw_crapdat.dtmvtopr
                                  , pr_cdagenci => 1
                                  , pr_cdbccxlt => 100
                                  , pr_nrdolote => 10105
                                  , pr_cdoperad => '1'
                                  , pr_nrdcaixa => 0
                                  , pr_tplotmov => 29
                                  , pr_cdhistor => 0
                                  , pr_craplot => rw_craplot_rvt
                                  , pr_dscritic => vr_dscritic);
                  
        if vr_dscritic is not null then
              RAISE vr_exc_saida;
        END IF;
              
        vr_nrseqdig := fn_sequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,''||pr_cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||10105);
        
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
                      ,craplci.cdcooper )
               VALUES (rw_craplot_rvt.dtmvtolt -- craplci.dtmvtolt 
                      ,rw_craplot_rvt.cdagenci -- craplci.cdagenci 
                      ,rw_craplot_rvt.cdbccxlt -- craplci.cdbccxlt 
                      ,rw_craplot_rvt.nrdolote -- craplci.nrdolote 
                      ,pr_nrdconta         -- craplci.nrdconta 
                      ,vr_nrseqdig -- craplci.nrdocmto 
                      ,496 /* Debito */    -- craplci.cdhistor 
                      ,pr_vlresgat         -- craplci.vllanmto 
                      ,vr_nrseqdig -- craplci.nrseqdig 
                      ,pr_cdcooper);       -- craplci.cdcooper 
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel inserir craplci(nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
        /*** Gera lancamentos Conta Investmento  - Credito Transf. ***/
        /* Projeto Revitalizacao - Remocao de lote */
        lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                  , pr_dtmvtolt => rw_crapdat.dtmvtopr
                                  , pr_cdagenci => 1
                                  , pr_cdbccxlt => 100
                                  , pr_nrdolote => 10104
                                  , pr_cdoperad => '1'
                                  , pr_nrdcaixa => 0
                                  , pr_tplotmov => 29
                                  , pr_cdhistor => 0
                                  , pr_craplot => rw_craplot_rvt
                                  , pr_dscritic => vr_dscritic);
                  
        if vr_dscritic is not null then
              RAISE vr_exc_saida;
        END IF;
              
        vr_nrseqdig := fn_sequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,''||pr_cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||10104);
        
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
                      ,craplci.cdcooper )
               VALUES (rw_craplot_rvt.dtmvtolt -- craplci.dtmvtolt 
                      ,rw_craplot_rvt.cdagenci -- craplci.cdagenci 
                      ,rw_craplot_rvt.cdbccxlt -- craplci.cdbccxlt 
                      ,rw_craplot_rvt.nrdolote -- craplci.nrdolote 
                      ,pr_nrdconta         -- craplci.nrdconta 
                      ,vr_nrseqdig -- craplci.nrdocmto 
                      ,489 /*credito*/     -- craplci.cdhistor 
                      ,pr_vlresgat         -- craplci.vllanmto 
                      ,vr_nrseqdig -- craplci.nrseqdig 
                      ,pr_cdcooper);       -- craplci.cdcooper 
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel inserir craplci (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
      END IF;   
      
      /* Resgatar para Conta Investimento */
      IF pr_flgcreci = 1 /*True*/ THEN  
        
        /*** Gera lancamentos Credito Saldo Conta Investimento ***/
        /* Projeto Revitalizacao - Remocao de lote */
        lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                  , pr_dtmvtolt => rw_crapdat.dtmvtopr
                                  , pr_cdagenci => 1
                                  , pr_cdbccxlt => 100
                                  , pr_nrdolote => 10106
                                  , pr_cdoperad => '1'
                                  , pr_nrdcaixa => 0
                                  , pr_tplotmov => 29
                                  , pr_cdhistor => 0
                                  , pr_craplot => rw_craplot_rvt
                                  , pr_dscritic => vr_dscritic);
                  
        if vr_dscritic is not null then
              RAISE vr_exc_saida;
        END IF;
              
        vr_nrseqdig := fn_sequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,''||pr_cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||10106);
        
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
                      ,craplci.cdcooper )
               VALUES (rw_craplot_rvt.dtmvtolt -- craplci.dtmvtolt 
                      ,rw_craplot_rvt.cdagenci -- craplci.cdagenci 
                      ,rw_craplot_rvt.cdbccxlt -- craplci.cdbccxlt 
                      ,rw_craplot_rvt.nrdolote -- craplci.nrdolote 
                      ,pr_nrdconta         -- craplci.nrdconta 
                      ,vr_nrseqdig -- craplci.nrdocmto 
                      ,490   /* Credito Proveniente Aplicacao*/     -- craplci.cdhistor 
                      ,pr_vlresgat         -- craplci.vllanmto 
                      ,vr_nrseqdig -- craplci.nrseqdig 
                      ,pr_cdcooper);       -- craplci.cdcooper 
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel inserir craplci (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;  
        
        --- Atualizar Saldo Conta Investimento ---
        BEGIN
          UPDATE crapsli
             SET crapsli.vlsddisp = crapsli.vlsddisp + pr_vlresgat
           WHERE crapsli.cdcooper = pr_cdcooper
             AND crapsli.nrdconta = pr_nrdconta
             AND to_char(crapsli.dtrefere,'MMRRRR') = to_char(rw_crapdat.dtmvtopr,'MMRRRR');
             
          -- guardar qtd de registros alterados   
          vr_qtdsli := SQL%ROWCOUNT;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel alterar crapsli (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
        -- se não alterou nenhum registro, deve inserir
        IF vr_qtdsli = 0 THEN
          BEGIN
            INSERT INTO crapsli
                        (crapsli.dtrefere,
                         crapsli.nrdconta,
                         crapsli.cdcooper,
                         crapsli.vlsddisp)
                 VALUES (last_day(rw_crapdat.dtmvtopr)
                        ,pr_nrdconta
                        ,pr_cdcooper
                        ,pr_vlresgat);
          EXCEPTION 
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir crapsli (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
              RAISE vr_exc_saida;  
          END;
        END IF;
        
      END IF;
      
      
    END pc_gera_lancamentos_craplci;

  BEGIN

      ------------------------------- VARIAVEIS -------------------------------
            IF pr_flgcreci = 0 /* false */ THEN /*Resgate Conta Corrente*/
              /* Projeto Revitalizacao - Remocao de lote */
              lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                        , pr_dtmvtolt => rw_crapdat.dtmvtopr
                                        , pr_cdagenci => 1
                                        , pr_cdbccxlt => 100
                                        , pr_nrdolote => 8473
                                        , pr_cdoperad => '1'
                                        , pr_nrdcaixa => 0
                                        , pr_tplotmov => 1
                                        , pr_cdhistor => 0
                                        , pr_craplot => rw_craplot_rvt
                                        , pr_dscritic => vr_dscritic);
                      
              if vr_dscritic is not null then
                    RAISE vr_exc_saida;
              END IF;
                  
              vr_nrseqdig := fn_sequence('CRAPLOT'
                                        ,'NRSEQDIG'
                                        ,''||pr_cdcooper||';'
                                         ||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||';'
                                         ||1||';'
                                         ||100||';'
                                         ||8473); 

                  
            -- PRJ450 - 03/07/2018.
            lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_craplot_rvt.dtmvtolt
                                             , pr_cdagenci => rw_craplot_rvt.cdagenci
                                             , pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                                             , pr_nrdolote => rw_craplot_rvt.nrdolote
                                             , pr_nrdconta => rw_craprpp.nrdconta
                                             , pr_nrdocmto => vr_nrseqdig
                                             , pr_cdhistor => (CASE rw_craprpp.flgctain 
                               WHEN 1 /* true */ THEN 501 -- TRANSF. RESGATE POUP.PROGRAMADA DA C/I PARA C/C
                               ELSE 159 -- CR.POUP.PROGR
                                                               END)      
                                             , pr_nrseqdig => vr_nrseqdig
                                             , pr_vllanmto => vr_vlresgat
                                             , pr_nrdctabb => rw_craprpp.nrdconta
                                             --, pr_cdpesqbb => NVL(vr_cdpesqbb,0)
                                             --, pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                             --, pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                             --, pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                             --, pr_cdbanchq => lt_d_nrbanori
                                             --, pr_cdcmpchq => lt_d_cdcmpori
                                             --, pr_cdagechq => lt_d_nrageori
                                             --, pr_nrctachq => lt_d_nrctarem
                                             --, pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                             --, pr_sqlotchq => lt_d_nrsequen
                                             --, pr_dtrefere => rw_craprda.dtmvtolt
                                             --, pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                             --, pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                             --, pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                             , pr_cdcooper => pr_cdcooper
                                             , pr_nrdctitg => gene0002.fn_mask(rw_craprpp.nrdconta,'99999999')
                                             --, pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                             --, pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                             --, pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                             --, pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                             --, pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                             --, pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                             --, pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                             --, pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                             --, pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                             -------------------------------------------------
                                             -- Dados do lote (Opcional)
                                             -------------------------------------------------
                                             --, pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                             --, pr_tplotmov  => 1
                                             , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                             , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                             , pr_cdcritic  => vr_cdcritic      -- OUT
                                             , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
      
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução
              IF vr_incrineg = 0 THEN  
                vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
                  RAISE vr_exc_saida;  
              ELSE
                -- Neste caso se trata de uma crítica de Negócio e o lançamento não pode ser efetuado
                -- Para CREDITO: Utilizar o CONTINUE ou gerar uma mensagem de retorno(se for chamado por uma tela); 
                -- Para DEBITO: Será necessário identificar se a rotina ignora esta inconsistência(CONTINUE) ou se devemos tomar alguma ação(efetuar algum cancelamento por exemplo, gerar mensagem de retorno ou abortar o programa)
                vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
                RAISE vr_exc_saida;  
              END IF;  
            END IF;	
				
            END IF; --> Fim IF rw_craplrg.flgcreci = 0 /* false */ /*Resgate Conta Corrente*/
                                              
            /* Gerar  lançamento na conta investimento*/
            pc_gera_lancamentos_craplci(pr_cdcooper => pr_cdcooper,
                                        pr_flgctain => rw_craprpp.flgctain,
                                        pr_flgcreci => pr_flgcreci,
                                        pr_nrdconta => rw_craprpp.nrdconta,
                                        pr_vlresgat => vr_vlresgat);
                                              
            --> Gera lancamento do resgate <--
            /* Projeto Revitalizacao - Remocao de lote */
            lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                      , pr_dtmvtolt => rw_crapdat.dtmvtopr
                                      , pr_cdagenci => 1
                                      , pr_cdbccxlt => 100
                                      , pr_nrdolote => 8383
                                      , pr_cdoperad => '1'
                                      , pr_nrdcaixa => 0
                                      , pr_tplotmov => 14
                                      , pr_cdhistor => 0
                                      , pr_craplot => rw_craplot_rvt
                                      , pr_dscritic => vr_dscritic);
                      
            if vr_dscritic is not null then
                  RAISE vr_exc_saida;
            END IF;
                  
            vr_nrseqdig := fn_sequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,''||pr_cdcooper||';'
                                       ||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||';'
                                       ||1||';'
                                       ||100||';'
                                       ||8383);
                  
            -- inserir lançamento
            BEGIN
              INSERT INTO craplpp
                          (craplpp.dtmvtolt
                          ,craplpp.cdagenci
                          ,craplpp.cdbccxlt
                          ,craplpp.nrdolote
                          ,craplpp.nrdconta
                          ,craplpp.nrctrrpp
                          ,craplpp.nrdocmto
                          ,craplpp.txaplmes
                          ,craplpp.txaplica
                          ,craplpp.cdhistor
                          ,craplpp.nrseqdig
                          ,craplpp.dtrefere
                          ,craplpp.vllanmto
                          ,craplpp.cdcooper)
                   VALUES( rw_craplot_rvt.dtmvtolt           -- craplpp.dtmvtolt
                          ,rw_craplot_rvt.cdagenci           -- craplpp.cdagenci
                          ,rw_craplot_rvt.cdbccxlt           -- craplpp.cdbccxlt
                          ,rw_craplot_rvt.nrdolote           -- craplpp.nrdolote
                          ,rw_craprpp.nrdconta           -- craplpp.nrdconta
                          ,rw_craprpp.nrctrrpp           -- craplpp.nrctrrpp
                          ,vr_nrseqdig           -- craplpp.nrdocmto
                          ,vr_rpp_txaplmes               -- craplpp.txaplmes
                          ,vr_rpp_txaplica               -- craplpp.txaplica
                          ,(CASE rw_craprpp.flgctain 
                              WHEN 1 /*YES*/  THEN 
                                  496   /* RESGATE POUP. p/ C.I */ 
                              ELSE 158  /* RESGATE POUP. */       -- craplpp.cdhistor
                            END) 
                          ,vr_nrseqdig           -- craplpp.nrseqdig
                          ,rw_craprpp.dtfimper           -- craplpp.dtrefere
                          ,vr_vlresgat                   -- craplpp.vllanmto
                          ,pr_cdcooper );                -- craplpp.cdcooper 
                  
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar craplpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;  
    END pc_gera_resgate_poup_prog;

  /*.......................................................................................

   Programa: PC_CRPS156             
   Sigla   : -
   Autor   : Rubens Lima.
   Data    : Janeiro/2019                          Ultima atualizacao: 

   Dados referentes ao programa:
      
   Objetivo  : Rotina para tratamento de erros da aplicacao

   Alteracoes: 
                
  .......................................................................................*/  
  PROCEDURE pr_trata_erro (prm_nr_tentativa IN NUMBER, 
                           prm_nr_sqlcode   IN NUMBER, 
                           prm_nm_tabela    IN VARCHAR2, 
                           prm_ds_critica   OUT VARCHAR2,
                           prm_des_unit     IN VARCHAR2,
                           prm_nr_linha     IN NUMBER) IS 
  BEGIN

    IF (prm_nr_sqlcode = -54) THEN 
      IF (prm_nr_tentativa < vr_gbl_total_vezes) THEN 
        DBMS_LOCK.SLEEP(1); --Sleep 1 segundo 
      ELSE 
        -- Gera exceção 
        prm_ds_critica := 'Nao foi possivel alocar a tabela '||prm_nm_tabela||' - '||prm_des_unit||' linha '||prm_nr_linha;        
      END IF; 
    ELSE
      prm_ds_critica := 'Nao foi possivel alocar a tabela '||prm_nm_tabela||' - ERRO '||prm_nr_sqlcode||' - '||prm_des_unit||' linha '||prm_nr_linha;
    END IF;          

  EXCEPTION 
    WHEN OTHERS THEN 
      prm_ds_critica := 'Erro geral na pr_trata_erro. Descrição: '||SQLERRM; 
  END pr_trata_erro;                                               
      
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

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
      RAISE vr_exc_saida;
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
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Se for informado o numero da conta nao deve-se fazer a validacao de inicio de programa,
    -- pois refere-se a um processo do BacenJud
    IF nvl(pr_nrdconta,0) = 0 THEN
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF nvl(vr_cdcritic,0) <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
    ELSE
      -- Coloca a data do proximo processo como data atual, para o credito
      -- entrar no mesmo dia
      rw_crapdat.dtmvtopr := rw_crapdat.dtmvtolt;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    vr_regexist := FALSE;
    
    -- buscar percentual
    vr_dstextab_apli :=  tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'CONFIG'
                                                    ,pr_cdempres => 0
                                                    ,pr_cdacesso => 'PERCIRAPLI'
                                                    ,pr_tpregist => 0);
                                             
    IF TRIM(vr_dstextab_apli) IS NOT NULL THEN
      vr_percenir := vr_dstextab_apli;
    ELSE
      vr_percenir := 0;
    END IF;
    -- Buscar lancamentos de resgates solicitados.
    FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => nvl(pr_nrdconta,0),
                                  pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP
      vr_cdcritic := 0;
      vr_vlresgat := 0;
      vr_saldorpp := 0;
      
      vr_gbl_tentativa:=0;
      vr_gbl_achou_registro:=0;
      
      WHILE vr_gbl_achou_registro=0 AND vr_gbl_tentativa<vr_gbl_total_vezes LOOP  
        BEGIN
        vr_gbl_tentativa:=vr_gbl_tentativa+1;         
        vr_geraprotocolo := 0;
	vr_valortir := 0;
          -- Buscar cadastro da poupanca programada.
          OPEN cr_craprpp (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_craplrg.nrdconta,
                           pr_nraplica => rw_craplrg.nraplica);
          FETCH cr_craprpp INTO rw_craprpp;
        vr_gbl_achou_registro:=1; --condição de saida
    
          vr_fcraprpp := cr_craprpp%FOUND; 
          CLOSE cr_craprpp;
          
          IF NOT vr_fcraprpp THEN
            vr_cdcritic := 484;
          ELSE
              vr_cdcritic := 0;
              IF (rw_craprpp.cdprodut < 1) THEN
            /* Rotina de calculo do saldo da aplicac?o ate a data do movimento */
            APLI0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper,        --> Cooperativa
                                      pr_dstextab  => vr_dstextab_apli,         --> Percentual de IR da aplicac?o
                                      pr_cdprogra  => vr_cdprogra,        --> Programa chamador
                                      pr_inproces  => rw_crapdat.inproces,--> Indicador do processo
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,--> Data do processo
                                      pr_dtmvtopr  => rw_crapdat.dtmvtopr,--> Proximo dia util
                                      pr_rpp_rowid => rw_craprpp.rowid,   --> Identificador do registro da tabela CRAPRPP em processamento
                                      pr_vlsdrdpp  => vr_vlsdrdppe,       --> Saldo da poupanca programada
                                      -- conforme codigo original do progress, informações sempre são retornadas zeradas
                                      -- para esse programa
                                      -- pr_txaplmes  => vr_rpp_txaplmes     --> Taxa de aplicação mês
                                      -- pr_txaplica  => vr_rpp_txaplica     --> Taxa de aplicação 
                                      pr_cdcritic  => vr_cdcritic,        --> Codigo da critica de erro
                                      pr_des_erro  => vr_dscritic);       --> Descric?o do erro encontrado
        ELSE
              vr_vlresgat := 0;
              vr_saldorpp := 0;
              vr_vlsdrdppe := 0;
                /* Rotina de calculo do saldo da aplicac?o ate a data do movimento */
                apli0008.pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => vr_cdprogra
                                        ,pr_cdoperad => '1'
                                        ,pr_nrdconta => rw_craprpp.nrdconta
                                        ,pr_idseqttl => 1
                                        ,pr_idorigem => 5
                                        ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                                        ,pr_vlsdrdpp => vr_vlsdrdppe
                                        ,pr_des_erro => vr_dscritic);
        END IF;
            -- Se encontrar erros na execuc?o
            IF vr_dscritic is not null THEN
              RAISE vr_exc_saida;
            END IF;
            
            vr_flgresga := TRUE;
            vr_saldorpp := vr_vlsdrdppe;
            
          END IF;          
         
        EXCEPTION
          WHEN OTHERS THEN
          pr_trata_erro(vr_gbl_tentativa,SQLCODE,'craprpp',vr_dscritic, $$plsql_unit, $$plsql_line); 
          IF vr_dscritic IS NOT NULL THEN 
            RAISE vr_exc_saida; 
             END IF;
        END;                   
             
      END LOOP;
      
      /* Testa se aplicacao esta disponivel para saque */
      IF nvl(vr_cdcritic,0) <> 484   THEN
        -- buscar percentual
        OPEN cr_craptab( pr_cdcooper => pr_cdcooper
                        ,pr_nmsistem => 'CRED'
                        ,pr_tptabela => 'BLQRGT'
                        ,pr_cdempres => 00
                        ,pr_cdacesso => gene0002.fn_mask(rw_craplrg.nrdconta,'9999999999')
                        ,pr_dstextab => rw_craplrg.nraplica );
        FETCH cr_craptab INTO rw_craptab;
        IF cr_craptab%FOUND THEN
          /* Vencida e Bloqueada faz o resgate */
          IF rw_craprpp.dtvctopp <= rw_crapdat.dtmvtopr  THEN
            vr_cdcritic := 828;
          ELSIF pr_nrdconta = 0 AND rw_craplrg.idautblq = 1 THEN -- Somente validar abaixo se for do processo noturno   
            /* caso contrario critica, esta bloqueada e nao venceu */
            vr_cdcritic := 640;
          END IF;
        END IF;   
        CLOSE cr_craptab;
      END IF;
      
       /* Se nao houve erro ou é uma bloqueada vencida r ser resgatada */
      IF  nvl(vr_cdcritic,0) = 0 OR vr_cdcritic = 828  THEN
          IF vr_saldorpp > 0   THEN
            vr_vlirabap := 0;
                                      
            IF rw_craprpp.vlabcpmf <> 0 THEN
              /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
              IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => rw_craplrg.cdcooper  --> Codigo Cooperativa
                                                   ,pr_nrdconta  => rw_craplrg.nrdconta  --> Numero da Conta
                                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data movimento
                                                   ,pr_flgrvvlr  => FALSE        --> Identificador se deve gravar valor
                                                   ,pr_cdinsenc  => 5            --> Codigo da insenção
                                                   ,pr_vlinsenc  => 0            --> Valor insento
                                                   ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                                   ,pr_dsreturn  => vr_des_reto  --> Descricao Critica
                                                   ,pr_tab_erro  => vr_tab_erro);--> Tabela erros

              /*O tratamento de retorno abaixo foi comentado pois, no progress, o mesmo não
                é implementado.
              -- Caso retornou com erro, levantar exceção
              IF pr_des_reto = 'NOK' THEN
                RAISE vr_exc_erro;
              END IF; */
              
              -- se nao for imune, calcular valor
              IF NOT vr_flgimune THEN
                vr_vlirabap := TRUNC((rw_craprpp.vlabcpmf * vr_percenir / 100),2);
              END IF;                                     
            END IF; -- FIM IF rw_craprpp.vlabcpmf <> 0   
            CASE rw_craplrg.tpresgat
              WHEN  1  THEN  /*  Parcial  */
                IF rw_craplrg.vllanmto > (vr_saldorpp - vr_vlirabap) THEN
                  vr_vlresgat := vr_saldorpp - vr_vlirabap;
                  vr_cdcritic := 429; -- 429 - Resgate menor que o solicitado.
                ELSE
                  vr_vlresgat := rw_craplrg.vllanmto;
                END IF;
              WHEN  2  THEN  /*  Total  */
                vr_vlresgat := vr_saldorpp - vr_vlirabap;
              WHEN  3  THEN  /*  Antecipado  */
                IF rw_craplrg.vllanmto = 0 THEN
                  vr_vlresgat := vr_saldorpp - vr_vlirabap;
                ELSIF rw_craplrg.vllanmto > (vr_saldorpp - vr_vlirabap) THEN
                  vr_vlresgat := vr_saldorpp - vr_vlirabap;
                  vr_cdcritic := 429; -- 429 - Resgate menor que o solicitado.
                ELSE
                  vr_vlresgat := rw_craplrg.vllanmto;
                END IF;
            END CASE;
        ELSE
          vr_cdcritic := 494; --> 494 - Poupanca programada sem saldo.
        END IF;
      END IF;
      
      -- Se não há critica ainda 
      IF nvl(vr_cdcritic,0) NOT IN(484,828,640,494)  THEN
        -- Validar resgate
        Apli0002.pc_ver_val_bloqueio_poup(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => 1,
                                          pr_nrdcaixa => 1,
                                          pr_cdoperad => '1',
                                          pr_nmdatela => 'CRPS156',
                                          pr_idorigem => 7,
                                          pr_nrdconta => rw_craplrg.nrdconta,
                                          pr_idseqttl => 1,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                          pr_inproces => rw_crapdat.inproces,
                                          pr_cdprogra => 'CRPS156',
                                          pr_vlresgat => vr_vlresgat,
                                          pr_flgerlog => 0,
                                          pr_flgrespr => 0,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        
        -- Verifica se houve retorno de erros
        IF (NVL(vr_dscritic, 'OK') <> 'OK') OR (NVL(vr_cdcritic,0) > 0)  THEN
          IF rw_craprpp.dtvctopp <= rw_crapdat.dtmvtopr  THEN
             vr_cdcritic := 828;
             vr_dscritic := '';
          ELSE
             /* caso contrario critica, esta bloqueada e nao venceu */
             vr_cdcritic := 640;
             vr_dscritic := '';
          END IF;
        END IF;

      END IF;
	  /* Se nao houve erro ou é uma bloqueada vencida r ser resgatada */
      IF  (nvl(vr_cdcritic,0) = 0 OR vr_cdcritic = 828 OR vr_cdcritic = 429) THEN
      
        IF (rw_craprpp.cdprodut <= 0) THEN
           pc_gera_resgate_poup_prog(pr_cdcooper => pr_cdcooper,
                                          pr_flgcreci => rw_craplrg.flgcreci,
                                          pr_vlresgat => vr_vlresgat);
           vr_vlresgat_acu := vr_vlresgat;
        ELSE
           pc_gera_resgate_app_prog(pr_cdcooper => pr_cdcooper,
                                          pr_flgcreci => rw_craplrg.flgcreci,
                                          pr_tpresgat => rw_craplrg.tpresgat,
                                          pr_vlresgat => vr_vlresgat);
              END IF;
        IF (vr_dscritic IS NULL) THEN         
            vr_geraprotocolo := 1;
            /* Atualizar valor resgatado */
            BEGIN
              UPDATE craprpp
                 SET craprpp.vlrgtacu = craprpp.vlrgtacu + vr_vlresgat
               WHERE craprpp.rowid = rw_craprpp.rowid;
               
              /* resgate por vencimento */
              IF vr_fcraprpp   THEN
                IF rw_craprpp.dtvctopp <= rw_crapdat.dtmvtopr AND 
                   rw_craplrg.tpresgat = 2                    THEN
                
                  /* Atualizar saldo e situação, se for poupança vencida*/
                    UPDATE craprpp
                       SET craprpp.vlsdrdpp = 0,
                           craprpp.cdsitrpp = 5 -- 5-vencido.
                     WHERE craprpp.rowid = rw_craprpp.rowid;
                  
                END IF;
              END IF;
               
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar craprpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                RAISE vr_exc_saida; 
            END;
          END IF;      
            vr_regexist := TRUE;
            
      END IF;      
      
      IF nvl(vr_cdcritic,0) = 0 THEN
        IF rw_craprpp.dtvctopp <= rw_crapdat.dtmvtopr THEN
          vr_cdcritic := 921; --> 921 - Resgate por vencimento com sucesso
        ELSE
          vr_cdcritic := 434; --> 434 - Resgate efetuado com sucesso.
        END IF;
      END IF;  
      
      -- gravar rejeitado
      IF nvl(vr_cdcritic,0) > 0 THEN
        BEGIN
          INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.cdbccxlt
                      ,craprej.nrdolote
                      ,craprej.nrdconta
                      ,craprej.nraplica
                      ,craprej.dtdaviso
                      ,craprej.vldaviso
                      ,craprej.vlsdapli
                      ,craprej.vllanmto
                      ,craprej.cdcritic
                      ,craprej.tpintegr
                      ,craprej.cdcooper)
               VALUES (rw_crapdat.dtmvtopr  -- craprej.dtmvtolt 
                      ,156                  -- craprej.cdagenci 
                      ,156                  -- craprej.cdbccxlt 
                      ,156                  -- craprej.nrdolote 
                      ,rw_craplrg.nrdconta  -- craprej.nrdconta 
                      ,rw_craplrg.nraplica  -- craprej.nraplica 
                      ,rw_craplrg.dtmvtolt  -- craprej.dtdaviso 
                      ,rw_craplrg.vllanmto  -- craprej.vldaviso 
                      ,vr_saldorpp          -- craprej.vlsdapli 
                      ,vr_vlresgat          -- craprej.vllanmto 
                      ,nvl(vr_cdcritic,0)   -- craprej.cdcritic 
                      ,156                  -- craprej.tpintegr 
                      ,pr_cdcooper); 
                      
          vr_cdcritic := 0;
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel atualizar craprej (nrdconta:'||rw_craplrg.nrdconta||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
      END IF;

     /*##############################
         INICIO GERA PROTOCOLO
     ###############################*/
   
     IF vr_geraprotocolo = 1 THEN
	     -- Encontra registro do associado
	     OPEN cr_crapass(pr_cdcooper => pr_cdcooper
	                    ,pr_nrdconta => rw_craprpp.nrdconta);
	                      
	     FETCH cr_crapass INTO rw_crapass;
	       
	     IF cr_crapass%NOTFOUND THEN
	         
	       -- Fecha o cursor
	       CLOSE cr_crapass;
	         
	       -- Monta critica
	       vr_cdcritic := 9;
	       vr_dscritic := NULL;
	         
	       -- Gera exceção
	       RAISE vr_exc_saida;
	         
	     ELSE
	       -- Fecha o cursor
	       CLOSE cr_crapass;   
	       
	     END IF;        
	    
	     -- Busca a cidade do PA do associado
	     OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
	                    ,pr_cdagenci => rw_crapass.cdagenci);
	                          
	     FETCH cr_crapage INTO vr_nmcidade;
	           
	     IF cr_crapage%NOTFOUND THEN
	       --Fechar Cursor
	       CLOSE cr_crapage;
	               
	       vr_cdcritic:= 962;
	       vr_dscritic:= NULL;
	               
	       -- Gera exceção
	       RAISE vr_exc_saida;
	     ELSE
	       -- Fechar o cursor
	       CLOSE cr_crapage;
	             
	     END IF; 
	    
	     --Formata nrdconta para visualizacao na internet 
	     vr_nrdconta:= GENE0002.fn_mask_conta(rw_crapass.nrdconta);
	       
	     --Trocar o ultimo ponto por traco
	     vr_nrdconta:= SubStr(vr_nrdconta,1,Length(vr_nrdconta)-2)||'-'||
	                   SubStr(vr_nrdconta,Length(vr_nrdconta),1);
	       
	     --Se for pessoa fisica
	     IF rw_crapass.inpessoa = 1 THEN
	         
	       --ome do titular que fez a transferencia
	       OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
	                       ,pr_nrdconta => rw_crapass.nrdconta
	                       ,pr_idseqttl => 1);
	         
	       --Posicionar no proximo registro
	       FETCH cr_crapttl INTO rw_crapttl;
	         
	       --Se nao encontrar
	       IF cr_crapttl%NOTFOUND THEN
	         --Fechar Cursor
	         CLOSE cr_crapttl;
	           
	         vr_cdcritic:= 0;
	         vr_dscritic:= 'Titular nao encontrado.';
	           
	         -- Gera exceção
	         RAISE vr_exc_saida;
	       END IF;
	         
	       --Fechar Cursor
	       CLOSE cr_crapttl;
	         
	       --Nome titular
	       vr_nmextttl:= rw_crapttl.nmextttl;
	         
	     ELSE
	       vr_nmextttl:= rw_crapass.nmprimtl;
	     END IF;
	    
	     IF (vr_perirapl < 0) THEN
	        vr_dsperirapl := '';
	     ELSE
	         vr_dsperirapl := TO_CHAR(NVL(vr_perirapl, '0'), 'fm990D00') || '%';
	     END IF;
	     
	     vr_dsinfor1:= 'Resgate Aplic. Programada';          
	    
	     vr_dsinfor2:= vr_nmextttl ||'#' ||
	                   'Conta/dv: ' ||vr_nrdconta ||' - '||
	                   rw_crapass.nmprimtl||'#'|| gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
	                   ' - '|| rw_crapcop.nmrescop;
	     vr_dsinfor3:= 'Data do Resgate: '   || TO_CHAR(rw_crapdat.dtmvtolt,'dd/mm/yyyy')           || '#' ||
	                   'Numero do Resgate: ' || TO_CHAR(rw_craprpp.nrctrrpp,'9G999G990')    || '#' ||
	           'IRRF (Imposto de Renda Retido na Fonte): ' || TO_CHAR(vr_valortir,'999G999G990D00') || '#' ||
	                   'Aliquota IRRF: '       || vr_dsperirapl  || '#' ||
	                   'Valor Bruto: '         || TO_CHAR(vr_vlresgat_acu  + vr_valortir,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') || '#'  ||                                 
	                   'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' || 
	                   'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' ||
	                   UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(rw_crapdat.dtmvtolt,'dd') || ' DE ' || GENE0001.vr_vet_nmmesano(TO_CHAR(rw_crapdat.dtmvtolt,'mm')) || ' DE ' || TO_CHAR(rw_crapdat.dtmvtolt,'RRRR') || '.';                             
	    
	     --Gerar protocolo
	     GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper                         --> Código da cooperativa
	                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 --> Data movimento
	                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) --> Hora da transação NOK
	                               ,pr_nrdconta => rw_craprpp.nrdconta                         --> Número da conta
	                               ,pr_nrdocmto => rw_craprpp.nrctrrpp                         --> Número do documento
	                               ,pr_nrseqaut => 0                                   --> Número da sequencia
	                               ,pr_vllanmto => vr_vlresgat_acu                     --> Valor lançamento
	                               ,pr_nrdcaixa => 1                         	   --> Número do caixa NOK
	                               ,pr_gravapro => TRUE                                --> Controle de gravação
	                               ,pr_cdtippro => 12                                  --> Código de operação
	                               ,pr_dsinfor1 => vr_dsinfor1                         --> Descrição 1
	                               ,pr_dsinfor2 => vr_dsinfor2                         --> Descrição 2
	                               ,pr_dsinfor3 => vr_dsinfor3                         --> Descrição 3
	                               ,pr_dscedent => NULL                                --> Descritivo
	                               ,pr_flgagend => FALSE                               --> Controle de agenda
	                               ,pr_nrcpfope => 0                                   --> Número de operação
	                               ,pr_nrcpfpre => 0                                   --> Número pré operação
	                               ,pr_nmprepos => ''                                  --> Nome
	                               ,pr_dsprotoc => vr_dsprotoc                         --> Descrição do protocolo
	                               ,pr_dscritic => vr_dscritic                         --> Descrição crítica
	                               ,pr_des_erro => vr_des_erro);                       --> Descrição dos erros de processo
	                             
	         IF (vr_cdcritic <> 0 ) OR (vr_dscritic IS NOT NULL) THEN
	            RAISE vr_exc_saida;
	         END IF;
	END IF;
      
      /* Atualizar lancamentos de resgates solicitados como processado */
      BEGIN
        UPDATE craplrg
           SET craplrg.inresgat = 1
         WHERE craplrg.rowid = rw_craplrg.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar craplrg (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
          RAISE vr_exc_saida; 
      END; 
                     
    END LOOP;  -- Fim Loop craplrg  -- --  Leitura dos resgates programados                   
    
    -- Gerar relatorio somente se for o processo da cadeia
    IF nvl(pr_nrdconta,0) = 0 THEN
    
      /** Geração Relatorio crrl125 **/
      
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl125>');
          
      IF vr_regexist THEN
        pc_escreve_xml('<lote dtmvtolt="'||to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||'"  
                                cdagenci="'||1||'"
                                cdbccxlt="'||100||'"  
                                nrdolote="'||8383||'"
                                tplotmov="'||14||'" >');
      END IF;
        
      vr_cdcritic := 0;
        
      -- ler criticas
      FOR rw_craprej  IN cr_craprej (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP
        
        -- buscar descrição da critica
        IF nvl(vr_cdcritic,0) <> rw_craprej.cdcritic THEN
           vr_cdcritic := rw_craprej.cdcritic;
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pc_escreve_xml('<rejeitados>
                            <nrdconta>'|| gene0002.fn_mask_conta(rw_craprej.nrdconta) ||'</nrdconta>
                            <nraplica>'|| gene0002.fn_mask_contrato(rw_craprej.nraplica)||'</nraplica>
                            <dtdaviso>'|| to_char(rw_craprej.dtdaviso,'DD/MM/RRRR')   ||'</dtdaviso>
                            <vldaviso>'|| rw_craprej.vldaviso                         ||'</vldaviso>
                            <vlsdapli>'|| rw_craprej.vlsdapli                         ||'</vlsdapli>
                            <vllanmto>'|| rw_craprej.vllanmto                         ||'</vllanmto>
                            <dscritic>'||         vr_dscritic                         ||'</dscritic>
                        </rejeitados>');
                        
        IF rw_craprej.vllanmto = 0   THEN
          vr_rel_qtdrejln := nvl(vr_rel_qtdrejln,0) + 1;
          vr_rel_vldrejdb := nvl(vr_rel_vldrejdb,0) + rw_craprej.vldaviso;
      END IF;
      
      END LOOP;
      
      IF vr_regexist THEN
        pc_escreve_xml('</lote>');
      
        pc_escreve_xml('<total>
                          <tot_qtcompln>'|| 0 ||'</tot_qtcompln>
                          <tot_vlcompdb>'|| 0 ||'</tot_vlcompdb>
                          <tot_vlcompcr>'|| 0 ||'</tot_vlcompcr>
                          <tot_qtdrejln>'||     vr_rel_qtdrejln  ||'</tot_qtdrejln>    
                          <tot_vldrejdb>'||     vr_rel_vldrejdb  ||'</tot_vldrejdb>    
                          <tot_vldrejcr>'||     vr_rel_vldrejcr  ||'</tot_vldrejcr>
                        </total>');
      END IF;
      
      -- Finalizar o agrupador do relatório
      pc_escreve_xml('</crrl125>',TRUE);

      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    
      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl125/lote/rejeitados'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl125.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl125.lst' --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);                                        
    END IF; -- Fim da verificacao de processo da cadeia
    
    -- limpar rejeitados
    BEGIN
      DELETE craprej
       WHERE craprej.cdcooper = pr_cdcooper
         AND craprej.dtmvtolt = rw_crapdat.dtmvtopr
         AND craprej.cdagenci = 156
         AND craprej.cdbccxlt = 156
         AND craprej.nrdolote = 156
         AND craprej.tpintegr = 156;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel deletar craprej: '||SQLERRM;
        RAISE vr_exc_saida; 
    END;
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- efetuar o encerramento somente se for pela cadeia
    IF nvl(pr_nrdconta,0) = 0 THEN
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;
    END IF;

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
      -- efetuar o encerramento somente se for pela cadeia
      IF nvl(pr_nrdconta,0) = 0 THEN
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      END IF;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- efetuar o encerramento somente se for pela cadeia
      IF nvl(pr_nrdconta,0) = 0 THEN
        -- Efetuar rollback
        ROLLBACK;
      END IF;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- efetuar o encerramento somente se for pela cadeia
      IF nvl(pr_nrdconta,0) = 0 THEN
        -- Efetuar rollback
        ROLLBACK;
      END IF;
  END pc_crps156;
/