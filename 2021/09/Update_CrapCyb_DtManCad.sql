BEGIN
  UPDATE crapcyb x
     SET x.dtmancad = to_date('11/08/2021', 'DD/MM/RRRR')
   WHERE x.cdcooper = 8
     AND x.dtdbaixa IS NULL;

  COMMIT;
END;
