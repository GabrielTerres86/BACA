DECLARE
  
  vr_dtrefere_ris     DATE := to_date('30/11/2023', 'DD/MM/RRRR');
  vr_dscritic         VARCHAR2(4000);  
  vr_exc_erro         EXCEPTION;  
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    cecred.risc0001_nova_central.gerarRelatorioCompensacaoMicrocredito(pr_cdcooper => rw_crapcop.cdcooper
                                                                      ,pr_dtrefere => vr_dtrefere_ris
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
    raise_application_error(-20000, SQLERRM);
END;