BEGIN

  DELETE gestaoderisco.tb_score_carga a WHERE a.idscore = 1941;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
