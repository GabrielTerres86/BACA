BEGIN    
  UPDATE crapsnh
     SET tpdsenha = 3   
   WHERE crapsnh.cdcooper = 7
     AND crapsnh.nrdconta = 850004
     AND crapsnh.idseqttl = 1
     AND tpdsenha = 1;
     
  COMMIT;
END;