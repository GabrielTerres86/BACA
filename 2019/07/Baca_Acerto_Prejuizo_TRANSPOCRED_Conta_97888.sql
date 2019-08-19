BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = 9
       AND nrdconta = 97888;
    COMMIT;
  END;