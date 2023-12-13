BEGIN

  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 3
   WHERE c.nrdconta = 84606444
     AND (c.nrdconta, c.nrdocmto) in ((82475920, 61), (82475920, 59), (82475920, 79), (82475920, 80), (82475920, 63), (82475920, 64));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta 84606444 e 84606444');
END;
