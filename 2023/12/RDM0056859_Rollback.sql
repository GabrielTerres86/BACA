BEGIN

  DELETE FROM cecred.crapstf
   WHERE cdcooper = 1
     AND nrterfin = 280
     AND dtmvtolt = to_date('14/09/2022', 'dd/mm/yyyy');

  DELETE FROM cecred.crapstf
   WHERE cdcooper = 1
     AND nrterfin = 328
     AND dtmvtolt = to_date('28/10/2022', 'dd/mm/yyyy');

  COMMIT;

END;
