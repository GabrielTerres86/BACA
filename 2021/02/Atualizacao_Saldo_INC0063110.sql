BEGIN
  update crapepr -- Saldo será atualizado na data de liberação.
   set vlsdeved = 90000
 where cdcooper = 16 
   and nrdconta = 204021 
   and nrctremp = 132106;
   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
END;
