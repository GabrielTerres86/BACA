BEGIN
  
  UPDATE CECRED.CRAPPFP PFP SET PFP.flsitcre = 0
   WHERE PFP.dtcredit >= TO_DATE('21/08/2024', 'DD/MM/YYYY')
     AND PFP.idsitapr  > 3
     AND PFP.flsitdeb  = 1
     AND PFP.flsitcre  = 1
     AND EXISTS(SELECT 1
                  FROM craplfp lfp
                 WHERE pfp.cdcooper = lfp.cdcooper
                   AND pfp.cdempres = lfp.cdempres
                   AND pfp.nrseqpag = lfp.nrseqpag
                   AND lfp.idsitlct = 'L'
                   AND lfp.vllancto > 0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;