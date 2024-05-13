BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 10
   WHERE (idtitleg, nrdconta, nrdocmto) in ((134862487, 98742094, 2));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script 98742094');
END;
