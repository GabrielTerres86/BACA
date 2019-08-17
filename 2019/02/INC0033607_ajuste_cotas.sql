BEGIN
  DELETE craplct lct
   WHERE lct.cdcooper = lct.cdcooper
     AND lct.dtmvtolt >= '10/02/2019'
     AND lct.nrdolote = 10002
     AND NOT EXISTS (SELECT 1
                       FROM craplcm lcm
                      WHERE lcm.cdcooper = lct.cdcooper
                        AND lcm.nrdconta = lct.nrdconta
                        AND lcm.dtmvtolt = lct.dtmvtolt
                        AND lcm.nrdolote = 10129
                        AND lcm.cdpesqbb = to_char(lct.nrseqdig));

  COMMIT;
END;
