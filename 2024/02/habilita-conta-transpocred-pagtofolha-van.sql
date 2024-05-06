BEGIN
  UPDATE CECRED.crapemp emp
     SET emp.flgpgvan = 1
        ,emp.tpfloat = 0 
   WHERE cdcooper = 9
     AND nrdconta IN (99796120,99832712,99608189,99530694);
  
   COMMIT;
END;
