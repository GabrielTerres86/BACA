CREATE OR REPLACE PROCEDURE CECRED.pc_crps156 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Numero da conta (para processo da cadeia passar zeros)
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
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
                   
                 12/02/2010 - Quando o resgate da poupan�a for por vencimento da 
                              mesma e estiver bloqueada, dar a critica 828 e 
                              fazer o resgate da poupan�a(Guilherme).

                 14/06/2011 - Tratar poupanca inexistente.
                   
                 09/10/2013 - Tratamento para Imunidade Tributaria (Ze).
                   
                 05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                              (Lucas R.)
                                
                 16/01/2014 - Inclusao de VALIDATE craplot, craplcm, craplpp, 
                              craprej, crablot, craplci e crapsli (Carlos)
                                
                 11/03/2014 - Incluido ordenacao por craplrg.tpresgat no for each
                              craplrg. (Reinert)
                   
                 27/04/2015 - Convers�o Progress -> Oracle (Odirlei-AMcom)
                   
                 20/04/2016 - Adicionado validacao rw_craplrg.tpresgat = 2
                              para corre��o do chamado 414286. (Kelvin)
                              
                 13/06/2016 - Ajustado cursor da craptab para remover o NLV e o order by
                              pois o parametro sempre eh passado e nao precisa ordernar
                              (Douglas - Chamado 454248)

                 26/07/2016 - Finalizacao da conversao (Jonata-Rkam)
                   
                 29/11/2016 - Efetuar o resgate no dia quando passado uma conta especifica
                              Utilizado pela rotina BLQJ0002 (Andrino-Mouts)
                              
                 01/12/2017 - Inclusao da valida��o de bloqueis de aplic.
                              PRJ404 - Garantia(Odirlei-AMcom) 
                              
                 18/04/2018 - Tratamento se existe valor bloqueado como garantia de opera��o com poupan�a programa
                              PRJ404 - Garantia(Oscar-AMcom)              
                              
								 18/05/2018 - Validar bloqueio de poupan�a programada (SM404)            
                              
  ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- C�digo do programa
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

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor gen�rico de calend�rio
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
		    ,craplrg.idautblq
        FROM craplrg
       WHERE craplrg.cdcooper  = pr_cdcooper
         AND craplrg.nrdconta  = decode(pr_nrdconta, 0, craplrg.nrdconta, pr_nrdconta)
         AND craplrg.dtresgat <= pr_dtmvtopr
         AND craplrg.inresgat  = 0
         AND craplrg.tpaplica  = 4
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
        cpc.cdprodut = rac.cdprodut
        ORDER BY 
        rac.nraplica;
        
        rw_craprac     cr_craprac%rowtype;
    
    -- Buscar dados do lote
    CURSOR cr_craplot (pr_cdcooper craplot.cdcooper%TYPE,
                       pr_dtmvtopr craplot.dtmvtolt%TYPE,
                       pr_nrdolote craplot.nrdolote%TYPE) IS
      SELECT craplot.cdcooper,
             craplot.nrseqdig,
             craplot.dtmvtolt,
             craplot.cdagenci,
             craplot.cdbccxlt,
             craplot.nrdolote,
             craplot.tplotmov,
             craplot.qtcompln,
             craplot.vlcompdb,
             craplot.vlcompcr,
             craplot.ROWID
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtopr
         AND craplot.cdagenci = 1
         AND craplot.cdbccxlt = 100
         AND craplot.nrdolote = pr_nrdolote;
    rw_craplot  cr_craplot%ROWTYPE;
    
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
    
    /* Cursor gen�rico e padr�o para busca da craptab */
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
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml         CLOB;
    -- Vari�vel para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(100);
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
      
    PROCEDURE pc_gera_resgate_app_prog(pr_cdcooper crapcop.cdcooper%TYPE,
                                          pr_tpresgat craplrg.flgcreci%TYPE,
                                          pr_flgcreci craplrg.flgcreci%TYPE,
                                          pr_vlresgat NUMBER) IS

    BEGIN

        vr_nrseqrgt := 0;
        vr_vlrtotresgate_apl := 0;
        vr_vlresgat_acu := 0;
        vr_flgfimresga := FALSE;        
       
        -- Buscar aplica��es para os resgates solicitados.
        FOR rw_craprac IN cr_craprac (pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => rw_craprpp.nrdconta,
                                      pr_nrctrrpp => rw_craprpp.nrctrrpp) LOOP
                vr_vlrgappr := 0;
                vr_vlsdappr := 0;
                    apli0005.pc_busca_saldo_aplic_prog (pr_cdcooper => pr_cdcooper
                                           ,pr_cdoperad => '1'
                                           ,pr_nmdatela => 'ATENDA'
                                           ,pr_idorigem => 5
                                           ,pr_nrdconta => rw_craprac.nrdconta
                                           ,pr_idseqttl => 1
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                                           ,pr_nraplica => rw_craprac.nraplica 
                                           ,pr_cdprodut => rw_craprac.cdprodut
                                           ,pr_idblqrgt => 1                   -- Todas
                                           ,pr_idgerlog => 0                   -- Nao gerar log
                                           ,pr_vlsldtot => vr_vlsdappr         -- Saldo total
                                           ,pr_vlsldrgt => vr_vlrgappr         -- Saldo total para resgate
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

                -- Se encontrar erros na execuc?o
                IF vr_dscritic is not null THEN
                  RAISE vr_exc_saida;
                END IF;

            vr_nrseqrgt := vr_nrseqrgt + 1;
            vr_vlrtotresgate_apl := vr_vlrtotresgate_apl + vr_vlrgappr;
            vr_vlresgat_apl := vr_vlrgappr;
            vr_tpresgate_apl := 1;
            IF (pr_tpresgat = 1) THEN
                IF (vr_vlresgat > vr_vlrtotresgate_apl) THEN
                    vr_tpresgate_apl := 2;
                ELSIF (vr_vlresgat = vr_vlrtotresgate_apl) THEN
                    vr_tpresgate_apl := 2;
                    vr_flgfimresga := TRUE;
                ELSE
                    vr_vlresgat_apl := vr_vlresgat - vr_vlresgat_acu;    
                    vr_flgfimresga := TRUE;
                END IF;
            ELSE
                vr_tpresgate_apl := 2;
            END IF;
              apli0005.pc_efetua_resgate(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_craprac.nrdconta
                                      ,pr_nraplica => rw_craprac.nraplica
                                      ,pr_vlresgat => vr_vlresgat_apl
                                      ,pr_idtiprgt => vr_tpresgate_apl
                                      ,pr_dtresgat => rw_crapdat.dtmvtopr
                                      ,pr_nrseqrgt => vr_nrseqrgt
                                      ,pr_idrgtcti => pr_flgcreci
                                      ,pr_tpcritic => vr_tpcritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                vr_vlresgat_acu := vr_vlresgat_acu + vr_vlresgat_apl;
                -- Se encontrar erros na execuc?o
                IF vr_dscritic is not null THEN
                  RAISE vr_exc_saida;
                END IF;

                IF (vr_flgfimresga) THEN
                    EXIT;
                END IF;
          END LOOP; -- fim loop rac

            -- Buscar dados do lote
            OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                             pr_dtmvtopr => rw_crapdat.dtmvtopr,
                             pr_nrdolote => 8383);
            FETCH cr_craplot INTO rw_craplot;
            IF cr_craplot%NOTFOUND THEN
              BEGIN
                INSERT INTO craplot 
                           ( craplot.dtmvtolt
                            ,craplot.cdagenci
                            ,craplot.cdbccxlt
                            ,craplot.nrdolote
                            ,craplot.tplotmov
                            ,craplot.cdcooper)
                    VALUES ( rw_crapdat.dtmvtopr -- craplot.dtmvtolt
                            ,1                   -- craplot.cdagenci 
                            ,100                 -- craplot.cdbccxlt
                            ,8383                -- craplot.nrdolote
                            ,14                  -- craplot.tplotmov
                            ,pr_cdcooper)        -- craplot.cdcooper
                   RETURNING craplot.ROWID ,
                             craplot.dtmvtolt,
                             craplot.cdagenci,
                             craplot.cdbccxlt,
                             craplot.nrdolote
                        INTO rw_craplot.ROWID,
                             rw_craplot.dtmvtolt,
                             rw_craplot.cdagenci,
                             rw_craplot.cdbccxlt,
                             rw_craplot.nrdolote;
                      
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'N�o foi possivel inserir craplot(8383): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;
            -- fechar cursor;
            CLOSE cr_craplot;
                  
            -- atualizar informa��es do lote
            BEGIN
              UPDATE craplot
                 SET craplot.qtinfoln = craplot.qtinfoln + 1,
                     craplot.qtcompln = craplot.qtcompln + 1,
                     craplot.vlinfodb = craplot.vlinfodb + vr_vlresgat,
                     craplot.vlcompdb = craplot.vlcompdb + vr_vlresgat,
                     craplot.nrseqdig = craplot.nrseqdig + 1
               WHERE craplot.rowid = rw_craplot.rowid
              RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'N�o foi possivel atualizar craplot(8473): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;
    END pc_gera_resgate_app_prog;


    PROCEDURE pc_gera_resgate_poup_prog(pr_cdcooper crapcop.cdcooper%TYPE,
                                          pr_flgcreci craplrg.flgcreci%TYPE,
                                          pr_vlresgat NUMBER) IS
    /* Gerar  lan�amento na conta investimento*/
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
        -- Buscar dados do lote
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                         pr_dtmvtopr => rw_crapdat.dtmvtopr,
                         pr_nrdolote => 10105);
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot 
                       ( craplot.dtmvtolt
                        ,craplot.cdagenci
                        ,craplot.cdbccxlt
                        ,craplot.nrdolote
                        ,craplot.tplotmov
                        ,craplot.cdcooper)
                VALUES ( rw_crapdat.dtmvtopr -- craplot.dtmvtolt
                        ,1                   -- craplot.cdagenci 
                        ,100                 -- craplot.cdbccxlt
                        ,10105               -- craplot.nrdolote
                        ,29                  -- craplot.tplotmov
                        ,pr_cdcooper)        -- craplot.cdcooper
               RETURNING craplot.ROWID ,
                         craplot.dtmvtolt,
                         craplot.cdagenci,
                         craplot.cdbccxlt,
                         craplot.nrdolote
                    INTO rw_craplot.ROWID,
                         rw_craplot.dtmvtolt,
                         rw_craplot.cdagenci,
                         rw_craplot.cdbccxlt,
                         rw_craplot.nrdolote;
                  
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'N�o foi possivel inserir craplot(1015): '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        -- fechar cursor;
        CLOSE cr_craplot;
              
        -- atualizar informa��es do lote
        BEGIN
          UPDATE craplot
             SET craplot.qtinfoln = craplot.qtinfoln + 1,
                 craplot.qtcompln = craplot.qtcompln + 1,
                 craplot.vlinfodb = craplot.vlinfodb + pr_vlresgat,
                 craplot.vlcompdb = craplot.vlcompdb + pr_vlresgat,
                 craplot.nrseqdig = craplot.nrseqdig + 1
           WHERE craplot.rowid = rw_craplot.rowid
          RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel atualizar craplot(1015): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
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
               VALUES (rw_craplot.dtmvtolt -- craplci.dtmvtolt 
                      ,rw_craplot.cdagenci -- craplci.cdagenci 
                      ,rw_craplot.cdbccxlt -- craplci.cdbccxlt 
                      ,rw_craplot.nrdolote -- craplci.nrdolote 
                      ,pr_nrdconta         -- craplci.nrdconta 
                      ,rw_craplot.nrseqdig -- craplci.nrdocmto 
                      ,496 /* Debito */    -- craplci.cdhistor 
                      ,pr_vlresgat         -- craplci.vllanmto 
                      ,rw_craplot.nrseqdig -- craplci.nrseqdig 
                      ,pr_cdcooper);       -- craplci.cdcooper 
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel inserir craplci(nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
        /*** Gera lancamentos Conta Investmento  - Credito Transf. ***/
        -- Buscar dados do lote
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                         pr_dtmvtopr => rw_crapdat.dtmvtopr,
                         pr_nrdolote => 10104);
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot 
                       ( craplot.dtmvtolt
                        ,craplot.cdagenci
                        ,craplot.cdbccxlt
                        ,craplot.nrdolote
                        ,craplot.tplotmov
                        ,craplot.cdcooper)
                VALUES ( rw_crapdat.dtmvtopr -- craplot.dtmvtolt
                        ,1                   -- craplot.cdagenci 
                        ,100                 -- craplot.cdbccxlt
                        ,10104               -- craplot.nrdolote
                        ,29                  -- craplot.tplotmov
                        ,pr_cdcooper)        -- craplot.cdcooper
               RETURNING craplot.ROWID ,
                         craplot.dtmvtolt,
                         craplot.cdagenci,
                         craplot.cdbccxlt,
                         craplot.nrdolote
                    INTO rw_craplot.ROWID,
                         rw_craplot.dtmvtolt,
                         rw_craplot.cdagenci,
                         rw_craplot.cdbccxlt,
                         rw_craplot.nrdolote;
                  
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'N�o foi possivel inserir craplot(1015): '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        -- fechar cursor;
        CLOSE cr_craplot;
              
        -- atualizar informa��es do lote
        BEGIN
          UPDATE craplot
             SET craplot.qtinfoln = craplot.qtinfoln + 1,
                 craplot.qtcompln = craplot.qtcompln + 1,
                 craplot.vlinfocr = craplot.vlinfocr + pr_vlresgat,
                 craplot.vlcompcr = craplot.vlcompcr + pr_vlresgat,
                 craplot.nrseqdig = craplot.nrseqdig + 1
           WHERE craplot.rowid = rw_craplot.rowid
          RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel atualizar craplot(1015): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
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
               VALUES (rw_craplot.dtmvtolt -- craplci.dtmvtolt 
                      ,rw_craplot.cdagenci -- craplci.cdagenci 
                      ,rw_craplot.cdbccxlt -- craplci.cdbccxlt 
                      ,rw_craplot.nrdolote -- craplci.nrdolote 
                      ,pr_nrdconta         -- craplci.nrdconta 
                      ,rw_craplot.nrseqdig -- craplci.nrdocmto 
                      ,489 /*credito*/     -- craplci.cdhistor 
                      ,pr_vlresgat         -- craplci.vllanmto 
                      ,rw_craplot.nrseqdig -- craplci.nrseqdig 
                      ,pr_cdcooper);       -- craplci.cdcooper 
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel inserir craplci (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
      END IF;   
      
      /* Resgatar para Conta Investimento */
      IF pr_flgcreci = 1 /*True*/ THEN  
        
        /*** Gera lancamentos Credito Saldo Conta Investimento ***/
        -- Buscar dados do lote
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                         pr_dtmvtopr => rw_crapdat.dtmvtopr,
                         pr_nrdolote => 10106);
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot 
                       ( craplot.dtmvtolt
                        ,craplot.cdagenci
                        ,craplot.cdbccxlt
                        ,craplot.nrdolote
                        ,craplot.tplotmov
                        ,craplot.cdcooper)
                VALUES ( rw_crapdat.dtmvtopr -- craplot.dtmvtolt
                        ,1                   -- craplot.cdagenci 
                        ,100                 -- craplot.cdbccxlt
                        ,10106               -- craplot.nrdolote
                        ,29                  -- craplot.tplotmov
                        ,pr_cdcooper)        -- craplot.cdcooper
               RETURNING craplot.ROWID ,
                         craplot.dtmvtolt,
                         craplot.cdagenci,
                         craplot.cdbccxlt,
                         craplot.nrdolote
                    INTO rw_craplot.ROWID,
                         rw_craplot.dtmvtolt,
                         rw_craplot.cdagenci,
                         rw_craplot.cdbccxlt,
                         rw_craplot.nrdolote;
                  
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'N�o foi possivel inserir craplot(1015): '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        -- fechar cursor;
        CLOSE cr_craplot;
              
        -- atualizar informa��es do lote
        BEGIN
          UPDATE craplot
             SET craplot.qtinfoln = craplot.qtinfoln + 1,
                 craplot.qtcompln = craplot.qtcompln + 1,
                 craplot.vlinfocr = craplot.vlinfocr + pr_vlresgat,
                 craplot.vlcompcr = craplot.vlcompcr + pr_vlresgat,
                 craplot.nrseqdig = craplot.nrseqdig + 1
           WHERE craplot.rowid = rw_craplot.rowid
          RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel atualizar craplot(1015): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
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
               VALUES (rw_craplot.dtmvtolt -- craplci.dtmvtolt 
                      ,rw_craplot.cdagenci -- craplci.cdagenci 
                      ,rw_craplot.cdbccxlt -- craplci.cdbccxlt 
                      ,rw_craplot.nrdolote -- craplci.nrdolote 
                      ,pr_nrdconta         -- craplci.nrdconta 
                      ,rw_craplot.nrseqdig -- craplci.nrdocmto 
                      ,490   /* Credito Proveniente Aplicacao*/     -- craplci.cdhistor 
                      ,pr_vlresgat         -- craplci.vllanmto 
                      ,rw_craplot.nrseqdig -- craplci.nrseqdig 
                      ,pr_cdcooper);       -- craplci.cdcooper 
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel inserir craplci (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
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
            vr_dscritic := 'N�o foi possivel alterar crapsli (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
        
        -- se n�o alterou nenhum registro, deve inserir
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
              vr_dscritic := 'N�o foi possivel inserir crapsli (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
              RAISE vr_exc_saida;  
          END;
        END IF;
        
      END IF;
      
      
    END pc_gera_lancamentos_craplci;

  BEGIN

      ------------------------------- VARIAVEIS -------------------------------
            IF pr_flgcreci = 0 /* false */ THEN /*Resgate Conta Corrente*/
              -- Buscar dados do lote
              OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                               pr_dtmvtopr => rw_crapdat.dtmvtopr,
                               pr_nrdolote => 8473);
              FETCH cr_craplot INTO rw_craplot;
              IF cr_craplot%NOTFOUND THEN
                BEGIN
                  INSERT INTO craplot 
                             ( craplot.dtmvtolt
                              ,craplot.cdagenci
                              ,craplot.cdbccxlt
                              ,craplot.nrdolote
                              ,craplot.tplotmov
                              ,craplot.cdcooper)
                      VALUES ( rw_crapdat.dtmvtopr -- craplot.dtmvtolt
                              ,1                   -- craplot.cdagenci 
                              ,100                 -- craplot.cdbccxlt
                              ,8473                -- craplot.nrdolote
                              ,1                   -- craplot.tplotmov
                              ,pr_cdcooper)        -- craplot.cdcooper
                     RETURNING craplot.ROWID ,
                               craplot.dtmvtolt,
                               craplot.cdagenci,
                               craplot.cdbccxlt,
                               craplot.nrdolote
                          INTO rw_craplot.ROWID,
                               rw_craplot.dtmvtolt,
                               rw_craplot.cdagenci,
                               rw_craplot.cdbccxlt,
                               rw_craplot.nrdolote;
                      
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'N�o foi possivel inserir craplot(8473): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;
              -- fechar cursor;
              CLOSE cr_craplot;
                  
              -- atualizar informa��es do lote
              BEGIN
                UPDATE craplot
                   SET craplot.qtinfoln = craplot.qtinfoln + 1,
                       craplot.qtcompln = craplot.qtcompln + 1,
                       craplot.vlinfocr = craplot.vlinfocr + vr_vlresgat,
                       craplot.vlcompcr = craplot.vlcompcr + vr_vlresgat,
                       craplot.nrseqdig = craplot.nrseqdig + 1
                 WHERE craplot.rowid = rw_craplot.rowid
                RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'N�o foi possivel atualizar craplot(8473): '||SQLERRM;
                  RAISE vr_exc_saida;  
              END;
                  
              -- inserir lan�amento
  BEGIN
                INSERT INTO craplcm
                            (craplcm.dtmvtolt
                            ,craplcm.cdagenci
                            ,craplcm.cdbccxlt
                            ,craplcm.nrdolote
                            ,craplcm.nrdconta
                            ,craplcm.nrdctabb
                            ,craplcm.nrdctitg                 
                            ,craplcm.nrdocmto
                            ,craplcm.cdhistor
                            ,craplcm.vllanmto
                            ,craplcm.nrseqdig
                            ,craplcm.cdcooper)
                     VALUES( rw_craplot.dtmvtolt -- craplcm.dtmvtolt
                            ,rw_craplot.cdagenci -- craplcm.cdagenci
                            ,rw_craplot.cdbccxlt -- craplcm.cdbccxlt
                            ,rw_craplot.nrdolote -- craplcm.nrdolote
                            ,rw_craprpp.nrdconta -- craplcm.nrdconta
                            ,rw_craprpp.nrdconta -- craplcm.nrdctabb
                            ,gene0002.fn_mask(rw_craprpp.nrdconta,'99999999') -- craplcm.nrdctitg
                            ,rw_craplot.nrseqdig -- craplcm.nrdocmto
                            ,(CASE rw_craprpp.flgctain 
                               WHEN 1 /* true */ THEN 501 -- TRANSF. RESGATE POUP.PROGRAMADA DA C/I PARA C/C
                               ELSE 159 -- CR.POUP.PROGR
                              END)          -- craplcm.cdhistor
                            ,vr_vlresgat         -- craplcm.vllanmto
                            ,rw_craplot.nrseqdig -- craplcm.nrseqdig
                            ,pr_cdcooper);       -- craplcm.cdcooper
          
                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'N�o foi possivel atualizar craplcm (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                  RAISE vr_exc_saida;  
              END;    
            END IF; --> Fim IF rw_craplrg.flgcreci = 0 /* false */ /*Resgate Conta Corrente*/
                                              
            /* Gerar  lan�amento na conta investimento*/
            pc_gera_lancamentos_craplci(pr_cdcooper => pr_cdcooper,
                                        pr_flgctain => rw_craprpp.flgctain,
                                        pr_flgcreci => pr_flgcreci,
                                        pr_nrdconta => rw_craprpp.nrdconta,
                                        pr_vlresgat => vr_vlresgat);

            --> Gera lancamento do resgate <--
            -- Buscar dados do lote
            OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                             pr_dtmvtopr => rw_crapdat.dtmvtopr,
                             pr_nrdolote => 8383);
            FETCH cr_craplot INTO rw_craplot;
            IF cr_craplot%NOTFOUND THEN
              BEGIN
                INSERT INTO craplot 
                           ( craplot.dtmvtolt
                            ,craplot.cdagenci
                            ,craplot.cdbccxlt
                            ,craplot.nrdolote
                            ,craplot.tplotmov
                            ,craplot.cdcooper)
                    VALUES ( rw_crapdat.dtmvtopr -- craplot.dtmvtolt
                            ,1                   -- craplot.cdagenci 
                            ,100                 -- craplot.cdbccxlt
                            ,8383                -- craplot.nrdolote
                            ,14                  -- craplot.tplotmov
                            ,pr_cdcooper)        -- craplot.cdcooper
                   RETURNING craplot.ROWID ,
                             craplot.dtmvtolt,
                             craplot.cdagenci,
                             craplot.cdbccxlt,
                             craplot.nrdolote
                        INTO rw_craplot.ROWID,
                             rw_craplot.dtmvtolt,
                             rw_craplot.cdagenci,
                             rw_craplot.cdbccxlt,
                             rw_craplot.nrdolote;
                      
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'N�o foi possivel inserir craplot(8383): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;
            -- fechar cursor;
            CLOSE cr_craplot;
                  
            -- atualizar informa��es do lote
            BEGIN
              UPDATE craplot
                 SET craplot.qtinfoln = craplot.qtinfoln + 1,
                     craplot.qtcompln = craplot.qtcompln + 1,
                     craplot.vlinfodb = craplot.vlinfodb + vr_vlresgat,
                     craplot.vlcompdb = craplot.vlcompdb + vr_vlresgat,
                     craplot.nrseqdig = craplot.nrseqdig + 1
               WHERE craplot.rowid = rw_craplot.rowid
              RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'N�o foi possivel atualizar craplot(8473): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;
                  
            -- inserir lan�amento
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
                   VALUES( rw_craplot.dtmvtolt           -- craplpp.dtmvtolt
                          ,rw_craplot.cdagenci           -- craplpp.cdagenci
                          ,rw_craplot.cdbccxlt           -- craplpp.cdbccxlt
                          ,rw_craplot.nrdolote           -- craplpp.nrdolote
                          ,rw_craprpp.nrdconta           -- craplpp.nrdconta
                          ,rw_craprpp.nrctrrpp           -- craplpp.nrctrrpp
                          ,rw_craplot.nrseqdig           -- craplpp.nrdocmto
                          ,vr_rpp_txaplmes               -- craplpp.txaplmes
                          ,vr_rpp_txaplica               -- craplpp.txaplica
                          ,(CASE rw_craprpp.flgctain 
                              WHEN 1 /*YES*/  THEN 
                                  496   /* RESGATE POUP. p/ C.I */ 
                              ELSE 158  /* RESGATE POUP. */       -- craplpp.cdhistor
                            END) 
                          ,rw_craplot.nrseqdig           -- craplpp.nrseqdig
                          ,rw_craprpp.dtfimper           -- craplpp.dtrefere
                          ,vr_vlresgat                   -- craplpp.vllanmto
                          ,pr_cdcooper );                -- craplpp.cdcooper 
                  
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'N�o foi possivel atualizar craplpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;  
    END pc_gera_resgate_poup_prog;

      
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se n�o encontrar
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
      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro � <> 0
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
      
      FOR i IN 1..10 LOOP
        BEGIN
          -- Buscar cadastro da poupanca programada.
          OPEN cr_craprpp (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_craplrg.nrdconta,
                           pr_nraplica => rw_craplrg.nraplica);
          FETCH cr_craprpp INTO rw_craprpp;
          vr_fcraprpp := cr_craprpp%FOUND; 
          CLOSE cr_craprpp;
          
          IF NOT vr_fcraprpp THEN
            vr_cdcritic := 484;
          ELSE
              IF (rw_craprpp.cdprodut < 0) THEN
            /* Rotina de calculo do saldo da aplicac?o ate a data do movimento */
            APLI0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper,        --> Cooperativa
                                      pr_dstextab  => vr_dstextab_apli,         --> Percentual de IR da aplicac?o
                                      pr_cdprogra  => vr_cdprogra,        --> Programa chamador
                                      pr_inproces  => rw_crapdat.inproces,--> Indicador do processo
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,--> Data do processo
                                      pr_dtmvtopr  => rw_crapdat.dtmvtopr,--> Proximo dia util
                                      pr_rpp_rowid => rw_craprpp.rowid,   --> Identificador do registro da tabela CRAPRPP em processamento
                                      pr_vlsdrdpp  => vr_vlsdrdppe,       --> Saldo da poupanca programada
                                      -- conforme codigo original do progress, informa��es sempre s�o retornadas zeradas
                                      -- para esse programa
                                      -- pr_txaplmes  => vr_rpp_txaplmes     --> Taxa de aplica��o m�s
                                      -- pr_txaplica  => vr_rpp_txaplica     --> Taxa de aplica��o 
                                      pr_cdcritic  => vr_cdcritic,        --> Codigo da critica de erro
                                      pr_des_erro  => vr_dscritic);       --> Descric?o do erro encontrado
        ELSE
              vr_cdcritic := 0;
              vr_vlresgat := 0;
              vr_saldorpp := 0;
              vr_vlsdrdppe := 0;
                /* Rotina de calculo do saldo da aplicac?o ate a data do movimento */
                pc_calc_app_programada(pr_cdcooper  => pr_cdcooper,        --> Cooperativa
                                          pr_dstextab  => vr_dstextab_apli,         --> Percentual de IR da aplicac?o
                                          pr_cdprogra  => vr_cdprogra,        --> Programa chamador
                                          pr_inproces  => rw_crapdat.inproces,--> Indicador do processo
                                          pr_dtmvtolt  => rw_crapdat.dtmvtolt,--> Data do processo
                                          pr_dtmvtopr  => rw_crapdat.dtmvtopr,--> Proximo dia util
                                          pr_rpp_rowid => rw_craprpp.rowid,   --> Identificador do registro da tabela CRAPRPP em processamento
                                          pr_vlsdrdpp  => vr_vlsdrdppe,       --> Saldo da poupanca programada
                                          -- conforme codigo original do progress, informa��es sempre s�o retornadas zeradas
                                          -- para esse programa
                                          -- pr_txaplmes  => vr_rpp_txaplmes     --> Taxa de aplica��o m�s
                                          -- pr_txaplica  => vr_rpp_txaplica     --> Taxa de aplica��o 
                                          pr_cdcritic  => vr_cdcritic,        --> Codigo da critica de erro
                                          pr_des_erro  => vr_dscritic);       --> Descric?o do erro encontrado
        END IF;
            -- Se encontrar erros na execuc?o
            IF vr_dscritic is not null THEN
              RAISE vr_exc_saida;
            END IF;
            
            vr_flgresga := TRUE;
            vr_saldorpp := vr_vlsdrdppe;
            
          END IF;          
         
          -- sair do loop;
          EXIT;
        EXCEPTION
          WHEN OTHERS THEN
             CLOSE cr_craprpp;
             -- tentar 10 vezes 
             IF i = 10 THEN
               vr_cdcritic := 484;
               EXIT;
             END IF;
             -- aguardar 1 seg. antes de tentar novamente
             sys.dbms_lock.sleep(1); 
             
        END;                   
      END LOOP; -- fim loop rpp
      
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
      
       /* Se nao houve erro ou � uma bloqueada vencida r ser resgatada */
      IF  nvl(vr_cdcritic,0) = 0 OR vr_cdcritic = 828  THEN
          IF vr_saldorpp > 0   THEN
            vr_vlirabap := 0;
                                      
            IF rw_craprpp.vlabcpmf <> 0 THEN
              /* Procedure para verificar imunidade tributaria e inserir valor de insen��o */
              IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => rw_craplrg.cdcooper  --> Codigo Cooperativa
                                                   ,pr_nrdconta  => rw_craplrg.nrdconta  --> Numero da Conta
                                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data movimento
                                                   ,pr_flgrvvlr  => FALSE        --> Identificador se deve gravar valor
                                                   ,pr_cdinsenc  => 5            --> Codigo da insen��o
                                                   ,pr_vlinsenc  => 0            --> Valor insento
                                                   ,pr_flgimune  => vr_flgimune  --> Identificador se � imune
                                                   ,pr_dsreturn  => vr_des_reto  --> Descricao Critica
                                                   ,pr_tab_erro  => vr_tab_erro);--> Tabela erros

              /*O tratamento de retorno abaixo foi comentado pois, no progress, o mesmo n�o
                � implementado.
              -- Caso retornou com erro, levantar exce��o
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
      
      -- Se n�o h� critica ainda 
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
	  /* Se nao houve erro ou � uma bloqueada vencida r ser resgatada */
      IF  (nvl(vr_cdcritic,0) = 0 OR vr_cdcritic = 828 OR vr_cdcritic = 429) THEN
      
                      
        IF (rw_craprpp.cdprodut <= 0) THEN
           pc_gera_resgate_poup_prog(pr_cdcooper => pr_cdcooper,
                                          pr_flgcreci => rw_craplrg.flgcreci,
                                          pr_vlresgat => vr_vlresgat);
        ELSE
           pc_gera_resgate_app_prog(pr_cdcooper => pr_cdcooper,
                                        pr_flgcreci => rw_craplrg.flgcreci,
                                          pr_tpresgat => rw_craplrg.tpresgat,
                                        pr_vlresgat => vr_vlresgat);
            END IF;
            /* Atualizar valor resgatado */
            BEGIN
              UPDATE craprpp
                 SET craprpp.vlrgtacu = craprpp.vlrgtacu + vr_vlresgat
               WHERE craprpp.rowid = rw_craprpp.rowid;
               
              /* resgate por vencimento */
              IF vr_fcraprpp   THEN
                IF rw_craprpp.dtvctopp <= rw_crapdat.dtmvtopr AND 
                   rw_craplrg.tpresgat = 2                    THEN
                
                  /* Atualizar saldo e situa��o, se for poupan�a vencida*/
                    UPDATE craprpp
                       SET craprpp.vlsdrdpp = 0,
                           craprpp.cdsitrpp = 5 -- 5-vencido.
                     WHERE craprpp.rowid = rw_craprpp.rowid;
                  
                END IF;
              END IF;
               
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'N�o foi possivel atualizar craprpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                RAISE vr_exc_saida; 
            END;
                
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
            vr_dscritic := 'N�o foi possivel atualizar craprej (nrdconta:'||rw_craplrg.nrdconta||'): '||SQLERRM;
            RAISE vr_exc_saida;  
        END;
      END IF;
      
      /* Atualizar lancamentos de resgates solicitados como processado */
      BEGIN
        UPDATE craplrg
           SET craplrg.inresgat = 1
         WHERE craplrg.rowid = rw_craplrg.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'N�o foi possivel atualizar craplrg (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
          RAISE vr_exc_saida; 
      END; 
                     
    END LOOP;  -- Fim Loop craplrg  -- --  Leitura dos resgates programados                   
    
    -- Gerar relatorio somente se for o processo da cadeia
    IF nvl(pr_nrdconta,0) = 0 THEN
    
      /** Gera��o Relatorio crrl125 **/
      
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informa��es do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl125>');
          
      IF vr_regexist THEN
        -- Buscar dados do lote
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                         pr_dtmvtopr => rw_crapdat.dtmvtopr,
                         pr_nrdolote => 8383);
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          
          vr_cdcritic := 60; --> 060 - Lote inexistente. 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Lote dos resgates: '||
                         to_char(rw_crapdat.dtmvtopr,'DD/MM/RRRR')||'-001-100-8383';
          -- abortar programa               
          RAISE vr_exc_saida;               
          
        ELSE
          CLOSE cr_craplot;
          
          pc_escreve_xml('<lote dtmvtolt="'||to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||'"  
                                cdagenci="'||rw_craplot.cdagenci||'"
                                cdbccxlt="'||rw_craplot.cdbccxlt||'"  
                                nrdolote="'||rw_craplot.nrdolote||'"
                                tplotmov="'||rw_craplot.tplotmov||'" >');
          
        END IF;
    
      END IF;
        
      vr_cdcritic := 0;
        
      -- ler criticas
      FOR rw_craprej  IN cr_craprej (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP
        
        -- buscar descri��o da critica
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
                          <tot_qtcompln>'|| rw_craplot.qtcompln  ||'</tot_qtcompln>
                          <tot_vlcompdb>'|| rw_craplot.vlcompdb  ||'</tot_vlcompdb>
                          <tot_vlcompcr>'|| rw_craplot.vlcompcr  ||'</tot_vlcompcr>
                          <tot_qtdrejln>'||     vr_rel_qtdrejln  ||'</tot_qtdrejln>    
                          <tot_vldrejdb>'||     vr_rel_vldrejdb  ||'</tot_vldrejdb>    
                          <tot_vldrejcr>'||     vr_rel_vldrejcr  ||'</tot_vldrejcr>
                        </total>');
      END IF;
      
      -- Finalizar o agrupador do relat�rio
      pc_escreve_xml('</crrl125>',TRUE);

      -- Busca do diret�rio base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    
      -- Efetuar solicita��o de gera��o de relat�rio --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl125/lote/rejeitados'    --> N� base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl125.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl125.lst' --> Arquivo final com c�digo da ag�ncia
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress�o (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formul�rio para impress�o
                                 ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Sa�da com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exce��o
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a mem�ria alocada pro CLOB
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
        vr_dscritic := 'N�o foi possivel deletar craprej: '||SQLERRM;
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

      -- Salvar informa��es atualizadas
      COMMIT;
    END IF;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
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
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- efetuar o encerramento somente se for pela cadeia
      IF nvl(pr_nrdconta,0) = 0 THEN
        -- Efetuar rollback
        ROLLBACK;
      END IF;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- efetuar o encerramento somente se for pela cadeia
      IF nvl(pr_nrdconta,0) = 0 THEN
        -- Efetuar rollback
        ROLLBACK;
      END IF;
  END pc_crps156;
/
