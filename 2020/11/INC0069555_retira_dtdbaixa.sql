--INC0069555
--Ana Volles - 30/11/2020
--Retirar data de baixa de cartões atualizada invedidamente por conta do erro na importação do CB093

/*SELECT x.* FROM crapcyb x
WHERE 1=1 --x.cdcooper = 1
AND   x.dtdbaixa = '27/11/2020'
AND   x.cdorigem = 5
AND  NVL(x.idcessao,0) = 0;
*/
BEGIN
  UPDATE crapcyb x
  SET   x.dtdbaixa = NULL 
  WHERE 1=1
  AND   x.dtdbaixa = '27/11/2020'
  AND   x.cdorigem = 5
  AND   NVL(x.idcessao,0) = 0;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
