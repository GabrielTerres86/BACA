-- #551227 Padronização do nome do job e inclusão dos logs de controle de início, erro e fim de execução (Carlos)
BEGIN
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.EAD_CURSO_APROVAD$352358');
  
  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.jbpgd_rec_cursos_aprovados',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
      vr_dscritic VARCHAR2(4000);
      BEGIN
        progrid.wpgd0191.pc_recebe_cursos_aprovados (pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          raise_application_error(-20001, vr_dscritic);
        END IF;
      END;',
    start_date          => '12/02/2016 01:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=daily;ByHour=01;ByMinute=0;BySecond=0',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => TRUE,
    auto_drop           => TRUE,
    comments            => 'Recebe os cadastros de cursos e assembleias');
END;