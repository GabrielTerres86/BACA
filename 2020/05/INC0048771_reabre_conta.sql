--INC0048771 - reabir contas para estornar débitos indevidos
--Ana Volles - 12/05/2020

SELECT a.nrdconta, a.cdsitdct, a.dtdemiss FROM crapass a  WHERE a.cdcooper = 1 AND a.nrdconta IN (2493101, 3734676);

BEGIN
  UPDATE crapass a
  SET a.dtdemiss = NULL
     ,a.cdsitdct = 1
  WHERE a.nrdconta IN (2493101, 3734676)
  AND   a.cdcooper = 1;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  
END;
