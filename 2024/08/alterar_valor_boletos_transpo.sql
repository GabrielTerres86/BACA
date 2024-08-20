BEGIN
 
    UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 10
   WHERE progress_recid in (142098126, 142098127, 142098128);

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => '142098126, 142098127, 142098128');
END;