BEGIN
 
    UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 10
   WHERE progress_recid in (140688456);

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos');
END;