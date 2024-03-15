BEGIN
  UPDATE cecred.crappfp
     SET cdocorrencia = 'HA'
   WHERE cdocorrencia = 'YK'; 
  COMMIT;
END;
