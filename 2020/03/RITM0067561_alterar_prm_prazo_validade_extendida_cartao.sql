BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = p.dsvlrprm || ',31/03/2020,30/04/2020,31/05/2020,30/06/2020,31/07/2020'
   WHERE p.cdacesso = 'CRD_VALIDADE_EXTENDIDA';
   
  COMMIT;
END;