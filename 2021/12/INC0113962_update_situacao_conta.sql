BEGIN
  UPDATE craplfp l SET l.idsitlct = 'T'WHERE l.cdempres IN (280, 187) AND l.cdcooper = 7 AND l.nrdconta IN (308870, 402370) AND l.idsitlct = 'L' AND l.vllancto IN (5253.86, 2948.53);
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
END;