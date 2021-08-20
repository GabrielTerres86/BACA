BEGIN
  
UPDATE tbinss_notif_benef_sicredi a SET a.inaceitenotif = 0, a.inconfleitusic = 0, a.dhaceitenotif = NULL, a.dhconfleitusic = NULL
 WHERE a.inaceitenotif = 1 OR a.inaceitenotif <> 0;
COMMIT;
END;
