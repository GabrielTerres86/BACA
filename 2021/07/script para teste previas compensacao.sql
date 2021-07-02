DECLARE 
  CURSOR c1 IS
    SELECT *
      FROM  craptit t
     WHERE t.cdcooper = 16
       AND t.dtdpagto = to_date('17/05/2021','dd/mm/yyyy')
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
     SET t.dtdpagto = to_date('02/07/2021','dd/mm/yyyy'),
         t.dtmvtolt = to_date('02/07/2021','dd/mm/yyyy'),
         t.flgenvio = 0,
         t.cdbcoenv = 0
  WHERE t.cdcooper = 16
    AND t.dtdpagto = to_date('17/05/2021','dd/mm/yyyy')
    AND t.insittit = 4;
  

COMMIT;

END;       
