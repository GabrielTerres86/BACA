UPDATE craplau lau
   SET lau.insitlau = 4
     , lau.dtdebito = TO_DATE('30/01/2019', 'DD/MM/RRRR')
     , lau.dscritic = 'NOK - INC0031920'
WHERE cdcooper = 1 
  AND insitlau = 1
  AND dtdebito IS NULL
  AND dtmvtopg = '29/01/2019' 
  AND dsorigem = 'DEBAUT';
  
COMMIT;

