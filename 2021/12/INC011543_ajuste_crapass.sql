DECLARE
  vr_cdcooper  craplim.cdcooper%TYPE := 5;
  vr_nrdconta  craplim.nrdconta%TYPE := 198170;
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;

  UPDATE CECRED.crapass ass
     SET ass.vllimcre = 0
        ,ass.tplimcre = 2
        ,ass.dtultlcr = rw_crapdat.dtmvtolt
   WHERE ass.cdcooper = vr_cdcooper
     AND ass.nrdconta = vr_nrdconta;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
