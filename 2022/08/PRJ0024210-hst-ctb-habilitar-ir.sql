BEGIN
  
  UPDATE cecred.craphis 
  SET idapreir = 1 
  WHERE cdhistor IN (4002,4003,4004,4012,4013,4014,2255,1225,1067,933,931,3311,3471,3472,2842,3650,3457,3479,3284);

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024210');
    ROLLBACK;                         
END;