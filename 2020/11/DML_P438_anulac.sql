
UPDATE tbcadast_motivo_anulacao x
   SET x.incanaldigital = 1
 WHERE x.tpproduto = 1
   AND x.idativo = 1
   AND x.cdmotivo IN (1, 5, 6, 7, 8);

COMMIT;   
