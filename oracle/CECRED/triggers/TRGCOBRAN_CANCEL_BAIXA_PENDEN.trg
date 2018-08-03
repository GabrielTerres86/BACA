CREATE OR REPLACE TRIGGER CECRED.TRGCOBRAN_CANCEL_BAIXA_PENDEN                                 
  AFTER INSERT ON TBCOBRAN_BAIXA_PENDENTE FOR EACH ROW
DECLARE
  
  -- CONSTANTES
  vr_cdcooper   CONSTANT NUMBER := 3; -- Rodará sempre como CENTRAL
  vr_nrminuto   CONSTANT NUMBER := 1 / 24 / 60; -- Fator referente à 1 minuto
    
  -- Variáveis
  vr_dsnomjob   VARCHAR2(100);
  vr_dsdplsql   VARCHAR2(30000);
  vr_dscritic   VARCHAR2(1000);
  vr_dtprxexc   DATE;
  

BEGIN
  -- Define o prefixo do JOB
  vr_dsnomjob := 'JBCOBRAN_CNCL_BXA$'; -- CANCELAMENTO DE BAIXA AUTOMÁTICA
        
  -- Define o código a ser executado pelo JOB
  vr_dsdplsql := 'BEGIN'||CHR(13)||
                 '  DDDA0001.pc_pendencia_cancel_baixa(pr_dsrowid  => '''||:old.rowid||''');'||CHR(13)||
                 'END;';                                                 
  
  -- A PRÓXIMA TENTATIVA OCORRERÁ APÓS 5 MINUTOS
  vr_dtprxexc := SYSDATE + (vr_nrminuto * 5);
      
  -- Reagendar JOB para a próxima hora definida
  GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper
                        ,pr_cdprogra  => 'DDDA0001'
                        ,pr_dsplsql   => vr_dsdplsql
                        ,pr_dthrexe   => TO_TIMESTAMP(TO_CHAR(vr_dtprxexc,'dd/mm/rrrr hh24:mi:ss'),'dd/mm/rrrr hh24:mi:ss')
                        ,pr_interva   => NULL
                        ,pr_jobname   => vr_dsnomjob          
                        ,pr_des_erro  => vr_dscritic);
        
  -- Tratamento Erro
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20000,'Falha no agendamento do JOB. (Job: '||vr_dsnomjob||'). Erro: '||vr_dscritic);
  END IF;

END;
/
