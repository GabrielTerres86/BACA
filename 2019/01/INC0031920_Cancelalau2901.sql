UPDATE craplau
   SET craplau.insitlau = 4
     , craplau.dtdebito = TO_DATE('30/01/2019', 'DD/MM/RRRR')
     , craplau.dscritic = 'NOK - INC0031920'
 WHERE craplau.cdcooper = 1
   AND craplau.cdtiptra <> 4
   AND ((    craplau.cdcooper = 1
        AND   craplau.dtmvtopg = TO_DATE('29/01/2019','DD/MM/RRRR')
        AND   craplau.insitlau = 1
        AND   craplau.dsorigem IN ('INTERNET','TAA')
        AND    craplau.tpdvalor = 0)
        OR
       (    craplau.cdcooper  = 1
        AND craplau.dtmvtopg  = TO_DATE('29/01/2019','DD/MM/RRRR')
        AND craplau.insitlau  = 1
        AND craplau.dsorigem  = 'DEBAUT'));
  
COMMIT;

