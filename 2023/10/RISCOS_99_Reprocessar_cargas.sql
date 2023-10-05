DECLARE
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtrefere         VARCHAR2(20) := '01/10/2023';
  vr_dtrefere_ris     VARCHAR2(20) := '30/09/2023';
  
  vr_cdprogra VARCHAR2(50) := 'RelatoContabParalelo';
  vr_dsplsql  VARCHAR2(4000);
  vr_jobname  VARCHAR2(4000);
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN


  FOR rw_crapcop IN cr_crapcop LOOP

    IF vr_dscritic IS NOT null THEN
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
