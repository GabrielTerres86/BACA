BEGIN
  UPDATE crapsdc 
     SET crapsdc.indebito = 1
   WHERE crapsdc.cdcooper = 1
     AND crapsdc.nrdconta = 18709540;
  COMMIT;
END;
