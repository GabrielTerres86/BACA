begin
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JBEPR_POS_DIARIA_CPA',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'begin
     empr0002.pc_carga_pos_diaria_epr(pr_cdcooper => 0, pr_qtddias_blq => 5, pr_qtdias_manter => 5);
  end;',
                                start_date          => to_date('17-07-2017 20:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=DAILY;ByHour=20',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => '');
end;
/
