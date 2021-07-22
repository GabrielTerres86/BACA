BEGIN

  UPDATE craplot
     SET nrseqdig = 1
   WHERE cdcooper = 1
     AND dtmvtolt = to_date('07/06/2021', 'dd/mm/rrrr')
     AND nrdolote = 320414;

  COMMIT;
END;
