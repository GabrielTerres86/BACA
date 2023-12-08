DECLARE 
  vr_nrdrowid        ROWID;
  vr_nmprograma      CECRED.tbgen_prglog.cdprograma%TYPE := 'Remover Progamas Batch - RITM745552'; 
  vr_next_nrordprg   CECRED.crapprg.nrordprg%TYPE := 0;
   
  CURSOR cr_crapprg IS
    SELECT prg.cdprogra
          ,prg.nrsolici
          ,prg.nrordprg
          ,prg.inlibprg
          ,prg.cdcooper
          ,prg.progress_recid
      FROM CECRED.crapprg prg
     WHERE prg.cdprogra IN ('CRPS375', 'CRPS594', 'CRPS595', 'CRPS613');
BEGIN
  BEGIN
    SELECT MAX(prg.nrordprg)
      INTO vr_next_nrordprg
      FROM CECRED.crapprg prg;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CECRED.pc_internal_exception(pr_cdcooper => 0
                                  ,pr_compleme => ' Script: => ' || vr_nmprograma ||
                                                  ' Etapa: 1 - Nao foi encontrado o valor maximo crapprg.nrordprg'); 
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 0
                                  ,pr_compleme => ' Script: => ' || vr_nmprograma ||
                                                  ' Etapa: 1 - Selecionar o valor maximo crapprg.nrordprg');  
  END;
    
  FOR rw_crapprg IN cr_crapprg LOOP
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_crapprg.cdcooper
                               ,pr_nrdconta => rw_crapprg.progress_recid
                               ,pr_idseqttl => 0
                               ,pr_cdoperad => 't0035324'
                               ,pr_dscritic => 'Valores antes do UPDATE salvos com sucesso.'
                               ,pr_dsorigem => 'COBRANCA'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'RITM745552'
                               ,pr_nrdrowid => vr_nrdrowid);
                  
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapprg.nrsolici'
                                    ,pr_dsdadant => rw_crapprg.nrsolici
                                    ,pr_dsdadatu => NULL);
                                    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapprg.nrordprg'
                                    ,pr_dsdadant => rw_crapprg.nrordprg
                                    ,pr_dsdadatu => NULL);
                                  
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapprg.inlibprg'
                                    ,pr_dsdadant => rw_crapprg.inlibprg
                                    ,pr_dsdadatu => NULL);
                                    
    vr_next_nrordprg := vr_next_nrordprg + 1;
     
    UPDATE CECRED.crapprg prg
       SET prg.nrordprg = vr_next_nrordprg
     WHERE prg.progress_recid = rw_crapprg.progress_recid;
  END LOOP;

  UPDATE CECRED.crapprg prg
     SET prg.inlibprg = 2
   WHERE prg.cdprogra IN ('CRPS375', 'CRPS594', 'CRPS595', 'CRPS613');

  UPDATE CECRED.crapprg prg
     SET prg.nrsolici = 9001
   WHERE prg.cdprogra IN ('CRPS375', 'CRPS594', 'CRPS595');
   
  UPDATE CECRED.crapprg prg
     SET prg.nrsolici = 9002
   WHERE prg.cdprogra = 'CRPS613';
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => ' Script: => ' || vr_nmprograma ||
                                                ' Etapa: 2 - Update crapprg ');   
END;
