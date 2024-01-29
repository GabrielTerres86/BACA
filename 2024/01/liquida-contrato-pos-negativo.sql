DECLARE
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN  BTCH0001.cr_crapdat(pr_cdcooper => 1);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE (cdcooper, nrdconta, nrctremp) IN (
          (10, 129305, 31003)
         ,(1, 4063562, 3425190)
       );

  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0,
         qtprepag = qtpreemp,
         dtliquid = rw_crapdat.dtmvtolt
   WHERE (cdcooper, nrdconta, nrctremp) IN (
          (10, 129305, 31003)
         ,(1, 4063562, 3425190)
       );

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
