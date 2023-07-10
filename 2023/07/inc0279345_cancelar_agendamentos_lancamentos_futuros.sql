DECLARE
  vr_dttransa                     CECRED.craplgm.dttransa%TYPE;
  vr_hrtransa                     CECRED.craplgm.hrtransa%TYPE;
  vr_nrdconta                     CECRED.crapass.nrdconta%TYPE;
  vr_cdcooper                     CECRED.crapcop.cdcooper%TYPE;
  vr_cdoperad                     CECRED.craplgm.cdoperad%TYPE;
  vr_cdcritic                     CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic                     CECRED.crapcri.dscritic%TYPE;
  vr_nrdrowid                     ROWID;
  vr_des_reto                     VARCHAR2(3);
  
  vr_dtmvtolt                     DATE;
  vr_busca                        VARCHAR2(100);
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_vldCotas                     NUMBER;
  vr_vldCotas_crapcot             NUMBER;
  vr_vlsddisp                     CECRED.crapsda.vlsddisp%TYPE;
  vr_incrineg                     NUMBER;
  vr_index                        NUMBER;
  vr_cdhistor                     CECRED.craphis.cdhistor%TYPE;
  
  vc_nrdolote_cota                CONSTANT CECRED.craplct.nrdolote%TYPE := 600040;
  vc_tpdevCotas                   CONSTANT NUMBER := 3;
  vc_tpdevDepVista                CONSTANT NUMBER := 4;
  vc_cdhistDepVistaPF             CONSTANT NUMBER := 2061;
  vc_cdhistDepVistaPJ             CONSTANT NUMBER := 2062;
  vc_cdhistCotasPF                CONSTANT NUMBER := 2079;
  vc_cdhistCotasPJ                CONSTANT NUMBER := 2080;  
  vc_dstransaStatusCC             CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0279345';
  vc_dstransaDevCotas             CONSTANT VARCHAR2(4000) := 'Alteração de Cotas e devolução - INC0279345';
  vc_dstransaDevDepVista          CONSTANT VARCHAR2(4000) := 'Alteracao da devolução do Depósito a Vista - INC0279345';
  vc_inpessoaPF                   CONSTANT NUMBER := 1;
  vc_inpessoaPJ                   CONSTANT NUMBER := 2; 
  vc_nrdolote_lanc                CONSTANT NUMBER := 37000;
  vc_cdbccxlt                     CONSTANT NUMBER := 1;
  vc_cdsitdctProcesDemis          CONSTANT NUMBER := 8;
  vc_cdsitdctEncerrada            CONSTANT NUMBER := 4;
  vc_dstransaInternet             CONSTANT VARCHAR2(4000) := 'Baixa do Lancamento de Tarifa de Internet - INC0279345';
  vc_insitlau                     CONSTANT CECRED.craplau.insitlau%TYPE := 3;
  
 CURSOR cr_craplau(pr_cdcooper CECRED.craplau.cdcooper%TYPE,
                   pr_nrdconta CECRED.craplau.nrdconta%TYPE) IS
 SELECT l.dtmvtolt,
        l.nrdconta,
        l.insitlau,
        l.dtdebito,
        l.cdcooper,
        l.idlancto
   FROM craplau l
  WHERE 1=1
    AND l.nrdconta = pr_nrdconta
    AND l.cdcooper = pr_cdcooper
    AND l.dtdebito IS NULL
    AND l.vllanaut > 0;    

  
 CURSOR cr_crapass(pr_cdcooper CECRED.craplau.cdcooper%TYPE
                  ,pr_nrdconta CECRED.craplau.nrdconta%TYPE
                  ,pr_dtmvtolt CECRED.crapdat.dtmvtolt%TYPE) IS
   SELECT t.cdagenci
         ,t.cdcooper
         ,t.nrdconta
         ,t.inpessoa
         ,t.vllimcre
         ,t.cdsitdct AS cdsitdct_old
         ,a.cdsitdct AS cdsitdct_new
         ,t.dtdemiss AS dtdemiss_old
         ,a.dtdemiss AS dtdemiss_new
         ,t.dtelimin AS dtelimin_old
         ,a.dtelimin AS dtelimin_new
         ,t.dtasitct AS dtasitct_old
         ,a.dtasitct AS dtasitct_new
         ,t.cdmotdem AS cdmotdem_old
         ,a.cdmotdem AS cdmotdem_new
     FROM CECRED.crapass t
        ,(SELECT pr_cdcooper AS cdcooper
                ,pr_nrdconta AS nrdconta
                ,vc_cdsitdctEncerrada AS cdsitdct
                ,pr_dtmvtolt AS dtdemiss
                ,pr_dtmvtolt AS dtelimin
                ,pr_dtmvtolt AS dtasitct
                ,11 AS cdmotdem
            FROM dual) a
    WHERE 1=1
      AND t.cdcooper = a.cdcooper
      AND t.nrdconta = a.nrdconta
    ORDER BY a.cdsitdct DESC;
  rg_crapass cr_crapass%ROWTYPE;
  
  TYPE typ_rec_conta_corrente IS RECORD
    (cdcooper CECRED.craplau.cdcooper%TYPE,
     nrdconta CECRED.craplau.nrdconta%TYPE);
  TYPE typ_tab_conta_corrente IS TABLE OF typ_rec_conta_corrente
    INDEX BY PLS_INTEGER;
  vr_tab_conta_corrente typ_tab_conta_corrente;
   
  rw_crapdat                      CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_sald                     CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro                     CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno                  CECRED.LANC0001.typ_reg_retorno;
  vr_exc_sem_data_cooperativa     EXCEPTION;
  vr_exc_saldo                    EXCEPTION;
  vr_exc_lanc_conta               EXCEPTION;
  vr_inpessoa_invalido            EXCEPTION;
  
