DELETE
 FROM craplat l
      WHERE cdcooper = 13
        AND l.insitlat = 1
        AND l.cdhistor IN (1441,1465)
        AND nrdconta = 187631
        AND dtmvtolt = '13/02/2019'
;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 37605;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 76228;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 158607;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 160377;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 170577;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 187631;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 211648;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 309800;
UPDATE crapsld l SET l.vlsmnmes = 0 ,l.vlsmnesp = 0 ,l.vlsmnblq = 0 ,l.vliofmes = 0 WHERE cdcooper = 13 AND nrdconta = 406600;

COMMIT;