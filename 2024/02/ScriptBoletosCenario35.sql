BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118074961, 83480102, 105), (118074958, 83480102, 102), (118074955, 83480102, 99), (118074897, 83480102, 88));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script 29');
END;
