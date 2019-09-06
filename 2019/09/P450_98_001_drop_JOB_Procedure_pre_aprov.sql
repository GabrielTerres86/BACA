--job vai ser substituido, a pedido do Jaison, pelo job JBEPR_DESBLOQ_PREAPRV_RAT
begin
 sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBEPR_CARGA_MANUAL_PREAPROV');    

end;
/

drop procedure cecred.PC_JOB_LIBERA_PRE_MANUL;