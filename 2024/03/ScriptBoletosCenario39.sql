BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118083866, 82475920, 122));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 122');
END;
