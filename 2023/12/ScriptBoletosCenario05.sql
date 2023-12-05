BEGIN
  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo + c.vlabatim + c.vldescto + 100
   WHERE c.nrdident IN ('3023110901118124610', '3023110906118323177');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 3023110901118124610 e 3023110906118323177');
END;
