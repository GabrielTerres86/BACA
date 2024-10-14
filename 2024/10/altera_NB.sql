begin
  UPDATE cecred.crapass q
  SET q.nrdconta = 2321
WHERE q.cdcooper = 1
  AND q.nrdconta = 99997614;     

UPDATE cecred.crapttl q
  SET q.nrdconta = 2321
WHERE q.cdcooper = 1
  AND q.nrdconta = 99997614; 

  commit;

  end;