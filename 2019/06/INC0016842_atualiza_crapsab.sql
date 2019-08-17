BEGIN
  
  UPDATE crapsab s SET cdtpinsc = 1
 WHERE s.cdcooper = 16
   AND s.nrdconta = 171077
   AND s.progress_recid = 15113216;
   
COMMIT;

END;
