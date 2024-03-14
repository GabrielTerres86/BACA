BEGIN
  sys.dbms_scheduler.drop_job(job_name => 'JBCRD_CONTAB_CESSAO');
  commit;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, 'Erro no drop JBCRD_CONTAB_CESSAO: ' || SQLERRM);
END;