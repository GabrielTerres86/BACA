BEGIN
  dbms_scheduler.run_job('CECRED.JBCOMPE_AGENDAMENTO_TED');
END;
