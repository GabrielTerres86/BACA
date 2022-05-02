BEGIN
  UPDATE cecred.tbseg_nrproposta p
     SET p.tpcustei = 0
   WHERE p.dhseguro IS NULL
     AND p.tpcustei = 1
     AND ROWNUM BETWEEN 1 AND 2000;
  COMMIT;
END;
/
