BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE c.nrdconta = 84606444
     AND c.nrdocmto IN (67, 77);

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE c.nrdconta = 82475920
     AND c.nrdocmto IN (74);
  
  UPDATE cecred.craptit t
  SET t.vltitulo = 2100
  WHERE t.progress_recid = 209276508;
  
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta 82475920 e 84606444');
END;
