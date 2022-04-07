BEGIN
  UPDATE tbseg_nrproposta p
     SET p.tpcustei = 0
   WHERE p.dhseguro IS NULL
     AND p.tpcustei = 1;

  UPDATE tbseg_nrproposta p
     SET p.tpcustei = 0
   WHERE p.dhseguro = to_date('06/02/2025', 'DD/MM/RRRR')
     AND p.tpcustei = 1;
  COMMIT;
END;
/
