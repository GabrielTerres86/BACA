/*
SELECT l.*
  FROM craptel l
 WHERE l.nmdatela = 'LANRQE';
*/
UPDATE craptel
   SET cdopptel = cdopptel || ',P', 
       lsopptel = lsopptel || ',PEDIDOS'
 WHERE upper(nmdatela) = 'LANRQE';


 
 /* */