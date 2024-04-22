DECLARE

BEGIN
      
      UPDATE cecred.crapprm t 
      SET t.dsvlrprm = '27/03/2024#1'
      where t.cdacesso = 'CTRL_PREJU_TRF_EXEC'
      and t.cdcooper = 1;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
