begin

UPDATE gestaoderisco.tbrisco_central_carga x
   SET x.CDSTATUS = 2
 WHERE x.DTREFERE = to_date('05/03/2024','DD/MM/RRRR')
   AND x.CDSTATUS = 6
   AND x.CDCOOPER = 1;

COMMIT;

END;