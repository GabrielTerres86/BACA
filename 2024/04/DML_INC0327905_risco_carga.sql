BEGIN

  UPDATE gestaoderisco.tbrisco_Central_Carga t
   SET t.CDSTATUS = 7
 WHERE t.CDSTATUS = 6;
 
 COMMIT;

   UPDATE gestaoderisco.tbrisco_Central_Carga t
   SET t.CDSTATUS = 4
 WHERE t.CDSTATUS = 2
   and t.cdcooper = 3;
 
 COMMIT; 
END; 