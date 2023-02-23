DECLARE
  
  CURSOR cr_crapass is
    SELECT t.cdcooper
         , t.nrdconta 
         , t.cdsitdct
         , t.cdagenci
         , t.inpessoa
         , t.vllimcre
      FROM cecred.CRAPASS t
     WHERE t.progress_recid = 819193;
  rg_crapass   cr_crapass%rowtype;
   
  vr_nrdrowid  ROWID;
  vr_vldcotas  NUMBER;
  vr_nrdocmto  NUMBER;
  vr_nrseqdig  NUMBER;
  vr_cdhistor  NUMBER;
  vr_busca     VARCHAR2(100);
  vr_incrineg  NUMBER;
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(2000);
  vr_dtmvtolt  DATE;
  vr_des_reto  VARCHAR2(3);
  vr_index     NUMBER;
  vr_vlsddisp  NUMBER;
  vr_tab_sald  CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro  CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno cecred.LANC0001.typ_reg_retorno;
  
  vc_nrdolote             CONSTANT cecred.craplct.nrdolote%type := 600040;
  vc_cdhistCotasPF        CONSTANT NUMBER := 2079;
  vc_cdhistCotasPJ        CONSTANT NUMBER := 2080; 
  vc_cdhistDepVistaPF     CONSTANT NUMBER := 2061;
  vc_cdhistDepVistaPJ     CONSTANT NUMBER := 2062;
  vc_cdbccxlt             CONSTANT NUMBER := 1;
  vc_nrdolote_lanc        CONSTANT NUMBER := 37000;
  vc_tpdevCotas           CONSTANT NUMBER := 3;
  vc_tpdevDepVista        CONSTANT NUMBER := 4;
  vc_dstransaStatusCC     CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0250646';
  vc_dstransaDevCotas     CONSTANT VARCHAR2(4000) := 'Alteração de Cotas e devolução - INC0250646';
  vc_dstransaDevDepVista  CONSTANT VARCHAR2(4000) := 'Alteracao da devolução do Depósito a Vista - INC0250646';
  
