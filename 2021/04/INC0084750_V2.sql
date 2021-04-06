BEGIN
  UPDATE crapdir 
  SET    vlsddvem = 120947.41
  WHERE  cdcooper = 1 
  AND    nrdconta = 10855939 
  AND    dtmvtolt = to_date('31/12/2020','DD/MM/RRRR');
  COMMIT;
END;
