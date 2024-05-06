BEGIN
 
  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118064958, 84606444, 92));
 
 UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (idtitleg, nrdconta, nrdocmto) in ((118083867, 82475920, 123));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 122');
END;