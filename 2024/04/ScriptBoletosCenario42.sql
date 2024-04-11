BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE (cdcooper, idtitleg, nrdconta, nrdocmto) in ((8, 118083867, 82475920, 123), (8, 118076926, 82475920, 90), (8, 118076921, 82475920, 85), (8, 118076920, 82475920, 84));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script diversos');
END;
