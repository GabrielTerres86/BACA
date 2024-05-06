BEGIN

  UPDATE cecred.crapcob c SET c.vldpagto = 180.38 WHERE c.progress_recid = 128174862;

  UPDATE cecred.crapret c SET c.vlrpagto = 180.38 WHERE c.progress_recid = 297684928;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boleto 128174862');
END;
