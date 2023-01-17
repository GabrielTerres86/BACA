BEGIN
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 14729253 AND nrctremp = 198365;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 14646692 AND nrctremp = 203874;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 15201015 AND nrctremp = 221505;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 14376229 AND nrctremp = 186257;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 665843 AND nrctremp = 192455;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 689971 AND nrctremp = 181475;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 696544 AND nrctremp = 185931;
  DELETE cecred.crapebn WHERE cdcooper = 13 AND nrdconta = 413402 AND nrctremp = 208327;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
