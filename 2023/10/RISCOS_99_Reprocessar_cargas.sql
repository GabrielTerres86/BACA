DECLARE
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;

  vr_dtrefere         VARCHAR2(20) := '30/09/2023';

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP


    GESTAODERISCO.geraCargaCentral(pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_flggarpr => TRUE
                                  ,pr_dtrefere => vr_dtrefere
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic  := NULL; 
      vr_dscritic  := NULL;
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
