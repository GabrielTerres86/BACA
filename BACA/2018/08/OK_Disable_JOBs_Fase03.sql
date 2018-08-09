--Desativar JOBs
BEGIN
  dbms_scheduler.disable ('CECRED.JBRCEL_DEBAGE');           --rcel0001   
  dbms_scheduler.disable ('CECRED.JBPAGTO_AGENDAMENTO_DEB'); --CRPS509_CRPS642_CRPS688_DEBBAN
END;
/
commit;