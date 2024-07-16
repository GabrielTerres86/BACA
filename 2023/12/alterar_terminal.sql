BEGIN

  UPDATE craptfn tfn
     SET tfn.cdsitfin = 8
	    ,tfn.tpterfin = 7
   WHERE tfn.cdcooper = 10
     AND tfn.nrterfin = 15;

  COMMIT;

END;
