BEGIN
  delete crapdir where cdcooper = 14 and dtmvtolt >= to_date('01/12/2021','dd/mm/yyyy');

  delete crapsda where cdcooper = 14 and dtmvtolt >= to_date('01/12/2021','dd/mm/yyyy');

  COMMIT;
END;
