BEGIN
  update crapepr -- Saldo ser� atualizado na data de libera��o.
   set vlsdeved = 90000
 where cdcooper = 16 
   and nrdconta = 204021 
   and nrctremp = 132106;
   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
END;
