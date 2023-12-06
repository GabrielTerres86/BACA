BEGIN
  UPDATE gestaoderisco.tbrisco_central_carga x
     SET x.CDSTATUS = 2
   WHERE x.CDCOOPER = 1
     AND x.DTREFERE = to_date('30/11/2023','DD/MM/RRRR')
     AND x.CDSTATUS = 6;

  COMMIT;
END;