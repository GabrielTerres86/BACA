begin

UPDATE craplmt
   SET hrtransa = 46942
 WHERE cdcooper = 13
   AND nrdconta = 99555620
   AND dttransa = to_date('31/07/2023','dd/mm/yyyy')
   AND nrctrlif = '1230731011277647938I';

COMMIT;

end;