BEGIN
  UPDATE cecred.crapcob c
     SET c.vltitulo = 2
   WHERE c.nrdconta = 84606444
     AND c.nrdocmto IN (1, 2, 3, 4);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 1,2,3 e 4');
END;
