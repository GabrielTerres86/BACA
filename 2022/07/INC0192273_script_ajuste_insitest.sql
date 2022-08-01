BEGIN

  UPDATE cecred.crawlim lim
     SET lim.insitest = 4
   WHERE lim.cdcooper = 6
     AND lim.nrdconta = 204781
     AND lim.nrctrmnt = 256
     AND lim.tpctrlim = 2;
  
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
