BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118066891, 84606444, 136), (118066847, 84606444, 99));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta yyyyyy');
END;
