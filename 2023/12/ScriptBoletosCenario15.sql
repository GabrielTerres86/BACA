BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = 15
   WHERE (c.nrdconta, c.nrdocmto) in ((82475920,27),(82475920,25));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 27 e 25');
END;
