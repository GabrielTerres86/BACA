--INC0033084 - retirar a conta de prejuízo
--Ana Volles - 30/12/2019
/*
SELECT c.inprejuz, c.cdsitdct, c.cdcooper, c.* FROM crapass c WHERE c.cdcooper = 1 AND c.nrdconta = 9790470;
*/
BEGIN

  --Atualiza conta
  UPDATE crapass a 
  SET a.inprejuz = 0 
  WHERE a.cdcooper = 1 
  AND a.nrdconta = 9790470;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  
END;
