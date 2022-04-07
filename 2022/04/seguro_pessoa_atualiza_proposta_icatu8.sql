BEGIN
  UPDATE tbseg_nrproposta p
     SET p.tpcustei = 1, dhseguro = NULL
   WHERE p.dhseguro = to_date('06/02/2025', 'DD/MM/RRRR')
     AND p.tpcustei = 0;
  COMMIT;
END;
/
