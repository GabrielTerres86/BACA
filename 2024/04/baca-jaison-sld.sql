BEGIN

  DELETE FROM crapsld s
   WHERE s.cdcooper = 13
         AND s.dtrefere = to_date('20/03/2024', 'dd/mm/yyyy');

  UPDATE crapsld s
     SET s.dtrefere = to_date('08/04/2024', 'dd/mm/yyyy')
   WHERE s.cdcooper = 13
         AND s.dtrefere = to_date('14/03/2024', 'dd/mm/yyyy');

  COMMIT;

END;
