BEGIN
  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 225.46
   WHERE progress_recid = 141040458;
   
  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 467.59
   WHERE progress_recid = 137589202;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0332738');
    ROLLBACK;
END;
