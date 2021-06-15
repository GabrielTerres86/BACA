-- Habilitacao de JOBS de COMPEFORA
declare 
  begin
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_1');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_2');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_5');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_6');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_7');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_8');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_9');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_10');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_11');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_12');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_13');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_14');
    dbms_scheduler.enable(name => 'JBBTCH_COMPEFORABB_16');
  end;