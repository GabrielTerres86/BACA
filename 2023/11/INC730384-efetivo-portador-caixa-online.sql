DECLARE 
  vr_nrdrowid            ROWID;
  vr_dstransa            CECRED.craplgm.dstransa%TYPE := 'Alterar Valor Pgto Portador INC730384';
  vr_vl_pgto_portador    CECRED.crapprm.dsvlrprm%TYPE := 200001;
  vr_exc_erro            EXCEPTION;
  
  CURSOR cr_crapprm IS
   SELECT prm.dsvlrprm
     FROM CECRED.crapprm prm
    WHERE UPPER(prm.cdacesso) = UPPER('VL_PAGAMENTOPORTADOR')
      AND prm.cdcooper = 0
      AND prm.nmsistem = 'CRED';
   rw_crapprm cr_crapprm%ROWTYPE;
BEGIN
  OPEN cr_crapprm;
  FETCH cr_crapprm INTO rw_crapprm;
  
  IF cr_crapprm%NOTFOUND THEN
    RAISE vr_exc_erro;
    CLOSE cr_crapprm;
  END IF;
  
  CLOSE cr_crapprm;
  
  UPDATE CECRED.crapprm prm
     SET prm.dsvlrprm = vr_vl_pgto_portador
   WHERE UPPER(prm.cdacesso) = UPPER('VL_PAGAMENTOPORTADOR')
     AND prm.cdcooper = 0
     AND prm.nmsistem = 'CRED';
 
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => 0
                             ,pr_nrdconta => 0
                             ,pr_idseqttl => 0
                             ,pr_cdoperad => 't0035324'
                             ,pr_dscritic => 'Registro alterado com sucesso.'
                             ,pr_dsorigem => 'CAIXAONLINE'
                             ,pr_dstransa => vr_dstransa
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                             ,pr_nmdatela => 'SCRIPT ADHOC'
                             ,pr_nrdrowid => vr_nrdrowid);
                
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'crapprm.dsvlrprm'
                                  ,pr_dsdadant => rw_crapprm.dsvlrprm
                                  ,pr_dsdadatu => vr_vl_pgto_portador); 
  COMMIT;
EXCEPTION 
  WHEN vr_exc_erro THEN
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => 0
                               ,pr_nrdconta => 0
                               ,pr_idseqttl => 0
                               ,pr_cdoperad => 't0035324'
                               ,pr_dscritic => 'Valor do campo crapprm.dsvlrprm nao encontrado.'
                               ,pr_dsorigem => 'CAIXAONLINE'
                               ,pr_dstransa => vr_dstransa
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'SCRIPT ADHOC'
                               ,pr_nrdrowid => vr_nrdrowid);
    
  WHEN OTHERS THEN
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => ' Erro nao tratado - Script: => ' || vr_dstransa);
    ROLLBACK;
END;
