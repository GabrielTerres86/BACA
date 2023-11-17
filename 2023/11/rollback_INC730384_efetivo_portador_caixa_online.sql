DECLARE  
  vr_nrdrowid  ROWID;
  vr_exc_erro  EXCEPTION;
  vr_dstransa  CECRED.craplgm.dstransa%TYPE := 'Alterar Valor Pgto Portador INC730384';

  CURSOR cr_lgi IS
   SELECT lgi.dsdadant
     FROM craplgi lgi
         ,craplgm lgm
    WHERE lgi.cdcooper = 0
      AND lgi.nrdconta = 0
      AND lgi.idseqttl = 0
      AND lgi.nmdcampo = 'crapprm.dsvlrprm'
      AND lgm.dstransa = vr_dstransa
      AND lgm.cdoperad = 't0035324'
      AND lgm.flgtrans = 1
      AND lgm.nmdatela = 'SCRIPT ADHOC'
      AND lgm.dsorigem = 'CAIXAONLINE';
      rw_lgi cr_lgi%ROWTYPE;
BEGIN
  OPEN cr_lgi;
  FETCH cr_lgi INTO rw_lgi;
  
  IF cr_lgi%NOTFOUND THEN
    RAISE vr_exc_erro;
    CLOSE cr_lgi;
  END IF;
  
  CLOSE cr_lgi;
  
  UPDATE CECRED.crapprm prm
    SET prm.dsvlrprm = rw_lgi.dsdadant
  WHERE UPPER(prm.cdacesso) = UPPER('VL_PAGAMENTOPORTADOR')
    AND prm.cdcooper = 0
    AND prm.nmsistem = 'CRED';
      
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => 0
                             ,pr_nrdconta => 0
                             ,pr_idseqttl => 0
                             ,pr_cdoperad => 't0035324'
                             ,pr_dscritic => 'Registro revertido com sucesso.'
                             ,pr_dsorigem => 'CAIXAONLINE'
                             ,pr_dstransa => vr_dstransa
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                             ,pr_nmdatela => 'ROLLBACK SCR'
                             ,pr_nrdrowid => vr_nrdrowid);
  COMMIT;
EXCEPTION 
  WHEN vr_exc_erro THEN
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => 0
                               ,pr_nrdconta => 0
                               ,pr_idseqttl => 0
                               ,pr_cdoperad => 't0035324'
                               ,pr_dscritic => 'Valor do campo craplgi.dsdadant nao encontrado.'
                               ,pr_dsorigem => 'CAIXAONLINE'
                               ,pr_dstransa => vr_dstransa
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'ROLLBACK SCR'
                               ,pr_nrdrowid => vr_nrdrowid);
    
  WHEN OTHERS THEN
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => ' Erro nao tratado - Script Rollback: => ' || vr_dstransa);
    ROLLBACK;
END;
