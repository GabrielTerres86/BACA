/*   

     Criação do Job JBEPR_GRV_ATUALIZA_REGISTRO para correção dos registro de gravames onde o registrado está menor que o solicitado
     PRJ442 - Registro automático de gravames

*/

DECLARE
  vr_dsplsql  VARCHAR2(3500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'cecred.JBEPR_GRV_ATUALIZA_REGISTRO';
                
  -- Verifica se JOB existe, caso não existir remove para criar novamente
  BEGIN
    SYS.DBMS_SCHEDULER.DROP_JOB(job_name => vr_jobname);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  

END;
/
