BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE (c.nrdconta, c.nrdocmto) in ((84606444, 95), (84606444, 94), (82475920, 75), (82475920, 76));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta xxxxx');
END;
