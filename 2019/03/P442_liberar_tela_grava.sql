UPDATE craptel t
   SET t.inacesso = 1
 WHERE t.cdcooper = 3 
   AND t.nmdatela = 'GRAVAM';

COMMIT;