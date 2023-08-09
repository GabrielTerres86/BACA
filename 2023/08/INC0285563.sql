BEGIN
  UPDATE gestaoderisco.tbrisco_central_carga x
     SET x.CDSTATUS = 2
   WHERE x.CDCOOPER = 1
     AND x.DTREFERE = to_date('08/08/2023', 'DD/MM/RRRR')
     AND x.CDSTATUS = 6;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
