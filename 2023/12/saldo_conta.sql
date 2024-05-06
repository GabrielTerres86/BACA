BEGIN
  UPDATE crapsda
     SET vlsddisp = 100000
   WHERE cdcooper = 9
     AND nrdconta = 99581221
     AND dtmvtolt >= to_date('20/12/2023', 'dd/mm/yyyy');
  COMMIT;
END;