DECLARE
  vr_registros NUMBER := 0;
BEGIN
  LOOP 
    DELETE /*+ parallel(20) */ gestaoderisco.tb_score_carga a WHERE a.idscore = 1941 AND rownum < 10000;
    vr_registros := SQL%ROWCOUNT;
      
    COMMIT;
      
    EXIT WHEN vr_registros = 0;
    
  END LOOP;  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
