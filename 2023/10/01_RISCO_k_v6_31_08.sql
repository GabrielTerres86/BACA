DECLARE
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtrefere_ris     VARCHAR2(20) := '31/08/2023';
  
  vr_cdprogra VARCHAR2(50) := 'RelatoContabParalelo';
  vr_dsplsql  VARCHAR2(4000);
  vr_jobname  VARCHAR2(4000);
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND a.cdcooper IN (2,3,5,6,7,8,9,10,11,12,13,14);
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN
  
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    vr_jobname := 'gera_relato_' || to_char(rw_crapcop.cdcooper) || '_K';
    vr_dsplsql := 'DECLARE' || chr(13) ||
                        '  wvr_retfile  VARCHAR2(500);' || chr(13) ||
                        '  wpr_dscritic VARCHAR2(1500);' || chr(13) ||
                        'BEGIN' || chr(13) ||
                        '  CECRED.RISC0001_NOVA_CENTRAL.pc_risco_k(pr_cdcooper => ' || rw_crapcop.cdcooper || chr(13) ||
                                                                 ',pr_dtrefere => ''' || vr_dtrefere_ris || '''' || chr(13) ||
                                                                 ',pr_retfile  => wvr_retfile' || chr(13) ||
                                                                 ',pr_dscritic => wpr_dscritic);' || chr(13) ||
                  'END;';
    
    cecred.gene0001.pc_submit_job(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdprogra => vr_cdprogra        
                                 ,pr_dsplsql  => vr_dsplsql         
                                 ,pr_dthrexe  => SYSTIMESTAMP       
                                 ,pr_interva  => NULL               
                                 ,pr_jobname  => vr_jobname         
                                 ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT null THEN
      vr_dscritic := vr_dscritic || ' - ' || vr_jobname;
      RAISE vr_exc_erro;
    END IF;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
