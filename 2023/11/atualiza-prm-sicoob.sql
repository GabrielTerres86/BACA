BEGIN
  UPDATE crapprm
     SET dsvlrprm = 'apibancoobhml.ailos.coop.br:9443'
   WHERE cdacesso = 'CONV_URL_BCB'
     AND cdcooper = 0;
  COMMIT;
END;
