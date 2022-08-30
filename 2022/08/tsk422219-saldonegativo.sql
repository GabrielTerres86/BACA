BEGIN
     UPDATE cecred.crapepr epr
        SET epr.vlsdeved = (SELECT nvl(sum(vlsdvpar),0)
                            FROM   cecred.crappep pep 
                            WHERE  pep.cdcooper = epr.cdcooper 
                            AND    pep.nrdconta = epr.nrdconta 
                            AND    pep.nrctremp = epr.nrctremp
                            and    pep.inliquid = 0)
      WHERE (cdcooper , nrdconta, nrctremp ) in ((1, 9633138, 2792685)) ;      
   
   COMMIT;
   
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
