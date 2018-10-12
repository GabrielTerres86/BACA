/* Remover Job rotina será executada durante o processo batch */
BEGIN
  --> Excluir job
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCC_GRUPO_ECONOMICO_NOVO'); 
  
END;  
