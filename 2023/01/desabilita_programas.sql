BEGIN

  UPDATE CECRED.crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS516';
  UPDATE CECRED.crapprg SET nrsolici = 99 || SUBSTR(cdprogra,5), inlibprg = 2 WHERE UPPER(NMSISTEM) = 'CRED' AND UPPER(CDPROGRA) = 'CRPS280';  
  
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCONTAB_PROCESSA_CONTABIL');
  
  COMMIT;
END;
