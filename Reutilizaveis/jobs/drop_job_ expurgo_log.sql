/*
#551207 O job EXPURGO_LOG_$51652 n�o est� excluindo os logs desde 2015. O mesmo ser� exclu�do, juntamente com outras rotinas
de expurgo, assim que for liberada a rotina automatizada de todos os expurgos, que est� sendo implementada pelo Odirlei (solicita��o do Julio).
*/
begin
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.EXPURGO_LOG_$51652');
end;
