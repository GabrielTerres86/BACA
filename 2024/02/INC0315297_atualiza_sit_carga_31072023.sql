UPDATE gestaoderisco.tbrisco_central_carga x
   SET x.CDSTATUS = 2
 WHERE x.CDCOOPER = 14
   AND x.DTREFERE = to_date('16/02/2024','DD/MM/RRRR')
   AND x.TPPRODUTO in (2,90,96) ;

COMMIT;
