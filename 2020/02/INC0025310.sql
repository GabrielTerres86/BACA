BEGIN
  dbms_scheduler.drop_job(job_name => 'CECRED.JBEPR_SELECIONA_PREAPROV');
END;
