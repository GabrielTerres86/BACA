BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = 13
       AND nrdconta = 140538;
    COMMIT;
  END;