
UPDATE CRAPASS
   SET DTDEMISS = TO_DATE('01/10/2020','DD/MM/YYYY')
     , CDSITDCT = 4
 WHERE cdcooper = 16
   AND nrdconta = 142670 ; 

commit;