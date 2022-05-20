DECLARE

BEGIN

  SYS.DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'CECRED.jbdda_baixa_operac');

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3);
END;
