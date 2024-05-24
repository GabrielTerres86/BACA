BEGIN
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = 'N'
   WHERE upper(p.nmsistem) = 'CRED'
     AND p.cdcooper = 0
     AND upper(p.cdacesso) = 'ATIVO_VALIDA_INSS_RL';
  COMMIT;
END;
