BEGIN
 
  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo - 5
   WHERE progress_recid = 131555458;

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 28 e 29');
END;