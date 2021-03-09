BEGIN
  --
  UPDATE cecred.craphis
    SET flprlndb = 1
  WHERE cdhistor IN (360, 362, 2051, 2052, 2053, 2912, 
                     2697, 2056, 2054, 3042, 3228, 3249,
                     1877, 1536, 302, 2910, 2911, 2086,
                     2089, 1667)
    AND cdcooper = 1;
  --
  DBMS_OUTPUT.PUT_LINE('TOTAL DE REGISTROS ALTERADOS PRIMEIRO UPDATE: ' || SQL%ROWCOUNT);
  --
  UPDATE cecred.craphis
    SET flprlndb = 1
  WHERE cdhistor IN (362, 1667)
    AND cdcooper = 13;
  --
  DBMS_OUTPUT.PUT_LINE('TOTAL DE REGISTROS ALTERADOS SEGUNDO UPDATE: ' || SQL%ROWCOUNT);
  --
  COMMIT;
  --
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
