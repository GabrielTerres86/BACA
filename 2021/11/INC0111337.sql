BEGIN
  -- CREDCREA

INSERT INTO tbcrd_expurgo (
       cdcooper, 
       nrcrcard,
       nrcctitg,
       instatus
) (
  SELECT C.CDCOOPER, C.NRCRCARD, C.NRCCTITG, 'PENDENTE' 
  FROM CRAWCRD C
  WHERE C.NRCCTITG = 7564416007705 );
 
  COMMIT;
END;
