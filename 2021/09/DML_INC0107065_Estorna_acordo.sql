
DECLARE  

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
                                    ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                    ,pr_dscritic        OUT VARCHAR2) IS
   
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    BEGIN
      UPDATE craptdb tdb
         SET tdb.insittit = 4
            ,tdb.dtdebito = NULL
            ,tdb.vlsdprej = tdb.vlsdprej + NVL(pr_vlsdprej, 0) -- Saldo Prejuizo
            ,tdb.vlpgjmpr = tdb.vlpgjmpr - NVL(pr_vlpgjmpr, 0) -- Juros Mora
            ,tdb.vlpgmupr = tdb.vlpgmupr - NVL(pr_vlpgmupr, 0) -- Multa
            ,tdb.vlpgjrpr = tdb.vlpgjrpr - NVL(pr_vlpgjrpr, 0) -- Acumulado
            ,tdb.vlpgjm60 = CASE WHEN (NVL(pr_vlpgjmpr,0) >= tdb.vlpgjm60) THEN 0 ELSE (tdb.vlpgjm60 - NVL(pr_vlpgjmpr,0)) END
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrtitulo = pr_nrtitulo;
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
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_realiza_estorno_prejuizo
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor S. Assanuma (GFT)
      Data     : 08/11/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Realizar o Estorno do Borderô em Prejuízo
      Alterações:
      -- Lucas Negoseki (GFT) - Adicionado novo histórico 2876 na busca de lançamentos borderô
    ---------------------------------------------------------------------------------------------------------------------*/
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
        AND tlb.dtmvtolt BETWEEN  pr_dtini AND pr_dtfim
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
        AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorno) FROM tbdsct_estorno WHERE cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta AND nrborder = pr_nrborder),pr_dtini)
        AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                            ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                            ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                            ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                            ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                            )
        -- Se algum título estiver em acordo, não lista.
        
        AND tlb.dthrtran > to_date('21/09/2021 04:00','DD/MM/RRRR HH24:MI')
        AND tlb.dthrtran < to_date('21/09/2021 07:00','DD/MM/RRRR HH24:MI')
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
        AND lcm.dttrans > to_date('21/09/2021 04:00','DD/MM/RRRR HH24:MI')
        AND lcm.dttrans < to_date('21/09/2021 07:00','DD/MM/RRRR HH24:MI')
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
  
  PROCEDURE pc_estorno_pagamento(pr_cdcooper IN number
                                ,pr_cdagenci in number
                                ,pr_nrdconta in number
                                ,pr_nrctremp in number
                                ,pr_dtmvtolt in DATE
                                ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
    
      TYPE typ_reg_historico IS RECORD (cdhistor craphis.cdhistor%TYPE
                                      , dscritic VARCHAR2(100));
                                      
      TYPE typ_tab_historicos IS TABLE OF typ_reg_historico INDEX BY PLS_INTEGER;
      
      vr_tab_historicos typ_tab_historicos;

    -- Cursor principal da rotina de estorno
    CURSOR c_craplem (prc_cdcooper craplem.cdcooper%TYPE
                     ,prc_nrdconta craplem.nrdconta%TYPE
                     ,prc_nrctremp craplem.nrctremp%TYPE
                     ,prc_dtmvtolt  craplem.dtmvtolt%TYPE) IS
         select lem.dtmvtolt,
                lem.cdhistor,
                lem.cdcooper,
                lem.nrdconta,
                lem.nrctremp,
                lem.vllanmto,
                lem.cdagenci,
                lem.nrdocmto,
                lem.rowid,
                lem.nrdolote,
                lem.nrparepr
           from craplem lem
          where lem.cdcooper = prc_cdcooper
            and lem.nrdconta = prc_nrdconta
            and lem.nrctremp = prc_nrctremp
            and lem.dtmvtolt = prc_dtmvtolt -- ESTORNAR TUDO DO DIA
            AND lem.dthrtran > to_date('21/09/2021 04:00','DD/MM/RRRR HH24:MI')
            AND lem.dthrtran < to_date('21/09/2021 07:00','DD/MM/RRRR HH24:MI')        
            and lem.cdhistor in (2701  -- Valor pagamento
                                ,2388  -- Valor Principal
                                ,2473  -- Juros +60
                                ,2389  -- Juros atualização
                                ,2390  -- Multa  atraso
                                ,2475  -- Juros Mora
                                ,2391  -- Abono
                                );
    -- Buscar proximo Lote
    CURSOR c_busca_prx_lote(pr_dtmvtolt DATE
                           ,pr_cdcooper NUMBER
                           ,pr_cdagenci NUMBER) IS
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci;

    -- Buscar Pagamentos na conta
    CURSOR c_craplcm (prc_cdcooper craplcm.cdcooper%TYPE,
                      prc_nrdconta craplcm.nrdconta%TYPE,
                      prc_dtmvtolt craplcm.dtmvtolt%TYPE,
                      prc_nrctremp craplem.nrctremp%TYPE,
                      prc_vllanmto craplem.vllanmto%TYPE) IS
      SELECT t.vllanmto
        FROM craplcm t
       WHERE t.cdcooper = prc_cdcooper
         AND t.nrdconta = prc_nrdconta
         AND t.cdhistor = 2386 -- Pagamento na conta
         AND t.cdbccxlt = 100
         AND TO_NUMBER(trim(replace(t.cdpesqbb,'.',''))) = prc_nrctremp
         AND t.dttrans > to_date('21/09/2021 04:00','DD/MM/RRRR HH24:MI')
         AND t.dttrans < to_date('21/09/2021 07:00','DD/MM/RRRR HH24:MI')           
         AND t.dtmvtolt = prc_dtmvtolt
         AND t.vllanmto = prc_vllanmto;

      CURSOR c_prejuizo(pr_cdcooper craplcm.cdcooper%TYPE,
                        pr_nrdconta craplcm.nrdconta%TYPE,
                        pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                      pr_nrctremp craplem.nrctremp%TYPE,
                      pr_vllanmto craplem.vllanmto%TYPE) IS
        SELECT t.vllanmto
          FROM tbcc_prejuizo_detalhe t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.cdhistor = 2781 -- Pagamento via conta transitória
           AND t.nrctremp = pr_nrctremp
           AND t.dtmvtolt = pr_dtmvtolt
           AND t.vllanmto = pr_vllanmto;

      -- Cursor para buscar o ROWID da CRAPLCM para exclusão do registro pela centralizadora     
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE,
                         pr_nrdconta IN craplcm.nrdconta%TYPE,
                         pr_nrctremp IN craplem.nrctremp%TYPE,
                       pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                       pr_vllanmto IN craplem.vllanmto%TYPE) IS
      SELECT craplcm.rowid
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.nrdconta = pr_nrdconta
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdhistor = 2386 -- Pagamento na conta 
         AND craplcm.cdbccxlt = 100         
         AND craplcm.dttrans > to_date('21/09/2021 04:00','DD/MM/RRRR HH24:MI')
         AND craplcm.dttrans < to_date('21/09/2021 07:00','DD/MM/RRRR HH24:MI')
         AND TO_NUMBER(TRIM(REPLACE(craplcm.cdpesqbb,'.',''))) = pr_nrctremp
         AND craplcm.vllanmto = pr_vllanmto;
      rw_craplcm cr_craplcm%ROWTYPE;
      
      --
      CURSOR C_CRAPCYC(PR_CDCOOPER IN NUMBER
                       , PR_NRDCONTA IN NUMBER
                       , PR_NRCTREMP IN NUMBER) IS          
        SELECT 1
          FROM CRAPCYC 
         WHERE CDCOOPER = PR_CDCOOPER
           AND NRDCONTA = PR_NRDCONTA
           AND NRCTREMP = PR_NRCTREMP
           AND FLGEHVIP = 1
           AND CDMOTCIN = 2;           
      --                 
     
    -- Buscar os bens da proposta
    CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                       pr_nrdconta IN crapbpr.nrdconta%TYPE,
                       pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
      SELECT COUNT(1) total
        FROM crapbpr
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp
         AND crapbpr.tpctrpro IN (90,99)
         AND crapbpr.cdsitgrv IN (0,2)
         AND crapbpr.flgbaixa = 1
         AND crapbpr.tpdbaixa = 'A';
    vr_existbpr PLS_INTEGER := 0;

    -- Buscar bens baixados
    CURSOR cr_crapbpr_baixado(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                              pr_nrdconta IN crapbpr.nrdconta%TYPE,
                              pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
      SELECT COUNT(1) total
        FROM crapbpr
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp
         AND crapbpr.dtdbaixa = pr_dtmvtolt
         AND crapbpr.tpctrpro IN (90,99)
         AND crapbpr.cdsitgrv IN (1,4) -- Em processamento, Baixado
         AND crapbpr.flgbaixa = 1
         AND crapbpr.tpdbaixa = 'A'
         ;
         
    CURSOR cr_lancto_2781(pr_cdcooper craplem.cdcooper%TYPE
                        , pr_nrdconta craplem.nrdconta%TYPE
                        , pr_nrctremp craplem.nrctremp%TYPE
                        , pr_dtmvtolt craplem.dtmvtolt%TYPE
                        , pr_vllanmto craplem.vllanmto%TYPE) IS
    SELECT idlancto
      FROM tbcc_prejuizo_detalhe 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND dtmvtolt = pr_dtmvtolt
       AND vllanmto = pr_vllanmto
    ;
    
    vr_idlancto_2781 NUMBER;
    vr_existbpr_baixado PLS_INTEGER := 0;

    -- VARIAVEIS
    rw_crapdat     btch0001.cr_crapdat%rowtype;
    vr_erro        exception;
    vr_dscritic    varchar2(1000);
    vr_cdcritic    integer;
    vr_flgativo    integer;
    vr_nrdolote    number;
    vr_nrdrowid    rowid;
    vr_inBloqueioDebito number;

    vr_vllanmto craplcm.vllanmto%TYPE;

      EXC_LCT_NAO_EXISTE exception;
  --
  BEGIN
    -- Monta tabela de históricos de pagamento e respectivo histórico de estorno
    -- Reginaldo/AMcom - P450 - 07/12/2018
    vr_tab_historicos(2388).cdhistor := 2392;
    vr_tab_historicos(2388).dscritic := 'valor principal';
    vr_tab_historicos(2473).cdhistor := 2474;
    vr_tab_historicos(2473).dscritic := 'juros +60';
    vr_tab_historicos(2389).cdhistor := 2393;
    vr_tab_historicos(2389).dscritic := 'juros atualizacao';
    vr_tab_historicos(2390).cdhistor := 2394;
    vr_tab_historicos(2390).dscritic := 'multa atraso';
    vr_tab_historicos(2475).cdhistor := 2476;
    vr_tab_historicos(2475).dscritic := 'juros mora';
        vr_tab_historicos(2391).cdhistor := 2395;
    vr_tab_historicos(2391).dscritic := 'abono';
    vr_tab_historicos(2701).cdhistor := 2702;
    vr_tab_historicos(2701).dscritic := 'pagamento parcela';

    -- Buscar Calendário
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Buscar Contrato
    OPEN cr_crapepr(pr_cdcooper, pr_nrdconta, pr_nrctremp);
    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;

    -- Buscar bens baixados
    OPEN cr_crapbpr_baixado(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);
    FETCH cr_crapbpr_baixado
     INTO vr_existbpr_baixado;
    CLOSE cr_crapbpr_baixado;
    -- NÃO PERMITIR ESTORNAR CASO HAJA BAIXA DE GRAVAME
    IF vr_existbpr_baixado > 0 THEN
      vr_cdcritic := 0;
      pr_des_reto := 'NOK';
      vr_dscritic := 'Não é permitido estorno, existe baixa da alienação: ';
      raise vr_erro;
    END IF;

    IF nvl(rw_crapepr.inprejuz,0) = 0 THEN
      vr_dscritic := 'Não é permitido estorno, empréstimo não está em prejuízo: ';
      raise vr_erro;
    END IF;
    --
    vr_inBloqueioDebito := 0;
    credito.verificarBloqueioDebito(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrctremp => pr_nrctremp,
                                    pr_bloqueio => vr_inBloqueioDebito,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
    if vr_dscritic is not null or vr_cdcritic > 0 then
      RAISE vr_erro;
    end if;

    IF vr_inBloqueioDebito = 1 THEN
      vr_dscritic := 'Atencao! Estorno nao permitido. Bloqueio Judicial encontrado!';
      RAISE vr_erro;
    END IF;

    -- Buscar todos os lançamentos efetuados
    FOR r_craplem in c_craplem(prc_cdcooper => pr_cdcooper
                              ,prc_nrdconta => pr_nrdconta
                              ,prc_nrctremp => pr_nrctremp
                              ,prc_dtmvtolt => pr_dtmvtolt) LOOP
      -- Estorno na data corrente
      IF r_craplem.dtmvtolt = rw_crapdat.dtmvtolt THEN
        IF r_craplem.cdhistor = 2388 THEN -- Valor Principal
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2473 THEN --Juros +60
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2389 THEN --Juros atualização
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2390 THEN --Multa atraso
          -- Atualizar o valor pago de multa
          rw_crapepr.vlpgmupr := rw_crapepr.vlpgmupr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2475 THEN --Juros Mora
          -- Atualizar o valor pago de juros mora
          rw_crapepr.vlpgjmpr := rw_crapepr.vlpgjmpr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2701 THEN
          OPEN cr_lancto_2781(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_nrctremp => pr_nrctremp 
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_vllanmto => r_craplem.vllanmto);
          FETCH cr_lancto_2781 INTO vr_idlancto_2781;
          
          IF cr_lancto_2781%FOUND THEN
            DELETE FROM tbcc_prejuizo_detalhe
             WHERE idlancto = vr_idlancto_2781;
        END IF;
          
          CLOSE cr_lancto_2781;
            END IF;

        /* 1) Excluir Lancamento LEM */
        BEGIN
          DELETE FROM craplem t
              WHERE t.rowid = r_craplem.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Falha na exclusao CRAPLEM, cooper: ' || pr_cdcooper ||
                           ', conta: ' || pr_nrdconta;
            RAISE vr_erro;
        END;

      IF r_craplem.cdhistor = 2701 THEN
        /* excluir lancamento LCM */
        BEGIN
              
                OPEN cr_craplcm( pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp,
                                 pr_dtmvtolt => r_craplem.dtmvtolt,
                                 pr_vllanmto => r_craplem.vllanmto);
                FETCH cr_craplcm INTO rw_craplcm;
        
                IF cr_craplcm%NOTFOUND THEN
                  if (prej0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, 
                                                      pr_nrdconta => pr_nrdconta)) then
                    delete tbcc_prejuizo_detalhe a
                    where a.cdcooper=pr_cdcooper
                      and a.nrdconta=pr_nrdconta
                      and a.cdhistor=2386;
                  else
                    CLOSE cr_craplcm;
                    vr_cdcritic := 0;
                    vr_dscritic := 'Nao foi possivel recuperar os dados do lancto para estornar:'||
                    pr_cdcooper||'/'||pr_nrdconta||'/'||pr_nrctremp||'/'||r_craplem.dtmvtolt;
                    RAISE EXC_LCT_NAO_EXISTE;
                  end if;
                END IF;
        
                -- Chamada da rotina centralizadora em substituição ao DELETE
                IF cr_craplcm%FOUND THEN
                   LANC0001.pc_estorna_lancto_conta(pr_cdcooper => NULL 
                                                  , pr_dtmvtolt => NULL 
                                                  , pr_cdagenci => NULL
                                                  , pr_cdbccxlt => NULL 
                                                  , pr_nrdolote => NULL 
                                                  , pr_nrdctabb => NULL 
                                                  , pr_nrdocmto => NULL 
                                                  , pr_cdhistor => NULL 
                                                  , pr_nrctachq => NULL
                                                  , pr_nrdconta => NULL
                                                  , pr_cdpesqbb => NULL
                                                  , pr_rowid    => rw_craplcm.rowid
                                                  , pr_cdcritic => vr_cdcritic
                                                  , pr_dscritic => vr_dscritic);
                                               
                  IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                    CLOSE cr_craplcm;
                    RAISE vr_erro;
                  END IF;
                end if;
                
                if (prej0003.fn_verifica_preju_conta(pr_cdcooper => r_craplem.cdcooper, 
                                                     pr_nrdconta => r_craplem.nrdconta)) 
                       and r_craplem.cdhistor = 2701 then
                   prej0003.pc_gera_cred_cta_prj (pr_cdcooper => pr_cdcooper, 
                                                  pr_nrdconta => pr_nrdconta, 
                                                  pr_cdoperad => '1', 
                                                  pr_vlrlanc  => r_craplem.vllanmto, 
                                                  pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                                  pr_nrdocmto => null, 
                                                  pr_cdcritic => vr_cdcritic, 
                                                  pr_dscritic => vr_dscritic);
                   if (vr_cdcritic <> 0 or vr_dscritic is not null) then
                     RAISE vr_erro;
                   end if;
                end if;

                IF cr_craplcm%isopen THEN
                   CLOSE cr_craplcm;
                END IF;   
              
        EXCEPTION
              WHEN EXC_LCT_NAO_EXISTE THEN
                RAISE vr_erro ;              
          WHEN OTHERS THEN
            vr_dscritic := 'Falha na exclusao CRAPLCM, cooper: ' || pr_cdcooper ||
                           ', conta: ' || pr_nrdconta;
            RAISE vr_erro ;
        END;
        --
      END IF;
      ELSE
        -- Estorno de data anterior
          -- cria lancamento LCM
          IF gl_nrdolote IS NULL THEN
            OPEN c_busca_prx_lote(pr_dtmvtolt => RW_CRAPDAT.DTMVTOLT
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => r_craplem.cdagenci);
            fetch c_busca_prx_lote into vr_nrdolote;
            close c_busca_prx_lote;

            vr_nrdolote := nvl(vr_nrdolote,0) + 1;
            gl_nrdolote := vr_nrdolote;
          ELSE
            vr_nrdolote := gl_nrdolote;
          END IF;
          --

              OPEN c_craplcm (r_craplem.cdcooper,
                                      r_craplem.nrdconta,
                                      r_craplem.dtmvtolt,
                          r_craplem.nrctremp,
                          r_craplem.vllanmto);
              FETCH c_craplcm INTO vr_vllanmto;
              
              IF c_craplcm%NOTFOUND THEN
                -- Reginaldo/AMcom - P450 - 07/12/2018
                OPEN c_prejuizo(r_craplem.cdcooper,
                                r_craplem.nrdconta,
                                r_craplem.dtmvtolt,
                            r_craplem.nrctremp,
                            r_craplem.vllanmto);
                FETCH c_prejuizo INTO vr_vllanmto;
                CLOSE c_prejuizo;
              END IF;
              
              CLOSE c_craplcm;      
              
            IF r_craplem.cdhistor = 2701 THEN
              IF prej0003.fn_verifica_preju_conta(pr_cdcooper => r_craplem.cdcooper,
                                                  pr_nrdconta => r_craplem.nrdconta) THEN
                PREJ0003.pc_gera_cred_cta_prj (pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta, 
                                                pr_cdoperad => '1', 
                                                pr_vlrlanc  => vr_vllanmto,
                                                pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                                pr_nrdocmto => null, 
                                                pr_cdcritic => vr_cdcritic, 
                                                pr_dscritic => vr_dscritic);
                                                  
                IF nvl(vr_cdcritic,0) <> 0 OR trim(vr_dscritic) IS NOT NULL THEN
                   RAISE vr_erro;
                END IF;                                  
              ELSE
            empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => r_craplem.cdagenci
                                          ,pr_cdbccxlt => 100
                                          ,pr_cdoperad => '1'
                                          ,pr_cdpactra => r_craplem.cdagenci
                                          ,pr_nrdolote => vr_nrdolote
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_cdhistor => 2387 -- EST.RECUP.PREJUIZO
                                              ,pr_vllanmto => vr_vllanmto
                                          ,pr_nrparepr => 0
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrseqava => 0
                                          ,pr_idlautom => 0
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => vr_tab_erro );

            IF vr_des_reto <> 'OK' THEN
              IF vr_tab_erro.count() > 0 THEN
                -- Atribui críticas às variaveis
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := 'Falha estorno Pagamento '||vr_tab_erro(vr_tab_erro.first).dscritic;
                RAISE vr_erro;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Falha ao Estornar Pagamento '||sqlerrm;
                raise vr_erro;
              END IF;
            END IF;
              END IF;
             
              OPEN cr_lancto_2781(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_nrctremp => pr_nrctremp 
                                , pr_dtmvtolt => pr_dtmvtolt
                                , pr_vllanmto => r_craplem.vllanmto);
              FETCH cr_lancto_2781 INTO vr_idlancto_2781;
              
              IF cr_lancto_2781%FOUND THEN
                DELETE FROM tbcc_prejuizo_detalhe
                 WHERE idlancto = vr_idlancto_2781;
            END IF;
              
              CLOSE cr_lancto_2781;
            END IF;
            
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => r_craplem.cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => '1'
                                             ,pr_cdpactra => r_craplem.cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_tab_historicos(r_craplem.cdhistor).cdhistor
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => r_craplem.vllanmto
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => r_craplem.nrparepr
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

            IF vr_dscritic is not null THEN
              vr_dscritic := 'Ocorreu falha ao retornar gravacao LEM (' || 
                vr_tab_historicos(r_craplem.cdhistor).dscritic || '): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              raise vr_erro;
            END IF;
            
            --
            IF r_craplem.cdhistor IN (2391, 2701) THEN
              BEGIN
                UPDATE craplem lem
                   SET lem.dtestorn = TRUNC(rw_crapdat.dtmvtolt)
                 WHERE lem.rowid = r_craplem.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Ocorreu falha ao registrar data de estorno (' || 
                    r_craplem.cdhistor || '): ' || vr_dscritic;
                  pr_des_reto := 'NOK';
                  raise vr_erro;
              END;
        END IF;

        --
        IF r_craplem.cdhistor = 2388 THEN -- Valor Principal
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2473 THEN --Juros +60
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2389 THEN --Juros atualização
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2390 THEN --Multa atraso
          -- Atualizar o valor pago de multa
          rw_crapepr.vlpgmupr := rw_crapepr.vlpgmupr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2475 THEN --Juros Mora
          -- Atualizar o valor pago de juros mora
          rw_crapepr.vlpgjmpr := rw_crapepr.vlpgjmpr - r_craplem.vllanmto;
        END IF;
      END IF;
    END LOOP;

    -- Verifica se existem bems em Gravames
    OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crapbpr
     INTO vr_existbpr;
    CLOSE cr_crapbpr;

    IF NVL(vr_existbpr,0) > 0 THEN
      -- Solicita a baixa no gravames
      GRVM0001.pc_desfazer_baixa_automatica(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctrpro => pr_nrctremp
                                           ,pr_des_reto => vr_des_reto
                                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_dscritic := 'GRVM001 - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          pr_des_reto := 'NOK';
          RAISE vr_erro;
        END IF;
      END IF;

    END IF; -- END IF NVL(vr_existbpr,0) > 0 THEN

    --
    /* Atualiza CRAPEPR com o valor do lançamento */
    BEGIN
      UPDATE crapepr c
         SET c.vlsdprej = nvl(rw_crapepr.vlsdprej,c.vlsdprej)  --vlsdprej - vr_vldescto - nvl(pr_vldabono,0)
            ,c.vlpgjmpr = nvl(rw_crapepr.vlpgjmpr,c.vlpgjmpr) --abs(nvl(c.vlpgjmpr,0) - nvl(vr_vlttjmpr,0))
            ,c.vlpgmupr = nvl(rw_crapepr.vlpgmupr,c.vlpgmupr) --abs(nvl(c.vlpgmupr,0) - nvl(vr_vlttmupr,0))
       WHERE c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp
         AND c.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Falha ao atualizar emprestimo para estorno: ' || sqlerrm;
        pr_des_reto := 'NOK';
        RAISE vr_erro;
    END;
        
    
  EXCEPTION
    WHEN vr_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Falha na rotina pc_estorno_pagamento: ';
      END IF;
      --
      pr_des_reto := 'NOK';
      --
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
     when others then
        ROLLBACK;
         if vr_dscritic is null then
            vr_dscritic := 'Falha geral rotina pc_estorno_pagamento: ' || sqlerrm;
         end if;

         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => 'PROCESSO'
                             ,pr_dscritic => vr_dscritic
                             ,pr_dsorigem => 'INTRANET'
                             ,pr_dstransa => 'PREJ0002-Estorno pagamento.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'crps780'
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
        
  END pc_estorno_pagamento;


  


BEGIN
  
  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH btch0001.cr_crapdat into rw_crapdat;
  IF (btch0001.cr_crapdat%NOTFOUND) THEN
    CLOSE btch0001.cr_crapdat;
    vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
    RAISE vr_exc_erro;
  END IF;
  CLOSE btch0001.cr_crapdat;

  pc_realiza_estorno_prejuizo(pr_cdcooper  => 1
                             ,pr_nrdconta  => 7893175
                             ,pr_nrborder  => 550327
                             ,pr_cdagenci  => 1
                             ,pr_cdoperad  => 1
                             ,pr_dsjustificativa => 'INC - Estorno devido a pagamento indevido de processo'
                             -- OUT --
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  --> Emprestimo
  pc_estorno_pagamento (pr_cdcooper => 1
                       ,pr_cdagenci => 1
                       ,pr_nrdconta => 7893175
                       ,pr_nrctremp => 1170774
                       ,pr_dtmvtolt => to_date('20/09/2021','dd/mm/yyyy')
                       ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                       ,pr_tab_erro => vr_tab_erro);
  IF vr_des_reto = 'NOK' THEN
    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Não foi possivel executar estorno do Pagamento do Prejuízo.';
    END IF;
    RAISE vr_exc_erro;
  END IF;
  
  
  -- Realiza o lançamento do saldo bloqueado na conta corrente do cooperado
  EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => 1           --> Cooperativa conectada
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                ,pr_cdagenci => 1          --> Código da agência
                                ,pr_cdbccxlt => 100                          --> Número do caixa
                                ,pr_cdoperad => 1                  --> Código do Operador
                                ,pr_cdpactra => 1          --> P.A. da transação
                                ,pr_nrdolote => 650001                       --> Numero do Lote
                                ,pr_nrdconta => 7893175           --> Número da conta
                                ,pr_cdhistor => 2193                         --> Codigo historico 2193 - DEBITO BLOQUEIO ACORDOS
                                ,pr_vllanmto => 20.77                  --> Valor da parcela emprestimo
                                ,pr_nrparepr => 0                  --> Número parcelas empréstimo
                                ,pr_nrctremp => 0                            --> Número do contrato de empréstimo
                                ,pr_des_reto => vr_des_reto                  --> Retorno OK / NOK
                                ,pr_tab_erro => vr_tab_erro);                --> Tabela com possíves erros

  -- Se ocorreu erro
  IF vr_des_reto <> 'OK' THEN
    -- Se possui algum erro na tabela de erros
    IF vr_tab_erro.COUNT() > 0 THEN
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
    END IF;
    RAISE vr_exc_erro;
  END IF;
  
  -- Alterar o valor bloqueado no acordo, com o valor lançado
  BEGIN
    -- Alterar a situação do acordo para cancelado
    UPDATE tbrecup_acordo
       SET vlbloqueado = NVL(vlbloqueado,0) + NVL(20.77,0)
     WHERE nracordo = 318802;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar acordo: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  COMMIT;

EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500,vr_cdcritic||'-'||vr_dscritic); 
  
END;
