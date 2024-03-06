begin

UPDATE gestaoderisco.tbrisco_central_carga x
   SET x.CDSTATUS = 2
 WHERE x.DTREFERE = to_date('05/03/2024','DD/MM/RRRR')
   AND x.CDSTATUS = 6;


UPDATE gestaoderisco.tbrisco_central_carga x
   SET x.CDSTATUS = 2
 WHERE x.DTREFERE = to_date('05/03/2024','DD/MM/RRRR')
   AND t.TPPRODUTO IN (95,96)
   AND t.CDCOOPER IN (  1, 
                        6, 
                        8, 
                       10, 
                       11, 
                       12, 
                       13, 
                       14  

);

COMMIT;

end;