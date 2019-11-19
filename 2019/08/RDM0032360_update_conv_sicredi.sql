UPDATE crapscn
   SET crapscn.nrrenorm = 1
 WHERE crapscn.dsoparre <> 'E' 
   AND crapscn.dtencemp IS NULL
   AND crapscn.dsdianor = 'U'
   AND crapscn.nrrenorm = 0;
   
COMMIT;

   
