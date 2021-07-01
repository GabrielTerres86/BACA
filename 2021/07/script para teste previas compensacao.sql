DECLARE 
  CURSOR c1 IS
    SELECT *
      FROM  craptit t
     WHERE t.cdcooper IN(6,13,16)
       AND t.dtdpagto = '20/05/2021' 
       AND t.insittit = 4
       AND t.idanafrd IS NOT NULL;
BEGIN
  FOR r1 IN c1 LOOP
    UPDATE tbgen_analise_fraude t
       SET t.cdparecer_analise = 1
     WHERE t.idanalise_fraude = r1.idanafrd;
  END LOOP;
  --
  UPDATE craptit t
     SET t.dtdpagto = '01/07/2021',
         t.dtmvtolt = '01/07/2021',
         t.flgenvio = 0,
         t.cdbcoenv = 0
  WHERE t.cdcooper IN(6,13,16)
    AND t.dtdpagto = '20/05/2021' 
    AND t.insittit = 4
    AND t.idanafrd IS NOT NULL;
  

COMMIT;

END;       
