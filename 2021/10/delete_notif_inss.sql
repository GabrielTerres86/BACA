BEGIN
  DELETE FROM tbinss_notif_benef_sicredi a
    WHERE a.inaceitenotif = 1;
    
    COMMIT;
END;
