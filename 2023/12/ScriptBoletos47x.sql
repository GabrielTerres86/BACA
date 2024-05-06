BEGIN
  UPDATE cecred.crapcob c
     SET c.vltitulo = 4
   WHERE c.nrdconta = 82475920
     AND c.nrdocmto IN (4, 7);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 4 e 7');
END;
