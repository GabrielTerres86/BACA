BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (c.nrdconta, c.nrdocmto) in ((99149931, 5), (99149931, 7), (99149931, 8), (99149931, 33265), (99149931, 33263), (99149931, 33269), (82475920, 72), (82475920,67));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta yyyyyy');
END;
