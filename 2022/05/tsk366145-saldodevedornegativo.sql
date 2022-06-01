BEGIN
     UPDATE cecred.crapepr epr
        SET epr.vlsdeved = (SELECT nvl(sum(vlsdvpar),0)
                            FROM   cecred.crappep pep 
                            WHERE  pep.cdcooper = epr.cdcooper 
                            AND    pep.nrdconta = epr.nrdconta 
                            AND    pep.nrctremp = epr.nrctremp
                            and    pep.inliquid = 0)
      WHERE (cdcooper , nrdconta, nrctremp ) in ((16, 647101, 306986),(1, 7928890, 2295730)) ;      
   
   COMMIT;
   
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
