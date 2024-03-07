BEGIN

  UPDATE CECRED.crapemp emp
     SET emp.flgpgvan = 1
        ,emp.tpfloat = 1
   WHERE cdcooper = 9
     AND nrdconta = 99796120;
  
   COMMIT;
END;
