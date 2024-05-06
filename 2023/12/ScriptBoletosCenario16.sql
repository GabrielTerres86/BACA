BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 50
   WHERE (nrdconta, nrdocmto) in ((99149931, 18), (99149931, 16), (99149931, 33266), (99149931, 33265));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 99149931');
END;
