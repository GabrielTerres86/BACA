BEGIN
  DELETE cecred.crapcti crapcti
   WHERE crapcti.cdcooper = 9
     AND crapcti.nrdconta = 166430
     AND crapcti.cddbanco = 756
     AND crapcti.nrctatrf IN (329312, 712221, 329321, 3293126);
     
  COMMIT;
END;