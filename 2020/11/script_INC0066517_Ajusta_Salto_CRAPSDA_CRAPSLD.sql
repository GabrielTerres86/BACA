/*
1 9895370 2032238 f0012270  4599.70
1 6705464 2032479 f0010725  1932.21
1 2278812 2032485 f0013330  1921.04
*/


-- 9895370
UPDATE crapsda sda
   SET sda.vlsddisp = sda.vlsddisp + 4599.70
 WHERE sda.cdcooper = 1
   AND sda.nrdconta = 9895370
   AND sda.dtmvtolt = '03/11/2020';

UPDATE crapsld sld
   SET sld.vlsddisp = sld.vlsddisp + 4599.70
 WHERE sld.cdcooper = 1
   AND sld.nrdconta = 9895370;

-- 6705464
UPDATE crapsda sda
   SET sda.vlsddisp = sda.vlsddisp + 1932.21
 WHERE sda.cdcooper = 1
   AND sda.nrdconta = 6705464
   AND sda.dtmvtolt = '03/11/2020';

UPDATE crapsld sld
   SET sld.vlsddisp = sld.vlsddisp + 1932.21
 WHERE sld.cdcooper = 1
   AND sld.nrdconta = 6705464;

-- 2278812
UPDATE crapsda sda
   SET sda.vlsddisp = sda.vlsddisp + 1921.04
 WHERE sda.cdcooper = 1
   AND sda.nrdconta = 2278812
   AND sda.dtmvtolt = '03/11/2020';

UPDATE crapsld sld
   SET sld.vlsddisp = sld.vlsddisp + 1921.04
 WHERE sld.cdcooper = 1
   AND sld.nrdconta = 2278812;
   
   
COMMIT;   