DECLARE
 i number;
BEGIN
  delete crapalt WHERE cdcooper = 1 AND nrdconta = 6487505 AND tpaltera = 1;
  commit;
END;
/
