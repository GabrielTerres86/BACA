BEGIN

  DELETE FROM cecred.crapstf WHERE cdcooper =  2 AND nrterfin =    6 AND dtmvtolt = to_date('08-11-2013', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper = 11 AND nrterfin =    3 AND dtmvtolt = to_date('04-10-2011', 'dd-mm-yyyy');

  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =   31 AND dtmvtolt = to_date('10-12-2010', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  113 AND dtmvtolt = to_date('09-09-2011', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  136 AND dtmvtolt = to_date('26-12-2011', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  133 AND dtmvtolt = to_date('03-01-2013', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =   63 AND dtmvtolt = to_date('23-05-2013', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =   34 AND dtmvtolt = to_date('07-03-2014', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  164 AND dtmvtolt = to_date('10-06-2014', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =   32 AND dtmvtolt = to_date('10-06-2014', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  272 AND dtmvtolt = to_date('06-01-2015', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  273 AND dtmvtolt = to_date('06-01-2015', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =    7 AND dtmvtolt = to_date('10-08-2015', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  295 AND dtmvtolt = to_date('04-11-2015', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  316 AND dtmvtolt = to_date('30-03-2016', 'dd-mm-yyyy');
  
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  170 AND dtmvtolt = to_date('05-06-2023', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  124 AND dtmvtolt = to_date('05-06-2023', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =   88 AND dtmvtolt = to_date('05-06-2023', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =   94 AND dtmvtolt = to_date('07-06-2023', 'dd-mm-yyyy');

  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  280 AND dtmvtolt = to_date('14-09-2022', 'dd-mm-yyyy');
  DELETE FROM cecred.crapstf WHERE cdcooper =  1 AND nrterfin =  328 AND dtmvtolt = to_date('28-10-2022', 'dd-mm-yyyy');

  COMMIT;

END;