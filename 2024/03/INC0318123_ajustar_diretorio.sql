BEGIN
  UPDATE crapscb t
     SET t.dsdirarq = TRIM(t.dsdirarq)
   WHERE t.tparquiv = 9;

  COMMIT;
END;
