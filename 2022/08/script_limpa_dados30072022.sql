DECLARE
      vr_dtprox     crapdat.dtmvtolt%TYPE;
      vr_exc_erro   exception;
      vr_cdcritic  PLS_INTEGER;
      vr_dscritic  VARCHAR2(300);     

      CURSOR cr_crapprm IS
        SELECT t.cdacesso
              ,t.dsvlrprm
          FROM crapprm t
         WHERE t.cdacesso LIKE 'CTRL_%'
           AND t.cdacesso NOT IN ('CTRL_ERRO_PRG_DEBITADOR')
           AND t.cdcooper = 16;

     pr_cdcooper number(2) := 16;
     pr_dtmvtolt date := to_date('30/07/2022','dd/mm/yyyy'); 	 
		   
BEGIN
      
      BEGIN 
        DELETE FROM crapris t WHERE t.cdcooper = pr_cdcooper AND t.dtrefere = pr_dtmvtolt;
        DELETE FROM crapvri t WHERE t.cdcooper = pr_cdcooper AND t.dtrefere = pr_dtmvtolt;
        DELETE FROM crapsda t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;
        DELETE FROM craplem t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;
        DELETE FROM craplcm t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;
        DELETE FROM tbgen_batch_controle t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;

        FOR rw_crapprm IN cr_crapprm LOOP
          UPDATE crapprm 
             SET dsvlrprm = to_char(pr_dtmvtolt - 1,'dd/mm/yyyy') || '#1'
           WHERE cdcooper = pr_cdcooper
             AND cdacesso = rw_crapprm.cdacesso;
        END LOOP;

        COMMIT;
      END;
      
      pr_dtmvtolt := to_date('29/07/2022','dd/mm/yyyy'); 	 
      BEGIN 
        DELETE FROM crapris t WHERE t.cdcooper = pr_cdcooper AND t.dtrefere = pr_dtmvtolt;
        DELETE FROM crapvri t WHERE t.cdcooper = pr_cdcooper AND t.dtrefere = pr_dtmvtolt;
        DELETE FROM crapsda t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;
        DELETE FROM craplem t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;
        DELETE FROM craplcm t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;
        DELETE FROM tbgen_batch_controle t WHERE t.cdcooper = pr_cdcooper AND t.dtmvtolt = pr_dtmvtolt;

        FOR rw_crapprm IN cr_crapprm LOOP
          UPDATE crapprm 
             SET dsvlrprm = to_char(pr_dtmvtolt - 1,'dd/mm/yyyy') || '#1'
           WHERE cdcooper = pr_cdcooper
             AND cdacesso = rw_crapprm.cdacesso;
        END LOOP;

        COMMIT;
      END;
      
      UTIL_BATCH.pc_muda_data(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => pr_dtmvtolt,
                              pr_dtmvtopr => vr_dtprox,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
