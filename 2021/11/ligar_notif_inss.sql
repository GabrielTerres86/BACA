BEGIN
  UPDATE crapprm SET dsvlrprm = 'S' WHERE cdacesso = 'FLG_NOTIF_INSS_SICREDI';
  COMMIT;
END;
