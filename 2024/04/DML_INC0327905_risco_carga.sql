BEGIN

  UPDATE gestaoderisco.tbrisco_Central_Carga t
   SET t.CDSTATUS = 7
 WHERE t.CDSTATUS = 6;
 
 COMMIT;
 
END; 