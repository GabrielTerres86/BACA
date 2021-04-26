BEGIN
       sys.dbms_scheduler.drop_job(job_name => 'jbcrd_notifica_carga_preaprov');
END;