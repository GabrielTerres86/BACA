BEGIN
  UPDATE CRAWEPR SET CDORIGEM = 3, NRSIMULA = 1, NRSEQRRQ = NULL, DTLIBERA = TO_DATE ('31/08/2021', 'dd/mm/yyyy')
  WHERE CDCOOPER = 2
  AND NRDCONTA IN (931250,931250,776971,776971,855715,855715,976733,976733,868205,868205,784532,784532,712183,712183,909572,909572,624101,624101,264431,264431)
  AND CDLCREMP = 10701
  AND CDFINEMP = 64
  AND CDORIGEM = 5;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
BEGIN
  UPDATE CRAWEPR SET CDORIGEM = 3, NRSIMULA = 1, NRSEQRRQ = NULL, DTLIBERA = TO_DATE ('31/08/2021', 'dd/mm/yyyy')
  WHERE CDCOOPER = 1
  AND NRDCONTA IN (7095040,7095040,3097846,3097846,3555372,3555372,7743033,7743033,3010449,3010449,11402873,11402873,2719630,2719630,8425884,8425884,7432070,7432070,11035137,11035137)
  AND CDLCREMP = 10701
  AND CDFINEMP = 64
  AND CDORIGEM = 5;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;