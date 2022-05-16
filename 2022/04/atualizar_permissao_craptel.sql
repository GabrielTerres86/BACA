DECLARE
BEGIN
    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',I'
          ,t.lsopptel = t.lsopptel || ',INTERVENCAO TEC.'
     WHERE t.cdcooper = 3
       AND UPPER(t.nmdatela) = 'RCONSI';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;