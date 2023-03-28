BEGIN

  --insere para liberar o  DA do convenio UNIMED  para as cooperativas
  INSERT   INTO CECRED.TBCONV_LIBERACAO(TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
  SELECT 3, coop.cdcooper, 0, 248, 1 FROM CECRED.crapcop coop;

  ----insere para liberar o  DA do convenio CERBRANORTE  para as cooperativas
  INSERT   INTO CECRED.TBCONV_LIBERACAO(TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
  SELECT 3, coop.cdcooper, 0, 246, 1 FROM CECRED.crapcop coop;

  COMMIT;
END;	