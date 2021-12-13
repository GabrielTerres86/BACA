BEGIN
  UPDATE craplfp l
     SET l.idsitlct = 'T', l.dsobslct = ''
   WHERE l.cdempres IN (280, 187)
         AND l.cdcooper = 7
         AND l.nrdconta IN (308870, 402370)
         AND l.vllancto IN (5253.86, 2948.53)
         AND l.nrseqpag IN(219,338);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;