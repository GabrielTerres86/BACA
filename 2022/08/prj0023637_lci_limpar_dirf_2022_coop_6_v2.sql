BEGIN
  update cecred.crapdir set dtmvtolt = to_date('30/12/2022','dd/mm/yyyy') where cdcooper = 6 and dtmvtolt = to_date('29/12/2022','dd/mm/yyyy');
  delete cecred.crapvir where cdcooper = 6 and nranocal = 2022;
  delete cecred.crapdrf where cdcooper = 6 and nranocal = 2022;
  COMMIT;
END;
/
