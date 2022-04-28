BEGIN
   
  UPDATE crapemp emp
    SET emp.nmresemp = 'MATEUS'
  WHERE emp.cdcooper = 8 
    AND emp.cdempres = 81;

  COMMIT;
END;
