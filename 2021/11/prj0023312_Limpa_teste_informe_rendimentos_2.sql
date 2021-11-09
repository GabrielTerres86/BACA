BEGIN
  delete crapsda where cdcooper = 14 and dtmvtolt >= to_date('01/11/2021','dd/mm/yyyy');

  COMMIT;
END;
