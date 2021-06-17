/* Geração do novo motivo F3 */
BEGIN
  
  FOR r1 in (
            SELECT crapmot.*
            FROM crapmot
            WHERE crapmot.cddbanco = 85
            AND   crapmot.cdocorre = 98
            AND   crapmot.cdmotivo = 'F2'
            ORDER BY crapmot.cdcooper) LOOP
      --      
      INSERT INTO crapmot (CDCOOPER, CDDBANCO, CDOCORRE, TPOCORRE, CDMOTIVO, DSMOTIVO, DSABREVI, CDOPERAD, DTALTERA, HRTRANSA, PROGRESS_RECID)
      VALUES (r1.cdcooper, r1.cddbanco, r1.cdocorre, r1.tpocorre, 'F3', 'Protesto Cancelado', ' ', '1', trunc(sysdate), 0, null);
      --
  END LOOP;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: '||SQLERRM);
    
END;  
  
