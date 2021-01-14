--INC0050846 - ajuste saldo deveder para IR - contrato foi quitado em 2016
--Ana Volles - 05/06/2020

/*SELECT crapdir.dtmvtolt, crapdir.vlsddvem
FROM crapdir crapdir
WHERE crapdir.cdcooper = 13
AND   crapdir.nrdconta = 3840
AND   to_number(to_char(crapdir.dtmvtolt,'YYYY')) = '2019';*/

BEGIN
  UPDATE crapdir a
  SET    a.vlsddvem = 0
  WHERE  a.cdcooper = 13
  AND    a.nrdconta = 3840
  AND    to_number(to_char(a.dtmvtolt,'YYYY')) = '2019';
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
