-- Exclusão de lançamentos futuros - INC0034984 - Wagner - Sustentação.
UPDATE craplau a
   SET a.insitlau = 4
     , a.dtdebito = TO_DATE('15/03/2019', 'DD/MM/RRRR')
     , a.dscritic = 'Exclusão de lançamentos futuros - INC0034984'
 where a.progress_recid in (26331924, 26331988, 
                            26332015, 26332065, 
							26332111, 26331848, 
							26331942, 26332004, 
							26374294, 26374389);
   
COMMIT;

