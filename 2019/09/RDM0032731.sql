delete
from crapavt
where cdcooper = 1
and nrdconta in ( 82910 , 9915168 )
and tpctrato = 6
and dtvalida <= trunc( sysdate ) ;

DELETE
  FROM CRAPAVT
 WHERE CDCOOPER = 1
   AND NRDCONTA IN ( 9517618, 862304 )
   AND NRCPFCGC = 63910586953;

  COMMIT; 
