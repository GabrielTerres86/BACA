BEGIN
 
    UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 10
   WHERE progress_recid in (142071121, 142071122);

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos');
END;