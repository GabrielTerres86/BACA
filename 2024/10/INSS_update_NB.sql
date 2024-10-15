begin
  UPDATE cecred.crapass q
  SET q.nrdconta = 9018000
WHERE q.cdcooper = 1
  AND q.nrdconta = 9018077;     

UPDATE cecred.crapttl q
  SET q.nrdconta = 9018000
WHERE q.cdcooper = 1
  AND q.nrdconta = 9018077; 

  commit;
  end;