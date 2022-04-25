BEGIN
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCONV_BANCOOB_CONTABIL');
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;
  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCAPT_CONTAB_APLPROG');
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;
  COMMIT;
END;
