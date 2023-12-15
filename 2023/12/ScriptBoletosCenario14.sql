BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (c.nrdconta, c.nrdocmto) in ((84606444,97),(84606444,98),(84606444,99));

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (c.nrdconta, c.nrdocmto) in ((83390618,61),(82475920,51));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta yyyyyy');
END;
