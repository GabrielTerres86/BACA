--INC0052142 - Ana Volles - 22/06/2020 - rollback
--Ajustar valor pago de empréstimos no extrato de IR

--conta 80097324
/*SELECT to_number(to_char(crapdir.dtmvtolt,'YYYY')), crapdir.dtmvtolt, crapdir.vlprepag  --1559,70
FROM crapdir crapdir
WHERE crapdir.cdcooper = 1
AND   crapdir.nrdconta = 80097324
AND   to_number(to_char(crapdir.dtmvtolt,'YYYY')) >= '2017';
*/
BEGIN
--2019
  UPDATE crapdir a
  SET    a.vlprepag = 18716.40
  WHERE  a.cdcooper = 1
  AND    a.nrdconta = 80097324
  AND    to_number(to_char(a.dtmvtolt,'YYYY')) = '2019';
  
--2018
  UPDATE crapdir a
  SET    a.vlprepag = 16258.14
  WHERE  a.cdcooper = 1
  AND    a.nrdconta = 80097324
  AND    to_number(to_char(a.dtmvtolt,'YYYY')) = '2018';
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
