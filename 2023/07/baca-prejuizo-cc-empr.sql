DECLARE

  vr_des_erro VARCHAR2(1000);
  vr_nmdatela VARCHAR2(100) := 'RITM0320715';

  vr_idpreju  NUMBER := 0;
  vr_des_reto VARCHAR2(100);
  vr_tab_erro gene0001.typ_tab_erro;

  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_saida EXCEPTION;
  vr_nrdrowid ROWID;

  vr_rootmicros  VARCHAR2(4000) := gene0001.fn_param_sistema('CRED'
                                                            ,3
                                                            ,'ROOT_MICROS');
  vr_nmdireto    VARCHAR2(4000) := vr_rootmicros ||
                                   '/cpd/bacas/RITM0320715';
  vr_arq_leitura VARCHAR2(100) := '/Aptos_29_30_Julho.v2.csv';
  vr_ind_arquiv  utl_file.file_type;
  vr_linha       VARCHAR2(5000);
  vr_campo       GENE0002.typ_split;

  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  TYPE typ_reg_contrato IS RECORD(
     cdcooper cecred.crapepr.cdcooper%TYPE
    ,nrdconta cecred.crapepr.nrdconta%TYPE
    ,nrctremp cecred.crapepr.nrctremp%TYPE
    ,tppreju  VARCHAR2(4000));
  TYPE typ_tab_contrato IS TABLE OF typ_reg_contrato INDEX BY PLS_INTEGER;
  vr_tab_contrato typ_tab_contrato;

  CURSOR cr_prejuizo(pr_cdcooper cecred.crapepr.nrdconta%TYPE
                    ,pr_nrdconta cecred.crapepr.nrdconta%TYPE
                    ,pr_nrctremp cecred.crapepr.nrctremp%TYPE) IS
    SELECT *
      FROM cecred.crapepr a
     WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
  rw_prejuizo cr_prejuizo%ROWTYPE;

  CURSOR cr_crapass(pr_cdcooper cecred.crapepr.nrdconta%TYPE
                   ,pr_nrdconta cecred.crapepr.nrdconta%TYPE) IS
    SELECT *
      FROM cecred.crapass a
     WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  PROCEDURE pc_atualiza_crapcot(pr_cdcooper IN crapepr.cdcooper%TYPE
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE
                               ,pr_nrctremp IN crapepr.nrctremp%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
  
    vr_vllanmto craplem.vllanmto%TYPE;
    vr_qtjurmfx crapcot.qtjurmfx%TYPE;
  
    CURSOR cr_crapmfx(pr_cdcooper IN crapmfx.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                     ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
      SELECT crapmfx.cdcooper, crapmfx.vlmoefix
        FROM cecred.crapmfx
       WHERE crapmfx.cdcooper = pr_cdcooper
             AND crapmfx.dtmvtolt = pr_dtmvtolt
             AND crapmfx.tpmoefix = pr_tpmoefix;
    rw_crapmfx cr_crapmfx%ROWTYPE;
  BEGIN
  
    BEGIN
    
      SELECT NVL(SUM(tab.vllanmto), 0) sum_vlr
        INTO vr_vllanmto
        FROM (SELECT lem.dtmvtolt
                    ,lem.vllanmto
                    ,(SELECT MAX(ll.dtmvtolt)
                        FROM cecred.craplem ll
                       WHERE ll.cdcooper = lem.cdcooper
                             AND ll.nrdconta = lem.nrdconta
                             AND ll.nrctremp = lem.nrctremp
                             AND ll.cdhistor IN (2326
                                                ,2327
                                                ,2330
                                                ,2331
                                                ,1036
                                                ,1044
                                                ,1045
                                                ,3654
                                                ,1039
                                                ,1057
                                                ,1059
                                                ,91
                                                ,92
                                                ,95
                                                ,2335
                                                ,2330
                                                ,2331
                                                ,3026
                                                ,3027
                                                ,2013
                                                ,2014
                                                ,3279
                                                ,99)
                             AND ll.dtmvtolt <= lem.dtmvtolt) dtpgtant
                FROM cecred.crapepr epr, cecred.craplem lem
               WHERE epr.cdcooper = pr_cdcooper
                     AND epr.nrdconta = pr_nrdconta
                     AND epr.nrctremp = pr_nrctremp
                     AND lem.cdcooper = epr.cdcooper
                     AND lem.nrdconta = epr.nrdconta
                     AND lem.nrctremp = epr.nrctremp
                     AND lem.cdagenci > 0
                     AND lem.cdhistor IN
                     (98, 1037, 1038, 2342, 2343, 2344, 2345)
                     AND lem.dtmvtolt >=
                     to_date('01/01/' || (to_char(pr_dtmvtolt, 'YYYY'))
                                ,'DD/MM/YYYY')
              
              UNION
              SELECT lem.dtmvtolt
                    ,lem.vllanmto
                    ,(SELECT MAX(ll.dtmvtolt)
                        FROM cecred.tbepr_renegociacao_craplem ll
                       WHERE ll.cdcooper = lem.cdcooper
                             AND ll.nrdconta = lem.nrdconta
                             AND ll.nrctremp = lem.nrctremp
                             AND ll.nrversao = lem.nrversao
                             AND ll.cdhistor IN (2326
                                                ,2327
                                                ,2330
                                                ,2331
                                                ,1036
                                                ,1044
                                                ,1045
                                                ,3654
                                                ,1039
                                                ,1057
                                                ,1059
                                                ,91
                                                ,92
                                                ,95
                                                ,2335
                                                ,2330
                                                ,2331
                                                ,3026
                                                ,3027
                                                ,2013
                                                ,2014
                                                ,3279
                                                ,99)
                             AND ll.dtmvtolt <= lem.dtmvtolt) dtpgtant
                FROM cecred.tbepr_renegociacao_crapepr epr
                    ,cecred.tbepr_renegociacao_craplem lem
               WHERE epr.cdcooper = pr_cdcooper
                     AND epr.nrdconta = pr_nrdconta
                     AND epr.nrctremp = pr_nrctremp
                     AND lem.cdcooper = epr.cdcooper
                     AND lem.nrdconta = epr.nrdconta
                     AND lem.nrctremp = epr.nrctremp
                     AND lem.nrversao = epr.nrversao
                     AND lem.cdagenci > 0
                     AND lem.cdhistor IN
                     (98, 1037, 1038, 2342, 2343, 2344, 2345)
                     AND lem.dtmvtolt >=
                     to_date('01/01/' || (to_char(pr_dtmvtolt, 'YYYY'))
                                ,'DD/MM/YYYY')) tab
       WHERE dtmvtolt - dtpgtant <= 59;
    EXCEPTION
      WHEN OTHERS THEN
        vr_vllanmto := 0;
    END;
  
    OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => pr_dtmvtolt
                   ,pr_tpmoefix => 2);
    FETCH cr_crapmfx
      INTO rw_crapmfx;
    CLOSE cr_crapmfx;
  
    BEGIN
      UPDATE cecred.crapcot
         SET crapcot.qtjurmfx = crapcot.qtjurmfx -
                                round((vr_vllanmto / rw_crapmfx.vlmoefix), 4)
       WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
      RETURNING qtjurmfx INTO vr_qtjurmfx;
    END;
  
    IF vr_qtjurmfx < 0 THEN
      UPDATE cecred.crapcot
         SET crapcot.qtjurmfx = 0
       WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta;
    END IF;
  
  END pc_atualiza_crapcot;

BEGIN

  cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                                 ,pr_nmarquiv => vr_arq_leitura
                                 ,pr_tipabert => 'R'
                                 ,pr_utlfileh => vr_ind_arquiv
                                 ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  cecred.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                     ,pr_des_text => vr_linha);
  LOOP
    BEGIN
      cecred.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                         ,pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
  
    vr_campo := cecred.GENE0002.fn_quebra_string(pr_string  => vr_linha
                                                ,pr_delimit => ';');
  
    vr_idpreju := vr_idpreju + 1;
  
    vr_tab_contrato(vr_idpreju).cdcooper := 1;
    vr_tab_contrato(vr_idpreju).nrdconta := cecred.GENE0002.fn_char_para_number(vr_campo(1));
    vr_tab_contrato(vr_idpreju).nrctremp := cecred.GENE0002.fn_char_para_number(vr_campo(2));
    vr_tab_contrato(vr_idpreju).tppreju := TRIM(upper(vr_campo(10)));
  
  END LOOP;

  vr_idpreju := vr_tab_contrato.FIRST;

  WHILE vr_idpreju IS NOT NULL LOOP
  
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    IF vr_tab_contrato(vr_idpreju).tppreju = 'EMPRESTIMO' THEN
    
      OPEN cr_prejuizo(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper
                      ,pr_nrdconta => vr_tab_contrato(vr_idpreju).nrdconta
                      ,pr_nrctremp => vr_tab_contrato(vr_idpreju).nrctremp);
      FETCH cr_prejuizo
        INTO rw_prejuizo;
      CLOSE cr_prejuizo;
    
      IF (rw_prejuizo.inprejuz = 1 OR rw_prejuizo.inliquid = 1) THEN
      
        IF rw_prejuizo.inprejuz = 1 THEN
        
          cecred.gene0001.pc_gera_log(pr_cdcooper => rw_prejuizo.cdcooper
                                     ,pr_cdoperad => '1'
                                     ,pr_dscritic => 'Contrato em prejuizo!'
                                     ,pr_dsorigem => 'AIMARO'
                                     ,pr_dstransa => 'Falha Transf Prejuizo'
                                     ,pr_dttransa => trunc(SYSDATE)
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                      ,'HH24MISS'))
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nrdconta => rw_prejuizo.nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
        
          cecred.gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Contrato'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => rw_prejuizo.nrctremp);
        
        ELSIF rw_prejuizo.inliquid = 1 THEN
        
          cecred.gene0001.pc_gera_log(pr_cdcooper => rw_prejuizo.cdcooper
                                     ,pr_cdoperad => '1'
                                     ,pr_dscritic => 'Contrato liquidado!'
                                     ,pr_dsorigem => 'AIMARO'
                                     ,pr_dstransa => 'Falha Transf Prejuizo PP'
                                     ,pr_dttransa => trunc(SYSDATE)
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                      ,'HH24MISS'))
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nrdconta => rw_prejuizo.nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
        
          cecred.gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Contrato'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => rw_prejuizo.nrctremp);
        
        END IF;
      
        vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
        CONTINUE;
      END IF;
    
      IF rw_prejuizo.tpemprst = 1 THEN
      
        cecred.PREJ0001.pc_transfere_epr_prejuizo_PP(pr_cdcooper => rw_prejuizo.cdcooper
                                                    ,pr_cdagenci => rw_prejuizo.cdagenci
                                                    ,pr_nrdcaixa => 0
                                                    ,pr_cdoperad => '1'
                                                    ,pr_nrdconta => rw_prejuizo.nrdconta
                                                    ,pr_idseqttl => 1
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                    ,pr_nrctremp => rw_prejuizo.nrctremp
                                                    ,pr_des_reto => vr_des_reto
                                                    ,pr_tab_erro => vr_tab_erro);
      
        IF vr_des_reto = 'OK' THEN
        
          pc_atualiza_crapcot(pr_cdcooper => rw_prejuizo.cdcooper
                             ,pr_nrdconta => rw_prejuizo.nrdconta
                             ,pr_nrctremp => rw_prejuizo.nrctremp
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        
        ELSIF vr_des_reto <> 'OK' THEN
        
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Não foi possivel Transferir contrato PP . Conta:' ||
                           to_char(rw_prejuizo.nrdconta) || ' Contrato: ' ||
                           to_char(rw_prejuizo.nrctremp);
          END IF;
          cecred.gene0001.pc_gera_log(pr_cdcooper => rw_prejuizo.cdcooper
                                     ,pr_cdoperad => '1'
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_dsorigem => 'AIMARO'
                                     ,pr_dstransa => 'Falha Transf Prejuizo'
                                     ,pr_dttransa => trunc(SYSDATE)
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                      ,'HH24MISS'))
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nrdconta => rw_prejuizo.nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
        
          cecred.gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Contrato'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => rw_prejuizo.nrctremp);
        
          vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
        
          CONTINUE;
        
        END IF;
      
      ELSIF rw_prejuizo.tpemprst = 0 THEN
      
        cecred.PREJ0001.pc_transfere_epr_prejuizo_TR(pr_cdcooper => rw_prejuizo.cdcooper
                                                    ,pr_cdagenci => rw_prejuizo.cdagenci
                                                    ,pr_nrdcaixa => 0
                                                    ,pr_cdoperad => '1'
                                                    ,pr_nrdconta => rw_prejuizo.nrdconta
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                    ,pr_nrctremp => rw_prejuizo.nrctremp
                                                    ,pr_des_reto => vr_des_reto
                                                    ,pr_tab_erro => vr_tab_erro);
      
        IF vr_des_reto = 'OK' THEN
        
          pc_atualiza_crapcot(pr_cdcooper => rw_prejuizo.cdcooper
                             ,pr_nrdconta => rw_prejuizo.nrdconta
                             ,pr_nrctremp => rw_prejuizo.nrctremp
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        
        ELSIF vr_des_reto <> 'OK' THEN
        
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Não foi possivel Transferir contrato TR . Conta:' ||
                           to_char(rw_prejuizo.nrdconta) || ' Contrato: ' ||
                           to_char(rw_prejuizo.nrctremp);
          END IF;
          cecred.gene0001.pc_gera_log(pr_cdcooper => rw_prejuizo.cdcooper
                                     ,pr_cdoperad => '1'
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_dsorigem => 'AIMARO'
                                     ,pr_dstransa => 'Falha Transf Prejuizo'
                                     ,pr_dttransa => trunc(SYSDATE)
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                      ,'HH24MISS'))
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nrdconta => rw_prejuizo.nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
        
          cecred.gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Contrato'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => rw_prejuizo.nrctremp);
        
          vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
          CONTINUE;
        
        END IF;
      
      ELSIF rw_prejuizo.tpemprst = 2 THEN
        cecred.PREJ0001.pc_transfere_epr_prejuizo_pos(pr_cdcooper => rw_prejuizo.cdcooper
                                                     ,pr_cdagenci => rw_prejuizo.cdagenci
                                                     ,pr_nrdcaixa => 0
                                                     ,pr_cdoperad => '1'
                                                     ,pr_nrdconta => rw_prejuizo.nrdconta
                                                     ,pr_idseqttl => 1
                                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                     ,pr_nrctremp => rw_prejuizo.nrctremp
                                                     ,pr_des_reto => vr_des_reto
                                                     ,pr_tab_erro => vr_tab_erro);
      
        IF vr_des_reto = 'OK' THEN
        
          pc_atualiza_crapcot(pr_cdcooper => rw_prejuizo.cdcooper
                             ,pr_nrdconta => rw_prejuizo.nrdconta
                             ,pr_nrctremp => rw_prejuizo.nrctremp
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        
        ELSIF vr_des_reto <> 'OK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Não foi possivel Transferir contrato Pos . Conta:' ||
                           to_char(rw_prejuizo.nrdconta) || ' Contrato: ' ||
                           to_char(rw_prejuizo.nrctremp);
          END IF;
          cecred.gene0001.pc_gera_log(pr_cdcooper => rw_prejuizo.cdcooper
                                     ,pr_cdoperad => '1'
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_dsorigem => 'AIMARO'
                                     ,pr_dstransa => 'Falha Transf Prejuizo'
                                     ,pr_dttransa => trunc(SYSDATE)
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                      ,'HH24MISS'))
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nrdconta => rw_prejuizo.nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
        
          cecred.gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Contrato'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => rw_prejuizo.nrctremp);
        
          vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
          CONTINUE;
        
        END IF;
      END IF;
    
      cecred.gene0001.pc_gera_log(pr_cdcooper => rw_prejuizo.cdcooper
                                 ,pr_cdoperad => '1'
                                 ,pr_dscritic => 'Tranferencia realizada com sucesso!'
                                 ,pr_dsorigem => 'AIMARO'
                                 ,pr_dstransa => 'Transf Prejuizo'
                                 ,pr_dttransa => trunc(SYSDATE)
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                  ,'HH24MISS'))
                                 ,pr_idseqttl => 1
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_nrdconta => rw_prejuizo.nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
    
      cecred.gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Contrato'
                                      ,pr_dsdadant => ' '
                                      ,pr_dsdadatu => rw_prejuizo.nrctremp);
    
    ELSIF vr_tab_contrato(vr_idpreju).tppreju = 'CONTA' THEN
    
      OPEN cr_crapass(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper
                     ,pr_nrdconta => vr_tab_contrato(vr_idpreju).nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
    
      IF rw_crapass.inprejuz = 1 THEN
      
        cecred.gene0001.pc_gera_log(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper
                                   ,pr_cdoperad => '1'
                                   ,pr_dscritic => 'Conta em prejuizo!'
                                   ,pr_dsorigem => 'AIMARO'
                                   ,pr_dstransa => 'Falha Transf Prejuizo'
                                   ,pr_dttransa => trunc(SYSDATE)
                                   ,pr_flgtrans => 1
                                   ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                    ,'HH24MISS'))
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nrdconta => vr_tab_contrato(vr_idpreju).nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
      
        vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
        CONTINUE;
      
      END IF;
    
      cecred.PREJ0003.pc_grava_prejuizo_cc(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper
                                          ,pr_nrdconta => vr_tab_contrato(vr_idpreju).nrdconta
                                          ,pr_tpope    => 'N'
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_des_erro);
    
      IF vr_des_erro <> 'OK' THEN
      
        cecred.gene0001.pc_gera_log(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper
                                   ,pr_cdoperad => '1'
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_dsorigem => 'AIMARO'
                                   ,pr_dstransa => 'Falha Transf Prejuizo'
                                   ,pr_dttransa => trunc(SYSDATE)
                                   ,pr_flgtrans => 1
                                   ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                    ,'HH24MISS'))
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nrdconta => vr_tab_contrato(vr_idpreju).nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
      
        vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
        CONTINUE;
      
      END IF;
    
      cecred.gene0001.pc_gera_log(pr_cdcooper => vr_tab_contrato(vr_idpreju).cdcooper
                                 ,pr_cdoperad => '1'
                                 ,pr_dscritic => 'Tranferencia realizada com sucesso!'
                                 ,pr_dsorigem => 'AIMARO'
                                 ,pr_dstransa => 'Transf Prejuizo'
                                 ,pr_dttransa => trunc(SYSDATE)
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => to_number(to_char(SYSDATE
                                                                  ,'HH24MISS'))
                                 ,pr_idseqttl => 1
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_nrdconta => vr_tab_contrato(vr_idpreju).nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
    
    END IF;
  
    vr_idpreju := vr_tab_contrato.NEXT(vr_idpreju);
  
  END LOOP;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 3);
END;
