BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118065875, 82475920, 63), (118065874, 82475920, 62), (118065873, 82475920, 61), (118065872, 82475920, 60));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 82475920');
END;
