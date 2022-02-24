DECLARE
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;
BEGIN

  SELECT dtmvtolt INTO vr_dtmvtolt FROM crapdat WHERE cdcooper = 9;
  
  UPDATE crapepr SET inliquid = 1, dtliquid = vr_dtmvtolt WHERE cdcooper = 9 AND nrdconta = 501220 AND nrctremp = 20000341;
  UPDATE crapepr SET inliquid = 1, dtliquid = vr_dtmvtolt WHERE cdcooper = 9 AND nrdconta = 503657 AND nrctremp = 20100328;
  UPDATE crapepr SET inliquid = 1, dtliquid = vr_dtmvtolt WHERE cdcooper = 9 AND nrdconta = 504300 AND nrctremp = 19100665;
  UPDATE crapepr SET inliquid = 1, dtliquid = vr_dtmvtolt WHERE cdcooper = 9 AND nrdconta = 506591 AND nrctremp = 20200023;
  UPDATE crapepr SET inliquid = 1, dtliquid = vr_dtmvtolt WHERE cdcooper = 9 AND nrdconta = 516236 AND nrctremp = 20000568;
  UPDATE crapepr SET inliquid = 1, dtliquid = vr_dtmvtolt WHERE cdcooper = 9 AND nrdconta = 519952 AND nrctremp = 20100075;
  
  COMMIT;
END;