BEGIN
  vr_dttransa    := trunc(SYSDATE);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  
  vr_tab_conta_corrente(0).cdcooper := 1;
  vr_tab_conta_corrente(0).nrdconta := 11674318;
  
  vr_tab_conta_corrente(1).cdcooper := 1;
  vr_tab_conta_corrente(1).nrdconta := 12686573;
  
  OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => 1);
  FETCH CECRED.BTCH0001.cr_crapdat INTO rw_crapdat;
  
  IF CECRED.BTCH0001.cr_crapdat%NOTFOUND THEN
    CLOSE CECRED.BTCH0001.cr_crapdat;
    RAISE vr_exc_sem_data_cooperativa;
  ELSE
    CLOSE CECRED.BTCH0001.cr_crapdat;
  END IF;
  vr_dtmvtolt := rw_crapdat.dtmvtolt;
  
  
  FOR vr_idx IN vr_tab_conta_corrente.FIRST..vr_tab_conta_corrente.LAST LOOP
    FOR rw_craplau IN cr_craplau(pr_cdcooper => vr_tab_conta_corrente(vr_idx).cdcooper,
                                 pr_nrdconta => vr_tab_conta_corrente(vr_idx).nrdconta) LOOP
      
      vr_cdcooper := rw_craplau.cdcooper;
      vr_nrdconta := rw_craplau.nrdconta;   
      vr_nrdrowid := NULL;
      
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                  pr_cdoperad => vr_cdoperad,
                                  pr_dscritic => vr_dscritic,
                                  pr_dsorigem => 'AIMARO',
                                  pr_dstransa => vc_dstransaInternet,
                                  pr_dttransa => vr_dttransa,
                                  pr_flgtrans => 1,
                                  pr_hrtransa => vr_hrtransa,
                                  pr_idseqttl => 0,
                                  pr_nmdatela => NULL,
                                  pr_nrdconta => vr_nrdconta,
                                  pr_nrdrowid => vr_nrdrowid);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplau.cdcooper',
                                       pr_dsdadant => vr_cdcooper,
                                       pr_dsdadatu => vr_cdcooper);
                                       
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplau.nrdconta',
                                       pr_dsdadant => vr_nrdconta,
                                       pr_dsdadatu => vr_nrdconta);
                                       
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplau.idlancto',
                                       pr_dsdadant => rw_craplau.idlancto,
                                       pr_dsdadatu => rw_craplau.idlancto);
                                       
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplau.insitlau',
                                       pr_dsdadant => rw_craplau.insitlau,
                                       pr_dsdadatu => vc_insitlau);
                                       
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplau.dtdebito',
                                       pr_dsdadant => rw_craplau.dtdebito,
                                       pr_dsdadatu => rw_craplau.dtmvtolt);
      UPDATE CECRED.craplau t
         SET t.insitlau = vc_insitlau
            ,t.dtdebito = t.dtmvtolt
       WHERE t.cdcooper = rw_craplau.cdcooper
         AND t.nrdconta = rw_craplau.nrdconta
         AND t.idlancto = rw_craplau.idlancto;
     
    END LOOP;
  END LOOP;    
  
  FOR vr_idx IN vr_tab_conta_corrente.FIRST..vr_tab_conta_corrente.LAST LOOP
    FOR rg_crapass IN cr_crapass(pr_cdcooper => vr_tab_conta_corrente(vr_idx).cdcooper
                                ,pr_nrdconta => vr_tab_conta_corrente(vr_idx).nrdconta
                                ,pr_dtmvtolt => vr_dtmvtolt) LOOP
      vr_cdcooper := rg_crapass.cdcooper;
      vr_nrdconta := rg_crapass.nrdconta;
                
      vr_nrdrowid := NULL;
      
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                  pr_cdoperad => vr_cdoperad,
                                  pr_dscritic => vr_dscritic,
                                  pr_dsorigem => 'AIMARO',
                                  pr_dstransa => vc_dstransaStatusCC,
                                  pr_dttransa => vr_dttransa,
                                  pr_flgtrans => 1,
                                  pr_hrtransa => vr_hrtransa,
                                  pr_idseqttl => 0,
                                  pr_nmdatela => NULL,
                                  pr_nrdconta => rg_crapass.nrdconta,
                                  pr_nrdrowid => vr_nrdrowid);
                           
      IF (rg_crapass.cdsitdct_new IS NOT NULL) THEN
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'crapass.cdsitdct',
                                         pr_dsdadant => rg_crapass.cdsitdct_old,
                                         pr_dsdadatu => rg_crapass.cdsitdct_new);
      END IF;
      
      IF (rg_crapass.dtdemiss_new IS NOT NULL) THEN    
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'crapass.dtdemiss',
                                         pr_dsdadant => rg_crapass.dtdemiss_old,
                                         pr_dsdadatu => rg_crapass.dtdemiss_new);
      END IF;
                                
      IF (rg_crapass.cdmotdem_new IS NOT NULL) THEN    
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'crapass.dtelimin',
                                         pr_dsdadant => rg_crapass.dtelimin_old,
                                         pr_dsdadatu => rg_crapass.dtelimin_new);  
      END IF;
                                                              
      IF (rg_crapass.cdmotdem_new IS NOT NULL) THEN    
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'crapass.cdmotdem',
                                         pr_dsdadant => rg_crapass.cdmotdem_old,
                                         pr_dsdadatu => rg_crapass.cdmotdem_new); 
      END IF;
                                                               
      IF (rg_crapass.dtasitct_new IS NOT NULL) THEN    
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'crapass.dtasitct',
                                         pr_dsdadant => rg_crapass.dtasitct_old,
                                         pr_dsdadatu => rg_crapass.dtasitct_new);                                
      END IF;

      UPDATE CECRED.crapass a
         SET a.cdsitdct = nvl(rg_crapass.cdsitdct_new, a.cdsitdct)
            ,a.dtdemiss = nvl(rg_crapass.dtdemiss_new, a.dtdemiss)
            ,a.dtelimin = nvl(rg_crapass.dtelimin_new, a.dtelimin)
            ,a.cdmotdem = nvl(rg_crapass.cdmotdem_new, a.cdmotdem)
            ,a.dtasitct = nvl(rg_crapass.dtasitct_new, a.dtasitct)
       WHERE a.cdcooper = rg_crapass.cdcooper
         AND a.nrdconta = rg_crapass.nrdconta;
      
      
      vr_vldCotas_crapcot := 0;
      
      BEGIN
        SELECT nvl(vldCotas,0)
          INTO vr_vldCotas_crapcot
          FROM CECRED.crapcot
         WHERE nrdconta = rg_crapass.nrdconta
           AND cdcooper = rg_crapass.cdcooper;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        
          dbms_output.put_line(chr(10) ||
                               'Não encontrado registro em crapcot para conta ' ||
                               rg_crapass.nrdconta);
          vr_vldCotas_crapcot := 0;
        
      END;
      
      IF vr_vldCotas_crapcot > 0 THEN
        vr_busca := TRIM(to_char(rg_crapass.cdcooper)) || ';' ||
                    TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                    TRIM(to_char(rg_crapass.cdagenci)) || ';' ||
                    '100;' || 
                            vc_nrdolote_cota;
        vr_nrdocmto := CECRED.fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);
        vr_nrseqdig := CECRED.fn_sequence('CRAPLOT','NRSEQDIG',''||rg_crapass.cdcooper||';'||
                                          TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR'))||';'||
                                          rg_crapass.cdagenci||
                                          ';100;'|| 
                                          vc_nrdolote_cota);
      
        CASE rg_crapass.inpessoa
          WHEN vc_inpessoaPF THEN
            vr_cdhistor := vc_cdhistCotasPF;
          WHEN vc_inpessoaPJ THEN
            vr_cdhistor := vc_cdhistCotasPJ;
          ELSE 
            RAISE vr_inpessoa_invalido;
        END CASE;
        
        INSERT INTO CECRED.craplct
          (cdcooper,
           cdagenci,
           cdbccxlt,
           nrdolote,
           dtmvtolt,
           cdhistor,
           nrctrpla,
           nrdconta,
           nrdocmto,
           nrseqdig,
           vllanmto,
           cdopeori,
           dtinsori)
        VALUES
          (rg_crapass.cdcooper,
           rg_crapass.cdagenci,
           100,
           vc_nrdolote_cota,
           vr_dtmvtolt,
           vr_cdhistor,
           0,
           rg_crapass.nrdconta,
           vr_nrdocmto,
           vr_nrseqdig,
           vr_vldCotas_crapcot,
           1,
           sysdate);
        
        vr_nrdrowid := NULL;
        
        CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                    pr_cdoperad => vr_cdoperad,
                                    pr_dscritic => vr_dscritic,
                                    pr_dsorigem => 'AIMARO',
                                    pr_dstransa => vc_dstransaDevCotas,
                                    pr_dttransa => vr_dttransa,
                                    pr_flgtrans => 1,
                                    pr_hrtransa => vr_hrtransa,
                                    pr_idseqttl => 0,
                                    pr_nmdatela => NULL,
                                    pr_nrdconta => rg_crapass.nrdconta,
                                    pr_nrdrowid => vr_nrdrowid);
      
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'craplct.dtmvtolt',
                                         pr_dsdadant => NULL,
                                         pr_dsdadatu => vr_dtmvtolt);
      
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'craplct.vllanmto',
                                         pr_dsdadant => NULL,
                                         pr_dsdadatu => vr_vldCotas_crapcot);
      
        UPDATE CECRED.crapcot
           SET vldCotas = 0
         WHERE cdcooper = rg_crapass.cdcooper
           AND nrdconta = rg_crapass.nrdconta;
      
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                         pr_nmdcampo => 'crapcot.vldCotas',
                                         pr_dsdadant => vr_vldCotas_crapcot,
                                         pr_dsdadatu => 0);
                                  
         MERGE INTO CECRED.tbcotas_devolucao a
         USING (SELECT rg_crapass.cdcooper AS cdcooper, 
                       rg_crapass.nrdconta AS nrdconta, 
                       vc_tpdevCotas AS tpdevolucao 
                  FROM dual) b
                    ON (a.cdcooper = b.cdcooper 
                      AND a.nrdconta = b.nrdconta 
                      AND a.tpdevolucao = b.tpdevolucao)
         WHEN MATCHED THEN 
           UPDATE SET a.vlcapital =(a.vlcapital + vr_vldCotas_crapcot)
         WHEN NOT MATCHED THEN 
           INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
             VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vldCotas_crapcot);
      
      END IF;
      
      IF rg_crapass.cdsitdct_new = vc_cdsitdctEncerrada THEN
        CECRED.EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
                                          ,pr_rw_crapdat => rw_crapdat
                                          ,pr_cdagenci   => rg_crapass.cdagenci
                                          ,pr_nrdcaixa   => 0 
                                          ,pr_cdoperad   => 1 
                                          ,pr_nrdconta   => rg_crapass.nrdconta
                                          ,pr_vllimcre   => rg_crapass.vllimcre
                                          ,pr_dtrefere   => vr_dtmvtolt
                                          ,pr_flgcrass   => FALSE 
                                          ,pr_tipo_busca => 'A' 
                                          ,pr_des_reto   => vr_des_reto
                                          ,pr_tab_sald   => vr_tab_sald
                                          ,pr_tab_erro   => vr_tab_erro);
                       
        IF vr_des_reto = 'OK' AND vr_tab_sald.count() > 0 THEN
           vr_index    := vr_tab_sald.first();
           vr_vlsddisp := vr_tab_sald(vr_index).vlsddisp;
        ELSE
           IF vr_tab_erro.count() > 0 THEN
              vr_index    := vr_tab_erro.first();
              vr_cdcritic := vr_tab_erro(vr_index).cdcritic;
              vr_dscritic := vr_tab_erro(vr_index).dscritic;
              RAISE vr_exc_saldo;
           END IF;
        END IF; 
        
        IF vr_vlsddisp > 0 THEN
           vr_nrdocmto := TO_NUMBER(CECRED.GENE0002.fn_mask(rg_crapass.nrdconta,'9999999999')) ||
                                    CECRED.GENE0002.fn_mask(TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),'9999999999');
                                    
           CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => rg_crapass.cdcooper
                                                    ,pr_dtmvtolt => vr_dtmvtolt
                                                    ,pr_cdagenci => rg_crapass.cdagenci
                                                    ,pr_cdbccxlt => vc_cdbccxlt
                                                    ,pr_nrdolote => vc_nrdolote_lanc
                                                    ,pr_nrdctabb => rg_crapass.nrdconta
                                                    ,pr_nrdocmto => vr_nrdocmto
                                                    ,pr_cdhistor => vr_cdhistor
                                                    ,pr_vllanmto => vr_vlsddisp
                                                    ,pr_nrdconta => rg_crapass.nrdconta
                                                    ,pr_hrtransa => vr_hrtransa
                                                    ,pr_nrdctitg => TO_CHAR(CECRED.GENE0002.fn_mask(rg_crapass.nrdconta,'99999999'))
                                                    ,pr_cdorigem => 0 
                                                    ,pr_inprolot => 1 
                                                    ,pr_tab_retorno => vr_tab_retorno 
                                                    ,pr_incrineg  => vr_incrineg      
                                                    ,pr_cdcritic  => vr_cdcritic      
                                                    ,pr_dscritic  => vr_dscritic);    
                                                    
           IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_lanc_conta;
           END IF;
           
           MERGE INTO CECRED.tbcotas_devolucao a
           USING (SELECT rg_crapass.cdcooper AS cdcooper, 
                         rg_crapass.nrdconta AS nrdconta, 
                         vc_tpdevDepVista AS tpdevolucao 
                  FROM dual) b
                    ON (a.cdcooper = b.cdcooper 
                      AND a.nrdconta = b.nrdconta 
                      AND a.tpdevolucao = b.tpdevolucao)
           WHEN MATCHED THEN 
             UPDATE SET a.vlcapital =(a.vlcapital + vr_vlsddisp)
           WHEN NOT MATCHED THEN 
             INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
               VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vlsddisp);
                    
           vr_nrdrowid := NULL;
           
           CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                       pr_cdoperad => vr_cdoperad,
                                       pr_dscritic => vr_dscritic,
                                       pr_dsorigem => 'AIMARO',
                                       pr_dstransa => vc_dstransaDevDepVista,
                                       pr_dttransa => vr_dttransa,
                                       pr_flgtrans => 1,
                                       pr_hrtransa => vr_hrtransa,
                                       pr_idseqttl => 0,
                                       pr_nmdatela => NULL,
                                       pr_nrdconta => rg_crapass.nrdconta,
                                       pr_nrdrowid => vr_nrdrowid);
                                       
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.cdagenci',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => rg_crapass.cdagenci);
                                           
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.cdbccxlt',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => vc_cdbccxlt);
                                           
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.nrdolote',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => vc_nrdolote_lanc);
                                           
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.nrdctabb',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => rg_crapass.nrdconta);
                                           
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.nrdocmto',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => vr_nrdocmto);
                                           
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.dtmvtolt',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => vr_dtmvtolt);
                                           
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplcm.vllanmto',
                                           pr_dsdadant => NULL,
                                           pr_dsdadatu => vr_vlsddisp);
                                    
        END IF;
      END IF;
    END LOOP;
  END LOOP;
  COMMIT;

EXCEPTION
  WHEN vr_exc_sem_data_cooperativa THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao buscar data da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
  WHEN vr_exc_saldo THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,
                            'Erro ao buscar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
    
  WHEN vr_exc_lanc_conta THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,
                            'Erro ao realizar lançamento na cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
  
  WHEN vr_inpessoa_invalido THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002,
                            'Erro tipo de pessoa inválido da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
    
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20003,
                            'Erro geral script -> cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
