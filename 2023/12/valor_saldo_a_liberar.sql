BEGIN

  UPDATE crapsda sda
     SET sda.vlsdbloq = 500000
   WHERE sda.cdcooper = 9
     AND sda.dtmvtolt = to_date('11/07/2024', 'dd/mm/yyyy')
     AND sda.nrdconta IN (81613970, 99999595);

  COMMIT;

END;
