BEGIN
 UPDATE crapcje 
    SET crapcje.tpcttrab = 1, 
    crapcje.nmextemp = 'ESTADO DE SANTA CATARINA', 
    crapcje.nrdocnpj = 0,
    crapcje.DSPROFTL = 'PROFESSOR', 
    crapcje.CDNVLCGO = 5, 
    crapcje.CDTURNOS = 1, 
    crapcje.DTADMEMP = '02/02/2018', 
    crapcje.VLSALARI = 2000.04, 
    crapcje.nrramemp = 0
 WHERE crapcje.cdcooper = 16 
   AND crapcje.nrdconta = 491314;
  IF SQL%ROWCOUNT = 1 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
    