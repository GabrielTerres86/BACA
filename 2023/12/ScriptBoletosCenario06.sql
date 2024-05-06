BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE c.nrdconta = 82475920
     AND c.nrdocmto IN (73, 77, 78, 79, 80, 81);
  
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta 82475920');
END;
