UPDATE crapcon c SET c.nrseqint = 11
 WHERE (c.cdempcon, c.cdsegmto, c.cdcooper) IN ((305, 4, 9));
UPDATE crapcon c SET c.nrseqint = 126
 WHERE (c.cdempcon, c.cdsegmto, c.cdcooper) IN ((71, 4, 2));
COMMIT;




