BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118074884, 82475920, 70), (118074882, 82475920, 68));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script 29');
END;
