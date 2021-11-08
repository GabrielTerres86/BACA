BEGIN
  UPDATE crapope o 
     SET o.vlapvcre = o.vlapvcap,
         o.vlestor1 = o.vlapvcap,
         o.vlestor2 = o.vlapvcap,
         o.vllimted = o.vlapvcap,
         o.vlpagchq = o.vlapvcap
   WHERE cdcooper = 12 AND cdoperad = '1';
  COMMIT;
END;
