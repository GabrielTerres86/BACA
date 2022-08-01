BEGIN
  
  UPDATE CECRED.crapcot
    SET vldcotas = 100
  WHERE cdcooper = 1
    AND nrdconta = 14690683;
    
  UPDATE CECRED.crapcot
    SET vldcotas = 100
  WHERE cdcooper = 1
    AND nrdconta = 14690691;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
