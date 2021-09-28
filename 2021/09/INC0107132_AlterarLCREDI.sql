BEGIN
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 3 AND cdlcremp IN (16);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 1 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 2 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 5 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 6 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 7 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 8 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 9 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 10 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 11 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 12 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 14 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 16 AND cdlcremp IN (1600);
  UPDATE craplcr SET dsoperac = 'FINANCIAMENTO' WHERE cdcooper = 13 AND cdlcremp IN (1600,1601,1602);
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
       ROLLBACK;
END;
