BEGIN
  UPDATE cecred.crapcob c
     SET c.vltitulo = 45456456465456456465465456465454
   WHERE c.nrdconta = 82475920
     AND c.nrdocmto IN (4, 7);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 4 e 7');
END;
