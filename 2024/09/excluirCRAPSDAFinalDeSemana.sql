BEGIN
  DELETE crapsda t WHERE t.cdcooper = 7 AND t.dtmvtolt BETWEEN to_date('28/09/2024','dd/mm/yyyy') AND to_date('29/09/2024','dd/mm/yyyy');
  COMMIT;
END;
