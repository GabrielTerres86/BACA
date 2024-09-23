DECLARE
  vr_dscritic VARCHAR2(4000);
  vr_cdcritic INTEGER;
  vr_exc_erro EXCEPTION;
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1 
       AND c.cdcooper = 8;
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    gestaoderisco.geraCargaCentral(pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_flgexadp => TRUE
                                  ,pr_dtrefere => to_date('18/09/2024', 'DD/MM/RRRR')
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    COMMIT;
  END LOOP;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
