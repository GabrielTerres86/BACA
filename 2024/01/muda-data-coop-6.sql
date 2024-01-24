BEGIN

  UPDATE cecred.crapsld b
     SET b.dtrefere = to_date('23/01/2024', 'dd/mm/yyyy')
   WHERE cdcooper = 6;

  COMMIT;

END;
