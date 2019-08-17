-- Exclusão de lançamentos futuros - SCTASK0049558 - Wagner - Sustentação.
UPDATE craplau a
   SET a.insitlau = 4
     , a.dtdebito = TO_DATE('01/03/2019', 'DD/MM/RRRR')
     , a.dscritic = 'Exclusão de lançamentos futuros - SCTASK0049558'
 WHERE a.cdcooper = 1
   AND a.nrdconta = 8247153 
   AND a.insitlau = 1;
   
COMMIT;
   