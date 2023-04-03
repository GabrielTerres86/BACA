BEGIN
  sys.dbms_scheduler.drop_job(job_name => 'CREDITO.JBEPR_BLOQ_PREAPROV_CDC');
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
