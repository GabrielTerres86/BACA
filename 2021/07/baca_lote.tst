PL/SQL Developer Test script 3.0
13
DECLARE 
  i integer;
BEGIN
  UPDATE craplot l 
     SET l.vlcompcr = l.vlinfocr 
   WHERE l.cdcooper = 3 
     AND l.dtmvtolt = to_date('19/07/2021','dd/mm/yyyy') 
     AND l.nrdolote = 10001;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
0
0
