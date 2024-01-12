BEGIN
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCC_EMITE_AUX_EMERGENCIAL');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/
