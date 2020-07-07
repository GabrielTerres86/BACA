BEGIN 
  UPDATE crapalt alt 
  SET alt.flgctitg = 2
  WHERE alt.cdcooper = 8 
  AND alt.nrdconta  = 30910
  AND alt.flgctitg = 1;

  UPDATE crapass ass 
  SET ass.flgctitg = 3
  WHERE ass.cdcooper = 8 
  AND ass.nrdconta  = 30910;
  
  COMMIT;
END;  
