DECLARE
  
  CURSOR cr_contas IS
    SELECT t.cdcooper
         , t.nrdconta
      FROM crapass  t
     WHERE t.dtdemiss IS NOT NULL 
       AND t.idastcjt = 1
       AND EXISTS (SELECT 1 
                     FROM crapopi o 
                    WHERE o.cdcooper = t.cdcooper 
                      AND o.nrdconta = t.nrdconta 
                      AND o.flgsitop = 1);
  
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
  
  vc_dstransa    CONSTANT VARCHAR2(4000) := 'Cancelar acesso operadores de conta demitida - INC0215694';
  
  vr_dttransa    cecred.craplgm.dttransa%TYPE := TRUNC(SYSDATE);
  vr_hrtransa    cecred.craplgm.hrtransa%TYPE := CECRED.GENE0002.fn_busca_time;
  vr_dscritic    VARCHAR2(2000);
  vr_nrdrowid    ROWID;
  
BEGIN
  
  FOR conta IN cr_contas LOOP     
  
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
                                 ,pr_dstransa => vc_dstransa
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
  
  COMMIT;
  
END;
