BEGIN
  
  UPDATE CECRED.CRAPLAU t
     SET t.insitlau = 3
       , t.dtdebito = t.dtmvtolt
   WHERE cdcooper = 5 -- ACENTRA
     AND nrdconta = 177199
     AND nrdocmto IN (166,167,168)
     AND dtmvtolt = to_date('31-10-2019', 'dd-mm-yyyy');
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;