PL/SQL Developer Test script 3.0
13
/*
  Programa deve estar dentro da cadeia e será executada no final da CECRED.PC_CRPS445
  para atender uma demanda do BI
*/
BEGIN
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JB_GRAVA_SLD_BLQ_APLIC');
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;
END;
0
0
