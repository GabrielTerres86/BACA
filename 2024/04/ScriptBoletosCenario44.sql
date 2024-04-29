BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE (cdcooper, idtitleg, nrdconta, nrdocmto) in ((9, 118084991, 84606444, 220), (9, 118084990, 84606444, 219));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script diversos');
END;
