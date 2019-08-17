 BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = 1
       AND nrdconta = 7601042;
    COMMIT;
  END;