BEGIN
  delete crapatr atr where atr.cdcooper = 1 and atr.nrdconta = 3596559  and atr.cdhistor = 2074;
  COMMIT;
END;