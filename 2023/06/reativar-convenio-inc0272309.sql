BEGIN
  UPDATE cecred.crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.cdcooper = 1
    AND atr.nrdconta = 14934566
    AND atr.cdhistor = 2074
    AND atr.cdrefere = 930427031729;

  COMMIT;
END;
