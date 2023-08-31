BEGIN
  UPDATE cecred.crawepr 
    SET insitest = 6
       ,dtanulac = to_date('28/08/2023','dd/mm/yyyy')
  WHERE cdcooper = 1
    AND nrdconta = 11699337
    AND nrctremp = 7292587;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;