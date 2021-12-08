DECLARE
BEGIN
  
  UPDATE crawlim lim
     SET lim.insitlim = 3
   WHERE lim.cdcooper = 16
     AND lim.nrdconta = 730513
     AND lim.nrctrlim = 143637
     AND lim.tpctrlim = 1;

  UPDATE crapass ass
     SET ass.vllimcre = 1000
   WHERE ass.cdcooper = 16
     AND ass.nrdconta = 730513;

  UPDATE crapsda sda
     SET sda.vllimcre = 1000
   WHERE sda.cdcooper = 16
     AND sda.nrdconta = 730513
     AND sda.dtmvtolt >= '07/12/2021';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    ROLLBACK;
END;
