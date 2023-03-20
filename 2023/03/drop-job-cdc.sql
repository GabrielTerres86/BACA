BEGIN
  sys.dbms_scheduler.drop_job(job_name => 'CREDITO.JBEPR_BLOQ_PREAPROV_CDC');
COMMIT;
  WHEN OTHERS THEN
    raise_application_error(-20500,SQLERRM);;
END;