BEGIN

update crapstf set vldsdini =   0, vldsdfin =   0 where cdcooper = 11 and nrterfin = 43 and dtmvtolt = to_date('26/08/2021','dd/mm/yyyy');
update crapstf set vldsdini =   0, vldsdfin = 770 where cdcooper = 11 and nrterfin = 43 and dtmvtolt = to_date('27/08/2021','dd/mm/yyyy');
update crapstf set vldsdini = 770, vldsdfin = 770 where cdcooper = 11 and nrterfin = 43 and dtmvtolt = to_date('30/08/2021','dd/mm/yyyy');
update crapstf set vldsdini = 770, vldsdfin = 770 where cdcooper = 11 and nrterfin = 43 and dtmvtolt = to_date('31/08/2021','dd/mm/yyyy');

  COMMIT;

END;