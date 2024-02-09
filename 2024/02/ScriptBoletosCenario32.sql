BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118074903, 83480102, 94), (118074901, 83480102, 92), (118074896, 83480102, 87));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script 29');
END;
