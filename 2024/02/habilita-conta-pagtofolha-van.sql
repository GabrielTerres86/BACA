BEGIN

  UPDATE CECRED.crapemp emp
     SET emp.flgpgvan = 1
        ,emp.tpfloat = 1 
   WHERE cdcooper = 1
     AND nrdconta = 99914492;
  
   COMMIT;
END;
