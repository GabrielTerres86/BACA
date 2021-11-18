BEGIN

  DELETE FROM tbinss_notif_benef_sicredi a
    where a.idnotificacao = 139;

  COMMIT;

END;
