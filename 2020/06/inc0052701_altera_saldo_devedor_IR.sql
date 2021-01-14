--INC0052701 - Ana Volles - 23/06/2020
--Ajustar valor saldo devedor de empréstimos no extrato de IR

--conta 70335
/*SELECT to_number(to_char(crapdir.dtmvtolt,'YYYY')), crapdir.dtmvtolt, crapdir.vlprepag, crapdir.vlsddvem  --1559,70
FROM crapdir crapdir
WHERE crapdir.cdcooper = 9
AND   crapdir.nrdconta = 70335
AND   to_number(to_char(crapdir.dtmvtolt,'YYYY')) >= '2017';
*/
BEGIN
  
--2018
  UPDATE crapdir a
  SET    a.vlsddvem = 68725.77
  WHERE  a.cdcooper = 9
  AND    a.nrdconta = 70335
  AND    to_number(to_char(a.dtmvtolt,'YYYY')) = '2018';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
