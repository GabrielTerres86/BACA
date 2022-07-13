BEGIN
  
  UPDATE crapprm
     SET dsvlrprm = 'C'
   WHERE cdacesso in ('LIMITE_APLIC_MANUAIS','LIMITE_APLIC_AGENDADAS')
     AND cdcooper in (2,13);
     
  COMMIT;

END;  
