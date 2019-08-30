UPDATE craptel
   SET craptel.cdopptel = 'L,I,B'
 WHERE UPPER(craptel.nmdatela) = 'PRCCON';
 
COMMIT;
