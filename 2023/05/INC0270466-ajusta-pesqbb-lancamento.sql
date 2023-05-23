BEGIN
  
  UPDATE cecred.craplcm t
     SET t.cdpesqbb = 'Fato gerador tarifa:302'
   WHERE t.progress_recid = 1871568265;
   
  COMMIT;
  
END;
