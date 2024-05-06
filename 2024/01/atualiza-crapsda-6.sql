BEGIN

  DELETE crapsda a
   WHERE cdcooper = 6
     AND a.dtmvtolt = to_date('18/01/2024', 'dd/mm/yyyy');

  UPDATE crapsld b
     SET b.dtrefere = to_date('18/01/2024', 'dd/mm/yyyy')
   WHERE cdcooper = 6;

  COMMIT;

END;