BEGIN
  
  OPEN  cr_crapass;
  FETCH cr_crapass INTO rg_crapass;
  
  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    RAISE_APPLICATION_ERROR(-20001,'Dados da conta não encontrados pelo progress_recid.');
  END IF;
  
  CLOSE cr_crapass;
  
  OPEN  btch0001.cr_crapdat(rg_crapass.cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  
  BEGIN
    UPDATE cecred.crapass a
       SET a.cdsitdct = 8
     WHERE a.cdcooper = rg_crapass.cdcooper
       AND a.nrdconta = rg_crapass.nrdconta;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002,'Erro ao atualizar situação da conta: '||SQLERRM);
  END;
   
  vr_nrdrowid := null;
    
  GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                       pr_cdoperad => '1',
                       pr_dscritic => NULL,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => vc_dstransaStatusCC,
                       pr_dttransa => TRUNC(SYSDATE),
                       pr_flgtrans => 1,
                       pr_hrtransa => GENE0002.fn_busca_time,
                       pr_idseqttl => 0,
                       pr_nmdatela => NULL,
                       pr_nrdconta => rg_crapass.nrdconta,
                       pr_nrdrowid => vr_nrdrowid);
  
  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'crapass.cdsitdct',
                            pr_dsdadant => rg_crapass.cdsitdct,
                            pr_dsdadatu => 8);
  
  vr_vldcotas := 0;
    
  BEGIN
    SELECT nvl(vldcotas,0)
      INTO vr_vldcotas
      FROM CECRED.crapcot
     WHERE nrdconta = rg_crapass.nrdconta
       AND cdcooper = rg_crapass.cdcooper;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line(chr(10) ||
                          'Não encontrado registro em crapcot para conta ' ||
                           rg_crapass.nrdconta);
      vr_vldcotas := 0;
  END;
    
  IF vr_vldcotas > 0 THEN
      
    vr_busca := TRIM(to_char(rg_crapass.cdcooper)) || ';' ||
                TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                TRIM(to_char(rg_crapass.cdagenci)) || ';' ||
                '100;' || vc_nrdolote;
                          
    vr_nrdocmto := cecred.fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);
                                 
    vr_nrseqdig := cecred.fn_sequence('CRAPLOT','NRSEQDIG',''||rg_crapass.cdcooper||';'||
                                                           TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR'))||';'||
                                                           rg_crapass.cdagenci||
                                                           ';100;'|| vc_nrdolote);
    
    CASE rg_crapass.inpessoa
      WHEN 1 THEN 
        vr_cdhistor := vc_cdhistCotasPF;
      WHEN 2 THEN 
        vr_cdhistor := vc_cdhistCotasPJ;
      ELSE
        RAISE_APPLICATION_ERROR(-20003,'Tipo de pessoa invalido encontrado.');
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
         CDOPEORI,
         DTINSORI)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.cdagenci,
         100,
         vc_nrdolote,
         datascooperativa(rg_crapass.cdcooper).dtmvtolt,
         vr_cdhistor,
         0,
         rg_crapass.nrdconta,
         vr_nrdocmto,
         vr_nrseqdig,
         vr_vldcotas,
         1,
         SYSDATE);
      
    vr_nrdrowid := null;
      
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                pr_cdoperad => '1',
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaDevCotas,
                                pr_dttransa => TRUNC(SYSDATE),
                                pr_flgtrans => 1,
                                pr_hrtransa => gene0002.fn_busca_time,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => rg_crapass.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplct.dtmvtolt',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vr_dtmvtolt);
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplct.vllanmto',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vr_vldcotas);
    
    UPDATE CECRED.crapcot
       SET vldcotas = 0
     WHERE cdcooper = rg_crapass.cdcooper
       AND nrdconta = rg_crapass.nrdconta;
    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'crapcot.vldcotas',
                                     pr_dsdadant => vr_vldcotas,
                                     pr_dsdadatu => 0);
                                
    MERGE INTO CECRED.TBCOTAS_DEVOLUCAO a
    USING (SELECT rg_crapass.cdcooper as cdcooper, rg_crapass.nrdconta as nrdconta, vc_tpdevCotas as tpdevolucao 
                FROM DUAL) b
       ON (a.cdcooper = b.cdcooper AND a.nrdconta = b.nrdconta AND a.tpdevolucao = b.tpdevolucao)
     WHEN MATCHED THEN UPDATE SET a.vlcapital =(a.vlcapital + vr_vldcotas)
     WHEN NOT MATCHED THEN INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
                           VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vldcotas);
    
  END IF;
  
  cecred.EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rg_crapass.cdcooper
                                    ,pr_rw_crapdat => btch0001.rw_crapdat
                                    ,pr_cdagenci   => rg_crapass.cdagenci
                                    ,pr_nrdcaixa   => 0 
                                    ,pr_cdoperad   => 1 
                                    ,pr_nrdconta   => rg_crapass.nrdconta
                                    ,pr_vllimcre   => rg_crapass.vllimcre
                                    ,pr_dtrefere   => DatasCooperativa(rg_crapass.cdcooper).dtmvtolt
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
      RAISE_APPLICATION_ERROR(-20004,'Erro ao buscar saldo: '||vr_tab_erro(vr_index).dscritic);
    END IF;
  END IF; 
      
  IF vr_vlsddisp > 0 THEN
    vr_nrdocmto := TO_NUMBER(cecred.gene0002.fn_mask(rg_crapass.nrdconta,'9999999999')) ||
                             cecred.gene0002.fn_mask(TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),'9999999999');
         
    CASE rg_crapass.inpessoa
      WHEN 1 then
        vr_cdhistor := vc_cdhistDepVistaPF;
      WHEN 2 then
        vr_cdhistor := vc_cdhistDepVistaPJ;
      ELSE
       RAISE_APPLICATION_ERROR(-20005,'Tipo de pessoa invalido encontrado.');
    END CASE;
         
    cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper => rg_crapass.cdcooper
                                             ,pr_dtmvtolt => DatasCooperativa(rg_crapass.cdcooper).dtmvtolt
                                             ,pr_cdagenci => rg_crapass.cdagenci
                                             ,pr_cdbccxlt => vc_cdbccxlt
                                             ,pr_nrdolote => vc_nrdolote_lanc
                                             ,pr_nrdctabb => rg_crapass.nrdconta
                                             ,pr_nrdocmto => vr_nrdocmto
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_vllanmto => vr_vlsddisp
                                             ,pr_nrdconta => rg_crapass.nrdconta
                                             ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                             ,pr_nrdctitg => TO_CHAR(cecred.gene0002.fn_mask(rg_crapass.nrdconta,'99999999'))
                                             ,pr_cdorigem => 0 
                                             ,pr_inprolot => 1 
                                             ,pr_tab_retorno => vr_tab_retorno 
                                             ,pr_incrineg  => vr_incrineg      
                                             ,pr_cdcritic  => vr_cdcritic      
                                             ,pr_dscritic  => vr_dscritic);    
                                                  
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      RAISE_APPLICATION_ERROR(-20006,'Erro ao realizar o lançamento na conta: '||vr_dscritic);
    END IF;
         
    MERGE INTO CECRED.TBCOTAS_DEVOLUCAO a
    USING (SELECT rg_crapass.cdcooper as cdcooper, rg_crapass.nrdconta as nrdconta, vc_tpdevDepVista as tpdevolucao 
            FROM DUAL) b
       ON (a.cdcooper = b.cdcooper AND a.nrdconta = b.nrdconta AND a.tpdevolucao = b.tpdevolucao)
     WHEN MATCHED THEN UPDATE SET a.vlcapital =(a.vlcapital + vr_vlsddisp)
     WHEN NOT MATCHED THEN INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
                           VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vlsddisp);
                  
    vr_nrdrowid := null;
         
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                pr_cdoperad => '1',
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaDevDepVista,
                                pr_dttransa => TRUNC(SYSDATE),
                                pr_flgtrans => 1,
                                pr_hrtransa => gene0002.fn_busca_time,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => rg_crapass.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                              
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.cdagenci',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => rg_crapass.cdagenci);
                                  
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.cdbccxlt',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vc_cdbccxlt);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.nrdolote',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vc_nrdolote_lanc);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.nrdctabb',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => rg_crapass.nrdconta);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.nrdocmto',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vr_nrdocmto);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.dtmvtolt',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vr_dtmvtolt);
      
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'craplcm.vllanmto',
                                     pr_dsdadant => null,
                                     pr_dsdadatu => vr_vlsddisp);
                                  
  END IF;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'ERRO SCRIPT: '||SQLERRM);
END;    
