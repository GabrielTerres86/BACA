prompt RDM0031187

set feedback off
set define off


UPDATE CRAWEPR
   SET DSNIVORI = DECODE( dsnivris, '2', 'A', '3', 'B', '4', 'C', '5', 'D', '6', 'E', '7', 'F','8', 'G', '9', 'H' ) 
 WHERE CDCOOPER = 1
   AND NRDCONTA = 2140101
   AND NRCTREMP IN ( 1356136 );


UPDATE CRAWEPR
   SET DSNIVORI = DSNIVRIS
 WHERE CDCOOPER = 1
   AND NRDCONTA = 3804631
   AND NRCTREMP IN ( 1383755,668336,696537 );
    

UPDATE CRAWEPR
   SET DSNIVORI = DSNIVRIS
 WHERE CDCOOPER = 9
   AND NRDCONTA = 78239
   AND NRCTREMP = 13128;


commit;

prompt Done.
