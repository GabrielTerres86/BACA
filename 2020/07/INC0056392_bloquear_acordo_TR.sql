/*
--> cancelar acordo
UPDATE tbrecup_acordo ac
   SET ac.cdsituacao = 3
 WHERE ac.nracordo IN (201325,275847);
*/
--> Reativar acordo 
UPDATE tbrecup_acordo ac
   SET ac.cdsituacao = 1
 WHERE ac.nracordo IN (201325,275847,179160);

COMMIT; 
