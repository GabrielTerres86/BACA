BEGIN
  UPDATE crapope SET VLPAGCHQ = 99999 WHERE cdcooper = 16 AND cdoperad = '1';
COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;