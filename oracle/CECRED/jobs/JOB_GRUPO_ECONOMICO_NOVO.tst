PL/SQL Developer Test script 3.0
12
begin
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JOB_GRUPO_ECONOMICO_NOVO',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'BEGIN TELA_CONTAS_GRUPO_ECONOMICO.pc_job_grupo_economico_novo; END;',
                                start_date          => TO_TIMESTAMP_TZ(to_char(SYSDATE+1,'DD/MM/RRRR')||' 08:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR'),
                                repeat_interval     => 'Freq=daily;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=8;ByMinute=0;BySecond=0',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => '');
end;
0
0
