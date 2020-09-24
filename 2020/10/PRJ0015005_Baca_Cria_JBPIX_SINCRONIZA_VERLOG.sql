DECLARE
  vr_plsql_block varchar2(4000); 
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET
    nls_calendar = ''GREGORIAN''
    nls_comp = ''BINARY''
    nls_date_format = ''DD-MON-RR''
    nls_date_language = ''AMERICAN''
    nls_iso_currency = ''AMERICA''
    nls_language = ''AMERICAN''
    nls_length_semantics = ''BYTE''
    nls_nchar_conv_excp = ''FALSE''
    nls_numeric_characters = ''.,''
    nls_sort = ''BINARY''
    nls_territory = ''AMERICA''
    nls_time_format = ''HH.MI.SSXFF AM''
    nls_time_tz_format = ''HH.MI.SSXFF AM TZR''
    nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''
    nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  -- Verifica se JOB existe, caso não existir remove para criar novamente
  BEGIN
    SYS.DBMS_SCHEDULER.DROP_JOB(job_name => 'CECRED.JBPIX_SINCRONIZA_VERLOG');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  
  -- Bloco
  vr_plsql_block := 
'declare 
  -- Registros pendentes de LOG
  cursor cr_lgm is
    select lgm.nrsequen
          ,lgm.cdcooper
          ,lgm.nrdconta
          ,lgm.idseqttl
          ,lgm.dttransa
          ,lgm.dstransa
          ,lgm.dsorigem
          ,lgm.nmdatela
          ,lgm.flgtrans
          ,lgm.dscritic
          ,lgm.cdoperad
      from PIX.tbpix_craplgm lgm
     where lgm.flgreplicado = ''N''
     order by lgm.nrsequen
     FOR UPDATE;
  -- Itens do log
  cursor cr_craplgi(pr_nrsequen PIX.tbpix_craplgm.NRSEQUEN%type) is
    select lgi.NMDCAMPO
          ,lgi.DSDADANT
          ,lgi.DSDADATU
      from PIX.tbpix_craplgi lgi
     where lgi.NRSEQUEN = pr_nrsequen
     order by lgi.NRSEQCMP;    
  -- ROWID pai
  vr_rowid_Lgm rowid;
     
  -- Tratamento de erros
  vr_dscritica varchar2(1000);
  vr_exsaida   exception;     
begin
  -- Para cada LGM
  for rw_lgm in cr_lgm loop
    -- GErar CRAPLGM
    gene0001.pc_gera_log(pr_cdcooper => rw_lgm.cdcooper
                        ,pr_cdoperad => rw_lgm.cdoperad 
                        ,pr_dscritic => substr(rw_lgm.cdcooper,1,245)
                        ,pr_dsorigem => rw_lgm.dsorigem
                        ,pr_dstransa => rw_lgm.dstransa 
                        ,pr_dttransa => rw_lgm.dttransa 
                        ,pr_flgtrans => rw_lgm.flgtrans 
                        ,pr_hrtransa => to_char(rw_lgm.dttransa,''sssss'') 
                        ,pr_idseqttl => rw_lgm.idseqttl 
                        ,pr_nmdatela => rw_lgm.nmdatela 
                        ,pr_nrdconta => rw_lgm.nrdconta 
                        ,pr_nrdrowid => vr_rowid_Lgm);
    -- Se não gerou
    if vr_rowid_Lgm is null then
      vr_dscritica := ''Erro na geração de LGM a partir da sequencia ''||rw_lgm.nrsequen||'', favor analisar os logs do banco'';
      raise vr_exsaida;
    end if;
    
    -- Buscar cada item de log
    for rw_lgi in cr_craplgi(rw_lgm.nrsequen) loop 
      -- Para cada item, gerar o item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_Lgm
                               ,pr_nmdcampo => rw_lgi.nmdcampo
                               ,pr_dsdadant => rw_lgi.dsdadant
                               ,pr_dsdadatu => rw_lgi.dsdadatu);
    end loop;
    -- Atualizar LGM
    begin
      update PIX.tbpix_craplgm lgm
         set lgm.FLGREPLICADO = ''S''
       where lgm.NRSEQUEN = rw_lgm.nrsequen;
    exception
      when others then
        vr_dscritica := ''Erro na atualização da TBPIX_CRAPLGM: ''||sqlerrm;
        raise vr_exsaida;
    end;       
    -- Commitar a cada 500 registros
    if mod(cr_lgm%rowcount,500) = 0 then
      commit;
    end if;
  end loop;
  -- Commitar ao final
  commit;
exception
  when vr_exsaida then
    rollback;
    RAISE_APPLICATION_ERROR(-20500,''Erro no JOB jb_replica_lgm_pix: ''||vr_dscritica);
  when others then 
    rollback;
    RAISE_APPLICATION_ERROR(-20500,''Erro não tratado no JOB jb_replica_lgm_pix: ''||sqlerrm);
end;';
  
  
  -- Criação do JOB
  SYS.DBMS_SCHEDULER.CREATE_JOB(job_name        => 'CECRED.JBPIX_SINCRONIZA_VERLOG',
                                job_type        => 'PLSQL_BLOCK',
                                job_action      => vr_plsql_block,
                                start_date      => sysdate,
                                repeat_interval => 'FREQ=MINUTELY;INTERVAL=5;',
                                end_date        => to_date(null),
                                job_class       => 'DEFAULT_JOB_CLASS',
                                enabled         => true,
                                auto_drop       => true,
                                comments        => 'Integração de dados da tabela TBPIX_CRAPLGM e LGI para CRAPLGM e CRAPLGI (VERLOG)');
END;
/
