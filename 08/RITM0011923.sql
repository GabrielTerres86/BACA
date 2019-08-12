BEGIN
  UPDATE crapprm 
     SET dsvlrprm = 'D'
   WHERE cdcooper = 7
     AND cdacesso = 'LIMITE_APLIC_AGENDADAS';

  UPDATE crapprm 
     SET dsvlrprm = 'D'
   WHERE cdcooper = 13
     AND cdacesso = 'LIMITE_APLIC_PLANO_COTAS';

  COMMIT;
END;
