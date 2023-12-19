DECLARE 
  vr_nrdrowid        ROWID;
  vr_nmprograma      CECRED.tbgen_prglog.cdprograma%TYPE := 'Salarios nao creditados - PRB0048645';
  
  CURSOR cr_craptab(pr_cdempres IN CECRED.craptab.cdempres%TYPE) IS 
   SELECT *
     FROM CECRED.craptab tab
    WHERE tab.cdempres = pr_cdempres
      AND tab.cdacesso = 'VLTARIF008'
      AND tab.cdcooper = 12;
   rw_craptab cr_craptab%ROWTYPE;
  
BEGIN 
  OPEN cr_craptab (pr_cdempres => 441);
  FETCH cr_craptab INTO rw_craptab;
  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_craptab.cdcooper
                             ,pr_nrdconta => rw_craptab.cdempres
                             ,pr_idseqttl => 1
                             ,pr_cdoperad => 't0035324'
                             ,pr_dscritic => 'Registro atualizado com sucesso.'
                             ,pr_dsorigem => 'PAGTO'
                             ,pr_dstransa => vr_nmprograma
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                             ,pr_nmdatela => 'PRB0048645'
                             ,pr_nrdrowid => vr_nrdrowid);
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.nmsistem'
                                  ,pr_dsdadant => rw_craptab.nmsistem
                                  ,pr_dsdadatu => NULL);    
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.tptabela'
                                  ,pr_dsdadant => rw_craptab.tptabela
                                  ,pr_dsdadatu => NULL);
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.cdempres'
                                  ,pr_dsdadant => rw_craptab.cdempres
                                  ,pr_dsdadatu => NULL);
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.cdacesso'
                                  ,pr_dsdadant => rw_craptab.cdacesso
                                  ,pr_dsdadatu => NULL);
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.tpregist'
                                  ,pr_dsdadant => rw_craptab.tpregist
                                  ,pr_dsdadatu => NULL);
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.dstextab'
                                  ,pr_dsdadant => rw_craptab.dstextab
                                  ,pr_dsdadatu => NULL);
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'craptab.cdcooper'
                                  ,pr_dsdadant => rw_craptab.cdcooper
                                  ,pr_dsdadatu => NULL);
  CLOSE cr_craptab;

  DELETE FROM CECRED.craptab tab
   WHERE tab.cdempres = 441
     AND tab.cdacesso = 'VLTARIF008'
     AND tab.cdcooper = 12;
     
  OPEN cr_craptab (pr_cdempres => 442);
  FETCH cr_craptab INTO rw_craptab;
  
  INSERT INTO CECRED.craptab
    (nmsistem
    ,tptabela
    ,cdempres
    ,cdacesso
    ,tpregist
    ,dstextab
    ,cdcooper)
  VALUES
    (rw_craptab.nmsistem
    ,rw_craptab.tptabela
    ,441
    ,rw_craptab.cdacesso
    ,rw_craptab.tpregist
    ,rw_craptab.dstextab
    ,rw_craptab.cdcooper);
    
  CLOSE cr_craptab;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  CECRED.pc_internal_exception(pr_cdcooper => 0
                              ,pr_compleme => ' Script: => ' || vr_nmprograma );   
END;
