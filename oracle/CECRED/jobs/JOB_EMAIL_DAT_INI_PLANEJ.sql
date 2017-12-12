BEGIN
  dbms_scheduler.drop_job(job_name => 'CECRED.EMAIL_DAT_INI_PLANEJ');

  sys.dbms_scheduler.create_job(job_name            => 'CECRED.EMAIL_DAT_INI_PLANEJ',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'declare vr_cdcritic integer := 0; vr_dscritic varchar2(4000); begin PROGRID.ASSE0001.pc_email_dat_ini_planej(pr_cdcritic => vr_cdcritic,pr_dscritic => vr_dscritic) ; end;',
                                start_date          => to_date('29-08-2017 01:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=DAILY;ByDay=Mon,Tue,Wed,Thu,Fri;ByHour=01;ByMinute=00;BySecond=0',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => 'Rodar programa PROGRID.ASSE0001.pc_email_dat_ini_planej - Responsavel por enviar de email de data de início de planejamento, roda toda os dias as 01:00h.');
end;
