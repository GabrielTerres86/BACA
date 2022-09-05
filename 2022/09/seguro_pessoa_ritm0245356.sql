BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = 'S'
   WHERE p.cdcooper = 11
     AND p.cdacesso = 'PROPOSTA_API_ICATU';
  COMMIT;
END;
/
