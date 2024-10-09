BEGIN
  UPDATE cecred.tbcrd_carga_score x
     SET x.qtregis_fisica = 1480220
        ,x.qtregis_juridi = 196870
   WHERE x.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
     AND x.cdmodelo = 3;
  COMMIT;
END;
