begin
  sys.dbms_scheduler.set_attribute(name => 'CECRED.JBGEN_NOTIF_ENVIO', attribute => 'job_class', value => 'DEFAULT_JOB_CLASS');
end;