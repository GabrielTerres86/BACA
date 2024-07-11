BEGIN
 UPDATE cecred.crapprm
    SET dsvlrprm = 'S'
  WHERE upper(cdacesso) = 'ATIVO_VALIDA_INSS_RL'
    AND upper(nmsistem) = 'CRED'
    AND cdcooper = 0;
COMMIT;
END;
