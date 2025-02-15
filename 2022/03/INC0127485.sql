DECLARE
  vr_dttransa                     cecred.craplgm.dttransa%type;
  vr_hrtransa                     cecred.craplgm.hrtransa%type;
  vr_nrdconta                     cecred.crapass.nrdconta%type;
  vr_cdcooper                     cecred.crapcop.cdcooper%type;
  vr_cdoperad                     cecred.craplgm.cdoperad%TYPE;
  vr_cdcritic                     cecred.crapcri.cdcritic%type;
  vr_dscritic                     cecred.crapcri.dscritic%TYPE;
  vr_nrdrowid                     ROWID;
  vr_des_reto                     VARCHAR2(3);
  

  vr_dtmvtolt                     DATE;
  vr_nrdolote                     cecred.craplct.nrdolote%type;
  vr_busca                        VARCHAR2(100);
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_vldcotas                     NUMBER;
  vr_vldcotas_crapcot             NUMBER;
  vr_vlsddisp                     cecred.crapsda.vlsddisp%type;
  vr_incrineg                     NUMBER;
  vr_index                        NUMBER;
  vr_cdhistor                     cecred.craphis.cdhistor%type;
  
  
  vc_tpdevCotas                   CONSTANT NUMBER := 3;
  vc_tpdevDepVista                CONSTANT NUMBER := 4;
  vc_cdhistDepVistaPF             CONSTANT NUMBER := 2061;
  vc_cdhistDepVistaPJ             CONSTANT NUMBER := 2062;
  vc_cdhistCotasPF                CONSTANT NUMBER := 2079;
  vc_cdhistCotasPJ                CONSTANT NUMBER := 2080;  
  vc_dstransaStatusCC             CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0127485';
  vc_dstransaDevCotas             CONSTANT VARCHAR2(4000) := 'Altera��o de Cotas e devolu��o - INC0127485';
  vc_dstransaDevDepVista          CONSTANT VARCHAR2(4000) := 'Alteracao da devolu��o do Dep�sito a Vista - INC0127485';
  vc_inpessoaPF                   CONSTANT NUMBER := 1;
  vc_inpessoaPJ                   CONSTANT NUMBER := 2; 
  vc_cdsitcta_encerrada           CONSTANT NUMBER := 4;
  vc_cdmotdem                     CONSTANT NUMBER := 11;
  vc_nrdolote                     CONSTANT NUMBER := 37000;
  vc_cdbccxlt                     CONSTANT NUMBER := 1;
  
  CURSOR cr_crapass is
    SELECT t.cdagenci
          ,t.cdsitdct
          ,t.cdcooper
          ,t.nrdconta
          ,t.inpessoa
          ,t.dtdemiss
          ,t.dtelimin
          ,t.vllimcre
          ,t.cdmotdem
          ,t.dtasitct
      FROM CRAPASS t
     WHERE 1=1
       AND t.cdcooper = 9
       AND t.nrdconta = 530646;

  rg_crapass                      cr_crapass%rowtype;
   
  rw_crapdat                      CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_sald                     CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro                     CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno                  cecred.LANC0001.typ_reg_retorno;
  vr_exc_sem_data_cooperativa     EXCEPTION;
  vr_exc_saldo                    EXCEPTION;
  vr_exc_lanc_conta               EXCEPTION;
  vr_inpessoa_invalido            EXCEPTION;
  

BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;
  
  
  FOR rg_crapass IN cr_crapass LOOP
    
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;

    
    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;
   
    IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE cecred.btch0001.cr_crapdat;
      raise vr_exc_sem_data_cooperativa;
    ELSE
      CLOSE cecred.btch0001.cr_crapdat;
    END IF;
    vr_dtmvtolt := rw_crapdat.dtmvtolt;
          
    vr_nrdrowid := null;
    
    GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
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
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdsitdct',
                              pr_dsdadant => rg_crapass.cdsitdct,
                              pr_dsdadatu => vc_cdsitcta_encerrada);

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.dtdemiss',
                              pr_dsdadant => rg_crapass.dtdemiss,
                              pr_dsdadatu => vr_dtmvtolt);
                              
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.dtelimin',
                              pr_dsdadant => rg_crapass.dtelimin,
                              pr_dsdadatu => vr_dtmvtolt);                                

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdmotdem',
                              pr_dsdadant => rg_crapass.cdmotdem,
                              pr_dsdadatu => vc_cdmotdem);                                

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.dtasitct',
                              pr_dsdadant => rg_crapass.dtasitct,
                              pr_dsdadatu => vr_dtmvtolt);                                
    update crapass a
       set a.cdsitdct = vc_cdsitcta_encerrada
          ,a.dtdemiss = vr_dtmvtolt
          ,a.dtelimin = vr_dtmvtolt
          ,a.cdmotdem = vc_cdmotdem
          ,a.dtasitct = vr_dtmvtolt
     where a.cdcooper = rg_crapass.cdcooper
       and a.nrdconta = rg_crapass.nrdconta;
    
    
    vr_vldcotas_crapcot := 0;
    
    BEGIN
      SELECT nvl(vldcotas,0)
        INTO vr_vldcotas_crapcot
        FROM CECRED.crapcot
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'N�o encontrado registro em crapcot para conta ' ||
                             rg_crapass.nrdconta);
        vr_vldcotas_crapcot := 0;
      
    END;
    
    IF vr_vldcotas_crapcot > 0 THEN
      
      vr_nrdolote := 600040;
      
      vr_busca := TRIM(to_char(rg_crapass.cdcooper)) || ';' ||
                          TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                          TRIM(to_char(rg_crapass.cdagenci)) || ';' ||
                          '100;' || 
                          vr_nrdolote;
                          
      vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);
                                 
      vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||rg_crapass.cdcooper||';'||
                                                                  TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR'))||';'||
                                                                  rg_crapass.cdagenci||
                                                                  ';100;'|| 
                                                                  vr_nrdolote);
    
      case rg_crapass.inpessoa
        when vc_inpessoaPF then
          vr_cdhistor := vc_cdhistCotasPF;
        when vc_inpessoaPJ then
          vr_cdhistor := vc_cdhistCotasPJ;
        else
          raise vr_inpessoa_invalido;
      end case;
      
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
         CDOPEORI,
         DTINSORI)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.cdagenci,
         100,
         vr_nrdolote,
         vr_dtmvtolt,
         vr_cdhistor,
         0,
         rg_crapass.nrdconta,
         vr_nrdocmto,
         vr_nrseqdig,
         vr_vldcotas_crapcot,
         1,
         sysdate);
      
      vr_nrdrowid := null;
      
      GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
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
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplct.dtmvtolt',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_dtmvtolt);
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplct.vllanmto',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_vldcotas_crapcot);
    
      UPDATE CECRED.crapcot
         SET vldcotas = 0
       WHERE cdcooper = rg_crapass.cdcooper
         AND nrdconta = rg_crapass.nrdconta;
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'crapcot.vldcotas',
                                pr_dsdadant => vr_vldcotas_crapcot,
                                pr_dsdadatu => 0);

       MERGE INTO CECRED.TBCOTAS_DEVOLUCAO a
       USING (SELECT rg_crapass.cdcooper as cdcooper, rg_crapass.nrdconta as nrdconta, vc_tpdevCotas as tpdevolucao 
                FROM DUAL) b
         ON (a.cdcooper = b.cdcooper AND a.nrdconta = b.nrdconta AND a.tpdevolucao = b.tpdevolucao)
       WHEN MATCHED THEN UPDATE SET a.vlcapital =(a.vlcapital + vr_vldcotas_crapcot)
       WHEN NOT MATCHED THEN INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
                             VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vldcotas_crapcot);
    
    END IF;
    
    cecred.EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
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
          raise vr_exc_saldo;
       END IF;
    END IF; 
    
    IF vr_vlsddisp > 0 THEN
       vr_nrdocmto := TO_NUMBER(gene0002.fn_mask(rg_crapass.nrdconta,'9999999999')) ||
                                gene0002.fn_mask(TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),'9999999999');
       
       case rg_crapass.inpessoa
         when vc_inpessoaPF then
           vr_cdhistor := vc_cdhistDepVistaPF;
         when vc_inpessoaPJ then
           vr_cdhistor := vc_cdhistDepVistaPJ;
         else
           raise vr_inpessoa_invalido;
       end case;
       
       cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper => rg_crapass.cdcooper
                                                ,pr_dtmvtolt => vr_dtmvtolt
                                                ,pr_cdagenci => rg_crapass.cdagenci
                                                ,pr_cdbccxlt => vc_cdbccxlt
                                                ,pr_nrdolote => vc_nrdolote
                                                ,pr_nrdctabb => rg_crapass.nrdconta
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_cdhistor => vr_cdhistor
                                                ,pr_vllanmto => vr_vlsddisp
                                                ,pr_nrdconta => rg_crapass.nrdconta
                                                ,pr_hrtransa => vr_hrtransa
                                                ,pr_nrdctitg => TO_CHAR(gene0002.fn_mask(rg_crapass.nrdconta,'99999999'))
                                                ,pr_cdorigem => 0 
                                                ,pr_inprolot => 1 
                                                ,pr_tab_retorno => vr_tab_retorno 
                                                ,pr_incrineg  => vr_incrineg      
                                                ,pr_cdcritic  => vr_cdcritic      
                                                ,pr_dscritic  => vr_dscritic);    
                                                
       IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         raise vr_exc_lanc_conta;
       END IF;
       
       MERGE INTO CECRED.TBCOTAS_DEVOLUCAO a
       USING (SELECT rg_crapass.cdcooper as cdcooper, rg_crapass.nrdconta as nrdconta, vc_tpdevDepVista as tpdevolucao 
                FROM DUAL) b
         ON (a.cdcooper = b.cdcooper AND a.nrdconta = b.nrdconta AND a.tpdevolucao = b.tpdevolucao)
       WHEN MATCHED THEN UPDATE SET a.vlcapital =(a.vlcapital + vr_vlsddisp)
       WHEN NOT MATCHED THEN INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
                             VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vlsddisp);
                
       vr_nrdrowid := null;
       
       GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
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
                            

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.cdagenci',
                                pr_dsdadant => null,
                                pr_dsdadatu => rg_crapass.cdagenci);
                                
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.cdbccxlt',
                                pr_dsdadant => null,
                                pr_dsdadatu => vc_cdbccxlt);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.nrdolote',
                                pr_dsdadant => null,
                                pr_dsdadatu => vc_nrdolote);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.nrdctabb',
                                pr_dsdadant => null,
                                pr_dsdadatu => rg_crapass.nrdconta);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.nrdocmto',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_nrdocmto);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.dtmvtolt',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_dtmvtolt);
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplcm.vllanmto',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_vlsddisp);
                                
    END IF;
  end loop;

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
                            'Erro ao realizar lan�amento na cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
  
  WHEN vr_inpessoa_invalido THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002,
                            'Erro tipo de pessoa inv�lido da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
    
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20003,
                            'Erro geral script -> cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;    
