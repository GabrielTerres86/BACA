BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (c.nrdconta, c.nrdocmto) and in ((83390618,61),(82475920,51));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta yyyyyy');
END;
