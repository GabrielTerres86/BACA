-- Exclusão de lançamentos futuros - INC0034509 - Wagner - Sustentação.
UPDATE craplau a
   SET a.insitlau = 4
     , a.dtdebito = TO_DATE('12/03/2019', 'DD/MM/RRRR')
     , a.dscritic = 'Exclusão de lançamentos futuros - INC0034509'
 where a.progress_recid in (26096503,26096592,26096667,26331967,26332001);
   
COMMIT;
