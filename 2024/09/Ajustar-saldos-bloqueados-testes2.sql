BEGIN
  
  UPDATE crapsld t
     SET t.vlsdbloq = DECODE(t.nrdconta,9730443,973.04
                                       ,9732225,973.22
                                       ,9733132,973.31
                                       ,0)
   WHERE t.cdcooper = 1
     AND t.nrdconta IN (9730443,9732225,9733132);
  
  COMMIT;
  
END;
