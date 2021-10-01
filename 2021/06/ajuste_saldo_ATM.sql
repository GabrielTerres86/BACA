begin


UPDATE crapstf
   SET vldsdfin = 1000
 WHERE cdcooper = 1
   AND nrterfin = 288
   AND dtmvtolt = to_date('24/09/2021', 'dd/mm/yyyy');


COMMIT;

END;