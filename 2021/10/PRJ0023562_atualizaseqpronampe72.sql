BEGIN
  UPDATE crapprm prm
     SET dsvlrprm = 72
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'NRSEQ_ARQUIVO_PRONAMPE';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
