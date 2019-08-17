BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = 13
       AND nrdconta = 170488;
    COMMIT;
  END;