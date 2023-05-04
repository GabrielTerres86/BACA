UPDATE craptel x
   SET x.inacesso = 1
 WHERE x.nmdatela = 'PRCBND'
   AND x.cdcooper = 3;

COMMIT;   
 
