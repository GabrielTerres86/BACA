BEGIN 
  UPDATE cecred.crapprm a SET a.dsvlrprm = 'custodia@ailos.coop.br;' WHERE a.cdacesso = 'DES_EMAILS_PROC_B3';
  COMMIT;
END;
