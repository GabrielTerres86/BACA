PL/SQL Developer Test script 3.0
16
-- Created on 28/01/2020 by T0032420 
BEGIN
  -- Test statements here
  UPDATE
    crawlim
  SET
    crawlim.insitest = 3
   WHERE crawlim.insitest = 0
     AND crawlim.insitlim = 2
     AND EXISTS (SELECT 1 FROM craplim WHERE crawlim.cdcooper = craplim.cdcooper
                                         AND crawlim.nrdconta = craplim.nrdconta
                                         AND crawlim.tpctrlim = craplim.tpctrlim
                                         AND craplim.tpctrlim = 3
                                         AND craplim.insitlim = 2);
  COMMIT;
END;
0
0
