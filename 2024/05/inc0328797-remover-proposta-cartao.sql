DECLARE 
  vr_nrdrowid       ROWID;
BEGIN

  BEGIN
    DELETE cecred.crawcrd t
     WHERE t.cdcooper = 5
       AND t.nrdconta = 17323622
       AND t.cdadmcrd IS NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao excluir proposta cartao: '||SQLERRM);
  END;
  
  vr_nrdrowid := NULL;
        
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => 5
                             ,pr_cdoperad => 1
                             ,pr_dscritic => NULL
                             ,pr_dsorigem => 'AIMARO'
                             ,pr_dstransa => 'Exclusao proposta de cartao de credito'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                             ,pr_idseqttl => 0
                             ,pr_nmdatela => NULL
                             ,pr_nrdconta => 17323622
                             ,pr_nrdrowid => vr_nrdrowid);
        
  COMMIT;
END;
