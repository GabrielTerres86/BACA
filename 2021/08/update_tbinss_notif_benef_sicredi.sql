BEGIN
  
UPDATE tbinss_notif_benef_sicredi a 
   SET a.cdtransactionid = NULL
 WHERE ROWNUM <= 1000;
 
COMMIT;
END;
