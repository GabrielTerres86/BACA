BEGIN
  
  UPDATE crapsld  t
     SET t.vlsmnmes = 0
       , t.vlsmnesp = 0
       , t.vljuresp = 0
       , t.vliofmes = 0
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11460148;
     
  COMMIT;
  
END;
