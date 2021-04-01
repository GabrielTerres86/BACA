BEGIN
  UPDATE crawepr 
  SET    vliofepr = 0 
  WHERE  cdcooper = 13 
  AND    nrdconta = 425680 
  AND    nrctremp = 109824;
  COMMIT;
END;
