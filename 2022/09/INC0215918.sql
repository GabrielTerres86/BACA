BEGIN
  DELETE craptit t
   WHERE t.cdcooper = 7
     AND t.nrdconta = 14776154
     AND t.vltitulo IN (60000, 30000)
     AND t.dtmvtolt >= to_date('01/09/2022', 'DD/MM/YYYY')
     AND t.progress_recid IN (164424626, 164437450);

  COMMIT;
END;