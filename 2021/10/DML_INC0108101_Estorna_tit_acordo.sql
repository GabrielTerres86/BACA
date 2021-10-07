
DECLARE  

  pr_cdcooper NUMBER := 13;
  pr_nrdconta NUMBER := 66842;
  vr_liquidou NUMBER;
  

  CURSOR cr_craptdb IS
    SELECT DISTINCT t.nrdconta
               ,t.nrborder
      FROM (SELECT bdt.nrdconta
                  ,tdb.nrborder
                  ,tdb.cdbandoc
                  ,tdb.nrdctabb
                  ,tdb.nrcnvcob
                  ,tdb.nrdocmto
                  ,CASE
                     WHEN bdt.inprejuz = 1 THEN
                      nvl(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr) + 
                                         (tdb.vlttmupr - tdb.vlpgmupr) +
                                         (tdb.vljraprj - tdb.vlpgjrpr) + 
                                         (tdb.vliofprj - tdb.vliofppr),
                          0)
                     ELSE
                      0
                   END AS vlsdprej
              FROM craptdb             tdb
                  ,tbdsct_titulo_cyber titcyb
                  ,crapbdt             bdt
             WHERE tdb.dtresgat IS NULL
               AND tdb.dtlibbdt IS NOT NULL
               AND tdb.dtdpagto IS NULL
               AND bdt.nrborder = tdb.nrborder
               AND bdt.nrdconta = tdb.nrdconta
               AND bdt.cdcooper = tdb.cdcooper
               AND tdb.nrtitulo = titcyb.nrtitulo
               AND tdb.nrborder = titcyb.nrborder
               AND tdb.nrdconta = titcyb.nrdconta
               AND tdb.cdcooper = titcyb.cdcooper
               AND titcyb.nrdconta = pr_nrdconta
               AND titcyb.cdcooper = pr_cdcooper) t
     WHERE t.vlsdprej < 0;

  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  vr_exc_erro     EXCEPTION;
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  gl_nrdolote NUMBER;
  vr_des_reto VARCHAR2(2000);
  vr_tab_erro gene0001.typ_tab_erro ;
  
  CURSOR cr_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  
  
   PROCEDURE pc_realiza_estor_tit_prj(pr_cdcooper        IN crapbdt.cdcooper%TYPE
                                    ,pr_nrborder        IN craptdb.nrborder%TYPE
                                    ,pr_nrtitulo        IN craptdb.nrtitulo%TYPE
                                    ,pr_vlsdprej        IN craptdb.vlsdprej%TYPE DEFAULT 0
                                    ,pr_vlpgjmpr        IN craptdb.vlpgjmpr%TYPE DEFAULT 0
                                    ,pr_vlpgmupr        IN craptdb.vlpgmupr%TYPE DEFAULT 0
                                    ,pr_vlpgjrpr        IN craptdb.vlpgjrpr%TYPE DEFAULT 0
                                    ,pr_dtmvtolt        IN DATE
                                    ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                    ,pr_dscritic        OUT VARCHAR2) IS
   
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
    vr_vlsdprej NUMBER;
    vr_vlpgjmpr NUMBER;
    vr_vlpgmupr NUMBER;
    vr_vlpgjrpr NUMBER;
    vr_vliofppr NUMBER;
    vr_vlttjmpr NUMBER;
    vr_vlttmupr NUMBER;
    vr_vljraprj NUMBER;
    vr_vliofprj NUMBER;
      
    BEGIN
      UPDATE craptdb tdb
         SET tdb.dtdebito = NULL
            ,tdb.vlsdprej = tdb.vlsdprej + NVL(pr_vlsdprej, 0) -- Saldo Prejuizo
            ,tdb.vlpgjmpr = tdb.vlpgjmpr - NVL(pr_vlpgjmpr, 0) -- Juros Mora
            ,tdb.vlpgmupr = tdb.vlpgmupr - NVL(pr_vlpgmupr, 0) -- Multa
            ,tdb.vlpgjrpr = tdb.vlpgjrpr - NVL(pr_vlpgjrpr, 0) -- Acumulado
            ,tdb.vlpgjm60 = CASE WHEN (NVL(pr_vlpgjmpr,0) >= tdb.vlpgjm60) THEN 0 ELSE (tdb.vlpgjm60 - NVL(pr_vlpgjmpr,0)) END
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrtitulo = pr_nrtitulo
         RETURNING vlsdprej,vlpgjmpr,vlpgmupr,vlpgjrpr,vliofppr
                           ,vlttjmpr,vlttmupr,vljraprj,vliofprj
              INTO vr_vlsdprej,vr_vlpgjmpr,vr_vlpgmupr,vr_vlpgjrpr,vr_vliofppr
                              ,vr_vlttjmpr,vr_vlttmupr,vr_vljraprj,vr_vliofprj;
                              
                              
      IF (vr_vlsdprej = 0
          AND (vr_vliofprj = vr_vliofppr)
          AND (vr_vlttjmpr = vr_vlpgjmpr)
          AND (vr_vlttmupr = vr_vlpgmupr)
          AND (vr_vljraprj = vr_vlpgjrpr)
          ) THEN
       UPDATE craptdb tdb
         SET tdb.insittit = 3
            ,tdb.dtdebito = pr_dtmvtolt
            ,tdb.dtdpagto = pr_dtmvtolt
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrtitulo = pr_nrtitulo;
      END IF; 
                               
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Não foi possivel atualizar a situção dos títulos.';
  END pc_realiza_estor_tit_prj;
  
  
  PROCEDURE pc_realiza_estorno_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                       ,pr_nrdconta  IN crapbdt.nrdconta%TYPE
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                       ,pr_cdagenci  IN crapbdt.cdagenci%TYPE
                                       ,pr_cdoperad  IN crapbdt.cdoperad%TYPE
                                       ,pr_dsjustificativa IN VARCHAR2
                                       -- OUT --
                                       ,pr_cdcritic OUT PLS_INTEGER
                                       ,pr_dscritic OUT VARCHAR2
                                       ) IS
   
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    -- Variável de Data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis locais
    vr_cdestorno       NUMBER;
    vr_est_abono       NUMBER(25,2);
    vr_cdhistor        NUMBER;
    vr_vllanmto_tot    NUMBER(25,2);
    vr_nrdolote craplcm.nrdolote%TYPE;
    vr_nrseqdig craplcm.nrseqdig%TYPE;    
    
    -- Cursor para verificar se há algum titulo do bordero em acordo
    CURSOR cr_crapaco IS
      SELECT
        COUNT(1) AS in_acordo
      FROM
        tbdsct_titulo_cyber ttc
      INNER JOIN tbrecup_acordo ta ON ta.cdcooper = ttc.cdcooper AND ta.nrdconta = ttc.nrdconta
      INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp AND tac.nracordo = ta.nracordo
      WHERE ttc.cdcooper = pr_cdcooper
        AND ttc.nrdconta = pr_nrdconta
        AND ttc.nrborder = pr_nrborder
        AND tac.cdorigem = 4   -- Desconto de Títulos
        AND ta.cdsituacao <> 3; -- Diferente de Cancelado
    rw_crapaco cr_crapaco%ROWTYPE;
    
    -- Cursor de lançamentos
    CURSOR cr_craplan(pr_dtini DATE,
                      pr_dtfim DATE) IS
      SELECT 
        tlb.cdcooper,
        tlb.nrdconta,
        tlb.nrborder,
        tlb.cdbandoc, 
        tlb.nrdctabb, 
        tlb.nrcnvcob, 
        tlb.nrdocmto, 
        tlb.nrtitulo,
        tlb.dtmvtolt,
        tlb.vllanmto,
        tlb.cdhistor,
        tlb.cdorigem,
        tlb.progress_recid AS id
      FROM tbdsct_lancamento_bordero tlb
      WHERE tlb.cdcooper = pr_cdcooper 
        AND tlb.nrborder = pr_nrborder 
        AND tlb.cdorigem IN (5, 7) 
        AND tlb.cdhistor = 2876 -- estornar apenas 2876
        --AND tlb.dtmvtolt BETWEEN  pr_dtini AND pr_dtfim
         AND tlb.dtmvtolt >= (SELECT MAX(lan.dtmvtolt) 
                              FROM tbdsct_lancamento_bordero lan
                              INNER JOIN craphis his ON lan.cdcooper = his.cdcooper AND lan.cdhistor = his.cdhistor AND his.indebcre = 'C'
                              WHERE lan.cdcooper = pr_cdcooper 
                                AND lan.nrdconta = pr_nrdconta 
                                AND lan.nrborder = pr_nrborder 
                                AND lan.cdorigem IN (5, 7)
                                AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                                                    ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                                                    ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                                                    ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                                                    ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                                                    )
                              )
        AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorno) FROM tbdsct_estorno WHERE cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta AND nrborder = pr_nrborder),to_date('01/08/2021','DD/MM/RRRR'))
        AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                            ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                            ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                            ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                            ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                            )
        AND tlb.dtestorn IS NULL
      ORDER BY tlb.nrtitulo;
    rw_craplan cr_craplan%ROWTYPE;
    
    -- Cursor de lançamento do estorno
    CURSOR cr_craplcm IS
      SELECT lcm.dtmvtolt,
          NVL(SUM(lcm.vllanmto), 0) AS vllanmto,
          lcm.cdhistor,
          lcm.cdbccxlt,
          lcm.nrdocmto
      FROM craplcm lcm
      WHERE lcm.cdcooper = pr_cdcooper
        AND lcm.nrdconta = pr_nrdconta
        AND lcm.nrdocmto = pr_nrborder
        AND lcm.cdhistor = PREJ0005.vr_cdhistordsct_recup_preju
      GROUP BY lcm.dtmvtolt, lcm.cdhistor, lcm.cdbccxlt, lcm.nrdocmto
      ORDER BY lcm.dtmvtolt DESC;
    rw_craplcm cr_craplcm%ROWTYPE;
    
    -- Cursor para saber se houve algum estorno no dia
    CURSOR cr_crapestorno(pr_cdcooper crapbdt.cdcooper%TYPE
                         ,pr_nrdconta crapbdt.nrdconta%TYPE
                         ,pr_nrborder crapbdt.nrborder%TYPE
                         ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(vllancamento),0) vllancamento
      FROM
        tbdsct_estornolancamento tbe
      WHERE tbe.cdcooper    = pr_cdcooper
        AND tbe.nrdconta    = pr_nrdconta
        AND tbe.nrborder    = pr_nrborder
        AND tbe.dtpagamento = pr_dtmvtolt;
    rw_crapestorno cr_crapestorno%ROWTYPE;
    
    BEGIN
      BEGIN
        raise_application_error(-20500,'teste');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;  
      END;
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
      
      vr_est_abono       := 0;
      -- Abre o cursor de lançamentos para efetuar os de estorno.
      OPEN cr_craplan(pr_dtini => rw_crapdat.dtinimes,
                      pr_dtfim => rw_crapdat.dtultdia);
      LOOP
        FETCH cr_craplan INTO rw_craplan;
        EXIT WHEN cr_craplan%NOTFOUND;
        
        -- Verifica qual o histórico de estorno deve ser lançado
        CASE rw_craplan.cdhistor            
          -- Abono
          WHEN PREJ0005.vr_cdhistordsct_rec_abono      THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_abono;
            vr_est_abono := vr_est_abono + rw_craplan.vllanmto;
                      
          -- Principal
          WHEN PREJ0005.vr_cdhistordsct_rec_principal  THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_principal;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlsdprej => rw_craplan.vllanmto
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Principal retira do saldo
          -- Juros +60
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_60     THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_jur_60;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlsdprej => rw_craplan.vllanmto
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Juros+60 retira do saldo
          -- Atualização
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_atuali THEN
            vr_cdhistor        := PREJ0005.vr_cdhistordsct_est_jur_prej;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgjrpr => rw_craplan.vllanmto
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Juros de Atualização
          -- Multa
          WHEN PREJ0005.vr_cdhistordsct_rec_mult_atras THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_mult_atras;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgmupr => rw_craplan.vllanmto
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Multa
          -- Mora
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_mora   THEN 
            vr_cdhistor := PREJ0005.vr_cdhistordsct_est_jur_mor;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgjmpr => rw_craplan.vllanmto
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Mora
          -- Juros de atualização
          WHEN DSCT0003.vr_cdhistordsct_sumjratuprejuz THEN
            vr_cdhistor := DSCT0003.vr_cdhistordsct_sumjratuprejuz;
            
          WHEN PREJ0005.vr_cdhistordsct_rec_preju THEN
            vr_cdhistor := PREJ0005.vr_cdhistordsct_est_preju;
        END CASE;
        
        -- Verifica se houve crítica   
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Caso o lançamento seja o mesmo dia de movimento deleta os lançamentos.
        IF (rw_craplan.dtmvtolt = rw_crapdat.dtmvtolt) THEN
          BEGIN
            DELETE FROM tbdsct_lancamento_bordero WHERE progress_recid = rw_craplan.id;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel remover o lançamento dos Lançamentos de Borderô.';
              RAISE vr_exc_erro;
          END; 
        ELSIF vr_cdhistor <> DSCT0003.vr_cdhistordsct_sumjratuprejuz THEN -- lançamento de juros de atualização
          -- Inserir registros de lancamento de estorno do borderô na tabela tbdsct_lancamento_border
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper, 
                                                 pr_nrdconta => pr_nrdconta, 
                                                 pr_nrborder => pr_nrborder, 
                                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                 pr_cdorigem => rw_craplan.cdorigem, 
                                                 pr_cdhistor => vr_cdhistor, 
                                                 pr_vllanmto => rw_craplan.vllanmto, 
                                                 pr_cdbandoc => rw_craplan.cdbandoc, 
                                                 pr_nrdctabb => rw_craplan.nrdctabb, 
                                                 pr_nrcnvcob => rw_craplan.nrcnvcob, 
                                                 pr_nrdocmto => rw_craplan.nrdocmto, 
                                                 pr_nrtitulo => rw_craplan.nrtitulo, 
                                                 pr_dscritic => pr_dscritic);
          -- Verifica se houve crítica   
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Atualiza o campo de estorno
          BEGIN
            UPDATE tbdsct_lancamento_bordero SET dtestorn = rw_crapdat.dtmvtolt WHERE progress_recid = rw_craplan.id;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel atualizar a data de estorno dos Lançamentos de Borderô.';
              RAISE vr_exc_erro;
          END; 
        END IF;
      END LOOP;
      CLOSE cr_craplan; 
        
      -- Atualiza o Borderô 
      BEGIN
        UPDATE crapbdt bdt
        SET bdt.insitbdt = 3,
            bdt.dtliqprj = NULL,
            bdt.vlaboprj = bdt.vlaboprj - vr_est_abono
        WHERE bdt.cdcooper = pr_cdcooper 
          AND bdt.nrborder = pr_nrborder;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel atualizar a situação do Borderô.';
          RAISE vr_exc_erro;
      END;
      
      vr_vllanmto_tot := 0;
      -- Faz o estorno do último lançamento da LCM
      OPEN  cr_craplcm;
      FETCH cr_craplcm INTO rw_craplcm;
      CLOSE cr_craplcm;
      
      --Cria o registro do Estorno
      DSCT0005.pc_insere_estorno(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_justific => pr_dsjustificativa
                       -- OUT --
                       ,pr_cdestorno => vr_cdestorno
                       ,pr_cdcritic  => vr_cdcritic
                       ,pr_dscritic  => vr_dscritic
                       );
                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         vr_cdcritic := 0;
         RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_crapestorno(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         );
      FETCH cr_crapestorno INTO rw_crapestorno;
      CLOSE cr_crapestorno;
      
      -- Caso tenha lançamentos no dia, retirar o que já foi lançado.
      vr_vllanmto_tot := rw_craplcm.vllanmto - rw_crapestorno.vllancamento;
      
      -- Insere o estorno na tabela de lançamentos de estorno
      DSCT0005.pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                 ,pr_nrdconta    => pr_nrdconta
                                 ,pr_nrborder    => pr_nrborder
                                 ,pr_nrtitulo    => 0           -- É do borderô
                                 ,pr_dtvencto    => NULL        -- É do borderô
                                 ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                 ,pr_vllanmto    => vr_vllanmto_tot
                                 ,pr_cdestorno   => vr_cdestorno
                                 ,pr_cdhistor    => rw_craplcm.cdhistor
                                 ,pr_cdcritic    => pr_cdcritic
                                 ,pr_dscritic    => pr_dscritic);
                                       
      IF TRIM(pr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := pr_dscritic;
        RAISE vr_exc_erro;      
      END IF;
      
      -- Caso tenha abono faz mais um lançamento dentro do estorno_lancamento
      IF vr_est_abono > 0 THEN
        -- Insere o estorno na tabela de lançamentos de estorno
        DSCT0005.pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                   ,pr_nrdconta    => pr_nrdconta
                                   ,pr_nrborder    => pr_nrborder
                                   ,pr_nrtitulo    => 0           -- É do borderô
                                   ,pr_dtvencto    => NULL        -- É do borderô
                                   ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                   ,pr_vllanmto    => vr_est_abono
                                   ,pr_cdestorno   => vr_cdestorno
                                   ,pr_cdhistor    => PREJ0005.vr_cdhistordsct_rec_abono
                                   ,pr_cdcritic    => pr_cdcritic
                                   ,pr_dscritic    => pr_dscritic);
                                         
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          vr_cdcritic := 0;
          vr_dscritic := pr_dscritic;
          RAISE vr_exc_erro;      
        END IF;
      END IF;
      
      -- Caso o lançamento seja do mesmo dia deleta os lançamentos, senão lança na CC o estorno.
      IF (rw_craplcm.dtmvtolt = rw_crapdat.dtmvtolt) THEN
        BEGIN
          DELETE FROM craplcm lcm WHERE lcm.cdcooper = pr_cdcooper 
                                    AND lcm.nrdconta = pr_nrdconta
                                    AND lcm.nrdocmto = pr_nrborder 
                                    AND lcm.dtmvtolt  = rw_craplcm.dtmvtolt
                                    AND lcm.cdhistor = PREJ0005.vr_cdhistordsct_recup_preju;
        EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel remover os registros na craplcm.';
          RAISE vr_exc_erro;
        END; 
      ELSE
        -- Realizar Lançamento do estorno na craplcm de Desconto de Títulos
        DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_cdagenci => pr_cdagenci, 
                                   pr_cdbccxlt => rw_craplcm.cdbccxlt, 
                                   pr_nrdconta => pr_nrdconta, 
                                   pr_vllanmto => vr_vllanmto_tot,
                                   pr_cdhistor => PREJ0005.vr_cdhistordsct_est_rec_princi, 
                                   pr_cdcooper => pr_cdcooper, 
                                   pr_cdoperad => pr_cdoperad, 
                                   pr_nrborder => pr_nrborder, 
                                   pr_cdpactra => NULL, 
                                   pr_nrdocmto => rw_craplcm.nrdocmto, 
                                   pr_nrdolote => vr_nrdolote,
                                   pr_nrseqdig => vr_nrseqdig,                                   
                                   pr_cdcritic => pr_cdcritic, 
                                   pr_dscritic => pr_dscritic);
                                   
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN 
        IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina DSCT0005.pc_realiza_estorno_prejuizo: ' || SQLERRM;
    
  END pc_realiza_estorno_prejuizo;



  


