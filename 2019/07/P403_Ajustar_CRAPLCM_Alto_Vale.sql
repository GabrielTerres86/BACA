INSERT INTO craplcm
  (dtmvtolt,
   cdagenci,
   cdbccxlt,
   nrdolote,
   nrdconta,
   nrdocmto,
   vllanmto,
   cdhistor,
   nrseqdig,
   nrdctabb,
   nrautdoc,
   cdcooper,
   cdpesqbb)
VALUES
  (TO_DATE('21/06/2019'),
   0,
   100,
   3,
   520632,
   (SELECT NVL(MAX(l.nrdocmto), 0) + 1 nrdocmto
      FROM craplcm l
     WHERE l.cdcooper = 16
       AND l.dtmvtolt = '21/06/2019'
       AND l.cdagenci = 0
       AND l.cdbccxlt = 100
       AND l.nrdolote = 3
       AND l.nrdctabb = 520632),
   4.09,
   325,
   (SELECT NVL(MAX(l.nrseqdig), 0) + 1 nrseqdig
      FROM craplcm l
     WHERE l.cdcooper = 16
       AND l.dtmvtolt = '21/06/2019'
       AND l.cdagenci = 0
       AND l.cdbccxlt = 100
       AND l.nrdolote = 3),
   520632,
   0,
   16,
   'Bordero 71036 - 000.000.973,42');
   
   
INSERT INTO craplcm
  (dtmvtolt,
   cdagenci,
   cdbccxlt,
   nrdolote,
   nrdconta,
   nrdocmto,
   vllanmto,
   cdhistor,
   nrseqdig,
   nrdctabb,
   nrautdoc,
   cdcooper,
   cdpesqbb)
VALUES
  (TO_DATE('21/06/2019'),
   0,
   100,
   4,
   520632,
   (SELECT NVL(MAX(l.nrdocmto), 0) + 1 nrdocmto
      FROM craplcm l
     WHERE l.cdcooper = 16
       AND l.dtmvtolt = '21/06/2019'
       AND l.cdagenci = 0
       AND l.cdbccxlt = 100
       AND l.nrdolote = 4
       AND l.nrdctabb = 520632),
   973.42,
   360,
   (SELECT NVL(MAX(l.nrseqdig), 0) + 1 nrseqdig
      FROM craplcm l
     WHERE l.cdcooper = 16
       AND l.dtmvtolt = '21/06/2019'
       AND l.cdagenci = 0
       AND l.cdbccxlt = 100
       AND l.nrdolote = 4),
   520632,
   0,
   16,
   'Desconto do Borderô 71036');
   
COMMIT;


/*
ROLLBACK

DELETE FROM CRAPLCM WHERE cdcooper = 16 AND nrdconta = 520632 AND cdhistor = 325 AND vllanmto = 4.09 AND dtmvtolt = TO_DATE('21/06/2019');
DELETE FROM CRAPLCM WHERE cdcooper = 16 AND nrdconta = 520632 AND cdhistor = 360 AND vllanmto = 973.42 AND dtmvtolt = TO_DATE('21/06/2019');

*/   