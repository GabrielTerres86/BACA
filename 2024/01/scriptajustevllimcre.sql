BEGIN

  UPDATE cecred.crapass ass
     SET ass.vllimcre = 0
   WHERE ass.vllimcre IS NULL 
     AND ass.cdcooper = 2;
  
  COMMIT;
  
END;