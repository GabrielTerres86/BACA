BEGIN
  dbms_scheduler.drop_job(job_name => 'JBEPR_MULT_JUR_TR');
  DBMS_SCHEDULER.CREATE_JOB (job_name => 'JBGEN_EFETIVA_LCTO_PENDENTE', 
                             job_type => 'PLSQL_BLOCK', 
                             job_action => 'begin TELA_LAUTOM.pc_efetiva_lcto_pendente_job; end;', 
                             number_of_arguments => 0, 
                             start_date => '27/07/16 11:00:00,000000 AMERICA/SAO_PAULO', 
                             repeat_interval => 'FREQ=DAILY;BYHOUR=11,17', 
                             end_date => null, 
                             job_class => 'DEFAULT_JOB_CLASS', 
                             enabled => FALSE, 
                             auto_drop => TRUE, 
                             comments => null, 
                             credential_name => null, 
                             destination_name => null);
END;
/
