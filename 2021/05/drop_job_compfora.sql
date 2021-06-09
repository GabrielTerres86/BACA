BEGIN
	sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBBTCH_COMPEFORABB');
END;
/