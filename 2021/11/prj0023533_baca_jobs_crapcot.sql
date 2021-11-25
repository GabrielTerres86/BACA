-- Created on 25/10/2021 by F0030248 
declare 
  -- Local variables here
  i integer;
  vr_dscritic VARCHAR2(1000);
  vr_plsql1 VARCHAR2(4000);
  vr_cdprogra            VARCHAR2(100) := 'JBSOBRAS_';
  vr_jobname             VARCHAR2(100);
  
begin
  -- Test statements here    
  
 FOR rw IN (SELECT cop.cdcooper, age.cdagenci
              FROM crapcop cop, crapage age
             WHERE cop.flgativo = 1
               AND cop.cdcooper <> 3
               AND cop.cdcooper = 1
               AND age.cdcooper = cop.cdcooper
               AND age.cdagenci > 0
               AND age.cdagenci NOT IN (90,91)) LOOP
               
    vr_plsql1 := 'begin cecred.pc_atualizar_qtjurmfx(' || rw.cdcooper || ',' || rw.cdagenci || '); end;';
                         
    -- Test statements here
    vr_jobname := vr_cdprogra || 'PA' || rw.cdagenci || '_$';
    
    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper => 3            --> Código da cooperativa
                          ,pr_cdprogra => vr_cdprogra || '_' || rw.cdagenci  --> Código do programa
                          ,pr_dsplsql  => vr_plsql1
                          ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname  => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro => vr_dscritic);
                            
    dbms_output.put_line(vr_dscritic);                          
 END LOOP;       
 
 COMMIT;
end;