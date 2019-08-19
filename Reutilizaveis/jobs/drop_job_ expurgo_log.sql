/*
#551207 O job EXPURGO_LOG_$51652 não está excluindo os logs desde 2015. O mesmo será excluído, juntamente com outras rotinas
de expurgo, assim que for liberada a rotina automatizada de todos os expurgos, que está sendo implementada pelo Odirlei (solicitação do Julio).
*/
begin
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.EXPURGO_LOG_$51652');
end;
