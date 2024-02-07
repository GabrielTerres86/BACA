BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118065869, 82475920, 57), (118063197, 82475920, 20));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta yyyyyy');
END;
