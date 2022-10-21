DECLARE
  
  CURSOR cr_contas_opi IS
    SELECT t.cdcooper
         , t.nrdconta
      FROM crapass  t
     WHERE t.dtdemiss IS NOT NULL 
       AND EXISTS (SELECT 1 
                     FROM crapopi o 
                    WHERE o.cdcooper = t.cdcooper 
                      AND o.nrdconta = t.nrdconta 
                      AND o.flgsitop = 1);
  
  CURSOR cr_contas_snh IS
    SELECT t.cdcooper
         , t.nrdconta
         , t.idastcjt
      FROM crapass  t
     WHERE t.dtdemiss IS NOT NULL 
       AND EXISTS (SELECT 1 
                     FROM crapsnh s 
                    WHERE s.cdcooper = t.cdcooper 
                      AND s.nrdconta = t.nrdconta 
                      AND s.cdsitsnh = 1
                      AND s.tpdsenha = 1);
  
  CURSOR cr_operad(pr_cdcooper NUMBER
                  ,pr_nrdconta NUMBER) IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.nrcpfope
      FROM crapopi t 
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.flgsitop = 1;
  
  CURSOR cr_senha(pr_cdcooper NUMBER
                 ,pr_nrdconta NUMBER) IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.idseqttl
         , t.cdsitsnh
         , t.dtaltsit
         , t.cdoperad
         , t.nrcpfcgc
         , t.cddsenha
         , t.dssenweb
         , t.flgbolet
         , t.vllbolet
         , t.vllimweb
         , t.vllimtrf
         , t.vllimpgo
         , t.vllimted
      FROM crapsnh t 
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.tpdsenha = 1
       AND t.cdsitsnh = 1;
  
  vc_dstransa_opi    CONSTANT VARCHAR2(4000) := 'Cancelar acesso operadores de conta demitida - INC0215694';
  vc_dstransa_snh    CONSTANT VARCHAR2(4000) := 'Cancelar as senhas de conta demitida - INC0215694';
  
  vr_dttransa    cecred.craplgm.dttransa%TYPE := TRUNC(SYSDATE);
  vr_hrtransa    cecred.craplgm.hrtransa%TYPE := CECRED.GENE0002.fn_busca_time;
  vr_dscritic    VARCHAR2(2000);
  vr_nrdrowid    ROWID;
  
BEGIN
  
  FOR conta IN cr_contas_opi LOOP     
  
    FOR operad IN cr_operad(conta.cdcooper, conta.nrdconta) LOOP
      
      BEGIN
        UPDATE crapopi t
           SET t.flgsitop = 0 
         WHERE ROWID = operad.dsdrowid;
      EXCEPTION 
        WHEN OTHERS THEN
          ROLLBACK;
          raise_application_error(-20000,'Erro ao atualizar CRAPOPI: '||SQLERRM);
      END;
      
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                                 ,pr_cdoperad => '1'
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_dsorigem => 'AIMARO'
                                 ,pr_dstransa => vc_dstransa_opi
                                 ,pr_dttransa => vr_dttransa
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => vr_hrtransa
                                 ,pr_idseqttl => 0
                                 ,pr_nmdatela => NULL
                                 ,pr_nrdconta => conta.nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapopi.nrcpfope'
                                      ,pr_dsdadant => operad.nrcpfope
                                      ,pr_dsdadatu => operad.nrcpfope);
      
    END LOOP;
  END LOOP;
  
  
  FOR conta IN cr_contas_snh LOOP     
  
    FOR senha IN cr_senha(conta.cdcooper, conta.nrdconta) LOOP
      
      BEGIN
        UPDATE crapsnh
           SET crapsnh.cdsitsnh = 3
              ,crapsnh.dtaltsit = vr_dttransa
              ,crapsnh.cdoperad = '1'
              ,crapsnh.nrcpfcgc = (CASE conta.idastcjt WHEN 0 THEN 0 ELSE crapsnh.nrcpfcgc END)
              ,crapsnh.cddsenha = ''
              ,crapsnh.dssenweb = ''
              ,crapsnh.flgbolet = 0
              ,crapsnh.vllbolet = 0
              ,crapsnh.vllimweb = 0
              ,crapsnh.vllimtrf = 0
              ,crapsnh.vllimpgo = 0
              ,crapsnh.vllimted = 0
        WHERE ROWID = senha.dsdrowid;
      EXCEPTION 
        WHEN OTHERS THEN
          ROLLBACK;
          raise_application_error(-20000,'Erro ao atualizar CRAPSNH: '||SQLERRM);
      END;
      
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                                 ,pr_cdoperad => '1'
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_dsorigem => 'AIMARO'
                                 ,pr_dstransa => vc_dstransa_snh
                                 ,pr_dttransa => vr_dttransa
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => vr_hrtransa
                                 ,pr_idseqttl => senha.idseqttl
                                 ,pr_nmdatela => NULL
                                 ,pr_nrdconta => conta.nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.cdsitsnh'
                                      ,pr_dsdadant => senha.cdsitsnh
                                      ,pr_dsdadatu => 3);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.dtaltsit'
                                      ,pr_dsdadant => senha.dtaltsit
                                      ,pr_dsdadatu => to_char(vr_dttransa,'dd/mm/rrrr'));
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.cdoperad'
                                      ,pr_dsdadant => senha.cdoperad
                                      ,pr_dsdadatu => '1');
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.nrcpfcgc'
                                      ,pr_dsdadant => senha.nrcpfcgc
                                      ,pr_dsdadatu => (CASE conta.idastcjt WHEN 0 THEN 0 ELSE senha.nrcpfcgc END));
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.cddsenha'
                                      ,pr_dsdadant => senha.cddsenha
                                      ,pr_dsdadatu => '');
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.dssenweb'
                                      ,pr_dsdadant => senha.dssenweb
                                      ,pr_dsdadatu => '');
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.flgbolet'
                                      ,pr_dsdadant => senha.flgbolet
                                      ,pr_dsdadatu => 0);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.vllbolet'
                                      ,pr_dsdadant => senha.vllbolet
                                      ,pr_dsdadatu => 0);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.vllimweb'
                                      ,pr_dsdadant => senha.vllimweb
                                      ,pr_dsdadatu => 0);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.vllimtrf'
                                      ,pr_dsdadant => senha.vllimtrf
                                      ,pr_dsdadatu => 0);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.vllimpgo'
                                      ,pr_dsdadant => senha.vllimpgo
                                      ,pr_dsdadatu => 0);
                             
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'crapsnh.vllimted'
                                      ,pr_dsdadant => senha.vllimted
                                      ,pr_dsdadatu => 0);
                                      
      
    END LOOP;
  END LOOP;
  
  COMMIT;
  
END;
