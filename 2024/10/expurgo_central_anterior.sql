DECLARE
  
  vr_dsplsql VARCHAR2(10000);
  
  CURSOR cr_crapcop IS
    SELECT cdcooper 
      FROM cecred.crapcop a 
     WHERE a.flgativo = 1
       AND a.cdcooper = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
  
    vr_dsplsql := '        
        DECLARE
          vr_dscritic VARCHAR2(4000);
        BEGIN
          DELETE FROM cecred.crapvri
           WHERE cdcooper = ' || rw_crapcop.cdcooper || '
             AND dtrefere = to_date(''' || '27/09/2024' || ''' ,''dd/mm/rrrr'');
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception(pr_compleme => ''Erro ao efetuar a limpeza de registros. Tabela de Vencimentos (CRAPVRI).'');
            vr_dscritic := ''Erro ao efetuar a limpeza de registros. Tabela de Vencimentos (CRAPVRI). Detalhes: ''||sqlerrm;
            RAISE_application_error(-20500,''Erro: ''||vr_dscritic);
        END;';
        
    dbms_scheduler.create_job(job_name        => 'LIMPA_VRI_ANT_1_' || rw_crapcop.cdcooper
                             ,job_type        => 'PLSQL_BLOCK' 
                             ,job_action      => vr_dsplsql    
                             ,start_date      => SYSDATE       
                             ,auto_drop       => TRUE          
                             ,enabled         => TRUE);        
        
    vr_dsplsql := '        
        DECLARE
          vr_dscritic VARCHAR2(4000);
        BEGIN
          DELETE FROM cecred.crapris
           WHERE cdcooper = ' || rw_crapcop.cdcooper || '
             AND dtrefere = to_date(''' || '27/09/2024' || ''' ,''dd/mm/rrrr'');
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception(pr_compleme => ''Erro ao efetuar a limpeza de registros. Tabela de Riscos (CRAPRIS).'');
            vr_dscritic := ''Erro ao efetuar a limpeza de registros. Tabela de Riscos (CRAPRIS). Detalhes: ''||sqlerrm;
            RAISE_application_error(-20500,''Erro: ''||vr_dscritic);
        END;';
        
       
    dbms_scheduler.create_job(job_name        => 'LIMPA_RIS_ANT_1_' || rw_crapcop.cdcooper
                             ,job_type        => 'PLSQL_BLOCK' 
                             ,job_action      => vr_dsplsql    
                             ,start_date      => SYSDATE       
                             ,auto_drop       => TRUE          
                             ,enabled         => TRUE);        
        
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM || '-' || dbms_utility.format_error_backtrace);
END limparCentralAnterior;
