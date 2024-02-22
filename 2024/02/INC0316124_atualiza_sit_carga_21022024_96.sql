begin

UPDATE gestaoderisco.tbrisco_central_carga x
   SET x.CDSTATUS = 2
 WHERE x.DTREFERE = to_date('21/02/2024','DD/MM/RRRR')
   AND x.cdcooper = 9   
   AND x.TPPRODUTO = 96;

COMMIT;

end;
