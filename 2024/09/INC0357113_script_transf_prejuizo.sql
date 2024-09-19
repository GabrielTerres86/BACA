DECLARE
  vr_registros      cecred.GENE0002.typ_split;
  vr_aux_reg        cecred.GENE0002.typ_split;
  vr_indexreg       INTEGER;
  vr_cdcooper       crapcop.cdcooper%TYPE;
  vr_progress_recid crapass.progress_recid%TYPE;  
  vr_nrborder       crapbdt.nrborder%TYPE;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_cdcritic       crapcri.cdcritic%TYPE;
  vr_nrdrowid       ROWID;

  
  CURSOR cr_crapass(pr_cdcooper       IN cecred.crapass.cdcooper%TYPE,
                    pr_nrborder       IN cecred.crapbdt.nrborder%TYPE
                   ,pr_progress_recid IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta
      FROM cecred.crapass a,
           cecred.crapbdt b
     WHERE a.cdcooper = b.cdcooper
       AND b.nrborder = pr_nrborder
       AND a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress_recid;
  rw_crapass cr_crapass%ROWTYPE;
    
  
BEGIN 
  vr_registros := cecred.GENE0002.fn_quebra_string(pr_string  =>
'6;1061612;24410|' ||
'6;1061612;24496|' ||
'6;1061612;24375|' ||
'6;1061612;24141|' ||
'6;1061612;23828|' ||
'6;1061612;23766|' ||
'6;1061612;24437|' ||
'6;1061612;23598|' ||
'6;1061612;23722|' ||
'6;1061612;23640|' ||
'6;1061612;24024|' ||
'6;1061612;23778|' ||
'6;1061612;23813|' ||
'6;1061612;24302|' ||
'6;1061612;24275|'
,pr_delimit => '|');


  FOR vr_indexreg IN 1..(vr_registros.COUNT-1) LOOP  
    
      vr_aux_reg := gene0002.fn_quebra_string(vr_registros(vr_indexreg),';');                                                                                          

      vr_cdcooper       := vr_aux_reg(1);
      vr_progress_recid := vr_aux_reg(2);
      vr_nrborder       := vr_aux_reg(3);

      OPEN cr_crapass(pr_cdcooper       => vr_cdcooper
                     ,pr_nrborder       => vr_nrborder
                     ,pr_progress_recid => vr_progress_recid);
      FETCH cr_crapass
       INTO rw_crapass;
          IF cr_crapass%FOUND THEN
            
             PREJ0005.pc_transferir_prejuizo(pr_cdcooper => vr_cdcooper
                                            ,pr_nrborder => vr_nrborder
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

             IF (NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
 
               GENE0001.pc_gera_log(pr_cdcooper =>  vr_cdcooper
                                   ,pr_cdoperad => '1'
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                   ,pr_dstransa => 'Erro ao transferir bordero para prejuizo - bordero:' || vr_nrborder
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 1
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => 'Script'
                                   ,pr_nrdconta => rw_crapass.nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
                                 
             END IF;

          END IF;
      
      CLOSE cr_crapass;   
      COMMIT;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    Raise_Application_Error(-20002, 'Erro Geral no Script. Erro: ' || sqlerrm);
END;
