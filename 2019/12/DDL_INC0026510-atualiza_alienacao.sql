--INC0026510
--Ana Volles - 03/12/2019
/*SELECT a.nrdconta, a.nrctrpro, a.flgalfid, a.flginclu, a.cdsitgrv, a.flgalien, a.flgalter, a.tpinclus, a.nrgravam, a.tpinclus, a.dtatugrv, a.dsjstinc, a.cdoperad, a.dscatbem, 
a.dsjstinc, a.tpctrpro, a.dtvigseg, a.* FROM CRAPBPR a 
WHERE (a.cdcooper = 14 AND a.nrdconta = 75051 AND a.nrctrpro = 7984 AND a.nrgravam = 12082164);
*/

BEGIN
  UPDATE crapbpr a
  SET    a.flgalfid = 1
  WHERE  a.cdcooper = 14
  AND    a.nrdconta = 75051
  AND    a.nrctrpro = 7984
  AND    a.nrgravam = 12082164;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
