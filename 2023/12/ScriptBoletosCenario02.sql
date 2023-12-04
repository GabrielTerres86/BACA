BEGIN
  UPDATE cecred.crapcob c
     SET c.vltitulo = 6
   WHERE c.nrdconta = 83480102
     AND c.nrdocmto IN (47, 44);

  UPDATE cecred.crapcob c
     SET c.vltitulo = 4
   WHERE c.nrdconta = 82475920
     AND c.nrdocmto IN (13, 14);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 47 e 44');
END;
