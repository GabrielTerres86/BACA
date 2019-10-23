BEGIN
  UPDATE craplat SET cdhistor = 2199, cdfvlcop = 125588 WHERE cdcooper = 12 AND nrdconta = 107620 AND (cdhistor IS NULL OR cdhistor = 0);
  UPDATE craplat SET cdhistor = 2199, cdfvlcop = 125588 WHERE cdcooper = 12 AND nrdconta = 101443 AND (cdhistor IS NULL OR cdhistor = 0);
  COMMIT;
END;