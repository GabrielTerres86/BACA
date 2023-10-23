DECLARE
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtrefere         DATE := to_date('02/10/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,16);
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP

    CECRED.gerarRelatoriosContabeisTbriscoRis(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_dtrefere => vr_dtrefere
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    BEGIN
        DELETE FROM craprej
         WHERE craprej.cdcooper = rw_crapcop.cdcooper
           AND craprej.cdpesqbb = 'CRPS249'
           AND craprej.dtmvtolt = to_date('29/09/2023', 'DD/MM/RRRR');
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' registros de despesa Sicredi: '||sqlerrm;
        RAISE vr_exc_erro;
    END;
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