BEGIN
  
  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat into rw_crapdat;
  IF (btch0001.cr_crapdat%NOTFOUND) THEN
    CLOSE btch0001.cr_crapdat;
    vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
    RAISE vr_exc_erro;
  END IF;
  CLOSE btch0001.cr_crapdat;

  FOR rw_craptdb IN cr_craptdb LOOP    
    pc_realiza_estorno_prejuizo(pr_cdcooper  => pr_cdcooper
                               ,pr_nrdconta  => rw_craptdb.nrdconta
                               ,pr_nrborder  => rw_craptdb.nrborder
                               ,pr_cdagenci  => 1
                               ,pr_cdoperad  => 1
                               ,pr_dsjustificativa => 'INC - Estorno devido a pagamento indevido de processo'
                               -- OUT --
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    UPDATE craptdb tdb
       SET tdb.vlpgjrpr = tdb.vljraprj
           ,tdb.insittit = 3
           ,tdb.dtdebito = nvl(tdb.dtdebito,rw_crapdat.dtmvtolt)
           ,tdb.dtdpagto = nvl(tdb.dtdpagto,rw_crapdat.dtmvtolt)
     WHERE tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = rw_craptdb.nrdconta
       AND tdb.nrborder = rw_craptdb.nrborder
       AND tdb.insittit <> 3
       AND tdb.vlsdprej +
          (tdb.vlttjmpr - tdb.vlpgjmpr) +
          (tdb.vlttmupr - tdb.vlpgmupr) +
          (tdb.vljraprj - tdb.vlpgjrpr) + 
          (tdb.vliofprj - tdb.vliofppr)  < 0; 
    
    PREJ0005.pc_liquidar_bordero_prejuizo(  pr_cdcooper => pr_cdcooper
                                           ,pr_nrborder => rw_craptdb.nrborder
                                           ,pr_vljratu_prej_mes => 0
                                           ,pr_liquidou => vr_liquidou
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
                                       
  END LOOP; 
  
  COMMIT;

EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500,vr_cdcritic||'-'||vr_dscritic); 
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,'Erro ao estornar '||SQLERRM);  
    
END;
