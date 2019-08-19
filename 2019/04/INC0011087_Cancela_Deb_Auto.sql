-- INC0011087, cancelar débitos automaticos.
UPDATE crapatr 
   SET dtfimatr       = to_date('05042019','ddmmyyyy') 
 WHERE cdcooper       = 1
   AND nrdconta       = 2787989
   AND progress_recid = 57867;
   
COMMIT;
   