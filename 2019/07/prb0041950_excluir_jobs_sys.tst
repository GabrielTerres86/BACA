PL/SQL Developer Test script 3.0
24
--10/07/2019 - PRB0041950 apagar os jobs com o owner SYS (Carlos)
BEGIN
  -- Excluir o job SYS.JBCHQ_CRPS710
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'SYS.JBCHQ_CRPS710');
  EXCEPTION 
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;
  -- Excluir o job SYS.JBDSCT_EFETUA_BAIXA_TIT_CAR
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'SYS.JBDSCT_EFETUA_BAIXA_TIT_CAR');
  EXCEPTION 
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;
  -- Excluir o job SYS.JBRCEL_ATUALIZA_PRODUTOS
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'SYS.JBRCEL_ATUALIZA_PRODUTOS');
  EXCEPTION 
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;
END;
0
0
