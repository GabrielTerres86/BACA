DECLARE
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtrefere_ris     VARCHAR2(50) := '30/09/2023';
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
     AND a.cdcooper IN (2,3,5,6,7,8,9,10,11,12,13,14);
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN
  
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  
  FOR rw_crapcop IN cr_crapcop LOOP
  
    CECRED.RISC0001_NOVA_CENTRAL.pc_risco_t(pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_dtrefere => vr_dtrefere_ris
                                           ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    CECRED.RISC0001_NOVA_CENTRAL.pc_risco_g(pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_dtrefere => vr_dtrefere_ris
                                           ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
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
