UPDATE crapsld s  
   SET s.dtrisclq = to_date('20/08/2018','DD/MM/YYYY')
 WHERE s.cdcooper = 1
   AND s.nrdconta = 9938  
   ;

COMMIT;