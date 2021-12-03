  
DECLARE  

  vr_dsINC    VARCHAR2(200) := 'PRB0046139';
  
  
  CURSOR cr_craptdb IS
    SELECT DISTINCT t.cdcooper
                   ,t.nrborder
                   ,t.nrdconta
                   ,t.nrtitulo
                   ,t.vlsdprej
                   ,t.nrctrdsc
                   ,t.vljraprj
                   ,t.vlpgjrpr
                   ,t.inprejuz
                   ,t.vliofprj
      FROM (SELECT bdt.inprejuz
                  ,tdb.nrborder
                  ,tdb.cdbandoc
                  ,tdb.nrdctabb
                  ,tdb.nrcnvcob
                  ,tdb.nrdocmto
                  ,bdt.nrdconta
                  ,bdt.cdcooper
                  ,tdb.nrtitulo
                  ,tdb.vljraprj
                  ,titcyb.nrctrdsc
                  ,tdb.vliofprj
                  ,tdb.vlpgjrpr
                  ,(CASE
                      WHEN bdt.inprejuz = 1 THEN
                       nvl(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr) + (tdb.vlttmupr - tdb.vlpgmupr) +
                                         (tdb.vljraprj - tdb.vlpgjrpr) + (tdb.vliofprj - tdb.vliofppr),
                          0)
                      ELSE 0 END) AS vlsdprej
              FROM craptdb                 tdb
                  ,tbdsct_titulo_cyber     titcyb
                  ,crapbdt                 bdt
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
               AND tdb.vljraprj = 0
               AND bdt.insitbdt = 3) t
     WHERE t.vlsdprej < 0
     ORDER BY t.cdcooper
             ,t.nrdconta
             ,t.nrborder;

  CURSOR cr_total_jur (pr_cdcooper IN NUMBER,
                       pr_nrdconta IN NUMBER,
                       pr_nrborder IN NUMBER,
                       pr_nrtitulo IN NUMBER)IS
   SELECT SUM(x.vllanmto) vljraprj
     FROM tbdsct_lancamento_bordero x
    WHERE x.cdcooper = pr_cdcooper
      AND x.nrborder = pr_nrborder
      AND x.nrdconta = pr_nrdconta
      AND x.nrtitulo = pr_nrtitulo
      AND x.cdhistor IN (2763);
  rw_total_jur cr_total_jur%ROWTYPE;

  CURSOR cr_acordo (pr_cdcooper  IN NUMBER,
                    pr_nrdconta  IN NUMBER,
                    pr_nrctremp  IN NUMBER) IS
    SELECT 1 quitado,
           a.nracordo
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c,
           tbdsct_titulo_cyber t
     WHERE a.nracordo = c.nracordo
       AND a.cdcooper = t.cdcooper
       AND a.nrdconta = t.nrdconta
       AND c.nrctremp = t.nrctrdsc
       AND c.cdorigem = 4
       AND a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp
       AND a.cdsituacao = 2;
  rw_acordo cr_acordo%ROWTYPE;

  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  vr_exc_erro     EXCEPTION;  
  gl_nrdolote NUMBER;
  vr_des_reto VARCHAR2(2000);
  vr_tab_erro gene0001.typ_tab_erro ;
  
  vr_dsdireto  VARCHAR2(200);
  
  
    
  PROCEDURE pc_gera_log (pr_dslog IN VARCHAR2) IS
    vr_dslog VARCHAR2(2000);
  BEGIN
    
    vr_dslog := to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||' -->  '||
                pr_dslog || '; ';              
    dbms_output.put_line(vr_dslog);                                                
    BTCH0001.pc_gera_log_batch ( pr_cdcooper     => 0
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_dsINC||'.log' 
                                ,pr_dsdirlog     => vr_dsdireto||'/'||vr_dsINC
                                ,pr_des_log      => vr_dslog);
    
    
  END;
      
  PROCEDURE pc_quitarTitAcordo(pr_cdcooper IN NUMBER,
                               pr_nrdconta IN NUMBER,
                               pr_nrborder IN NUMBER,
                               pr_nrctrdsc IN NUMBER,
                               pr_inprejuz IN NUMBER,
                               pr_dscritic OUT VARCHAR2) IS
    
    --Selecionar informacoes dos titulos do bordero
    CURSOR cr_craptdb_aco (pr_cdcooper IN craptdb.cdcooper%type
                          ,pr_nrdconta IN craptdb.nrdconta%TYPE
                          ,pr_nrborder IN NUMBER
                          ,pr_nrctrdsc IN tbdsct_titulo_cyber.nrctrdsc%type) IS
       SELECT bdt.inprejuz 
             ,tdb.nrborder
             ,tdb.cdbandoc
             ,tdb.nrdctabb
             ,tdb.nrcnvcob
             ,tdb.nrdocmto
              ,CASE
                 WHEN bdt.inprejuz = 0 THEN (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof))
                 ELSE 0
               END as vlsdeved    
              ,CASE
                 WHEN bdt.inprejuz = 1 THEN nvl(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr) + (tdb.vlttmupr - tdb.vlpgmupr) + (tdb.vljraprj - tdb.vlpgjrpr) + (tdb.vliofprj - tdb.vliofppr),0)
                 ELSE 0
               END as vlsdprej
              ,CASE
                 WHEN bdt.inprejuz = 0 THEN (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof))
                 ELSE 0
               END as vlatraso
          FROM   craptdb tdb
                ,tbdsct_titulo_cyber titcyb
                ,crapbdt bdt
          WHERE  tdb.dtresgat    IS NULL
          AND    tdb.dtlibbdt    IS NOT NULL
          AND    tdb.dtdpagto    IS NULL
          AND    bdt.nrborder    = tdb.nrborder
          AND    bdt.nrdconta    = tdb.nrdconta
          AND    bdt.cdcooper    = tdb.cdcooper
          AND    tdb.nrtitulo    = titcyb.nrtitulo
          AND    tdb.nrborder    = titcyb.nrborder
          AND    tdb.nrdconta    = titcyb.nrdconta
          AND    tdb.cdcooper    = titcyb.cdcooper
          AND    bdt.nrborder    = pr_nrborder
          AND    titcyb.nrctrdsc = pr_nrctrdsc
          AND    titcyb.nrdconta = pr_nrdconta
          AND    titcyb.cdcooper = pr_cdcooper;         
    rw_craptdb_aco cr_craptdb_aco%ROWTYPE;
    
    vr_dscritic      VARCHAR2(2000);
    vr_cdcritic      NUMBER;
    vr_exc_erro      EXCEPTION;
    vr_valor_pagar   NUMBER;            
    vr_valor_pagmto  NUMBER;
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
        
  BEGIN
    
    rw_acordo := NULL;
    OPEN cr_acordo (pr_cdcooper  => pr_cdcooper,
                    pr_nrdconta  => pr_nrdconta,
                    pr_nrctremp  => pr_nrctrdsc);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;

    IF rw_acordo.quitado = 1 THEN
      
      --Busca Saldo Devedor do Contrato
      OPEN cr_craptdb_aco(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder
                         ,pr_nrctrdsc => pr_nrctrdsc);

      FETCH cr_craptdb_aco INTO rw_craptdb_aco;
      IF cr_craptdb_aco%NOTFOUND THEN
        CLOSE cr_craptdb_aco;
                             
        -- Se o contrato não estiver com situação = 3 (esperada no cursor, desconsidera
        -- Grava para conferência, se necessário
        vr_dscritic := 'Origem 4 -> Contrato Num. ' || pr_nrctrdsc ||
                        ' nao encontrado.';
        RAISE vr_exc_erro; 
      ELSE
        CLOSE cr_craptdb_aco;
      END IF;
      
      -- Buscar data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Cooperativa sem data de nmovimento';
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
    
      --Verifica se é rejuízo ou não, para informar o valor a ser pago
      IF pr_inprejuz = 1 THEN
        
        IF nvl(rw_craptdb_aco.vlsdprej,0) <= 0 THEN
          pc_gera_log (pr_dslog => '-> Titulo nao possui saldo ('||nvl(rw_craptdb_aco.vlsdprej,0)||') a regularizar.');
        ELSE
        
          vr_valor_pagar  := nvl(rw_craptdb_aco.vlsdprej,0);
          vr_valor_pagmto := 0;
          
          pc_gera_log (pr_dslog => '-> Realizar abono de '||vr_valor_pagar);
          --Paga e abona o valor
          PREJ0005.pc_pagar_titulo_prejuizo(pr_cdcooper => pr_cdcooper
                                           ,pr_cdagenci => 1
                                           ,pr_nrdcaixa => 100
                                           ,pr_cdoperad => 1
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrborder => pr_nrborder
                                           ,pr_cdbandoc => rw_craptdb_aco.cdbandoc
                                           ,pr_nrdctabb => rw_craptdb_aco.nrdctabb
                                           ,pr_nrcnvcob => rw_craptdb_aco.nrcnvcob
                                           ,pr_nrdocmto => rw_craptdb_aco.nrdocmto
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_vlpagmto => vr_valor_pagmto
                                           ,pr_vlaboorj => vr_valor_pagar
                                           ,pr_flgvalac => 1
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

            -- Se retornar erro da rotina
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN

              RAISE vr_exc_erro;

            END IF;
          END IF;

      ELSE
        pc_gera_log (pr_dslog => '-> Rotina preparada apenas para titulos em prejuizo');
      END IF;

    ELSE
      pc_gera_log (pr_dslog => '-> Nao possui acordo quitado.');
    END IF;  
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;  
    
      pr_dscritic := vr_dscritic ||', Cooper: ' || pr_cdcooper ||
                                   ' Conta: '   || pr_nrdconta ||
                                   ' Contrato: ' || pr_nrctrdsc ||
                                   ' Acordo: '  || rw_acordo.nracordo ;
    WHEN OTHERS THEN  
      pr_dscritic := 'Erro ao quitar tit. acordo:' ||
                      'Cooper: ' || pr_cdcooper ||
                      ' Conta: ' || pr_nrdconta ||
                      ' Contrato: ' || pr_nrctrdsc ||' Erro: '||SQLERRM;
  END pc_quitarTitAcordo;    

BEGIN
  
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M',
                                      pr_cdcooper => '0',
                                      pr_nmsubdir => '/cpd/bacas/');



  FOR rw_craptdb IN cr_craptdb LOOP

    pc_gera_log (pr_dslog => 'Processando'||
                             ' cdcooper: '||  rw_craptdb.cdcooper ||
                             ' nrdconta: '||  rw_craptdb.nrdconta || 
                             ' nrborder: '||  rw_craptdb.nrborder ||
                             ' nrtitulo: '||  rw_craptdb.nrtitulo ||
                             ' Saldo Prej:'|| rw_craptdb.vlsdprej);
                             
    rw_total_jur := NULL;
    OPEN cr_total_jur (pr_cdcooper => rw_craptdb.cdcooper,
                       pr_nrdconta => rw_craptdb.nrdconta,
                       pr_nrborder => rw_craptdb.nrborder,
                       pr_nrtitulo => rw_craptdb.nrtitulo);
    FETCH cr_total_jur INTO rw_total_jur;
    CLOSE cr_total_jur;

    IF nvl(rw_total_jur.vljraprj,0) > 0 OR
       rw_craptdb.vliofprj < 0 THEN
      
      IF nvl(rw_total_jur.vljraprj,0) = nvl(rw_craptdb.vljraprj,0) THEN
        pc_gera_log (pr_dslog => 'Titulo nao sera alterado, pois valor de juros eh o mesmo: '||rw_craptdb.nrdconta||'-'||rw_craptdb.nrborder||'-'||rw_craptdb.nrtitulo);
      ELSE
        pc_gera_log (pr_dslog => '-> Alterado vljraprj, de '||nvl(rw_craptdb.vljraprj,0) ||' para '||nvl(rw_total_jur.vljraprj,0)||', possui valor pago de '||rw_craptdb.vlpgjrpr);
        BEGIN
          UPDATE craptdb tdb
             SET tdb.vljraprj = rw_total_jur.vljraprj
           WHERE tdb.cdcooper = rw_craptdb.cdcooper
             AND tdb.nrdconta = rw_craptdb.nrdconta
             AND tdb.nrborder = rw_craptdb.nrborder
             AND tdb.nrtitulo = rw_craptdb.nrtitulo;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar titulo:'||rw_craptdb.nrborder||'-'||rw_craptdb.nrtitulo||': '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
      
      IF rw_craptdb.vliofprj < 0 THEN
        pc_gera_log (pr_dslog => '-> Alterado vliofprj, de '||nvl(rw_craptdb.vliofprj,0) ||' para 0');
        BEGIN
          UPDATE craptdb tdb
             SET tdb.vliofprj = 0
           WHERE tdb.cdcooper = rw_craptdb.cdcooper
             AND tdb.nrdconta = rw_craptdb.nrdconta
             AND tdb.nrborder = rw_craptdb.nrborder
             AND tdb.nrtitulo = rw_craptdb.nrtitulo;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar titulo: '||rw_craptdb.nrborder||'-'||rw_craptdb.nrtitulo||': '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
      END IF;  
      
      pc_quitarTitAcordo(pr_cdcooper => rw_craptdb.cdcooper,
                         pr_nrdconta => rw_craptdb.nrdconta,
                         pr_nrborder => rw_craptdb.nrborder,
                         pr_nrctrdsc => rw_craptdb.nrctrdsc,
                         pr_inprejuz => rw_craptdb.inprejuz,
                         pr_dscritic => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  

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
