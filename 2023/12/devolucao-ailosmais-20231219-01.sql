BEGIN
  UPDATE cecred.crapcob c
     SET c.vltitulo = c.vltitulo + c.vlabatim + c.vldescto + 100
   WHERE c.nrdident IN ('3023110902118124040', '3023121506124355886');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos 3023110902118124040 e 3023121506124355886');
    ROLLBACK;
END;