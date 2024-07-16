BEGIN

  UPDATE crapsda sda
     SET sda.vlsdbloq = 500000
   WHERE sda.cdcooper = 10
     AND sda.dtmvtolt >= to_date('14/07/2024', 'dd/mm/yyyy')
     AND sda.nrdconta = 81417799;

  COMMIT;

END;
